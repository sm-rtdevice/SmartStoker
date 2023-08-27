/*****************************************************
Project : SMART-кочегар (Stoker)
Version : v.: 2.4a
Date    : 26.04.2018
Author  : SIS
Company : Sm@rt-Device
Comments: автоматизированный контроль и управление насосом системы отопления

Chip type           : ATMega32 A - PU
Clock frequency     : 8,000000 MHz, время выполнения команды: 1/8000000 = 0,000000125 сек = 0.125 мкс
Memory model        : Small Flash - 32KB (16K x 16), ROM - , RAM - , EEPROM - 2024 b
External SRAM size  : 0
Data Stack size     : 512

Дивайсы: DS1820/DS18S20/DS18B20 на шине 1-Wire, CPU AVR ATmega32, программатор USB/ISP (in system programmen), USART: адаптер USB -> TTL/blueTooth, LCD-display

алгоритм работы:
по умолчанию автоматическое управление от датчиков переход на импульсный режим в случае отказа датчика на радиаторе или вручную (по-выбору импульсного режима),
принудительное ручное управление насосом

выводы МК:
PORTD.5: 1 - включение насоса; 0 - отключение насоса
PORTA.5: 1 - неисправность датчика; 0 - датчик в норме (не используется)
PORTA.6: 0/1 индикатор работы импульсного режима
PORTA.7: 0/1 индикатор работы от датчиков
PORTA.6,7 = [0,0] - ручное управление, [1,0] - импульсный режим, [0,1] - работа от датчиков, [1,1] - ошибка инициализации датчиков

UART (9600bod/1start/1stop/no_parity) = 9600*0.8 = 7680бит/с = 960байт/с; 1байт = 1,041мс	~2*к-во байт + ожидание расчета температуры ~600-800мс
*****************************************************/

#include "stdafx.h"

#asm
   .equ __w1_port=0x12 ;PORTD // настраиваем порт D bit6 на шину 1-wire 20 ножка ATMega32
   .equ __w1_bit=6                         
#endasm

/*
// Timer 0 прерывание по таймеру
interrupt [TIM0_COMPA] void timer0_timer(void) // TIM0_COMP[A|B]  TIM0_OVF
{
	 //tLimit = 0;            // сбросить флаг таймаута (время вышло)
	 //PORTB.7 = !PORTB.7;    // инвертирование сигнала  DP тест
}
*/
// ----------------------------------------------------------------------------

