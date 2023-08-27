#ifndef _CONTRIOLLER_INIT_INCLUDED_
#define _CONTRIOLLER_INIT_INCLUDED_

#include <mega32.h>
#include <1wire.h>
#include "src\ADC.h"

inline void InitController()
{
// инициализация контроллера
// Port A initialization
// PORTA=0x00;  // Func2=In Func1=In Func0=In
// DDRA=0xFF;   // State2=T State1=T State0=T

// Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=In 
// State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=T 
PORTA = 0x00;
DDRA = 0xFE;

// Port B initialization
PORTB = 0x00;  // Func7=Out Func6=Out Func5=Out Func4=Out Func3=Out Func2=Out Func1=Out Func0=Out 
DDRB = 0x00;   // State7=0 State6=0 State5=0 State4=0 State3=0 State2=0 State1=0 State0=0 

               // Port C initialization
PORTC = 0x00;  // Func7=In Func6=In Func5=In Func4=In Func3=In Func2=In Func1=In Func0=In 
DDRC = 0x00;   // State7=T State6=T State5=T State4=T State3=T State2=T State1=T State0=T 

               // Port D initialization
               // PORTD=0x00;  // Func6=In Func5=In Func4=In Func3=Out Func2=Out Func1=Out Func0=Out
               // DDRD=0x3F;
PORTD = 0x03;  // Func6=In Func5=In Func4=In Func3=Out Func2=Out Func1=Out Func0=Out 
DDRD = 0x7C;   // State6=T State5=T State4=T State3=0 State2=0 State1=0 State0=0 P

               //----------- настройка таймера 0
               // Clock source: System Clock
TCCR0 = 0x00;  // Clock value: Timer 0 Stopped
TCNT0 = 0x00;  // Mode: Normal top=0xFF
OCR0 = 0x00;   // OC0 output: Disconnected

               //----------- настройка таймера 1
TCCR1A = 0x00;
TCCR1B = 0x05; // частота как-то выставляется
TCNT1H = 0x0F; // начальное значение счётчика при первом запуске
TCNT1L = 0xFF; // начальное значение счётчика при первом запуске
ICR1H = 0x00;
ICR1L = 0x00;
OCR1AH = 0x82; // 10  82 // значение срабатывания счётчика(делитель частоты) FF
OCR1AL = 0x30; // 46  30 // значение срабатывания счётчика(делитель частоты) FF

               //----------- настройка таймера 2
ASSR = 0x00;   // Clock source: System Clock
TCCR2 = 0x00;  // Clock value: Timer2 Stopped
TCNT2 = 0x00;  // Mode: Normal top=0xFF
OCR2 = 0x00;   // OC2 output: Disconnected

               // нинциализация внешних прерываний
               // INT0: Off
               // INT1: Off
               // INT2: Off
               // GIMSK=0x00;  
MCUCR = 0x00;
MCUCSR = 0x00;

TIMSK = 0x10;  // маска таймера для mega32

               // Universal Serial Interface initialization
               // Communication Parameters: 8 Data, 1 Stop, No Parity
               // USART Receiver: On
               // USART Transmitter: On
               // USART Mode: Asynchronous
               // USART Baud Rate: 9600
UCSRA = 0x00;
UCSRB = 0xD8;
UCSRC = 0x86;
UBRRH = 0x00;
UBRRL = 0x33;

// инициализация аналогового компаратора
ACSR = 0x80;   // отключение аналогового компаратора
SFIOR = 0x00;  // Analog Comparator Input Capture by Timer/Counter 1: Off
ADCSRA = 0x00; // ADC initialization - ADC disabled
SPCR = 0x00;   // SPI initialization - SPI disabled
TWCR = 0x00;   // TWI initialization - TWI disabled
               //----------- \инициализация контроллера

               // ADC initialization
               // ADC Clock frequency: 125,000 kHz
               // ADC Voltage Reference: AVCC pin
ADMUX = ADC_VREF_TYPE & 0xff;
ADCSRA = 0x86;

w1_init();
//i2c_init();
}

#endif // \_CONTRIOLLER_INIT_INCLUDED_
