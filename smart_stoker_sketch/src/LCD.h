#ifndef _LCD_INCLUDED_
#define _LCD_INCLUDED_

#ifdef LCD
char lcd_buffer[16];

void LCD_Show() // отобразить показания датчиков                         
{
	/*
	itoa(-25, DispStr);
	DispStr = 25 + 'o'
	lcd_putsf(DispStr );
	sprintf(lcd_buffer,"t=%.1f",temp);   //%.1f – единицы t 20.6 'C
	*/

	// [0] - радиатор; [1] - котел текущие значения температуры 
	lcd_clear();

	if (lcd_screen == 0)
	{

		lcd_gotoxy(0, 0);
		if (Temperature[1] != -90) // котел   
		{
			if (Sign[1]) { sprintf(lcd_buffer, "-%i.%u\xdfC", Temperature[1], TempDec[1]); }
			else { sprintf(lcd_buffer, "+%i.%u\xdfC", Temperature[1], TempDec[1]); }

			lcd_puts(lcd_buffer);
		}
		else
		{
			lcd_puts("--.-\xdfC");
		}

		lcd_gotoxy(8, 0);
		if (Temperature[0] != -90) // радиатор
		{
			if (Sign[0]) { sprintf(lcd_buffer, "-%i.%u\xdfC", Temperature[0], TempDec[0]); }
			else { sprintf(lcd_buffer, "+%i.%u\xdfC", Temperature[0], TempDec[0]); }

			lcd_puts(lcd_buffer);
		}
		else
		{
			lcd_puts("--.-\xdfC");
		}

		lcd_gotoxy(0, 1);
		if (Temperature[2] != -90) // улица   (внешний датчик)
		{
			if (Sign[2] == 1) { sprintf(lcd_buffer, "-%i.%u\xdfC", Temperature[2], TempDec[2]); }
			else { sprintf(lcd_buffer, "+%i.%u\xdfC", Temperature[2], TempDec[2]); }

			lcd_puts(lcd_buffer);
		}
		else
		{
			lcd_puts("--.-\xdfC");
		}

		lcd_gotoxy(8, 1);
		//sprintf(lcd_buffer,"%i.%u\x45",0,0); // концентрация газа (не используется, Резерв!)
		//sprintf(lcd_buffer,"%i.%i",read_adc(0),read_adc(0));
		sprintf(lcd_buffer, "%i%%.%i", read_adc(0) * 100 / 1024, read_adc(0));
		lcd_puts(lcd_buffer);
	}
	else if (lcd_screen == 1)
	{    
#ifdef RTC_DS_3231
        
//        RTC_read_time(); // обновить время 
//
//        lcd_gotoxy(0, 0);
//        sprintf(lcd_buffer, "day: %i hour: %i", day, hour23);
//        lcd_puts(lcd_buffer);
//
//        lcd_gotoxy(0, 1);  
//		sprintf(lcd_buffer, "min: %i sec: %i", minute23, sec23);
//        lcd_puts(lcd_buffer);
      
        lcd_gotoxy(0, 0);
        sprintf(lcd_buffer, "%i.%i.%4i", RTC_Get(RTC_DAY), RTC_Get(RTC_MONTH), 2000+RTC_Get(RTC_YEAR)); // DD.MM.HHHH (28.1.2019)
        lcd_puts(lcd_buffer);

        lcd_gotoxy(0, 1);  
        sprintf(lcd_buffer, "%i:%i:%i", RTC_Get(RTC_HOUR), RTC_Get(RTC_MIN), RTC_Get(RTC_SEC)); // hh:mm:ss (22:12:23)
        lcd_puts(lcd_buffer);
              
//        RTC_read_temper();
//        lcd_gotoxy(0, 1);  
//        sprintf(lcd_buffer, "%i,%i", t1,t2); // температура часов 25,5
//        lcd_puts(lcd_buffer);



//test
//lcd_gotoxy(0, 1);  
//sprintf(lcd_buffer, "screen 2 active");
//lcd_puts(lcd_buffer);

#endif  // \RTC_DS_3231
	}

}

#endif // \LCD 

#endif // \_LCD_INCLUDED_