// Timer 1 прерывание по таймеру (основной цикл обработки данных)
interrupt [TIM1_COMPA] void timer1_timer(void) // TIM1_COMP[A|B]  TIM0_OVF
{
	if(Errcount == 0 && AutoRestoration == 1){StokerMode = 0;}; // при восстановлении связи с датчиком, возобновить автоматическое управление от датчиков

	if( StokerMode == 0 || MeasureTemp == 1 || AutoRestoration == 1)  // опрос датчиков: если (включено управление от датчиков ) или (включено принудительное измерение температуры) или разрешено восстановление
	{
		for(k1 = 0; k1 < ds1820_devices; k1++) // опрос датчиков;
		// k1 = ++k1 % ds1820_devices;         // опрос по 1 датчику за прерывание, чтобы уменьшить время ожидания отклика команды
		{
			//Temperature[k1] = GetTemper(&ds1820_sn[k1][0]); // только целая часть
			Temperature[k1] = GetTemper(k1);

			/*
			#ifdef SAVETEMPER
			//if(таймаут сохранения){} // todo: реализовать
			//if(k1 == 0){SaveTemper(Temperature[k1]);}; // сохранить в энергонезависимую память, значение температуры возможно с ошибками!
			SaveTemper(Temperature[k1],k);
			#endif
			*/

			if(Temperature[k1] == -90) // ошибка получения данных от датчика ds1820.h
			{
				//PORTA.5 = 1;          // отказ датчика

				if(k1 == 0 && (StokerMode == 0) )  // датчик на радиаторе и режим управления от датчиков
				{
					Errcount++; // счетчик ошибок++ датчик на радиаторе
					if(Errcount >= 5){StokerMode = 1; TickCount = 0; /*PORTD.5 = 0;*/}; // (>60) --> переход в импульсный режим, включить аварийный светодиод PORTA.5 = 1, сброс настроек импульсного режима, начать с простоя (PORTD.5 = 0)??
					//continue; // продолжить for...  управлять... continue - по-любому
				}

				/*
				else if(k1 == 1) {
					//PORTA.5 = 1;          // отказ датчика
				}
				else if(k1 == 2) {
					//PORTA.5 = 1;          // отказ датчика
				}
				*/   

				continue; // продолжить for...  управлять...  
			}
			//else{ PORTA.5 = 0; }       // сброс отказа датчика

			if(k1 == 0) {Errcount = 0;}; // сброс счетчика ошибок датчика на радиаторе
		};

		//k1 = (k1+1)%ds1820_devices; // опрашивать по 1 датчику за цикл. распараллелить задачи (убрать for...)

		#ifdef SAVETEMPER
		if(SaveTimeOut == 37) // 8*37 = 296 c ~ 5 мин. | 8*75 = 600 c == 10 мин
		{
			SaveTemper(Temperature[k1],k1); // сохранить в энергонезависимую память, значение температуры возможно с ошибками!
			SaveTimeOut = 0;
		}
		SaveTimeOut += 8;
		#endif

	} // \опрос датчиков

	switch(StokerMode)	// 0 - авто; 1 - импульс; 2 -  принудительное включение; 3 - принудительное отключение
	{
		case 0x00:	// авто (управление от датчиков)
		{
			PORTA.6 = 0;              // отключить индикатор
			PORTA.7 = 1;              // индикатор режима работы от датчиков, мигание: PORTA.7 = !PORTA.7;
			// Temperature[0] - радиатор, Temperature[1] - котел, Temperature[2] - улица, T2k - 1 контур

			MaxT1 = MaxT;                                        // расчетный верхний предел отключения насоса (если в котле меньше температуры чем верхняя уставка)
			OnBlock = 1;                                         // блокировка включения 1 - включение разрешено (по умолчанию), 0 - включение заблокировано

			if(Temperature[1] != -90)                            // датчик на котле работает
			{                                              
				//if(Temperature[1] <= MinT){OnBlock = 0;}                      // заблокировать включение!
				if(Temperature[1] < MinTCaldron){OnBlock = 0; PORTD.5 = 0;}     // отключить и заблокировать включение! если температура в котле < "30" (нет смысла гонять насос)
				// if(Temperature[0] >= Temperature[1]){OnBlock = 0;}           // PORTD.5 = 0; заблокировать включение! если температура в радиаторе >= температура в котле ??? - может быть есть смысл перекачать кипяток вниз
				// if(Temperature[1] < MaxT){MaxT1 = Temperature[1];}           // передвинуть максимальный предел, если температура в котле < макс. предела отключения
				if(Temperature[0] >= Temperature[1]){PORTD.5 = 0; OnBlock = 0;} // температура воды в радиаторе достигла температуры в котле  !!!!!!!!!!!!!
			}

			/*
			if(T2k != -90)                             // датчик на 1 контуре работает  (не используется)
			{ 
				if(T2k < Temperature[0]){OnBlock = 0;} // температура в 1 контуре < температуры в 2 контуре -> заблокировать включение
			}
			*/

			if(Temperature[0] != -90) // если датчик на радиаторе работает то управлять, иначе оставить все без изменений
			{ 
				if(PORTD.5 == 1) {                                 // насос работает
					if(Temperature[0] >= MaxT1) {PORTD.5 = 0;}     // выключить достигнут максимальный предел MaxT1
				} else {                                           // насос отключен
					if(Temperature[0] < MinT) {PORTD.5 = OnBlock;} //  достигнут минимальный предел -> попытаться включить
				}
			}
		}
		break;	// \режим работы от датчиков

		case 0x01:	// импульсный режим (управление по времени)
		{
			PORTA.7 = 0;         // отключить индикатор
			PORTA.6 = 1;         // включить индикатор работы импульсного режима, мигание: PORTA.6 = !PORTA.6;

			TickCount += 8;      // todo: настроить тик таймера, рассчитать время итерации

			if(PORTD.5 == 1) {   // насос работает
				if(TickCount > WorkTime*60) {TickCount = 0; PORTD.5 = 0;} // выключить достигнуто максимальное время работы
			}
			else {               // насос отключен
				if(TickCount > IdleTime*60) {TickCount = 0; PORTD.5 = 1;} // включить достигнуто максимальное время простоя 
			}
		}
		break;	// \импульсный режим

		case 0x02:	// принудительное включение насоса
		{
			PORTD.5 = 1;
			PORTA.6 = 1; PORTA.7 = 1;  // включить индикаторы
		}
		break;

		case 0x03:	// принудительное отключение насоса
		{
			PORTD.5 = 0;
			PORTA.6 = 0; PORTA.7 = 0;  // отключить индикаторы
		}
		break;
	}

	#ifdef LCD
	LCD_Show();
	#endif
}
// ----------------------------------------------------------------------------

