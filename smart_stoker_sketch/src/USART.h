#ifdef TIMEOUTGET
bit tLimit;                                // флаг таймаута приема байта из UART tLimit = 0; - время вышло
bit tLimitF;

void StartResive()
{
	tLimit = 1; // 
				//запуск таймера 2
}
#endif //\TIMEOUTGET

// ------------------------- <<< USART >>> -------------------------------------------
#define FRAMING_ERROR (1<<FE)
#define PARITY_ERROR (1<<UPE)
#define DATA_OVERRUN (1<<DOR)
#define DATA_REGISTER_EMPTY (1<<UDRE)
#define RX_COMPLETE (1<<RXC)

// USART Receiver buffer
#define RX_BUFFER_SIZE 32		// 8 байт, увеличен до 32
char rx_buffer[RX_BUFFER_SIZE]; // приемный буфер

#if RX_BUFFER_SIZE <= 256
unsigned char rx_wr_index, rx_rd_index, rx_counter;
#else
unsigned int rx_wr_index, rx_rd_index, rx_counter;
#endif

bit rx_buffer_overflow; // флаг переполнения буфера
						// USART Receiver interrupt service routine, перывание по приему байта
interrupt[USART_RXC] void usart_rx_isr(void)
{
	char status, data;
	status = UCSRA;
	data = UDR;
	if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN)) == 0)
	{
		rx_buffer[rx_wr_index++] = data;
#if RX_BUFFER_SIZE == 256
		// special case for receiver buffer size=256
		if (++rx_counter == 0)
		{
#else
		if (rx_wr_index == RX_BUFFER_SIZE) rx_wr_index = 0;
		if (++rx_counter == RX_BUFFER_SIZE)
		{
			rx_counter = 0;
#endif
			rx_buffer_overflow = 1;
			// bit Global_Bit_buffer_overflow = rx_buffer_overflow; // использовать для подтверждения приема данных
			// использование: Global_Bit_buffer_overflow = 0; getchar()...; проверка if(rx_buffer_overflow) return false;
		}
		}
	// else{OtherErrors = 1;} // ошибки передачи
	}

#ifndef _DEBUG_TERMINAL_IO_
// Get a character from the USART Receiver buffer
#define _ALTERNATE_GETCHAR_
#pragma used+
char getchar(void)
{
	char data;
	while (rx_counter == 0) {};      // ожидание приема байта
	data = rx_buffer[rx_rd_index++]; // прочитать данные из буфера
#if RX_BUFFER_SIZE != 256
	if (rx_rd_index == RX_BUFFER_SIZE) rx_rd_index = 0;
#endif
	#asm("cli")
		--rx_counter; // счетчик байт приемного буфера
	#asm("sei")
		return data;
}

#ifdef TIMEOUTGET  // прототип
char GetCharEx()
{
	char data;
	StartResive(); // tLimit = 1; запуск таймера 2, в таймере 2: {tLimit = 0; остановка таймера 2;}
	while (rx_counter == 0 || !tLimit) {}; // ожидание пока не придет байт или не выйдет время tLimit
	tLimitF = tLimit;
	data = rx_buffer[rx_rd_index++];

#if RX_BUFFER_SIZE != 256
	if (rx_rd_index == RX_BUFFER_SIZE) rx_rd_index = 0;
#endif

	#asm("cli")
		--rx_counter;
	#asm("sei")

		return data;
}
#endif //\TIMEOUTGET

#pragma used-
#endif

// USART Transmitter buffer
#define TX_BUFFER_SIZE 8		// 8 байт
char tx_buffer[TX_BUFFER_SIZE]; // передающий буфер

#if TX_BUFFER_SIZE <= 256 // 256 !!!!
unsigned char tx_wr_index, tx_rd_index, tx_counter;
#else
unsigned int tx_wr_index, tx_rd_index, tx_counter;
#endif

// USART Transmitter interrupt service routine
interrupt[USART_TXC] void usart_tx_isr(void)
{
	if (tx_counter) // в буфере есть данные для передачи
	{
		--tx_counter; // счетчик байт передающего буфера
		UDR = tx_buffer[tx_rd_index++]; // записать данные в регистр UDR данные из буфера
#if TX_BUFFER_SIZE != 256
		if (tx_rd_index == TX_BUFFER_SIZE) tx_rd_index = 0; // tx_rd_index - индекс прочитанного байта из буфера передачи
#endif
	}
}

#ifndef _DEBUG_TERMINAL_IO_
#define _ALTERNATE_PUTCHAR_
#pragma used+
void putchar(char c) // записать символ в USART Transmitter buffer
{
	while (tx_counter == TX_BUFFER_SIZE);
	#asm("cli")
		if (tx_counter || ((UCSRA & DATA_REGISTER_EMPTY) == 0)) // буфер tx_counter -> не пустой или ( UCSRA & ( 1 << UDRE ) ) == 0 -> идет передача предыдущего байта
		{
			tx_buffer[tx_wr_index++] = c; // записать данные в буфер
#if TX_BUFFER_SIZE != 256
			if (tx_wr_index == TX_BUFFER_SIZE) tx_wr_index = 0; // tx_rd_index - индекс записанного байта в буфер передачи, tx_wr_index %= TX_BUFFER_SIZE
#endif
			++tx_counter; // счетчик байт передающего буфера
		}
		else
			UDR = c; // записать данные в регистр UDR, передача данных (напрямую)
	#asm("sei")
}
#pragma used-
#endif // _DEBUG_TERMINAL_IO_
// ------------------------- <<< \USART >>> -------------------------------------------

#ifdef RECEIVEPACKET
void PurgeUsart() { // очистить индексы приемного буфера
	#asm("cli")
		rx_counter = 0;
	rx_wr_index = 0; // !!
	rx_rd_index = 0; // !!
	#asm("sei")
}

unsigned char CmdLost(unsigned char needReadBytes, unsigned char timeOut) {   // bool не работает !
	delay_ms(timeOut); // за это время должны прийти все байты

	if (needReadBytes == rx_counter/*текущее количество прочитанных байт*/ /*&& !rx_buffer_overflow && OtherErrors*/) { /*rx_buffer_overflow = 0; OtherErrors = 0;*/ return 0; } // все байты поступили в буфер порта && не было переполнения буфера и других ошибок
	else { PurgeUsart();/*очистка входящего буфера*/return 1; } // continue, начать ожидание новой команды
}
#endif // RECEIVEPACKET
