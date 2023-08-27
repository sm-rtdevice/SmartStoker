#ifndef TEMPERATURE_H
#define TEMPERATURE_H 

/*
int GetTemper(unsigned char *addr) // прочитать температуру из датчиков (только целая часть)
{
int Temp = -90;

if(addr[0] == DS18B20_FAMILY_CODE)
{
Temp = ds18b20_temperature(addr);   // float
}
else // ds1820/ds18s20
{
Temp = ds1820_temperature_10(addr)/10;
};

if(Temp == -9999 || Temp == -999){return -90;}
return Temp;
}
*/

int GetTemper(unsigned char addr) // прочитать температуру из датчиков
{
	int Temp = -90;
	float fTemp;

	if (ds1820_sn[addr][0] == DS18B20_FAMILY_CODE) // ds18B20 минусовая температура
	{

		fTemp = ds18b20_temperature(&ds1820_sn[addr][0]);   // float
		if (fTemp<0) { Sign[addr] = 1; }
		else { Sign[addr] = 0; }

		Temp = abs(fTemp);                  // целая часть
										    // Temp = abs(Temp); без занака
		TempDec[addr] = fTemp * 10;         // дробная часть, *10 - 1 знак, *100 - 2 знака    
		TempDec[addr] = abs(TempDec[addr]);
		TempDec[addr] %= 10;

		// FloatTemp = (FloatTemp - Temp)*100;
		// TempDec[addr] = (unsigned char)((Temp & 0x000F)*10/16); // дробная часть
	}
	else // ds1820/ds18s20
	{
		Temp = ds1820_temperature_10(&ds1820_sn[addr][0]); // целая часть + дробная  -565  int 1 знак после запятой

		if (Temp<0) { Sign[addr] = 1; }
		else { Sign[addr] = 0; }

		Temp = abs(Temp);
		TempDec[addr] = Temp % 10;                         // дробная часть 0.5
														   // TempDec[addr] = abs(((unsigned char)Temp & 0x000F)*10)/2; // дробная часть
		Temp = Temp / 10;                                  // целая часть   -56   (теряется знак -0.1 .. -0.9  !!!!)

														   // Temp = ds1820_temperature_10(&ds1820_sn[addr][0])/10;               // целая часть
														   // TempDec[addr] = Temp/100; //(((unsigned char)Temp & 0x000F)*10/16); // дробная часть
	};

	// if(Temp == -9999 || Temp == -999){return -90;}
	if (Temp == 9999 || Temp == 999) { return -90; }
	return Temp;
}

#ifdef SAVETEMPER 
void SaveTemper(int temp, int ds) // сохранение температуры в памяти контроллера   
{
	LogTemp[ds][ind[ds]] = (char)temp;
	ind[ds] = (ind[ds] + 1) % TEMPER_POINT_COUNT;
}

void SendTemper(int ds)  // получение температуры (отправка данных на ПК)
{

	int ii;
	for (ii = ind[ds]; ii < TEMPER_POINT_COUNT; ii++)
	{
		putchar(LogTemp[ds][ii]); // отправить на ПК
	}
	for (ii = 0; ii<ind; ii++)
	{
		putchar(LogTemp[ds][ii]); // отправить на ПК
	}

}
#endif // \SAVETEMPER

#endif // \TEMPERATURE_H