void main(void)
{              
	InitController();

 /*
  ds18b20_init(     // - unsigned char - Радиатор
               &ds1820_sn[0][0], // unsigned char *addr
               -20,              // signed char temp_low
               50,               //signed char temp_high
               DS18B20_12BIT_RES); //DS18B20_12BIT_RES, DS18B20_11BIT_RES, DS18B20_10BIT_RES, DS18B20_9BIT_RES - resolution

  ds18b20_init(     // - unsigned char - Котел
               &ds1820_sn[1][0], // unsigned char *addr
               -20,              // signed char temp_low
               50,               //signed char temp_high
               DS18B20_12BIT_RES); //DS18B20_12BIT_RES, DS18B20_11BIT_RES, DS18B20_10BIT_RES, DS18B20_9BIT_RES - resolution
 */

#ifdef TEST  // тестовый режим поиск и опрос любых датчиков
	ds1820_devices = w1_search(0xf0,ds1820_sn);           // поиск подключенных датчиков и их нумерация  // определение глючного датчика

	// оперделение адреса Test
	lcd_init(16);
	lcd_clear();
	lcd_gotoxy(0, 0);
	sprintf(lcd_buffer,"%x %x %x %x %x %x %x %x %x",ds1820_sn[2][0], ds1820_sn[2][1], ds1820_sn[2][2], ds1820_sn[2][3], ds1820_sn[2][4], ds1820_sn[2][5], ds1820_sn[2][6], ds1820_sn[2][7], ds1820_sn[2][8]);
	lcd_puts(lcd_buffer);

	delay_ms(3000);
	// оперделение адреса Test

	if(ds1820_devices > 0) // если устройства найдены то прочитать мусор
	{
		for (i=0; i<ds1820_devices; i++)                            
		{
			//Temperature[i] = GetTemper(&ds1820_sn[i][0]); // прочитать мусор
			Temperature[0] = GetTemper(i);
		}
	}
#else // штатный режим
	//ds1820_devices = 3;  // подключено 3 датчика

	sncpy(ds1820_sn[0],ds1820_rom_codes[0]);                  // загрузить из еепром во flash
	sncpy(ds1820_sn[1],ds1820_rom_codes[1]);                  // загрузить из еепром во flash  
	sncpy(ds1820_sn[2],ds1820_rom_codes[2]);                  // загрузить из еепром во flash  

	//Temperature[0] = GetTemper(&ds1820_sn[0][0]);           // радиатор (прочитать мусор)
	//Temperature[1] = GetTemper(&ds1820_sn[1][0]);           // котел

	Temperature[0] = GetTemper(0);  // радиатор (прочитать мусор)
	Temperature[1] = GetTemper(1);  // котел
  //Temperature[2] = GetTemper(2);  // внешний
#endif

	PORTD.5 = 0;    // 9 нога на исполнительное устройство (насос - по умолчанию выключен), 1 - вкл; 0 - откл
	StokerMode = 0; // По умолчанию при включении всегда режим управления от датчиков

	// индикация режима управления:
	switch(StokerMode)
	{
	case 0:                       // авто - обновить состояние сигнальных светодиодов
		if ( (Temperature[0] == -90 || Temperature[1] == -90) || (ds1820_devices < 2) ) { // ds1820_devices < 2 // ошибка датчиков
			PORTA.7 = 1;          // включить оба индикатора (до следующего цикла измерения, затем загорается зеленый)
			PORTA.6 = 1;          //
			Errcount = 1;         // ошибка чтения данных
		} else {
			PORTA.7 = 1;          // горит зеленый постоянно все ОК
		}
	break;

	case 1:                       // импульс (горит желтый)
		PORTA.7 = 0;              // отключить индикатор
		PORTA.6 = 1;              // включить индикатор работы импульсного режима, мигание: PORTA.6 = !PORTA.6;
	break;

	case 2:
		PORTD.5 = 1;              // насос принудительно включен
		PORTA.6 = 1; PORTA.7 = 1; // горят оба индикатора
	break;

	case 3:
		PORTD.5 = 0;              // насос принудительно отключен
		PORTA.6 = 0; PORTA.7 = 0; // не горит ни один индикатор
	break;
	}
 
	nStart++;   // счетчик перезапусков контроллера

#ifdef SIMULATOR
	putchar('O'); putchar('K'); putchar(0x0D); // тест USARTа
#endif

#ifdef LCD
	lcd_init(16);
	lcd_puts("Smart Stoker");
	lcd_gotoxy(0, 1);
	lcd_puts("v:2.5 Loading...");
#endif

#ifdef RTC_DS_3231
    RTC_init();

//настройка даты:
//    RTC_write_year23(2018);
//    RTC_write_month23(06);
//    RTC_write_day23(13);
//    RTC_write_wday23(4);
//    RTC_Set(RTC_YEAR, 19);

//настройка времени: 
//    RTC_write_hour23(21);
//    RTC_write_minute23(58); 
//    RTC_write_sec23(30);

    lcd_gotoxy(0, 1);
    lcd_puts("i2c ok");
#endif

	#asm("sei") // разрешить прерывания (чтобы таймер работал)  

while(1)  // обработка входящих команд
 {
  BufCRC[0] = getchar(); // получен 1 байт

  switch(BufCRC[0]) // simv
  {
   case 0x01:                             // запрос температуры (отправка данных на ПК), формат: Rx: [CMD]; Tx: [T1][T2][CRC], v2.0 Tx: [T1][T2][T3][PumpState][CRC]
                                          // или (если int): T1[hiT1][loT1]  T2[hiT2][loT2]
	//if (CmdLost(1,10)) { continue; };   // (needReadBytes, TimeOut) пакет потерян, возвращаемся к ожиданию новой команды
    if(Temperature[0] == -90){tRadiator = -90;}else{tRadiator = Temperature[0];};  // int -> byte(unsigned char)
    if(Temperature[1] == -90){tCaldron = -90;}else{tCaldron = Temperature[1];};    // int -> byte
    //if(Temperature[2] == -90){tOutSide = -90;}else{tOutSide = Temperature[2];};  // int -> byte

    BufCRC[0] = tRadiator;
    BufCRC[1] = tCaldron;
	//BufCRC[2] = tOutSide;  // внешний датчик
	//BufCRC[3] = PORTD.5;   // состояние насоса PORTD.5: 1 - включен; 0 - отключен
	//BufCRC[4] = crc8(BufCRC, 5);
    BufCRC[2] = crc8(BufCRC, 2);
    for(i=0; i<3; i++){putchar(BufCRC[i]);}

   break;

   case 0x02:                       // запрос настроек (отправка данных на ПК), формат: Rx: [CMD]; Tx: [MinT][MaxT][MinTCaldron][WorkTime][IdleTime][PulseMode][PumpMode][nStart][CRC]
    BufCRC[0] = MinT;				// температура включения насоса  45 (радиатор)
    BufCRC[1] = MaxT;				// температура отключения насоса 55 (радиатор)
    BufCRC[2] = MinTCaldron;		// минимальная температура воды в котле при котором возможно включение насоса
    BufCRC[3] = WorkTime;			// время работы 5-10 мин
    BufCRC[4] = IdleTime;			// время простоя 20-30 мин
    BufCRC[5] = StokerMode;			// режим управления
    BufCRC[6] = 0;					// Резерв - AutoRestoration - автовосстановление
    BufCRC[7] = nStart;				// счетчик перезапусков контроллера
    BufCRC[8] = crc8(BufCRC, 8);	// [CRC]
    for(i=0; i<9; i++){putchar(BufCRC[i]);}

   break;

   case 0x03:                       // установка настроек (прием данных от ПК), формат: Rx: [CMD] [MinT][MaxT][MinTCaldron][WorkTime][IdleTime][StokerMode][CRC], подтверждение выполнения - 0xAA
	if (CmdLost(7, 14)) { continue; }; // 8-1											Tx: [0xAA]

    for(i=1; i<7; i++) // 6+crc, BufCRC[0] == 0x03;
    {
     BufCRC[i] = getchar();
    }

    BufCRC[7] = getchar(); // CRC

    if(crc8(BufCRC, 7) == BufCRC[7])    // CRC верна в Stoker'e - crc8(Command->SendPacket,7-1);
    {
     //BufCRC[0] - 0x03 номер команды
     MinT = BufCRC[1];                  // температура включения насоса  45 (радиатор)
     MaxT = BufCRC[2];                  // температура отключения насоса 55 (радиатор)
     MinTCaldron = BufCRC[3];           // минимальная температура воды в котле при котором возможно включение насоса
     WorkTime = BufCRC[4];              // время работы 5-10 мин
     IdleTime = BufCRC[5];              // время простоя 20-30 мин
     StokerMode = BufCRC[6];            // режим работы (от DS или импульсный)

     TickCount = 0;                     // обнуление времени работы
     //AutoRestoration = BufCRC[];      // автовосстановление

     switch(StokerMode)
     {
      case 0:                            // авто - обновить состояние сигнальных светодиодов
       PORTA.7 = 1;                      // включить индикатор, работа от DS1820
       PORTA.6 = 0;                      // отключить индикатор
      break;

      case 1:                            // импульс
       PORTA.7 = 0;                      // отключить индикатор
       PORTA.6 = 1;                      // включить индикатор работы импульсного режима
      break;

      case 2:
       PORTD.5 = 1;                      // принудительное включение насоса
       PORTA.6 = 1; PORTA.7 = 1;         // горят оба индикатора
      break;

      case 3:
       PORTD.5 = 0;                      // принудительное отключение насоса
       PORTA.6 = 0; PORTA.7 = 0;         // не горит ни один индикатор
      break;
     }

     putchar(0xAA);                      // OK команда выполнена
    }

   break;

   case 0x04:                            // запрос серийных номеров датчиков DS1820 "SN ds1 и ds2" (отправка данных на ПК), формат: Tx: [ds1_0][ds2_0][ds1_1][ds2_1][ds1_2]... [CRC]
										 //                                                                                         Rx: [CMD]
    for(i = 0; i < 8; i++)
    {
      BufCRC[i+i] = ds1820_sn[0][i];     // [0] - радиатор
      BufCRC[i+i+1] = ds1820_sn[1][i];   // [1] - котел
    }

    BufCRC[16] = crc8(BufCRC, 16);
    for(i=0; i<17; i++){putchar(BufCRC[i]);}

   break;

   case 0x05:                            // установка серийных номеров датчиков DS1820 "SN ds1 и ds2" (прием данных от ПК), формат: Rx: [CMD] [ds1_0][ds2_0][ds1_1][ds2_1][ds1_2]... [CRC8]
	if (CmdLost(17, 34)) { continue; };  //                                                                                         Tx: [0xAA]

    //BufCRC[0] = 0x05

    for(i = 0; i < 8; i++)           
    {
     BufCRC[i+i+1] = getchar();          // [0] - радиатор,  ds1820_rom_codes[0][i]
     BufCRC[i+i+1+1] = getchar();        // [1] - котел,     ds1820_rom_codes[1][i]
    }

    BufCRC[17] = getchar();              // CRC

    if(crc8(BufCRC, 17) == BufCRC[17])   // 0x05 + 16 s/s = 17, проверка CRC
    {

    for(i = 0; i < 8; i++)
    {
     ds1820_sn[0][i] = BufCRC[i+i+1];    // [0] - радиатор,  ds1820_rom_codes[0][i]
     ds1820_sn[1][i] = BufCRC[i+i+1+1];  // [1] - котел,     ds1820_rom_codes[1][i]
    }

     sncpy(ds1820_sn[0],ds1820_rom_codes[0]); // пересохранить из flash в еепром
     sncpy(ds1820_sn[1],ds1820_rom_codes[1]); // пересохранить из flash в еепром
     putchar(0xAA);                           // OK команда выполнена
    }

   break;

   case 0x06:                     // сброс счетчика перезапусков контроллера (прием данных от ПК), формат: Rx: [0x06], Tx: [0xAA]
    nStart = 0;
    putchar(0xAA);                // OK команда выполнена
   break;

   case 0x07:                     // GetState
                                  // запрос температуры (отправка данных на ПК), формат: Rx: [CMD]; Tx: [T1][T2][T3][PumpState][CRC]
                                  // или (если int): T1[hiT1][loT1]  T2[hiT2][loT2]
    if(Temperature[0] == -90){tRadiator = -90;}else{tRadiator = Temperature[0];};  // int -> byte(unsigned char)
    if(Temperature[1] == -90){tCaldron = -90;}else{tCaldron = Temperature[1];};    // int -> byte
    if(Temperature[2] == -90){tOutSide = -90;}else{tOutSide = Temperature[2];};    // int -> byte

    BufCRC[0] = tRadiator;
    BufCRC[1] = tCaldron;
	BufCRC[2] = tOutSide;  // внешний датчик
	BufCRC[3] = PORTD.5;   // состояние насоса PORTD.5: 1 - включен; 0 - отключен
	BufCRC[4] = crc8(BufCRC, 4);
    for(i=0; i<5; i++){putchar(BufCRC[i]);}

   break;

   //case 0x08:                     // резерв
   //break;

   case 0x09:						// проверка связи
   putchar('=');
   putchar('S');
   putchar('M');
   putchar('A');
   putchar('R');
   putchar('T');
   putchar('=');
   putchar('D');
   putchar('E');
   putchar('V');
   putchar('I');
   putchar('C');
   putchar('E');
   putchar('=');
   // =SMART-DEVICE=                // тест связи                     
   break;

  #ifdef SAVETEMPER
   case 0x0A:
    SendTemper(0); // получение температуры (отправка данных на ПК) без-CRC ds1
   break;
  #endif

   //case 0xFF:   // расширенные команды
   // simv = getchar();
   // switch(simv){case 0x01: /*команда*/ break;}
   //break;
  };

  //putchar(0x0D); // CR конец приема/передачи
 } // \while(1)

}
