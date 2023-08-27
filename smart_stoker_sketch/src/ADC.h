#ifndef _ADC_INCLUDED_
#define _ADC_INCLUDED_

#include <mega32.h>
#include <delay.h>

#define ADC_VREF_TYPE 0x40

// Read the AD conversion result
unsigned int read_adc(unsigned char adc_input)
{
	ADMUX = adc_input | (ADC_VREF_TYPE & 0xff);
	// Delay needed for the stabilization of the ADC input voltage
	delay_us(10);
	// Start the AD conversion
	ADCSRA |= 0x40;
	// Wait for the AD conversion to complete
	while ((ADCSRA & 0x10) == 0);
	ADCSRA |= 0x10;
	return ADCW; // 0..1024
}

#endif // \_ADC_INCLUDED_
