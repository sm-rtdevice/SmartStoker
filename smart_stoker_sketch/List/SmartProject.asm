
;CodeVisionAVR C Compiler V2.05.0 Professional
;(C) Copyright 1998-2010 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type                : ATmega32A
;Program type             : Application
;Clock frequency          : 8,000000 MHz
;Memory model             : Small
;Optimize for             : Size
;(s)printf features       : int, width
;(s)scanf features        : int, width
;External RAM size        : 0
;Data Stack size          : 512 byte(s)
;Heap size                : 0 byte(s)
;Promote 'char' to 'int'  : Yes
;'char' is unsigned       : Yes
;8 bit enums              : Yes
;global 'const' stored in FLASH: No
;Enhanced core instructions    : On
;Smart register allocation     : Off
;Automatic register allocation : Off

	#pragma AVRPART ADMIN PART_NAME ATmega32A
	#pragma AVRPART MEMORY PROG_FLASH 32768
	#pragma AVRPART MEMORY EEPROM 1024
	#pragma AVRPART MEMORY INT_SRAM SIZE 2143
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x60

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0060
	.EQU __SRAM_END=0x085F
	.EQU __DSTACK_SIZE=0x0200
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_timer
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart_rx_isr
	JMP  0x00
	JMP  _usart_tx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_conv_delay_G101:
	.DB  0x64,0x0,0xC8,0x0,0x90,0x1,0x20,0x3
_bit_mask_G101:
	.DB  0xF8,0xFF,0xFC,0xFF,0xFE,0xFF,0xFF,0xFF
_tbl10_G105:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G105:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;REGISTER BIT VARIABLES INITIALIZATION
__REG_BIT_VARS:
	.DW  0x0001

_0x6:
	.DB  0x3
_0x7:
	.DB  0xA6,0xFF,0xA6,0xFF
_0x8:
	.DB  0x32
_0x9:
	.DB  0x1
_0x0:
	.DB  0x2D,0x25,0x69,0x2E,0x25,0x75,0xDF,0x43
	.DB  0x0,0x2B,0x25,0x69,0x2E,0x25,0x75,0xDF
	.DB  0x43,0x0,0x2D,0x2D,0x2E,0x2D,0xDF,0x43
	.DB  0x0,0x25,0x69,0x25,0x25,0x2E,0x25,0x69
	.DB  0x0,0x53,0x6D,0x61,0x72,0x74,0x20,0x53
	.DB  0x74,0x6F,0x6B,0x65,0x72,0x0,0x76,0x3A
	.DB  0x32,0x2E,0x35,0x20,0x4C,0x6F,0x61,0x64
	.DB  0x69,0x6E,0x67,0x2E,0x2E,0x2E,0x0
_0x2060003:
	.DB  0x80,0xC0
_0x2080060:
	.DB  0x1
_0x2080000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x01
	.DW  0x02
	.DW  __REG_BIT_VARS*2

	.DW  0x01
	.DW  _ds1820_devices
	.DW  _0x6*2

	.DW  0x04
	.DW  _Temperature
	.DW  _0x7*2

	.DW  0x01
	.DW  _MaxT1
	.DW  _0x8*2

	.DW  0x01
	.DW  _OnBlock
	.DW  _0x9*2

	.DW  0x07
	.DW  _0x2E
	.DW  _0x0*2+18

	.DW  0x07
	.DW  _0x2E+7
	.DW  _0x0*2+18

	.DW  0x07
	.DW  _0x2E+14
	.DW  _0x0*2+18

	.DW  0x0D
	.DW  _0xA0
	.DW  _0x0*2+33

	.DW  0x11
	.DW  _0xA0+13
	.DW  _0x0*2+46

	.DW  0x02
	.DW  __base_y_G103
	.DW  _0x2060003*2

	.DW  0x01
	.DW  __seed_G104
	.DW  _0x2080060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	OUT  WDTCR,R31
	OUT  WDTCR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,__SRAM_START
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x260

	.CSEG
;/*****************************************************
;Project : SMART-кочегар (Stoker)
;Version : v.: 2.4a
;Date    : 26.04.2018
;Author  : SIS
;Company : Sm@rt-Device
;Comments: автоматизированный контроль и управление насосом системы отопления
;
;Chip type           : ATMega32 A - PU
;Clock frequency     : 8,000000 MHz, время выполнения команды: 1/8000000 = 0,000000125 сек = 0.125 мкс
;Memory model        : Small Flash - 32KB (16K x 16), ROM - , RAM - , EEPROM - 2024 b
;External SRAM size  : 0
;Data Stack size     : 512
;
;Дивайсы: DS1820/DS18S20/DS18B20 на шине 1-Wire, CPU AVR ATmega32, программатор USB/ISP (in system programmen), USART: адаптер USB -> TTL/blueTooth, LCD-display
;
;алгоритм работы:
;по умолчанию автоматическое управление от датчиков
;переход на импульсный режим в случае отказа датчика на радиаторе или вручную (по-выбору импульсного режима),
;принудительное ручное управление насосом
;
;выводы МК:
;PORTD.5: 1 - включение насоса; 0 - отключение насоса
;PORTA.5: 1 - неисправность датчика; 0 - датчик в норме (не используется)
;PORTA.6: 0/1 индикатор работы импульсного режима
;PORTA.7: 0/1 индикатор работы от датчиков
;
;PORTA.6,7 = [0,0] - ручное управление, [1,0] - импульсный режим, [0,1] - работа от датчиков, [1,1] - ошибка инициализации датчиков
;
;UART (9600bod/1start/1stop/no_parity) = 9600*0.8 = 7680бит/с = 960байт/с; 1байт = 1,041мс	~2*к-во байт + ожидание расчета температуры ~600-800мс
;*****************************************************/
;
;#include "stdafx.h"
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_sncpy:
;	*dest -> Y+2
;	*src -> Y+0
	LD   R26,Y
	LDD  R27,Y+1
	CALL __EEPROMRDB
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ST   X,R30
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,1
	CALL __EEPROMRDB
	__PUTB1SNS 2,1
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,2
	CALL __EEPROMRDB
	__PUTB1SNS 2,2
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,3
	CALL __EEPROMRDB
	__PUTB1SNS 2,3
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,4
	CALL __EEPROMRDB
	__PUTB1SNS 2,4
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,5
	CALL __EEPROMRDB
	__PUTB1SNS 2,5
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,6
	CALL __EEPROMRDB
	__PUTB1SNS 2,6
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,7
	CALL __EEPROMRDB
	__PUTB1SNS 2,7
	LD   R26,Y
	LDD  R27,Y+1
	ADIW R26,8
	CALL __EEPROMRDB
	__PUTB1SNS 2,8
	ADIW R28,4
	RET
;	data -> Y+1
;	bc -> R16
;	dec -> Y+5
;	bcd -> R16
;	n -> R17
;	dig -> R18
;	num -> R19
;	count -> R20

	.DSEG
   .equ __i2c_port=0x15 ;PORTC
   .equ __sda_bit=1
   .equ __scl_bit=0

	.CSEG
;	_param -> Y+1
;	result -> R16
;	_param -> Y+1
;	_value -> Y+0
;	*wholeT -> Y+2
;	*divT -> Y+0
;	min1 -> Y+0
;	hour1 -> Y+0
;	sec1 -> Y+0
;	wday1 -> Y+0
;	day1 -> Y+0
;	month1 -> Y+0
;	year1 -> Y+0
_read_adc:
;	adc_input -> Y+0
	LD   R30,Y
	ORI  R30,0x40
	OUT  0x7,R30
	__DELAY_USB 27
	SBI  0x6,6
_0xA:
	SBIS 0x6,4
	RJMP _0xA
	SBI  0x6,4
	IN   R30,0x4
	IN   R31,0x4+1
	RJMP _0x2120008
_InitController:
	LDI  R30,LOW(0)
	OUT  0x1B,R30
	LDI  R30,LOW(254)
	OUT  0x1A,R30
	LDI  R30,LOW(0)
	OUT  0x18,R30
	OUT  0x17,R30
	OUT  0x15,R30
	OUT  0x14,R30
	LDI  R30,LOW(3)
	OUT  0x12,R30
	LDI  R30,LOW(124)
	OUT  0x11,R30
	LDI  R30,LOW(0)
	OUT  0x33,R30
	OUT  0x32,R30
	OUT  0x3C,R30
	OUT  0x2F,R30
	LDI  R30,LOW(5)
	OUT  0x2E,R30
	LDI  R30,LOW(15)
	OUT  0x2D,R30
	LDI  R30,LOW(255)
	OUT  0x2C,R30
	LDI  R30,LOW(0)
	OUT  0x27,R30
	OUT  0x26,R30
	LDI  R30,LOW(130)
	OUT  0x2B,R30
	LDI  R30,LOW(48)
	OUT  0x2A,R30
	LDI  R30,LOW(0)
	OUT  0x22,R30
	OUT  0x25,R30
	OUT  0x24,R30
	OUT  0x23,R30
	OUT  0x35,R30
	OUT  0x34,R30
	LDI  R30,LOW(16)
	OUT  0x39,R30
	LDI  R30,LOW(0)
	OUT  0xB,R30
	LDI  R30,LOW(216)
	OUT  0xA,R30
	LDI  R30,LOW(134)
	OUT  0x20,R30
	LDI  R30,LOW(0)
	OUT  0x20,R30
	LDI  R30,LOW(51)
	OUT  0x9,R30
	LDI  R30,LOW(128)
	OUT  0x8,R30
	LDI  R30,LOW(0)
	OUT  0x30,R30
	OUT  0x6,R30
	OUT  0xD,R30
	OUT  0x36,R30
	LDI  R30,LOW(64)
	OUT  0x7,R30
	LDI  R30,LOW(134)
	OUT  0x6,R30
	CALL _w1_init
	RET
_usart_rx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
;	status -> R16
;	data -> R17
	IN   R16,11
	IN   R17,12
	MOV  R30,R16
	ANDI R30,LOW(0x1C)
	BRNE _0xD
	LDS  R30,_rx_wr_index
	SUBI R30,-LOW(1)
	STS  _rx_wr_index,R30
	CALL SUBOPT_0x0
	ST   Z,R17
	LDS  R26,_rx_wr_index
	CPI  R26,LOW(0x20)
	BRNE _0xE
	LDI  R30,LOW(0)
	STS  _rx_wr_index,R30
_0xE:
	LDS  R26,_rx_counter
	SUBI R26,-LOW(1)
	STS  _rx_counter,R26
	CPI  R26,LOW(0x20)
	BRNE _0xF
	LDI  R30,LOW(0)
	STS  _rx_counter,R30
	SET
	BLD  R2,1
_0xF:
_0xD:
	LD   R16,Y+
	LD   R17,Y+
	RJMP _0xFF
_getchar:
	ST   -Y,R16
;	data -> R16
_0x10:
	LDS  R30,_rx_counter
	CPI  R30,0
	BREQ _0x10
	LDS  R30,_rx_rd_index
	SUBI R30,-LOW(1)
	STS  _rx_rd_index,R30
	CALL SUBOPT_0x0
	LD   R16,Z
	LDS  R26,_rx_rd_index
	CPI  R26,LOW(0x20)
	BRNE _0x13
	LDI  R30,LOW(0)
	STS  _rx_rd_index,R30
_0x13:
	cli
	LDS  R30,_rx_counter
	SUBI R30,LOW(1)
	STS  _rx_counter,R30
	sei
	MOV  R30,R16
	LD   R16,Y+
	RET
_usart_tx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	LDS  R30,_tx_counter
	CPI  R30,0
	BREQ _0x14
	SUBI R30,LOW(1)
	STS  _tx_counter,R30
	LDS  R30,_tx_rd_index
	SUBI R30,-LOW(1)
	STS  _tx_rd_index,R30
	CALL SUBOPT_0x1
	LD   R30,Z
	OUT  0xC,R30
	LDS  R26,_tx_rd_index
	CPI  R26,LOW(0x8)
	BRNE _0x15
	LDI  R30,LOW(0)
	STS  _tx_rd_index,R30
_0x15:
_0x14:
_0xFF:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
_putchar:
;	c -> Y+0
_0x16:
	LDS  R26,_tx_counter
	CPI  R26,LOW(0x8)
	BREQ _0x16
	cli
	LDS  R30,_tx_counter
	CPI  R30,0
	BRNE _0x1A
	SBIC 0xB,5
	RJMP _0x19
_0x1A:
	LDS  R30,_tx_wr_index
	SUBI R30,-LOW(1)
	STS  _tx_wr_index,R30
	CALL SUBOPT_0x1
	LD   R26,Y
	STD  Z+0,R26
	LDS  R26,_tx_wr_index
	CPI  R26,LOW(0x8)
	BRNE _0x1C
	LDI  R30,LOW(0)
	STS  _tx_wr_index,R30
_0x1C:
	LDS  R30,_tx_counter
	SUBI R30,-LOW(1)
	STS  _tx_counter,R30
	RJMP _0x1D
_0x19:
	LD   R30,Y
	OUT  0xC,R30
_0x1D:
	sei
_0x2120008:
	ADIW R28,1
	RET
_PurgeUsart:
	cli
	LDI  R30,LOW(0)
	STS  _rx_counter,R30
	STS  _rx_wr_index,R30
	STS  _rx_rd_index,R30
	sei
	RET
_CmdLost:
;	needReadBytes -> Y+1
;	timeOut -> Y+0
	LD   R30,Y
	LDI  R31,0
	CALL SUBOPT_0x2
	LDS  R30,_rx_counter
	LDD  R26,Y+1
	CP   R30,R26
	BRNE _0x1E
	LDI  R30,LOW(0)
	RJMP _0x2120007
_0x1E:
	RCALL _PurgeUsart
	LDI  R30,LOW(1)
_0x2120007:
	ADIW R28,2
	RET
_GetTemper:
	SBIW R28,4
	ST   -Y,R17
	ST   -Y,R16
;	addr -> Y+6
;	Temp -> R16,R17
;	fTemp -> Y+2
	__GETWRN 16,17,-90
	CALL SUBOPT_0x3
	LD   R26,Z
	CPI  R26,LOW(0x28)
	BREQ PC+3
	JMP _0x20
	CALL SUBOPT_0x3
	ST   -Y,R31
	ST   -Y,R30
	RCALL _ds18b20_temperature
	__PUTD1S 2
	LDD  R26,Y+5
	TST  R26
	BRPL _0x21
	CALL SUBOPT_0x4
	LDI  R26,LOW(1)
	RJMP _0xF1
_0x21:
	CALL SUBOPT_0x4
	LDI  R26,LOW(0)
_0xF1:
	STD  Z+0,R26
	__GETD1S 2
	CALL __CFD1
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x5
	PUSH R31
	PUSH R30
	__GETD2S 2
	__GETD1N 0x41200000
	CALL __MULF12
	POP  R26
	POP  R27
	CALL __CFD1
	CALL SUBOPT_0x6
	PUSH R31
	PUSH R30
	LDD  R30,Y+6
	LDI  R26,LOW(_TempDec)
	LDI  R27,HIGH(_TempDec)
	CALL SUBOPT_0x7
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	CALL _abs
	POP  R26
	POP  R27
	CALL SUBOPT_0x6
	MOVW R22,R30
	MOVW R26,R30
	CALL __GETW1P
	MOVW R26,R30
	CALL SUBOPT_0x8
	RJMP _0x23
_0x20:
	CALL SUBOPT_0x3
	ST   -Y,R31
	ST   -Y,R30
	RCALL _ds1820_temperature_10
	MOVW R16,R30
	TST  R17
	BRPL _0x24
	CALL SUBOPT_0x4
	LDI  R26,LOW(1)
	RJMP _0xF2
_0x24:
	CALL SUBOPT_0x4
	LDI  R26,LOW(0)
_0xF2:
	STD  Z+0,R26
	ST   -Y,R17
	ST   -Y,R16
	CALL SUBOPT_0x5
	MOVW R22,R30
	MOVW R26,R16
	CALL SUBOPT_0x8
	MOVW R26,R16
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __DIVW21
	MOVW R16,R30
_0x23:
	LDI  R30,LOW(9999)
	LDI  R31,HIGH(9999)
	CP   R30,R16
	CPC  R31,R17
	BREQ _0x27
	LDI  R30,LOW(999)
	LDI  R31,HIGH(999)
	CP   R30,R16
	CPC  R31,R17
	BRNE _0x26
_0x27:
	LDI  R30,LOW(65446)
	LDI  R31,HIGH(65446)
	RJMP _0x2120006
_0x26:
	MOVW R30,R16
_0x2120006:
	LDD  R17,Y+1
	LDD  R16,Y+0
	ADIW R28,7
	RET
_LCD_Show:
	CALL _lcd_clear
	LDS  R30,_lcd_screen
	CPI  R30,0
	BREQ PC+3
	JMP _0x29
	LDI  R30,LOW(0)
	ST   -Y,R30
	ST   -Y,R30
	CALL _lcd_gotoxy
	CALL SUBOPT_0x9
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BREQ _0x2A
	__GETB1MN _Sign,1
	CPI  R30,0
	BREQ _0x2B
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,0
	RJMP _0xF3
_0x2B:
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,9
_0xF3:
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0x9
	CALL SUBOPT_0xB
	__GETW1MN _TempDec,2
	CALL SUBOPT_0xB
	CALL SUBOPT_0xC
	LDI  R30,LOW(_lcd_buffer)
	LDI  R31,HIGH(_lcd_buffer)
	RJMP _0xF4
_0x2A:
	__POINTW1MN _0x2E,0
_0xF4:
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
	LDI  R30,LOW(8)
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	CALL _lcd_gotoxy
	CALL SUBOPT_0xD
	CPI  R26,LOW(0xFFA6)
	LDI  R30,HIGH(0xFFA6)
	CPC  R27,R30
	BREQ _0x2F
	LDS  R30,_Sign
	CPI  R30,0
	BREQ _0x30
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,0
	RJMP _0xF5
_0x30:
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,9
_0xF5:
	ST   -Y,R31
	ST   -Y,R30
	LDS  R30,_Temperature
	LDS  R31,_Temperature+1
	CALL SUBOPT_0xB
	LDS  R30,_TempDec
	LDS  R31,_TempDec+1
	CALL SUBOPT_0xB
	CALL SUBOPT_0xC
	LDI  R30,LOW(_lcd_buffer)
	LDI  R31,HIGH(_lcd_buffer)
	RJMP _0xF6
_0x2F:
	__POINTW1MN _0x2E,7
_0xF6:
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
	CALL SUBOPT_0xE
	CALL SUBOPT_0xF
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BREQ _0x33
	__GETB2MN _Sign,2
	CPI  R26,LOW(0x1)
	BRNE _0x34
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,0
	RJMP _0xF7
_0x34:
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,9
_0xF7:
	ST   -Y,R31
	ST   -Y,R30
	CALL SUBOPT_0xF
	CALL SUBOPT_0xB
	__GETW1MN _TempDec,4
	CALL SUBOPT_0xB
	CALL SUBOPT_0xC
	LDI  R30,LOW(_lcd_buffer)
	LDI  R31,HIGH(_lcd_buffer)
	RJMP _0xF8
_0x33:
	__POINTW1MN _0x2E,14
_0xF8:
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
	LDI  R30,LOW(8)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	CALL _lcd_gotoxy
	CALL SUBOPT_0xA
	__POINTW1FN _0x0,25
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(0)
	ST   -Y,R30
	RCALL _read_adc
	LDI  R26,LOW(100)
	LDI  R27,HIGH(100)
	CALL __MULW12U
	CALL __LSRW2
	MOV  R30,R31
	LDI  R31,0
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	LDI  R30,LOW(0)
	ST   -Y,R30
	RCALL _read_adc
	CLR  R22
	CLR  R23
	CALL __PUTPARD1
	CALL SUBOPT_0xC
	CALL SUBOPT_0xA
	CALL _lcd_puts
_0x29:
	RET

	.DSEG
_0x2E:
	.BYTE 0x15
;
;#asm
   .equ __w1_port=0x12 ;PORTD               // настраиваем порт D bit6 на шину 1-wire 20 ножка ATMega32
   .equ __w1_bit=6
; 0000 0026 #endasm
;
;/*
;// Timer 0 прерывание по таймеру
;interrupt [TIM0_COMPA] void timer0_timer(void) // TIM0_COMP[A|B]  TIM0_OVF
;{
;	 //tLimit = 0;                // сбросить флаг таймаута (время вышло)
;	 // PORTB.7 = !PORTB.7;    // инвертирование сигнала  DP тест
;}
;*/
;// ----------------------------------------------------------------------------
;
;// Timer 1 прерывание по таймеру (основной цикл обработки данных)
;interrupt [TIM1_COMPA] void timer1_timer(void) // TIM1_COMP[A|B]  TIM0_OVF
; 0000 0034 {

	.CSEG
_timer1_timer:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0000 0035 	if(Errcount == 0 && AutoRestoration == 1){StokerMode = 0;}; // при восстановлении связи с датчиком, возобновить автоматическое управление от датчиков
	LDS  R26,_Errcount
	CPI  R26,LOW(0x0)
	BRNE _0x3A
	LDI  R26,LOW(_AutoRestoration)
	LDI  R27,HIGH(_AutoRestoration)
	CALL __EEPROMRDB
	CPI  R30,LOW(0x1)
	BREQ _0x3B
_0x3A:
	RJMP _0x39
_0x3B:
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
_0x39:
; 0000 0036 
; 0000 0037 	if( StokerMode == 0 || MeasureTemp == 1 || AutoRestoration == 1)  // опрос датчиков: если (включено управление от датчиков ) или (включено принудительное измерение температуры) или разрешено восстановление
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	CALL __EEPROMRDB
	CPI  R30,0
	BREQ _0x3D
	SBRC R2,0
	RJMP _0x3D
	LDI  R26,LOW(_AutoRestoration)
	LDI  R27,HIGH(_AutoRestoration)
	CALL __EEPROMRDB
	CPI  R30,LOW(0x1)
	BREQ _0x3D
	RJMP _0x3C
_0x3D:
; 0000 0038 	{
; 0000 0039 		for(k1 = 0; k1 < ds1820_devices; k1++) // опрос датчиков;
	LDI  R30,LOW(0)
	STS  _k1,R30
_0x40:
	LDS  R30,_ds1820_devices
	LDS  R26,_k1
	CP   R26,R30
	BRSH _0x41
; 0000 003A 		// k1 = ++k1 % ds1820_devices;   // опрос по 1 датчику за прерывание, чтобы уменьшить время ожидания отклика команды
; 0000 003B 		{
; 0000 003C 			//Temperature[k1] = GetTemper(&ds1820_sn[k1][0]); // только целая часть
; 0000 003D 			Temperature[k1] = GetTemper(k1);
	CALL SUBOPT_0x10
	ADD  R30,R26
	ADC  R31,R27
	PUSH R31
	PUSH R30
	LDS  R30,_k1
	ST   -Y,R30
	RCALL _GetTemper
	POP  R26
	POP  R27
	ST   X+,R30
	ST   X,R31
; 0000 003E 
; 0000 003F 			/*
; 0000 0040 			#ifdef SAVETEMPER
; 0000 0041 			// if(таймаут сохранения){} // реализовать !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; 0000 0042 			//if(k1 == 0){SaveTemper(Temperature[k1]);}; // сохранить в энергонезависимую память, значение температуры возможно с ошибками !
; 0000 0043 			SaveTemper(Temperature[k1],k);
; 0000 0044 			#endif
; 0000 0045 			*/
; 0000 0046 
; 0000 0047 			if(Temperature[k1] == -90) // ошибка получения данных от датчика ds1820.h
	CALL SUBOPT_0x10
	ADD  R26,R30
	ADC  R27,R31
	CALL __GETW1P
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BRNE _0x42
; 0000 0048 			{
; 0000 0049 				//PORTA.5 = 1;          // отказ датчика
; 0000 004A 
; 0000 004B 				if(k1 == 0 && (StokerMode == 0) )  // датчик на радиаторе и режим управления от датчиков
	LDS  R26,_k1
	CPI  R26,LOW(0x0)
	BRNE _0x44
	CALL SUBOPT_0x11
	CPI  R30,0
	BREQ _0x45
_0x44:
	RJMP _0x43
_0x45:
; 0000 004C 				{
; 0000 004D 					Errcount++;                                                        // счетчик ошибок++ датчик на радиаторе
	LDS  R30,_Errcount
	SUBI R30,-LOW(1)
	STS  _Errcount,R30
; 0000 004E 					if(Errcount >= 5){StokerMode = 1; TickCount = 0; /*PORTD.5 = 0;*/}; // (>60) --> переход в импульсный режим, включить аварийный светодиод PORTA.5 = 1, сброс настроек импульсного режима, начать с простоя (PORTD.5 = 0)??
	LDS  R26,_Errcount
	CPI  R26,LOW(0x5)
	BRLO _0x46
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	LDI  R30,LOW(1)
	CALL SUBOPT_0x12
_0x46:
; 0000 004F 					//continue; // продолжить for...  управлять... continue - по-любому
; 0000 0050 				}
; 0000 0051 
; 0000 0052 				/*
; 0000 0053 				else if(k1 == 1) {
; 0000 0054 					//PORTA.5 = 1;          // отказ датчика
; 0000 0055 				}
; 0000 0056 				else if(k1 == 2) {
; 0000 0057 					//PORTA.5 = 1;          // отказ датчика
; 0000 0058 				}
; 0000 0059 				*/
; 0000 005A 
; 0000 005B 				continue; // продолжить for...  управлять...
_0x43:
	RJMP _0x3F
; 0000 005C 			}
; 0000 005D 			//else{ PORTA.5 = 0; }    // сброс отказа датчика
; 0000 005E 
; 0000 005F 			if(k1 == 0) {Errcount = 0;}; // сброс счетчика ошибок датчика на радиаторе
_0x42:
	LDS  R30,_k1
	CPI  R30,0
	BRNE _0x47
	LDI  R30,LOW(0)
	STS  _Errcount,R30
_0x47:
; 0000 0060 		};
_0x3F:
	LDS  R30,_k1
	SUBI R30,-LOW(1)
	STS  _k1,R30
	RJMP _0x40
_0x41:
; 0000 0061 
; 0000 0062 		//k1 = (k1+1)%ds1820_devices; // опрашивать по 1 датчику за цикл. распараллелить задачи (убрать for...)
; 0000 0063 
; 0000 0064 		#ifdef SAVETEMPER
; 0000 0065 		if(SaveTimeOut == 37) // 8*37 = 296 c ~ 5 мин. | 8*75 = 600 c == 10 мин
; 0000 0066 		{
; 0000 0067 			SaveTemper(Temperature[k1],k1); // сохранить в энергонезависимую память, значение температуры возможно с ошибками !
; 0000 0068 			SaveTimeOut = 0;
; 0000 0069 		}
; 0000 006A 		SaveTimeOut += 8;
; 0000 006B 		#endif
; 0000 006C 
; 0000 006D 	} // \опрос датчиков
; 0000 006E 
; 0000 006F 	switch(StokerMode)	// 0 - авто; 1 - импульс; 2 -  принудительное включение; 3 - принудительное отключение
_0x3C:
	CALL SUBOPT_0x11
	CALL SUBOPT_0x13
; 0000 0070 	{
; 0000 0071 		case 0x00:	// авто (управление от датчиков)
	BREQ PC+3
	JMP _0x4B
; 0000 0072 		{
; 0000 0073 			PORTA.6 = 0;              // отключить индикатор
	CBI  0x1B,6
; 0000 0074 			PORTA.7 = 1;              // индикатор режима работы от датчиков, мигание: PORTA.7 = !PORTA.7;
	SBI  0x1B,7
; 0000 0075 			// Temperature[0] - радиатор, Temperature[1] - котел, Temperature[2] - улица, T2k - 1 контур
; 0000 0076 
; 0000 0077 			MaxT1 = MaxT;                                        // расчетный верхний предел отключения насоса (если в котле меньше температуры чем верхняя уставка)
	LDI  R26,LOW(_MaxT)
	LDI  R27,HIGH(_MaxT)
	CALL __EEPROMRDB
	STS  _MaxT1,R30
; 0000 0078 			OnBlock = 1;                                         // блокировка включения 1 - включение разрешено (по умолчанию), 0 - включение заблокировано
	LDI  R30,LOW(1)
	STS  _OnBlock,R30
; 0000 0079 
; 0000 007A 			if(Temperature[1] != -90)                            // датчик на котле работает
	CALL SUBOPT_0x9
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BREQ _0x50
; 0000 007B 			{
; 0000 007C 				//if(Temperature[1] <= MinT){OnBlock = 0;}                      // заблокировать включение! ???
; 0000 007D 				if(Temperature[1] < MinTCaldron){OnBlock = 0; PORTD.5 = 0;}      // отключить и заблокировать включение! если температура в котле < "30" (нет смысла гонять насос)
	LDI  R26,LOW(_MinTCaldron)
	LDI  R27,HIGH(_MinTCaldron)
	CALL __EEPROMRDB
	__GETW2MN _Temperature,2
	CALL SUBOPT_0x14
	BRGE _0x51
	LDI  R30,LOW(0)
	STS  _OnBlock,R30
	CBI  0x12,5
; 0000 007E 				// if(Temperature[0] >= Temperature[1]){OnBlock = 0;}  // PORTD.5 = 0; заблокировать включение! если температура в радиаторе >= температура в котле ??? - может быть есть смысл перекачать кипяток вниз
; 0000 007F 				// if(Temperature[1] < MaxT){MaxT1 = Temperature[1];}  // передвинуть максимальный предел, если температура в котле < макс. предела отключения
; 0000 0080 				if(Temperature[0] >= Temperature[1]){PORTD.5 = 0; OnBlock = 0;} // температура воды в радиаторе достигла температуры в котле  !!!!!!!!!!!!!
_0x51:
	CALL SUBOPT_0x9
	CALL SUBOPT_0xD
	CP   R26,R30
	CPC  R27,R31
	BRLT _0x54
	CBI  0x12,5
	LDI  R30,LOW(0)
	STS  _OnBlock,R30
; 0000 0081 			}
_0x54:
; 0000 0082 
; 0000 0083 			/*
; 0000 0084 			if(T2k != -90)                           // датчик на 1 контуре работает  (не используется)
; 0000 0085 			{
; 0000 0086 				if(T2k < Temperature[0]){OnBlock = 0;}    // температура в 1 контуре < температуры в 2 контуре -> заблокировать включение
; 0000 0087 			}
; 0000 0088 			*/
; 0000 0089 
; 0000 008A 			if(Temperature[0] != -90) // если датчик на радиаторе работает то управлять, иначе оставить все без изменений
_0x50:
	CALL SUBOPT_0x15
	BREQ _0x57
; 0000 008B 			{
; 0000 008C 				// управление работой
; 0000 008D 				if(PORTD.5 == 1) {  // насос работает
	SBIS 0x12,5
	RJMP _0x58
; 0000 008E 					if(Temperature[0] >= MaxT1) {PORTD.5 = 0;}      // выключить достигнут максимальный предел   MaxT1  !!!!!!!
	LDS  R30,_MaxT1
	CALL SUBOPT_0xD
	CALL SUBOPT_0x14
	BRLT _0x59
	CBI  0x12,5
; 0000 008F 				} else {              // насос отключен
_0x59:
	RJMP _0x5C
_0x58:
; 0000 0090 					if(Temperature[0] < MinT) {PORTD.5 = OnBlock;} //  достигнут минимальный предел -> попытаться включить
	LDI  R26,LOW(_MinT)
	LDI  R27,HIGH(_MinT)
	CALL __EEPROMRDB
	CALL SUBOPT_0xD
	CALL SUBOPT_0x14
	BRGE _0x5D
	LDS  R30,_OnBlock
	CPI  R30,0
	BRNE _0x5E
	CBI  0x12,5
	RJMP _0x5F
_0x5E:
	SBI  0x12,5
_0x5F:
; 0000 0091 				}
_0x5D:
_0x5C:
; 0000 0092 				// \управление работой
; 0000 0093 			}
; 0000 0094 		}
_0x57:
; 0000 0095 		break;	// \режим работы от датчиков
	RJMP _0x4A
; 0000 0096 
; 0000 0097 		case 0x01:	// импульсный режим (управление по времени)
_0x4B:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x60
; 0000 0098 		{
; 0000 0099 			PORTA.7 = 0;         // отключить индикатор
	CBI  0x1B,7
; 0000 009A 			PORTA.6 = 1;         // включить индикатор работы импульсного режима, мигание: PORTA.6 = !PORTA.6;
	SBI  0x1B,6
; 0000 009B 
; 0000 009C 			TickCount += 8;      // настроить тик таймера, рассчитать время итерации !!! !!! !!! !!! !!! !!!
	LDS  R30,_TickCount
	LDS  R31,_TickCount+1
	ADIW R30,8
	STS  _TickCount,R30
	STS  _TickCount+1,R31
; 0000 009D 
; 0000 009E 			if(PORTD.5 == 1) {    // насос работает
	SBIS 0x12,5
	RJMP _0x65
; 0000 009F 				if(TickCount > WorkTime*60) {TickCount = 0; PORTD.5 = 0;} // выключить достигнуто максимальное время работы
	LDI  R26,LOW(_WorkTime)
	LDI  R27,HIGH(_WorkTime)
	CALL SUBOPT_0x16
	BRSH _0x66
	LDI  R30,LOW(0)
	STS  _TickCount,R30
	STS  _TickCount+1,R30
	CBI  0x12,5
; 0000 00A0 			}
_0x66:
; 0000 00A1 			else {                // насос отключен
	RJMP _0x69
_0x65:
; 0000 00A2 				if(TickCount > IdleTime*60) {TickCount = 0; PORTD.5 = 1;} // включить достигнуто максимальное время простоя
	LDI  R26,LOW(_IdleTime)
	LDI  R27,HIGH(_IdleTime)
	CALL SUBOPT_0x16
	BRSH _0x6A
	LDI  R30,LOW(0)
	STS  _TickCount,R30
	STS  _TickCount+1,R30
	SBI  0x12,5
; 0000 00A3 			}
_0x6A:
_0x69:
; 0000 00A4 		}
; 0000 00A5 		break;	// \импульсный режим
	RJMP _0x4A
; 0000 00A6 
; 0000 00A7 		case 0x02:	// принудительное включение насоса
_0x60:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x6D
; 0000 00A8 		{
; 0000 00A9 			PORTD.5 = 1;
	SBI  0x12,5
; 0000 00AA 			PORTA.6 = 1; PORTA.7 = 1;  // включить индикаторы
	SBI  0x1B,6
	SBI  0x1B,7
; 0000 00AB 		}
; 0000 00AC 		break;
	RJMP _0x4A
; 0000 00AD 
; 0000 00AE 		case 0x03:	// принудительное отключение насоса
_0x6D:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x4A
; 0000 00AF 		{
; 0000 00B0 			PORTD.5 = 0;
	CBI  0x12,5
; 0000 00B1 			PORTA.6 = 0; PORTA.7 = 0;  // отключить индикаторы
	CBI  0x1B,6
	CBI  0x1B,7
; 0000 00B2 		}
; 0000 00B3 		break;
; 0000 00B4 	}
_0x4A:
; 0000 00B5 
; 0000 00B6 	#ifdef LCD
; 0000 00B7 	LCD_Show();
	RCALL _LCD_Show
; 0000 00B8 	#endif
; 0000 00B9 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;// ----------------------------------------------------------------------------
;void main(void)
; 0000 00BC {
_main:
; 0000 00BD 	InitController();
	RCALL _InitController
; 0000 00BE 
; 0000 00BF  /*
; 0000 00C0   ds18b20_init(     // - unsigned char - Радиатор
; 0000 00C1                &ds1820_sn[0][0], // unsigned char *addr
; 0000 00C2                -20,              // signed char temp_low
; 0000 00C3                50,               //signed char temp_high
; 0000 00C4                DS18B20_12BIT_RES); //DS18B20_12BIT_RES, DS18B20_11BIT_RES, DS18B20_10BIT_RES, DS18B20_9BIT_RES - resolution
; 0000 00C5 
; 0000 00C6   ds18b20_init(     // - unsigned char - Котел
; 0000 00C7                &ds1820_sn[1][0], // unsigned char *addr
; 0000 00C8                -20,              // signed char temp_low
; 0000 00C9                50,               //signed char temp_high
; 0000 00CA                DS18B20_12BIT_RES); //DS18B20_12BIT_RES, DS18B20_11BIT_RES, DS18B20_10BIT_RES, DS18B20_9BIT_RES - resolution
; 0000 00CB  */
; 0000 00CC 
; 0000 00CD #ifdef TEST  // тестовый режим поиск и опрос любых датчиков
; 0000 00CE 	ds1820_devices = w1_search(0xf0,ds1820_sn);           // поиск подключенных датчиков и их нумерация  // определение глючного датчика
; 0000 00CF 
; 0000 00D0 	// оперделение адреса Test
; 0000 00D1 	lcd_init(16);
; 0000 00D2 	lcd_clear();
; 0000 00D3 	lcd_gotoxy(0, 0);
; 0000 00D4 	sprintf(lcd_buffer,"%x %x %x %x %x %x %x %x %x",ds1820_sn[2][0], ds1820_sn[2][1], ds1820_sn[2][2], ds1820_sn[2][3], ds1820_sn[2][4], ds1820_sn[2][5], ds1820_sn[2][6], ds1820_sn[2][7], ds1820_sn[2][8]);
; 0000 00D5 	lcd_puts(lcd_buffer);
; 0000 00D6 
; 0000 00D7 	delay_ms(3000);
; 0000 00D8 	// оперделение адреса Test
; 0000 00D9 
; 0000 00DA 	if(ds1820_devices > 0) // если устройства найдены то прочитать мусор
; 0000 00DB 	{
; 0000 00DC 		for (i=0; i<ds1820_devices; i++)
; 0000 00DD 		{
; 0000 00DE 			//Temperature[i] = GetTemper(&ds1820_sn[i][0]); // прочитать мусор
; 0000 00DF 			Temperature[0] = GetTemper(i);
; 0000 00E0 		}
; 0000 00E1 	}
; 0000 00E2 #else // штатный режим
; 0000 00E3 	//ds1820_devices = 3;  // подключено 3 датчика
; 0000 00E4 
; 0000 00E5 	sncpy(ds1820_sn[0],ds1820_rom_codes[0]);                  // загрузить из еепром во flash
	CALL SUBOPT_0x17
; 0000 00E6 	sncpy(ds1820_sn[1],ds1820_rom_codes[1]);                  // загрузить из еепром во flash
; 0000 00E7 	sncpy(ds1820_sn[2],ds1820_rom_codes[2]);                  // загрузить из еепром во flash
	__POINTW1MN _ds1820_sn,18
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _ds1820_rom_codes,18
	ST   -Y,R31
	ST   -Y,R30
	CALL _sncpy
; 0000 00E8 
; 0000 00E9 	//Temperature[0] = GetTemper(&ds1820_sn[0][0]);             // радиатор (прочитать мусор)
; 0000 00EA 	//Temperature[1] = GetTemper(&ds1820_sn[1][0]);             // котел
; 0000 00EB 
; 0000 00EC 	Temperature[0] = GetTemper(0);  // радиатор (прочитать мусор)
	LDI  R30,LOW(0)
	ST   -Y,R30
	RCALL _GetTemper
	STS  _Temperature,R30
	STS  _Temperature+1,R31
; 0000 00ED 	Temperature[1] = GetTemper(1);  // котел
	LDI  R30,LOW(1)
	ST   -Y,R30
	RCALL _GetTemper
	__PUTW1MN _Temperature,2
; 0000 00EE   //Temperature[2] = GetTemper(2);  // внешний
; 0000 00EF #endif
; 0000 00F0 
; 0000 00F1 	PORTD.5 = 0;    // 9 нога на исполнительное устройство (насос - по умолчанию выключен), 1 - вкл; 0 - откл
	CBI  0x12,5
; 0000 00F2 	StokerMode = 0; // - По умолчанию при включении всегда режим управления от датчиков !!!
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
; 0000 00F3 
; 0000 00F4 	// индикация режима управления:
; 0000 00F5 	switch(StokerMode)
	CALL SUBOPT_0x11
	CALL SUBOPT_0x13
; 0000 00F6 	{
; 0000 00F7 	case 0:                            // авто - обновить состояние сигнальных светодиодов
	BRNE _0x80
; 0000 00F8 		if ( (Temperature[0] == -90 || Temperature[1] == -90) || (ds1820_devices < 2) ) { // ds1820_devices < 2 // ошибка датчиков
	CALL SUBOPT_0x15
	BREQ _0x82
	CALL SUBOPT_0x9
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BRNE _0x83
_0x82:
	RJMP _0x84
_0x83:
	LDS  R26,_ds1820_devices
	CPI  R26,LOW(0x2)
	BRSH _0x81
_0x84:
; 0000 00F9 			PORTA.7 = 1;         // включить оба индикатора (до следующего цикла измерения, затем загорается зеленый)
	SBI  0x1B,7
; 0000 00FA 			PORTA.6 = 1;         //
	SBI  0x1B,6
; 0000 00FB 			Errcount = 1;        // ОШИБКА ЧТЕНИЯ ДАННЫХ
	LDI  R30,LOW(1)
	STS  _Errcount,R30
; 0000 00FC 		} else {
	RJMP _0x8A
_0x81:
; 0000 00FD 			PORTA.7 = 1;         // горит зеленый постоянно все ОК
	SBI  0x1B,7
; 0000 00FE 		}
_0x8A:
; 0000 00FF 	break;
	RJMP _0x7F
; 0000 0100 
; 0000 0101 	case 1:                // импульс (горит желтый)
_0x80:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x8D
; 0000 0102 		PORTA.7 = 0;          // отключить индикатор
	CBI  0x1B,7
; 0000 0103 		PORTA.6 = 1;          // включить индикатор работы импульсного режима, мигание: PORTA.6 = !PORTA.6;
	SBI  0x1B,6
; 0000 0104 	break;
	RJMP _0x7F
; 0000 0105 
; 0000 0106 	case 2:
_0x8D:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x92
; 0000 0107 		PORTD.5 = 1;                      // насос принудительно включен
	SBI  0x12,5
; 0000 0108 		PORTA.6 = 1; PORTA.7 = 1;         // горят оба индикатора !!
	SBI  0x1B,6
	SBI  0x1B,7
; 0000 0109 	break;
	RJMP _0x7F
; 0000 010A 
; 0000 010B 	case 3:
_0x92:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x7F
; 0000 010C 		PORTD.5 = 0;                      // насос принудительно отключен
	CBI  0x12,5
; 0000 010D 		PORTA.6 = 0; PORTA.7 = 0;         // не горит ни один индикатор !!
	CBI  0x1B,6
	CBI  0x1B,7
; 0000 010E 	break;
; 0000 010F 	}
_0x7F:
; 0000 0110 
; 0000 0111 	nStart++;   // счетчик перезапусков контроллера
	LDI  R26,LOW(_nStart)
	LDI  R27,HIGH(_nStart)
	CALL __EEPROMRDB
	SUBI R30,-LOW(1)
	CALL __EEPROMWRB
	SUBI R30,LOW(1)
; 0000 0112 
; 0000 0113 #ifdef SIMULATOR
; 0000 0114 	putchar('O'); putchar('K'); putchar(0x0D); // тест USARTа
; 0000 0115 #endif
; 0000 0116 
; 0000 0117 #ifdef LCD
; 0000 0118 	lcd_init(16);
	LDI  R30,LOW(16)
	ST   -Y,R30
	CALL _lcd_init
; 0000 0119 	lcd_puts("Smart Stoker");
	__POINTW1MN _0xA0,0
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
; 0000 011A 	lcd_gotoxy(0, 1);
	CALL SUBOPT_0xE
; 0000 011B 	lcd_puts("v:2.5 Loading...");
	__POINTW1MN _0xA0,13
	ST   -Y,R31
	ST   -Y,R30
	CALL _lcd_puts
; 0000 011C #endif
; 0000 011D 
; 0000 011E #ifdef RTC_DS_3231
; 0000 011F     RTC_init();
; 0000 0120 
; 0000 0121 //настройка даты:
; 0000 0122 //    RTC_write_year23(2018);
; 0000 0123 //    RTC_write_month23(06);
; 0000 0124 //    RTC_write_day23(13);
; 0000 0125 //    RTC_write_wday23(4);
; 0000 0126 //    RTC_Set(RTC_YEAR, 19);
; 0000 0127 
; 0000 0128 //настройка времени:
; 0000 0129 //    RTC_write_hour23(21);
; 0000 012A //    RTC_write_minute23(58);
; 0000 012B //    RTC_write_sec23(30);
; 0000 012C 
; 0000 012D     lcd_gotoxy(0, 1);
; 0000 012E     lcd_puts("i2c ok");
; 0000 012F #endif
; 0000 0130 
; 0000 0131 	#asm("sei") // разрешить прерывания (чтобы таймер работал)
	sei
; 0000 0132 
; 0000 0133 while(1)  // обработка входящих команд
_0xA1:
; 0000 0134  {
; 0000 0135   BufCRC[0] = getchar(); // получен 1 байт
	RCALL _getchar
	STS  _BufCRC,R30
; 0000 0136 
; 0000 0137   switch(BufCRC[0]) // simv
	LDI  R31,0
; 0000 0138   {
; 0000 0139    case 0x01:                       // запрос температуры (отправка данных на ПК), формат: Rx: [CMD]; Tx: [T1][T2][CRC], v2.0 Tx: [T1][T2][T3][PumpState][CRC]
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0xA7
; 0000 013A                                     // или (если int): T1[hiT1][loT1]  T2[hiT2][loT2]
; 0000 013B 	//if (CmdLost(1,10)) { continue; };   // (needReadBytes, TimeOut) пакет потерян, возвращаемся к ожиданию новой команды
; 0000 013C     if(Temperature[0] == -90){tRadiator = -90;}else{tRadiator = Temperature[0];};  // int -> byte(unsigned char)
	CALL SUBOPT_0x15
	BRNE _0xA8
	LDI  R30,LOW(166)
	RJMP _0xF9
_0xA8:
	LDS  R30,_Temperature
_0xF9:
	STS  _tRadiator,R30
; 0000 013D     if(Temperature[1] == -90){tCaldron = -90;}else{tCaldron = Temperature[1];};    // int -> byte
	CALL SUBOPT_0x9
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BRNE _0xAA
	LDI  R30,LOW(166)
	RJMP _0xFA
_0xAA:
	__GETB1MN _Temperature,2
_0xFA:
	STS  _tCaldron,R30
; 0000 013E     //if(Temperature[2] == -90){tOutSide = -90;}else{tOutSide = Temperature[2];};    // int -> byte
; 0000 013F 
; 0000 0140     BufCRC[0] = tRadiator;
	CALL SUBOPT_0x18
; 0000 0141     BufCRC[1] = tCaldron;
; 0000 0142 	//BufCRC[2] = tOutSide;  // внешний датчик
; 0000 0143 	//BufCRC[3] = PORTD.5;   // состояние насоса PORTD.5: 1 - включен; 0 - отключен
; 0000 0144 	//BufCRC[4] = crc8(BufCRC, 5);
; 0000 0145     BufCRC[2] = crc8(BufCRC, 2);
	CALL SUBOPT_0x19
	LDI  R30,LOW(2)
	ST   -Y,R30
	RCALL _crc8
	__PUTB1MN _BufCRC,2
; 0000 0146     for(i=0; i<3; i++){putchar(BufCRC[i]);}
	LDI  R30,LOW(0)
	STS  _i,R30
_0xAD:
	LDS  R26,_i
	CPI  R26,LOW(0x3)
	BRSH _0xAE
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	RJMP _0xAD
_0xAE:
; 0000 0147 
; 0000 0148    break;
	RJMP _0xA6
; 0000 0149 
; 0000 014A    case 0x02:                       // запрос настроек (отправка данных на ПК), формат: Rx: [CMD]; Tx: [MinT][MaxT][MinTCaldron][WorkTime][IdleTime][PulseMode][PumpMode][nStart][CRC]
_0xA7:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BREQ PC+3
	JMP _0xAF
; 0000 014B     BufCRC[0] = MinT;				// температура включения насоса  45 (радиатор)
	LDI  R26,LOW(_MinT)
	LDI  R27,HIGH(_MinT)
	CALL __EEPROMRDB
	STS  _BufCRC,R30
; 0000 014C     BufCRC[1] = MaxT;				// температура отключения насоса 55 (радиатор)
	LDI  R26,LOW(_MaxT)
	LDI  R27,HIGH(_MaxT)
	CALL __EEPROMRDB
	__PUTB1MN _BufCRC,1
; 0000 014D     BufCRC[2] = MinTCaldron;		// минимальная температура воды в котле при котором возможно включение насоса
	LDI  R26,LOW(_MinTCaldron)
	LDI  R27,HIGH(_MinTCaldron)
	CALL __EEPROMRDB
	__PUTB1MN _BufCRC,2
; 0000 014E     BufCRC[3] = WorkTime;			// время работы 5-10 мин
	LDI  R26,LOW(_WorkTime)
	LDI  R27,HIGH(_WorkTime)
	CALL __EEPROMRDB
	__PUTB1MN _BufCRC,3
; 0000 014F     BufCRC[4] = IdleTime;			// время простоя 20-30 мин
	LDI  R26,LOW(_IdleTime)
	LDI  R27,HIGH(_IdleTime)
	CALL __EEPROMRDB
	__PUTB1MN _BufCRC,4
; 0000 0150     BufCRC[5] = StokerMode;			// режим управления
	CALL SUBOPT_0x11
	__PUTB1MN _BufCRC,5
; 0000 0151     BufCRC[6] = 0;					// Резерв - AutoRestoration - автовосстановление
	LDI  R30,LOW(0)
	__PUTB1MN _BufCRC,6
; 0000 0152     BufCRC[7] = nStart;				// счетчик перезапусков контроллера
	LDI  R26,LOW(_nStart)
	LDI  R27,HIGH(_nStart)
	CALL __EEPROMRDB
	__PUTB1MN _BufCRC,7
; 0000 0153     BufCRC[8] = crc8(BufCRC, 8);	// [CRC]
	CALL SUBOPT_0x19
	LDI  R30,LOW(8)
	ST   -Y,R30
	RCALL _crc8
	__PUTB1MN _BufCRC,8
; 0000 0154     for(i=0; i<9; i++){putchar(BufCRC[i]);}
	LDI  R30,LOW(0)
	STS  _i,R30
_0xB1:
	LDS  R26,_i
	CPI  R26,LOW(0x9)
	BRSH _0xB2
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	RJMP _0xB1
_0xB2:
; 0000 0155 
; 0000 0156    break;
	RJMP _0xA6
; 0000 0157 
; 0000 0158    case 0x03:                       // установка настроек (прием данных от ПК), формат: Rx: [CMD] [MinT][MaxT][MinTCaldron][WorkTime][IdleTime][StokerMode][CRC], подтверждение выполнения - 0xAA
_0xAF:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BREQ PC+3
	JMP _0xB3
; 0000 0159 	if (CmdLost(7, 14)) { continue; }; // 8-1											Tx: [0xAA]
	LDI  R30,LOW(7)
	ST   -Y,R30
	LDI  R30,LOW(14)
	ST   -Y,R30
	RCALL _CmdLost
	CPI  R30,0
	BREQ _0xB4
	RJMP _0xA1
_0xB4:
; 0000 015A 
; 0000 015B     for(i=1; i<7; i++) // 6+crc, BufCRC[0] == 0x03;
	LDI  R30,LOW(1)
	STS  _i,R30
_0xB6:
	LDS  R26,_i
	CPI  R26,LOW(0x7)
	BRSH _0xB7
; 0000 015C     {
; 0000 015D      BufCRC[i] = getchar();
	CALL SUBOPT_0x1C
	SUBI R30,LOW(-_BufCRC)
	SBCI R31,HIGH(-_BufCRC)
	PUSH R31
	PUSH R30
	RCALL _getchar
	POP  R26
	POP  R27
	ST   X,R30
; 0000 015E     }
	CALL SUBOPT_0x1B
	RJMP _0xB6
_0xB7:
; 0000 015F 
; 0000 0160     BufCRC[7] = getchar(); // CRC
	RCALL _getchar
	__PUTB1MN _BufCRC,7
; 0000 0161 
; 0000 0162     if(crc8(BufCRC, 7) == BufCRC[7])    // CRC верна в Stoker'e - crc8(Command->SendPacket,7-1); !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL SUBOPT_0x19
	LDI  R30,LOW(7)
	ST   -Y,R30
	RCALL _crc8
	MOV  R26,R30
	__GETB1MN _BufCRC,7
	CP   R30,R26
	BREQ PC+3
	JMP _0xB8
; 0000 0163     {
; 0000 0164      //BufCRC[0] - 0x03 номер команды
; 0000 0165      MinT = BufCRC[1];                  // температура включения насоса  45 (радиатор)
	__GETB1MN _BufCRC,1
	LDI  R26,LOW(_MinT)
	LDI  R27,HIGH(_MinT)
	CALL __EEPROMWRB
; 0000 0166      MaxT = BufCRC[2];                  // температура отключения насоса 55 (радиатор)
	__GETB1MN _BufCRC,2
	LDI  R26,LOW(_MaxT)
	LDI  R27,HIGH(_MaxT)
	CALL __EEPROMWRB
; 0000 0167      MinTCaldron = BufCRC[3];           // минимальная температура воды в котле при котором возможно включение насоса
	__GETB1MN _BufCRC,3
	LDI  R26,LOW(_MinTCaldron)
	LDI  R27,HIGH(_MinTCaldron)
	CALL __EEPROMWRB
; 0000 0168      WorkTime = BufCRC[4];              // время работы 5-10 мин
	__GETB1MN _BufCRC,4
	LDI  R26,LOW(_WorkTime)
	LDI  R27,HIGH(_WorkTime)
	CALL __EEPROMWRB
; 0000 0169      IdleTime = BufCRC[5];              // время простоя 20-30 мин
	__GETB1MN _BufCRC,5
	LDI  R26,LOW(_IdleTime)
	LDI  R27,HIGH(_IdleTime)
	CALL __EEPROMWRB
; 0000 016A      StokerMode = BufCRC[6];            // режим работы (от DS или импульсный)
	__GETB1MN _BufCRC,6
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	CALL SUBOPT_0x12
; 0000 016B 
; 0000 016C      TickCount = 0;                     // обнуление времени работы  ???...
; 0000 016D      //AutoRestoration = BufCRC[];    // автовосстановление
; 0000 016E 
; 0000 016F      switch(StokerMode)
	CALL SUBOPT_0x11
	CALL SUBOPT_0x13
; 0000 0170      {
; 0000 0171       case 0:                            // авто - обновить состояние сигнальных светодиодов
	BRNE _0xBC
; 0000 0172        PORTA.7 = 1;                      // включить индикатор, работа от DS1820
	SBI  0x1B,7
; 0000 0173        PORTA.6 = 0;                      // отключить индикатор
	CBI  0x1B,6
; 0000 0174       break;
	RJMP _0xBB
; 0000 0175 
; 0000 0176       case 1:                            // импульс
_0xBC:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0xC1
; 0000 0177        PORTA.7 = 0;                      // отключить индикатор
	CBI  0x1B,7
; 0000 0178        PORTA.6 = 1;                      // включить индикатор работы импульсного режима
	SBI  0x1B,6
; 0000 0179       break;
	RJMP _0xBB
; 0000 017A 
; 0000 017B       case 2:
_0xC1:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0xC6
; 0000 017C        PORTD.5 = 1;                      // принудительное включение насоса
	SBI  0x12,5
; 0000 017D        PORTA.6 = 1; PORTA.7 = 1;         // горят оба индикатора !!
	SBI  0x1B,6
	SBI  0x1B,7
; 0000 017E       break;
	RJMP _0xBB
; 0000 017F 
; 0000 0180       case 3:
_0xC6:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0xBB
; 0000 0181        PORTD.5 = 0;                      // принудительное отключение насоса
	CBI  0x12,5
; 0000 0182        PORTA.6 = 0; PORTA.7 = 0;         // не горит ни один индикатор !!
	CBI  0x1B,6
	CBI  0x1B,7
; 0000 0183       break;
; 0000 0184      }
_0xBB:
; 0000 0185 
; 0000 0186      putchar(0xAA);                      // OK команда выполнена
	LDI  R30,LOW(170)
	ST   -Y,R30
	RCALL _putchar
; 0000 0187     }
; 0000 0188 
; 0000 0189    break;
_0xB8:
	RJMP _0xA6
; 0000 018A 
; 0000 018B    case 0x04:                       // запрос серийных номеров датчиков DS1820 "SN ds1 и ds2" (отправка данных на ПК), формат: Tx: [ds1_0][ds2_0][ds1_1][ds2_1][ds1_2]... [CRC]
_0xB3:
	CPI  R30,LOW(0x4)
	LDI  R26,HIGH(0x4)
	CPC  R31,R26
	BRNE _0xD4
; 0000 018C 										 //											    									   Rx: [CMD]
; 0000 018D     for(i = 0; i < 8; i++)
	LDI  R30,LOW(0)
	STS  _i,R30
_0xD6:
	LDS  R26,_i
	CPI  R26,LOW(0x8)
	BRSH _0xD7
; 0000 018E     {
; 0000 018F       BufCRC[i+i] = ds1820_sn[0][i];   // [0] - радиатор
	CALL SUBOPT_0x1D
	ADD  R30,R26
	ADC  R31,R27
	SUBI R30,LOW(-_BufCRC)
	SBCI R31,HIGH(-_BufCRC)
	MOVW R26,R30
	CALL SUBOPT_0x1C
	SUBI R30,LOW(-_ds1820_sn)
	SBCI R31,HIGH(-_ds1820_sn)
	LD   R30,Z
	ST   X,R30
; 0000 0190       BufCRC[i+i+1] = ds1820_sn[1][i]; // [1] - котел
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x1E
	MOVW R0,R30
	__POINTW2MN _ds1820_sn,9
	CALL SUBOPT_0x1C
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	MOVW R26,R0
	ST   X,R30
; 0000 0191     }
	CALL SUBOPT_0x1B
	RJMP _0xD6
_0xD7:
; 0000 0192 
; 0000 0193     BufCRC[16] = crc8(BufCRC, 16);
	CALL SUBOPT_0x19
	LDI  R30,LOW(16)
	ST   -Y,R30
	RCALL _crc8
	__PUTB1MN _BufCRC,16
; 0000 0194     for(i=0; i<17; i++){putchar(BufCRC[i]);}
	LDI  R30,LOW(0)
	STS  _i,R30
_0xD9:
	LDS  R26,_i
	CPI  R26,LOW(0x11)
	BRSH _0xDA
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	RJMP _0xD9
_0xDA:
; 0000 0195 
; 0000 0196    break;
	RJMP _0xA6
; 0000 0197 
; 0000 0198    case 0x05:                       // установка серийных номеров датчиков DS1820 "SN ds1 и ds2" (прием данных от ПК), формат: Rx: [CMD] [ds1_0][ds2_0][ds1_1][ds2_1][ds1_2]... [CRC8]
_0xD4:
	CPI  R30,LOW(0x5)
	LDI  R26,HIGH(0x5)
	CPC  R31,R26
	BREQ PC+3
	JMP _0xDB
; 0000 0199 	if (CmdLost(17, 34)) { continue; }; //											    									   Tx: [0xAA]
	LDI  R30,LOW(17)
	ST   -Y,R30
	LDI  R30,LOW(34)
	ST   -Y,R30
	RCALL _CmdLost
	CPI  R30,0
	BREQ _0xDC
	RJMP _0xA1
_0xDC:
; 0000 019A 
; 0000 019B     //BufCRC[0] = 0x05
; 0000 019C 
; 0000 019D     for(i = 0; i < 8; i++)
	LDI  R30,LOW(0)
	STS  _i,R30
_0xDE:
	LDS  R26,_i
	CPI  R26,LOW(0x8)
	BRSH _0xDF
; 0000 019E     {
; 0000 019F      BufCRC[i+i+1] = getchar();   // [0] - радиатор,  ds1820_rom_codes[0][i]
	CALL SUBOPT_0x1D
	CALL SUBOPT_0x1E
	PUSH R31
	PUSH R30
	CALL _getchar
	POP  R26
	POP  R27
	ST   X,R30
; 0000 01A0      BufCRC[i+i+1+1] = getchar(); // [1] - котел,     ds1820_rom_codes[1][i]
	CALL SUBOPT_0x1D
	ADD  R30,R26
	ADC  R31,R27
	__ADDW1MN _BufCRC,2
	PUSH R31
	PUSH R30
	CALL _getchar
	POP  R26
	POP  R27
	ST   X,R30
; 0000 01A1     }
	CALL SUBOPT_0x1B
	RJMP _0xDE
_0xDF:
; 0000 01A2 
; 0000 01A3     BufCRC[17] = getchar(); // CRC !!!
	CALL _getchar
	__PUTB1MN _BufCRC,17
; 0000 01A4 
; 0000 01A5     if(crc8(BufCRC, 17) == BufCRC[17])    // 0x05 + 16 s/s = 17, проверка CRC
	CALL SUBOPT_0x19
	LDI  R30,LOW(17)
	ST   -Y,R30
	RCALL _crc8
	MOV  R26,R30
	__GETB1MN _BufCRC,17
	CP   R30,R26
	BRNE _0xE0
; 0000 01A6     {
; 0000 01A7 
; 0000 01A8     for(i = 0; i < 8; i++)
	LDI  R30,LOW(0)
	STS  _i,R30
_0xE2:
	LDS  R26,_i
	CPI  R26,LOW(0x8)
	BRSH _0xE3
; 0000 01A9     {
; 0000 01AA      ds1820_sn[0][i] = BufCRC[i+i+1];   // [0] - радиатор,  ds1820_rom_codes[0][i]
	CALL SUBOPT_0x1C
	MOVW R22,R30
	SUBI R30,LOW(-_ds1820_sn)
	SBCI R31,HIGH(-_ds1820_sn)
	MOVW R0,R30
	LDS  R26,_i
	CLR  R27
	MOVW R30,R22
	CALL SUBOPT_0x1E
	LD   R30,Z
	MOVW R26,R0
	ST   X,R30
; 0000 01AB      ds1820_sn[1][i] = BufCRC[i+i+1+1]; // [1] - котел,     ds1820_rom_codes[1][i]
	__POINTW2MN _ds1820_sn,9
	CALL SUBOPT_0x1C
	ADD  R30,R26
	ADC  R31,R27
	MOVW R0,R30
	CALL SUBOPT_0x1D
	ADD  R30,R26
	ADC  R31,R27
	__ADDW1MN _BufCRC,2
	LD   R30,Z
	MOVW R26,R0
	ST   X,R30
; 0000 01AC     }
	CALL SUBOPT_0x1B
	RJMP _0xE2
_0xE3:
; 0000 01AD 
; 0000 01AE      sncpy(ds1820_sn[0],ds1820_rom_codes[0]); // пересохранить из flash в еепром
	CALL SUBOPT_0x17
; 0000 01AF      sncpy(ds1820_sn[1],ds1820_rom_codes[1]); // пересохранить из flash в еепром
; 0000 01B0      putchar(0xAA);                           // OK команда выполнена
	LDI  R30,LOW(170)
	ST   -Y,R30
	RCALL _putchar
; 0000 01B1     }
; 0000 01B2 
; 0000 01B3    break;
_0xE0:
	RJMP _0xA6
; 0000 01B4 
; 0000 01B5    case 0x06:                       // сброс счетчика перезапусков контроллера (прием данных от ПК), формат: Rx: [0x06], Tx: [0xAA]
_0xDB:
	CPI  R30,LOW(0x6)
	LDI  R26,HIGH(0x6)
	CPC  R31,R26
	BRNE _0xE4
; 0000 01B6     nStart = 0;
	LDI  R26,LOW(_nStart)
	LDI  R27,HIGH(_nStart)
	LDI  R30,LOW(0)
	CALL __EEPROMWRB
; 0000 01B7     putchar(0xAA);                  // OK команда выполнена
	LDI  R30,LOW(170)
	RJMP _0xFB
; 0000 01B8    break;
; 0000 01B9 
; 0000 01BA    case 0x07:                     // GetState
_0xE4:
	CPI  R30,LOW(0x7)
	LDI  R26,HIGH(0x7)
	CPC  R31,R26
	BREQ PC+3
	JMP _0xE5
; 0000 01BB                                   // запрос температуры (отправка данных на ПК), формат: Rx: [CMD]; Tx: [T1][T2][T3][PumpState][CRC]
; 0000 01BC                                   // или (если int): T1[hiT1][loT1]  T2[hiT2][loT2]
; 0000 01BD     if(Temperature[0] == -90){tRadiator = -90;}else{tRadiator = Temperature[0];};  // int -> byte(unsigned char)
	CALL SUBOPT_0x15
	BRNE _0xE6
	LDI  R30,LOW(166)
	RJMP _0xFC
_0xE6:
	LDS  R30,_Temperature
_0xFC:
	STS  _tRadiator,R30
; 0000 01BE     if(Temperature[1] == -90){tCaldron = -90;}else{tCaldron = Temperature[1];};    // int -> byte
	CALL SUBOPT_0x9
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BRNE _0xE8
	LDI  R30,LOW(166)
	RJMP _0xFD
_0xE8:
	__GETB1MN _Temperature,2
_0xFD:
	STS  _tCaldron,R30
; 0000 01BF     if(Temperature[2] == -90){tOutSide = -90;}else{tOutSide = Temperature[2];};    // int -> byte
	CALL SUBOPT_0xF
	CPI  R30,LOW(0xFFA6)
	LDI  R26,HIGH(0xFFA6)
	CPC  R31,R26
	BRNE _0xEA
	LDI  R30,LOW(166)
	RJMP _0xFE
_0xEA:
	__GETB1MN _Temperature,4
_0xFE:
	STS  _tOutSide,R30
; 0000 01C0 
; 0000 01C1     BufCRC[0] = tRadiator;
	CALL SUBOPT_0x18
; 0000 01C2     BufCRC[1] = tCaldron;
; 0000 01C3 	BufCRC[2] = tOutSide;  // внешний датчик
	LDS  R30,_tOutSide
	__PUTB1MN _BufCRC,2
; 0000 01C4 	BufCRC[3] = PORTD.5;   // состояние насоса PORTD.5: 1 - включен; 0 - отключен
	LDI  R30,0
	SBIC 0x12,5
	LDI  R30,1
	__PUTB1MN _BufCRC,3
; 0000 01C5 	BufCRC[4] = crc8(BufCRC, 4);
	CALL SUBOPT_0x19
	LDI  R30,LOW(4)
	ST   -Y,R30
	RCALL _crc8
	__PUTB1MN _BufCRC,4
; 0000 01C6     for(i=0; i<5; i++){putchar(BufCRC[i]);}
	LDI  R30,LOW(0)
	STS  _i,R30
_0xED:
	LDS  R26,_i
	CPI  R26,LOW(0x5)
	BRSH _0xEE
	CALL SUBOPT_0x1A
	CALL SUBOPT_0x1B
	RJMP _0xED
_0xEE:
; 0000 01C7 
; 0000 01C8    break;
	RJMP _0xA6
; 0000 01C9 
; 0000 01CA    //case 0x08:                     // резерв
; 0000 01CB    //break;
; 0000 01CC 
; 0000 01CD    case 0x09:						// проверка связи
_0xE5:
	CPI  R30,LOW(0x9)
	LDI  R26,HIGH(0x9)
	CPC  R31,R26
	BRNE _0xA6
; 0000 01CE    putchar('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	CALL _putchar
; 0000 01CF    putchar('S');
	LDI  R30,LOW(83)
	ST   -Y,R30
	CALL _putchar
; 0000 01D0    putchar('M');
	LDI  R30,LOW(77)
	ST   -Y,R30
	CALL _putchar
; 0000 01D1    putchar('A');
	LDI  R30,LOW(65)
	ST   -Y,R30
	CALL _putchar
; 0000 01D2    putchar('R');
	LDI  R30,LOW(82)
	ST   -Y,R30
	CALL _putchar
; 0000 01D3    putchar('T');
	LDI  R30,LOW(84)
	ST   -Y,R30
	CALL _putchar
; 0000 01D4    putchar('=');
	LDI  R30,LOW(61)
	ST   -Y,R30
	CALL _putchar
; 0000 01D5    putchar('D');
	LDI  R30,LOW(68)
	CALL SUBOPT_0x1F
; 0000 01D6    putchar('E');
; 0000 01D7    putchar('V');
	LDI  R30,LOW(86)
	ST   -Y,R30
	CALL _putchar
; 0000 01D8    putchar('I');
	LDI  R30,LOW(73)
	ST   -Y,R30
	CALL _putchar
; 0000 01D9    putchar('C');
	LDI  R30,LOW(67)
	CALL SUBOPT_0x1F
; 0000 01DA    putchar('E');
; 0000 01DB    putchar('=');
	LDI  R30,LOW(61)
_0xFB:
	ST   -Y,R30
	CALL _putchar
; 0000 01DC    // =SMART-DEVICE=                // тест связи
; 0000 01DD    break;
; 0000 01DE 
; 0000 01DF   #ifdef SAVETEMPER
; 0000 01E0    case 0x0A:
; 0000 01E1     SendTemper(0);  // получение температуры (отправка данных на ПК) без-CRC ds1
; 0000 01E2    break;
; 0000 01E3   #endif
; 0000 01E4 
; 0000 01E5    //case 0xFF:                // ......  расширенные команды
; 0000 01E6    // simv = getchar();
; 0000 01E7    // switch(simv){case 0x01: /*команда*/ break; ...}
; 0000 01E8    //break;
; 0000 01E9 
; 0000 01EA    //------------------------------------------------------------------------------------------------
; 0000 01EB   };
_0xA6:
; 0000 01EC 
; 0000 01ED   //putchar(0x0D); // CR конец приема/передачи
; 0000 01EE  } // \while(1)
	RJMP _0xA1
; 0000 01EF 
; 0000 01F0 }
_0xF0:
	RJMP _0xF0

	.DSEG
_0xA0:
	.BYTE 0x1E
;/* please read copyright-notice at EOF */
;
;//#include <inttypes.h>
;typedef unsigned char uint8_t;  // 8
;typedef unsigned char uint16_t; // 16 !!!!!!
;
;#define CRC8INIT	0x00
;#define CRC8POLY	0x18              //0X18 = X^8+X^5+X^4+X^0
;
;
;
; uint8_t crc8 ( uint8_t *data_in, uint16_t number_of_bytes_to_read )
; 0001 000D  {

	.CSEG
_crc8:
; 0001 000E    uint8_t	 crc;
; 0001 000F    uint16_t loop_count;
; 0001 0010    uint8_t  bit_counter;
; 0001 0011    uint8_t  data;
; 0001 0012    uint8_t  feedback_bit;
; 0001 0013 
; 0001 0014    crc = CRC8INIT;
	CALL __SAVELOCR5
;	*data_in -> Y+6
;	number_of_bytes_to_read -> Y+5
;	crc -> R16
;	loop_count -> R17
;	bit_counter -> R18
;	data -> R19
;	feedback_bit -> R20
	LDI  R16,LOW(0)
; 0001 0015 
; 0001 0016    for (loop_count = 0; loop_count != number_of_bytes_to_read; loop_count++)
	LDI  R17,LOW(0)
_0x20004:
	LDD  R30,Y+5
	CP   R30,R17
	BREQ _0x20005
; 0001 0017     { data = data_in[loop_count];
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	CLR  R30
	ADD  R26,R17
	ADC  R27,R30
	LD   R19,X
; 0001 0018 
; 0001 0019       bit_counter = 8;
	LDI  R18,LOW(8)
; 0001 001A       do
_0x20007:
; 0001 001B        { feedback_bit = (crc ^ data) & 0x01;
	MOV  R30,R19
	EOR  R30,R16
	ANDI R30,LOW(0x1)
	MOV  R20,R30
; 0001 001C          if ( feedback_bit == 0x01 )
	CPI  R20,1
	BRNE _0x20009
; 0001 001D             crc = crc ^ CRC8POLY;
	LDI  R30,LOW(24)
	EOR  R16,R30
; 0001 001E 
; 0001 001F          crc = (crc >> 1) & 0x7F;
_0x20009:
	MOV  R30,R16
	LDI  R31,0
	ASR  R31
	ROR  R30
	ANDI R30,LOW(0x7F)
	ANDI R31,HIGH(0x7F)
	MOV  R16,R30
; 0001 0020          if ( feedback_bit == 0x01 )
	CPI  R20,1
	BRNE _0x2000A
; 0001 0021             crc = crc | 0x80;
	ORI  R16,LOW(128)
; 0001 0022 
; 0001 0023          data = data >> 1;
_0x2000A:
	MOV  R30,R19
	LDI  R31,0
	ASR  R31
	ROR  R30
	MOV  R19,R30
; 0001 0024          bit_counter--;
	SUBI R18,1
; 0001 0025        }
; 0001 0026       while (bit_counter > 0);
	CPI  R18,1
	BRSH _0x20007
; 0001 0027     }
	SUBI R17,-1
	RJMP _0x20004
_0x20005:
; 0001 0028    return crc;
	MOV  R30,R16
	CALL __LOADLOCR5
	ADIW R28,8
	RET
; 0001 0029  }
;
;
;
;/*
;This code is from Colin O'Flynn - Copyright (c) 2002
;only minor changes by M.Thomas 9/2004
;
;Permission is hereby granted, free of charge, to any person obtaining a copy of
;this software and associated documentation files (the "Software"), to deal in
;the Software without restriction, including without limitation the rights to
;use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
;the Software, and to permit persons to whom the Software is furnished to do so,
;subject to the following conditions:
;
;The above copyright notice and this permission notice shall be included in all
;copies or substantial portions of the Software.
;
;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
;FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
;COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
;IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;*/

	.CSEG
_ds1820_select:
	ST   -Y,R16
	CALL _w1_init
	CPI  R30,0
	BRNE _0x2000003
	LDI  R30,LOW(0)
	RJMP _0x2120004
_0x2000003:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,0
	BREQ _0x2000004
	LDI  R30,LOW(85)
	CALL SUBOPT_0x20
_0x2000006:
	CALL SUBOPT_0x21
	SUBI R16,-LOW(1)
	CPI  R16,8
	BRLO _0x2000006
	RJMP _0x2000008
_0x2000004:
	LDI  R30,LOW(204)
	ST   -Y,R30
	CALL _w1_write
_0x2000008:
	LDI  R30,LOW(1)
	RJMP _0x2120004
_ds1820_read_spd:
	CALL SUBOPT_0x22
	RCALL _ds1820_select
	CPI  R30,0
	BRNE _0x2000009
	LDI  R30,LOW(0)
	CALL __LOADLOCR3
	JMP  _0x2120002
_0x2000009:
	LDI  R30,LOW(190)
	CALL SUBOPT_0x20
	__POINTWRM 17,18,___ds1820_scratch_pad
_0x200000B:
	PUSH R18
	PUSH R17
	__ADDWRN 17,18,1
	CALL _w1_read
	POP  R26
	POP  R27
	ST   X,R30
	SUBI R16,-LOW(1)
	CPI  R16,9
	BRLO _0x200000B
	LDI  R30,LOW(___ds1820_scratch_pad)
	LDI  R31,HIGH(___ds1820_scratch_pad)
	CALL SUBOPT_0x23
	JMP  _0x2120002
_ds1820_temperature_10:
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	RCALL _ds1820_select
	CPI  R30,0
	BRNE _0x200000D
	LDI  R30,LOW(55537)
	LDI  R31,HIGH(55537)
	RJMP _0x2120005
_0x200000D:
	LDI  R30,LOW(68)
	ST   -Y,R30
	CALL _w1_write
	LDI  R30,LOW(550)
	LDI  R31,HIGH(550)
	CALL SUBOPT_0x2
	LD   R30,Y
	LDD  R31,Y+1
	ST   -Y,R31
	ST   -Y,R30
	RCALL _ds1820_read_spd
	CPI  R30,0
	BRNE _0x200000E
	LDI  R30,LOW(55537)
	LDI  R31,HIGH(55537)
	RJMP _0x2120005
_0x200000E:
	CALL _w1_init
	__GETB1HMN ___ds1820_scratch_pad,1
	LDI  R30,LOW(0)
	MOVW R26,R30
	LDS  R30,___ds1820_scratch_pad
	LDI  R31,0
	OR   R30,R26
	OR   R31,R27
	LDI  R26,LOW(5)
	LDI  R27,HIGH(5)
	CALL __MULW12
	RJMP _0x2120005

	.CSEG
_ds18b20_select:
	ST   -Y,R16
	CALL _w1_init
	CPI  R30,0
	BRNE _0x2020003
	LDI  R30,LOW(0)
	RJMP _0x2120004
_0x2020003:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	SBIW R30,0
	BREQ _0x2020004
	LDI  R30,LOW(85)
	CALL SUBOPT_0x20
_0x2020006:
	CALL SUBOPT_0x21
	SUBI R16,-LOW(1)
	CPI  R16,8
	BRLO _0x2020006
	RJMP _0x2020008
_0x2020004:
	LDI  R30,LOW(204)
	ST   -Y,R30
	CALL _w1_write
_0x2020008:
	LDI  R30,LOW(1)
	RJMP _0x2120004
_ds18b20_read_spd:
	CALL SUBOPT_0x22
	RCALL _ds18b20_select
	CPI  R30,0
	BRNE _0x2020009
	LDI  R30,LOW(0)
	CALL __LOADLOCR3
	JMP  _0x2120002
_0x2020009:
	LDI  R30,LOW(190)
	CALL SUBOPT_0x20
	__POINTWRM 17,18,___ds18b20_scratch_pad
_0x202000B:
	PUSH R18
	PUSH R17
	__ADDWRN 17,18,1
	CALL _w1_read
	POP  R26
	POP  R27
	ST   X,R30
	SUBI R16,-LOW(1)
	CPI  R16,9
	BRLO _0x202000B
	LDI  R30,LOW(___ds18b20_scratch_pad)
	LDI  R31,HIGH(___ds18b20_scratch_pad)
	CALL SUBOPT_0x23
	JMP  _0x2120002
_ds18b20_temperature:
	ST   -Y,R16
	CALL SUBOPT_0x24
	RCALL _ds18b20_read_spd
	CPI  R30,0
	BRNE _0x202000D
	CALL SUBOPT_0x25
	RJMP _0x2120004
_0x202000D:
	__GETB2MN ___ds18b20_scratch_pad,4
	LDI  R27,0
	LDI  R30,LOW(5)
	CALL __ASRW12
	ANDI R30,LOW(0x3)
	MOV  R16,R30
	CALL SUBOPT_0x24
	RCALL _ds18b20_select
	CPI  R30,0
	BRNE _0x202000E
	CALL SUBOPT_0x25
	RJMP _0x2120004
_0x202000E:
	LDI  R30,LOW(68)
	ST   -Y,R30
	CALL _w1_write
	MOV  R30,R16
	LDI  R26,LOW(_conv_delay_G101*2)
	LDI  R27,HIGH(_conv_delay_G101*2)
	CALL SUBOPT_0x7
	ADD  R30,R26
	ADC  R31,R27
	CALL __GETW1PF
	CALL SUBOPT_0x2
	CALL SUBOPT_0x24
	RCALL _ds18b20_read_spd
	CPI  R30,0
	BRNE _0x202000F
	CALL SUBOPT_0x25
	RJMP _0x2120004
_0x202000F:
	CALL _w1_init
	MOV  R30,R16
	LDI  R26,LOW(_bit_mask_G101*2)
	LDI  R27,HIGH(_bit_mask_G101*2)
	CALL SUBOPT_0x7
	ADD  R30,R26
	ADC  R31,R27
	CALL __GETW1PF
	LDS  R26,___ds18b20_scratch_pad
	LDS  R27,___ds18b20_scratch_pad+1
	AND  R30,R26
	AND  R31,R27
	CALL __CWD1
	CALL __CDF1
	__GETD2N 0x3D800000
	CALL __MULF12
	RJMP _0x2120004

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.DSEG

	.CSEG
__lcd_write_nibble_G103:
	LD   R30,Y
	ANDI R30,LOW(0x10)
	BREQ _0x2060004
	SBI  0x18,4
	RJMP _0x2060005
_0x2060004:
	CBI  0x18,4
_0x2060005:
	LD   R30,Y
	ANDI R30,LOW(0x20)
	BREQ _0x2060006
	SBI  0x18,5
	RJMP _0x2060007
_0x2060006:
	CBI  0x18,5
_0x2060007:
	LD   R30,Y
	ANDI R30,LOW(0x40)
	BREQ _0x2060008
	SBI  0x18,6
	RJMP _0x2060009
_0x2060008:
	CBI  0x18,6
_0x2060009:
	LD   R30,Y
	ANDI R30,LOW(0x80)
	BREQ _0x206000A
	SBI  0x18,7
	RJMP _0x206000B
_0x206000A:
	CBI  0x18,7
_0x206000B:
	__DELAY_USB 5
	SBI  0x18,2
	__DELAY_USB 13
	CBI  0x18,2
	__DELAY_USB 13
	RJMP _0x2120003
__lcd_write_data:
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_nibble_G103
    ld    r30,y
    swap  r30
    st    y,r30
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_nibble_G103
	__DELAY_USB 133
	RJMP _0x2120003
_lcd_gotoxy:
	LD   R30,Y
	LDI  R31,0
	SUBI R30,LOW(-__base_y_G103)
	SBCI R31,HIGH(-__base_y_G103)
	LD   R30,Z
	LDD  R26,Y+1
	ADD  R30,R26
	ST   -Y,R30
	RCALL __lcd_write_data
	LDD  R30,Y+1
	STS  __lcd_x,R30
	LD   R30,Y
	STS  __lcd_y,R30
_0x2120005:
	ADIW R28,2
	RET
_lcd_clear:
	LDI  R30,LOW(2)
	CALL SUBOPT_0x26
	LDI  R30,LOW(12)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(1)
	CALL SUBOPT_0x26
	LDI  R30,LOW(0)
	STS  __lcd_y,R30
	STS  __lcd_x,R30
	RET
_lcd_putchar:
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BREQ _0x2060011
	LDS  R30,__lcd_maxx
	LDS  R26,__lcd_x
	CP   R26,R30
	BRLO _0x2060010
_0x2060011:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDS  R30,__lcd_y
	SUBI R30,-LOW(1)
	STS  __lcd_y,R30
	ST   -Y,R30
	RCALL _lcd_gotoxy
	LD   R26,Y
	CPI  R26,LOW(0xA)
	BRNE _0x2060013
	RJMP _0x2120003
_0x2060013:
_0x2060010:
	LDS  R30,__lcd_x
	SUBI R30,-LOW(1)
	STS  __lcd_x,R30
	SBI  0x18,0
	LD   R30,Y
	ST   -Y,R30
	RCALL __lcd_write_data
	CBI  0x18,0
	RJMP _0x2120003
_lcd_puts:
	ST   -Y,R16
_0x2060014:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	MOV  R16,R30
	CPI  R30,0
	BREQ _0x2060016
	ST   -Y,R16
	RCALL _lcd_putchar
	RJMP _0x2060014
_0x2060016:
_0x2120004:
	LDD  R16,Y+0
	ADIW R28,3
	RET
_lcd_init:
	SBI  0x17,4
	SBI  0x17,5
	SBI  0x17,6
	SBI  0x17,7
	SBI  0x17,2
	SBI  0x17,0
	SBI  0x17,1
	CBI  0x18,2
	CBI  0x18,0
	CBI  0x18,1
	LD   R30,Y
	STS  __lcd_maxx,R30
	SUBI R30,-LOW(128)
	__PUTB1MN __base_y_G103,2
	LD   R30,Y
	SUBI R30,-LOW(192)
	__PUTB1MN __base_y_G103,3
	LDI  R30,LOW(20)
	LDI  R31,HIGH(20)
	CALL SUBOPT_0x2
	CALL SUBOPT_0x27
	CALL SUBOPT_0x27
	CALL SUBOPT_0x27
	LDI  R30,LOW(32)
	ST   -Y,R30
	RCALL __lcd_write_nibble_G103
	__DELAY_USW 200
	LDI  R30,LOW(40)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(4)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(133)
	ST   -Y,R30
	RCALL __lcd_write_data
	LDI  R30,LOW(6)
	ST   -Y,R30
	RCALL __lcd_write_data
	RCALL _lcd_clear
_0x2120003:
	ADIW R28,1
	RET

	.CSEG
_abs:
    ld   r30,y+
    ld   r31,y+
    sbiw r30,0
    brpl __abs0
    com  r30
    com  r31
    adiw r30,1
__abs0:
    ret

	.DSEG

	.CSEG
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x80
	.EQU __sm_mask=0x70
	.EQU __sm_powerdown=0x20
	.EQU __sm_powersave=0x30
	.EQU __sm_standby=0x60
	.EQU __sm_ext_standby=0x70
	.EQU __sm_adc_noise_red=0x10
	.SET power_ctrl_reg=mcucr
	#endif

	.CSEG
_put_buff_G105:
	ST   -Y,R17
	ST   -Y,R16
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	CALL __GETW1P
	SBIW R30,0
	BREQ _0x20A0010
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,4
	CALL __GETW1P
	MOVW R16,R30
	SBIW R30,0
	BREQ _0x20A0012
	__CPWRN 16,17,2
	BRLO _0x20A0013
	MOVW R30,R16
	SBIW R30,1
	MOVW R16,R30
	__PUTW1SNS 2,4
_0x20A0012:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	ADIW R26,2
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
	SBIW R30,1
	LDD  R26,Y+4
	STD  Z+0,R26
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	CALL __GETW1P
	TST  R31
	BRMI _0x20A0014
	LD   R30,X+
	LD   R31,X+
	ADIW R30,1
	ST   -X,R31
	ST   -X,R30
_0x20A0014:
_0x20A0013:
	RJMP _0x20A0015
_0x20A0010:
	LDD  R26,Y+2
	LDD  R27,Y+2+1
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	ST   X+,R30
	ST   X,R31
_0x20A0015:
	LDD  R17,Y+1
	LDD  R16,Y+0
_0x2120002:
	ADIW R28,5
	RET
__print_G105:
	SBIW R28,6
	CALL __SAVELOCR6
	LDI  R16,0
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	ST   X+,R30
	ST   X,R31
_0x20A0016:
	LDD  R30,Y+18
	LDD  R31,Y+18+1
	ADIW R30,1
	STD  Y+18,R30
	STD  Y+18+1,R31
	SBIW R30,1
	LPM  R30,Z
	MOV  R19,R30
	CPI  R30,0
	BRNE PC+3
	JMP _0x20A0018
	MOV  R30,R16
	CPI  R30,0
	BRNE _0x20A001C
	CPI  R19,37
	BRNE _0x20A001D
	LDI  R16,LOW(1)
	RJMP _0x20A001E
_0x20A001D:
	CALL SUBOPT_0x28
_0x20A001E:
	RJMP _0x20A001B
_0x20A001C:
	CPI  R30,LOW(0x1)
	BRNE _0x20A001F
	CPI  R19,37
	BRNE _0x20A0020
	CALL SUBOPT_0x28
	RJMP _0x20A00C9
_0x20A0020:
	LDI  R16,LOW(2)
	LDI  R21,LOW(0)
	LDI  R17,LOW(0)
	CPI  R19,45
	BRNE _0x20A0021
	LDI  R17,LOW(1)
	RJMP _0x20A001B
_0x20A0021:
	CPI  R19,43
	BRNE _0x20A0022
	LDI  R21,LOW(43)
	RJMP _0x20A001B
_0x20A0022:
	CPI  R19,32
	BRNE _0x20A0023
	LDI  R21,LOW(32)
	RJMP _0x20A001B
_0x20A0023:
	RJMP _0x20A0024
_0x20A001F:
	CPI  R30,LOW(0x2)
	BRNE _0x20A0025
_0x20A0024:
	LDI  R20,LOW(0)
	LDI  R16,LOW(3)
	CPI  R19,48
	BRNE _0x20A0026
	ORI  R17,LOW(128)
	RJMP _0x20A001B
_0x20A0026:
	RJMP _0x20A0027
_0x20A0025:
	CPI  R30,LOW(0x3)
	BREQ PC+3
	JMP _0x20A001B
_0x20A0027:
	CPI  R19,48
	BRLO _0x20A002A
	CPI  R19,58
	BRLO _0x20A002B
_0x20A002A:
	RJMP _0x20A0029
_0x20A002B:
	LDI  R26,LOW(10)
	MUL  R20,R26
	MOV  R20,R0
	MOV  R30,R19
	SUBI R30,LOW(48)
	ADD  R20,R30
	RJMP _0x20A001B
_0x20A0029:
	MOV  R30,R19
	CPI  R30,LOW(0x63)
	BRNE _0x20A002F
	CALL SUBOPT_0x29
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	LDD  R26,Z+4
	ST   -Y,R26
	CALL SUBOPT_0x2A
	RJMP _0x20A0030
_0x20A002F:
	CPI  R30,LOW(0x73)
	BRNE _0x20A0032
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2B
	CALL _strlen
	MOV  R16,R30
	RJMP _0x20A0033
_0x20A0032:
	CPI  R30,LOW(0x70)
	BRNE _0x20A0035
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2B
	CALL _strlenf
	MOV  R16,R30
	ORI  R17,LOW(8)
_0x20A0033:
	ORI  R17,LOW(2)
	ANDI R17,LOW(127)
	LDI  R18,LOW(0)
	RJMP _0x20A0036
_0x20A0035:
	CPI  R30,LOW(0x64)
	BREQ _0x20A0039
	CPI  R30,LOW(0x69)
	BRNE _0x20A003A
_0x20A0039:
	ORI  R17,LOW(4)
	RJMP _0x20A003B
_0x20A003A:
	CPI  R30,LOW(0x75)
	BRNE _0x20A003C
_0x20A003B:
	LDI  R30,LOW(_tbl10_G105*2)
	LDI  R31,HIGH(_tbl10_G105*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R16,LOW(5)
	RJMP _0x20A003D
_0x20A003C:
	CPI  R30,LOW(0x58)
	BRNE _0x20A003F
	ORI  R17,LOW(8)
	RJMP _0x20A0040
_0x20A003F:
	CPI  R30,LOW(0x78)
	BREQ PC+3
	JMP _0x20A0071
_0x20A0040:
	LDI  R30,LOW(_tbl16_G105*2)
	LDI  R31,HIGH(_tbl16_G105*2)
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R16,LOW(4)
_0x20A003D:
	SBRS R17,2
	RJMP _0x20A0042
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2C
	LDD  R26,Y+11
	TST  R26
	BRPL _0x20A0043
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	CALL __ANEGW1
	STD  Y+10,R30
	STD  Y+10+1,R31
	LDI  R21,LOW(45)
_0x20A0043:
	CPI  R21,0
	BREQ _0x20A0044
	SUBI R16,-LOW(1)
	RJMP _0x20A0045
_0x20A0044:
	ANDI R17,LOW(251)
_0x20A0045:
	RJMP _0x20A0046
_0x20A0042:
	CALL SUBOPT_0x29
	CALL SUBOPT_0x2C
_0x20A0046:
_0x20A0036:
	SBRC R17,0
	RJMP _0x20A0047
_0x20A0048:
	CP   R16,R20
	BRSH _0x20A004A
	SBRS R17,7
	RJMP _0x20A004B
	SBRS R17,2
	RJMP _0x20A004C
	ANDI R17,LOW(251)
	MOV  R19,R21
	SUBI R16,LOW(1)
	RJMP _0x20A004D
_0x20A004C:
	LDI  R19,LOW(48)
_0x20A004D:
	RJMP _0x20A004E
_0x20A004B:
	LDI  R19,LOW(32)
_0x20A004E:
	CALL SUBOPT_0x28
	SUBI R20,LOW(1)
	RJMP _0x20A0048
_0x20A004A:
_0x20A0047:
	MOV  R18,R16
	SBRS R17,1
	RJMP _0x20A004F
_0x20A0050:
	CPI  R18,0
	BREQ _0x20A0052
	SBRS R17,3
	RJMP _0x20A0053
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	LPM  R19,Z+
	STD  Y+6,R30
	STD  Y+6+1,R31
	RJMP _0x20A0054
_0x20A0053:
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LD   R19,X+
	STD  Y+6,R26
	STD  Y+6+1,R27
_0x20A0054:
	CALL SUBOPT_0x28
	CPI  R20,0
	BREQ _0x20A0055
	SUBI R20,LOW(1)
_0x20A0055:
	SUBI R18,LOW(1)
	RJMP _0x20A0050
_0x20A0052:
	RJMP _0x20A0056
_0x20A004F:
_0x20A0058:
	LDI  R19,LOW(48)
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	CALL __GETW1PF
	STD  Y+8,R30
	STD  Y+8+1,R31
	LDD  R30,Y+6
	LDD  R31,Y+6+1
	ADIW R30,2
	STD  Y+6,R30
	STD  Y+6+1,R31
_0x20A005A:
	LDD  R30,Y+8
	LDD  R31,Y+8+1
	LDD  R26,Y+10
	LDD  R27,Y+10+1
	CP   R26,R30
	CPC  R27,R31
	BRLO _0x20A005C
	SUBI R19,-LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	LDD  R30,Y+10
	LDD  R31,Y+10+1
	SUB  R30,R26
	SBC  R31,R27
	STD  Y+10,R30
	STD  Y+10+1,R31
	RJMP _0x20A005A
_0x20A005C:
	CPI  R19,58
	BRLO _0x20A005D
	SBRS R17,3
	RJMP _0x20A005E
	SUBI R19,-LOW(7)
	RJMP _0x20A005F
_0x20A005E:
	SUBI R19,-LOW(39)
_0x20A005F:
_0x20A005D:
	SBRC R17,4
	RJMP _0x20A0061
	CPI  R19,49
	BRSH _0x20A0063
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,1
	BRNE _0x20A0062
_0x20A0063:
	RJMP _0x20A00CA
_0x20A0062:
	CP   R20,R18
	BRLO _0x20A0067
	SBRS R17,0
	RJMP _0x20A0068
_0x20A0067:
	RJMP _0x20A0066
_0x20A0068:
	LDI  R19,LOW(32)
	SBRS R17,7
	RJMP _0x20A0069
	LDI  R19,LOW(48)
_0x20A00CA:
	ORI  R17,LOW(16)
	SBRS R17,2
	RJMP _0x20A006A
	ANDI R17,LOW(251)
	ST   -Y,R21
	CALL SUBOPT_0x2A
	CPI  R20,0
	BREQ _0x20A006B
	SUBI R20,LOW(1)
_0x20A006B:
_0x20A006A:
_0x20A0069:
_0x20A0061:
	CALL SUBOPT_0x28
	CPI  R20,0
	BREQ _0x20A006C
	SUBI R20,LOW(1)
_0x20A006C:
_0x20A0066:
	SUBI R18,LOW(1)
	LDD  R26,Y+8
	LDD  R27,Y+8+1
	SBIW R26,2
	BRLO _0x20A0059
	RJMP _0x20A0058
_0x20A0059:
_0x20A0056:
	SBRS R17,0
	RJMP _0x20A006D
_0x20A006E:
	CPI  R20,0
	BREQ _0x20A0070
	SUBI R20,LOW(1)
	LDI  R30,LOW(32)
	ST   -Y,R30
	CALL SUBOPT_0x2A
	RJMP _0x20A006E
_0x20A0070:
_0x20A006D:
_0x20A0071:
_0x20A0030:
_0x20A00C9:
	LDI  R16,LOW(0)
_0x20A001B:
	RJMP _0x20A0016
_0x20A0018:
	LDD  R26,Y+12
	LDD  R27,Y+12+1
	CALL __GETW1P
	CALL __LOADLOCR6
	ADIW R28,20
	RET
_sprintf:
	PUSH R15
	MOV  R15,R24
	SBIW R28,6
	CALL __SAVELOCR4
	CALL SUBOPT_0x2D
	SBIW R30,0
	BRNE _0x20A0072
	LDI  R30,LOW(65535)
	LDI  R31,HIGH(65535)
	RJMP _0x2120001
_0x20A0072:
	MOVW R26,R28
	ADIW R26,6
	CALL __ADDW2R15
	MOVW R16,R26
	CALL SUBOPT_0x2D
	STD  Y+6,R30
	STD  Y+6+1,R31
	LDI  R30,LOW(0)
	STD  Y+8,R30
	STD  Y+8+1,R30
	MOVW R26,R28
	ADIW R26,10
	CALL __ADDW2R15
	CALL __GETW1P
	ST   -Y,R31
	ST   -Y,R30
	ST   -Y,R17
	ST   -Y,R16
	LDI  R30,LOW(_put_buff_G105)
	LDI  R31,HIGH(_put_buff_G105)
	ST   -Y,R31
	ST   -Y,R30
	MOVW R30,R28
	ADIW R30,10
	ST   -Y,R31
	ST   -Y,R30
	RCALL __print_G105
	MOVW R18,R30
	LDD  R26,Y+6
	LDD  R27,Y+6+1
	LDI  R30,LOW(0)
	ST   X,R30
	MOVW R30,R18
_0x2120001:
	CALL __LOADLOCR4
	ADIW R28,10
	POP  R15
	RET

	.CSEG

	.CSEG

	.CSEG
_strlen:
    ld   r26,y+
    ld   r27,y+
    clr  r30
    clr  r31
strlen0:
    ld   r22,x+
    tst  r22
    breq strlen1
    adiw r30,1
    rjmp strlen0
strlen1:
    ret
_strlenf:
    clr  r26
    clr  r27
    ld   r30,y+
    ld   r31,y+
strlenf0:
	lpm  r0,z+
    tst  r0
    breq strlenf1
    adiw r26,1
    rjmp strlenf0
strlenf1:
    movw r30,r26
    ret

	.DSEG
___ds1820_scratch_pad:
	.BYTE 0x9
___ds18b20_scratch_pad:
	.BYTE 0x9

	.ESEG
_ds1820_rom_codes:
	.DB  LOW(0x2FE0FF28),HIGH(0x2FE0FF28),BYTE3(0x2FE0FF28),BYTE4(0x2FE0FF28)
	.DB  LOW(0xA1031590),HIGH(0xA1031590),BYTE3(0xA1031590),BYTE4(0xA1031590)
	.DB  LOW(0xBFF2800),HIGH(0xBFF2800),BYTE3(0xBFF2800),BYTE4(0xBFF2800)
	.DB  LOW(0x1157354),HIGH(0x1157354),BYTE3(0x1157354),BYTE4(0x1157354)
	.DB  LOW(0xFF2800A8),HIGH(0xFF2800A8),BYTE3(0xFF2800A8),BYTE4(0xFF2800A8)
	.DB  LOW(0x15907222),HIGH(0x15907222),BYTE3(0x15907222),BYTE4(0x15907222)
	.DW  0x4503
	.DB  0x0
_MinT:
	.DB  0x1C
_MaxT:
	.DB  0x1E
_MinTCaldron:
	.DB  0xA
_StokerMode:
	.DB  0x0
_WorkTime:
	.DB  0x5
_IdleTime:
	.DB  0xF
_nStart:
	.BYTE 0x1
_AutoRestoration:
	.DB  0x0

	.DSEG
_ds1820_devices:
	.BYTE 0x1
_Temperature:
	.BYTE 0x6
_TempDec:
	.BYTE 0x6
_Sign:
	.BYTE 0x3
_tRadiator:
	.BYTE 0x1
_tCaldron:
	.BYTE 0x1
_tOutSide:
	.BYTE 0x1
_ds1820_sn:
	.BYTE 0x1B
_MaxT1:
	.BYTE 0x1
_OnBlock:
	.BYTE 0x1
_TickCount:
	.BYTE 0x2
_Errcount:
	.BYTE 0x1
_k1:
	.BYTE 0x1
_i:
	.BYTE 0x1
_BufCRC:
	.BYTE 0x12
_lcd_screen:
	.BYTE 0x1
_hour23:
	.BYTE 0x1
_minute23:
	.BYTE 0x1
_sec23:
	.BYTE 0x1
_day:
	.BYTE 0x1
_wday:
	.BYTE 0x1
_month:
	.BYTE 0x1
_year:
	.BYTE 0x1
_t1:
	.BYTE 0x1
_t2:
	.BYTE 0x1
_rx_buffer:
	.BYTE 0x20
_rx_wr_index:
	.BYTE 0x1
_rx_rd_index:
	.BYTE 0x1
_rx_counter:
	.BYTE 0x1
_tx_buffer:
	.BYTE 0x8
_tx_wr_index:
	.BYTE 0x1
_tx_rd_index:
	.BYTE 0x1
_tx_counter:
	.BYTE 0x1
_lcd_buffer:
	.BYTE 0x10
__base_y_G103:
	.BYTE 0x4
__lcd_x:
	.BYTE 0x1
__lcd_y:
	.BYTE 0x1
__lcd_maxx:
	.BYTE 0x1
__seed_G104:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x0:
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer)
	SBCI R31,HIGH(-_rx_buffer)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer)
	SBCI R31,HIGH(-_tx_buffer)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x2:
	ST   -Y,R31
	ST   -Y,R30
	JMP  _delay_ms

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x3:
	LDD  R30,Y+6
	LDI  R26,LOW(9)
	MUL  R30,R26
	MOVW R30,R0
	SUBI R30,LOW(-_ds1820_sn)
	SBCI R31,HIGH(-_ds1820_sn)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x4:
	LDD  R30,Y+6
	LDI  R31,0
	SUBI R30,LOW(-_Sign)
	SBCI R31,HIGH(-_Sign)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x5:
	CALL _abs
	MOVW R16,R30
	LDD  R30,Y+6
	LDI  R26,LOW(_TempDec)
	LDI  R27,HIGH(_TempDec)
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x6:
	ST   X+,R30
	ST   X,R31
	LDD  R30,Y+6
	LDI  R26,LOW(_TempDec)
	LDI  R27,HIGH(_TempDec)
	LDI  R31,0
	LSL  R30
	ROL  R31
	ADD  R30,R26
	ADC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x7:
	LDI  R31,0
	LSL  R30
	ROL  R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x8:
	LDI  R30,LOW(10)
	LDI  R31,HIGH(10)
	CALL __MODW21
	MOVW R26,R22
	ST   X+,R30
	ST   X,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x9:
	__GETW1MN _Temperature,2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0xA:
	LDI  R30,LOW(_lcd_buffer)
	LDI  R31,HIGH(_lcd_buffer)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0xB:
	CALL __CWD1
	CALL __PUTPARD1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0xC:
	LDI  R24,8
	CALL _sprintf
	ADIW R28,12
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:11 WORDS
SUBOPT_0xD:
	LDS  R26,_Temperature
	LDS  R27,_Temperature+1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xE:
	LDI  R30,LOW(0)
	ST   -Y,R30
	LDI  R30,LOW(1)
	ST   -Y,R30
	JMP  _lcd_gotoxy

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xF:
	__GETW1MN _Temperature,4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x10:
	LDS  R30,_k1
	LDI  R26,LOW(_Temperature)
	LDI  R27,HIGH(_Temperature)
	RJMP SUBOPT_0x7

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x11:
	LDI  R26,LOW(_StokerMode)
	LDI  R27,HIGH(_StokerMode)
	CALL __EEPROMRDB
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x12:
	CALL __EEPROMWRB
	LDI  R30,LOW(0)
	STS  _TickCount,R30
	STS  _TickCount+1,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x13:
	LDI  R31,0
	SBIW R30,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x14:
	LDI  R31,0
	CP   R26,R30
	CPC  R27,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x15:
	RCALL SUBOPT_0xD
	CPI  R26,LOW(0xFFA6)
	LDI  R30,HIGH(0xFFA6)
	CPC  R27,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x16:
	CALL __EEPROMRDB
	LDI  R26,LOW(60)
	MUL  R30,R26
	MOVW R30,R0
	LDS  R26,_TickCount
	LDS  R27,_TickCount+1
	CP   R30,R26
	CPC  R31,R27
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:15 WORDS
SUBOPT_0x17:
	LDI  R30,LOW(_ds1820_sn)
	LDI  R31,HIGH(_ds1820_sn)
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(_ds1820_rom_codes)
	LDI  R31,HIGH(_ds1820_rom_codes)
	ST   -Y,R31
	ST   -Y,R30
	CALL _sncpy
	__POINTW1MN _ds1820_sn,9
	ST   -Y,R31
	ST   -Y,R30
	__POINTW1MN _ds1820_rom_codes,9
	ST   -Y,R31
	ST   -Y,R30
	JMP  _sncpy

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x18:
	LDS  R30,_tRadiator
	STS  _BufCRC,R30
	LDS  R30,_tCaldron
	__PUTB1MN _BufCRC,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 6 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x19:
	LDI  R30,LOW(_BufCRC)
	LDI  R31,HIGH(_BufCRC)
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:24 WORDS
SUBOPT_0x1A:
	LDS  R30,_i
	LDI  R31,0
	SUBI R30,LOW(-_BufCRC)
	SBCI R31,HIGH(-_BufCRC)
	LD   R30,Z
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 8 TIMES, CODE SIZE REDUCTION:18 WORDS
SUBOPT_0x1B:
	LDS  R30,_i
	SUBI R30,-LOW(1)
	STS  _i,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 10 TIMES, CODE SIZE REDUCTION:24 WORDS
SUBOPT_0x1C:
	LDS  R30,_i
	LDI  R31,0
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x1D:
	LDS  R26,_i
	CLR  R27
	RJMP SUBOPT_0x1C

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1E:
	ADD  R30,R26
	ADC  R31,R27
	__ADDW1MN _BufCRC,1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x1F:
	ST   -Y,R30
	CALL _putchar
	LDI  R30,LOW(69)
	ST   -Y,R30
	JMP  _putchar

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x20:
	ST   -Y,R30
	CALL _w1_write
	LDI  R16,LOW(0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x21:
	LDD  R26,Y+1
	LDD  R27,Y+1+1
	LD   R30,X+
	STD  Y+1,R26
	STD  Y+1+1,R27
	ST   -Y,R30
	JMP  _w1_write

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x22:
	CALL __SAVELOCR3
	LDD  R30,Y+3
	LDD  R31,Y+3+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x23:
	ST   -Y,R31
	ST   -Y,R30
	LDI  R30,LOW(9)
	ST   -Y,R30
	CALL _w1_dow_crc8
	CALL __LNEGB1
	CALL __LOADLOCR3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x24:
	LDD  R30,Y+1
	LDD  R31,Y+1+1
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x25:
	__GETD1N 0xC61C3C00
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x26:
	ST   -Y,R30
	CALL __lcd_write_data
	LDI  R30,LOW(3)
	LDI  R31,HIGH(3)
	RJMP SUBOPT_0x2

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x27:
	LDI  R30,LOW(48)
	ST   -Y,R30
	CALL __lcd_write_nibble_G103
	__DELAY_USW 200
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:21 WORDS
SUBOPT_0x28:
	ST   -Y,R19
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:9 WORDS
SUBOPT_0x29:
	LDD  R30,Y+16
	LDD  R31,Y+16+1
	SBIW R30,4
	STD  Y+16,R30
	STD  Y+16+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:7 WORDS
SUBOPT_0x2A:
	LDD  R30,Y+13
	LDD  R31,Y+13+1
	ST   -Y,R31
	ST   -Y,R30
	LDD  R30,Y+17
	LDD  R31,Y+17+1
	ICALL
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x2B:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+6,R30
	STD  Y+6+1,R31
	ST   -Y,R31
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x2C:
	LDD  R26,Y+16
	LDD  R27,Y+16+1
	ADIW R26,4
	CALL __GETW1P
	STD  Y+10,R30
	STD  Y+10+1,R31
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x2D:
	MOVW R26,R28
	ADIW R26,12
	CALL __ADDW2R15
	CALL __GETW1P
	RET


	.CSEG
_delay_ms:
	ld   r30,y+
	ld   r31,y+
	adiw r30,0
	breq __delay_ms1
__delay_ms0:
	__DELAY_USW 0x7D0
	wdr
	sbiw r30,1
	brne __delay_ms0
__delay_ms1:
	ret

_w1_init:
	clr  r30
	cbi  __w1_port,__w1_bit
	sbi  __w1_port-1,__w1_bit
	__DELAY_USW 0x3C0
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x25
	sbis __w1_port-2,__w1_bit
	ret
	__DELAY_USB 0xCB
	sbis __w1_port-2,__w1_bit
	ldi  r30,1
	__DELAY_USW 0x30C
	ret

__w1_read_bit:
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x5
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x1D
	clc
	sbic __w1_port-2,__w1_bit
	sec
	ror  r30
	__DELAY_USB 0xD5
	ret

__w1_write_bit:
	clt
	sbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x5
	sbrc r23,0
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0x23
	sbic __w1_port-2,__w1_bit
	rjmp __w1_write_bit0
	sbrs r23,0
	rjmp __w1_write_bit1
	ret
__w1_write_bit0:
	sbrs r23,0
	ret
__w1_write_bit1:
	__DELAY_USB 0xC8
	cbi  __w1_port-1,__w1_bit
	__DELAY_USB 0xD
	set
	ret

_w1_read:
	ldi  r22,8
	__w1_read0:
	rcall __w1_read_bit
	dec  r22
	brne __w1_read0
	ret

_w1_write:
	ldi  r22,8
	ld   r23,y+
	clr  r30
__w1_write0:
	rcall __w1_write_bit
	brtc __w1_write1
	ror  r23
	dec  r22
	brne __w1_write0
	inc  r30
__w1_write1:
	ret

_w1_dow_crc8:
	clr  r30
	ld   r24,y
	tst  r24
	breq __w1_dow_crc83
	ldi  r22,0x18
	ldd  r26,y+1
	ldd  r27,y+2
__w1_dow_crc80:
	ldi  r25,8
	ld   r31,x+
__w1_dow_crc81:
	mov  r23,r31
	eor  r23,r30
	ror  r23
	brcc __w1_dow_crc82
	eor  r30,r22
__w1_dow_crc82:
	ror  r30
	lsr  r31
	dec  r25
	brne __w1_dow_crc81
	dec  r24
	brne __w1_dow_crc80
__w1_dow_crc83:
	adiw r28,3
	ret

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__ZERORES:
	CLR  R30
	CLR  R31
	CLR  R22
	CLR  R23
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__ADDW2R15:
	CLR  R0
	ADD  R26,R15
	ADC  R27,R0
	RET

__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__ASRW12:
	TST  R30
	MOV  R0,R30
	MOVW R30,R26
	BREQ __ASRW12R
__ASRW12L:
	ASR  R31
	ROR  R30
	DEC  R0
	BRNE __ASRW12L
__ASRW12R:
	RET

__LSRW2:
	LSR  R31
	ROR  R30
	LSR  R31
	ROR  R30
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__LNEGB1:
	TST  R30
	LDI  R30,1
	BREQ __LNEGB1F
	CLR  R30
__LNEGB1F:
	RET

__MULW12U:
	MUL  R31,R26
	MOV  R31,R0
	MUL  R30,R27
	ADD  R31,R0
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	RET

__MULW12:
	RCALL __CHKSIGNW
	RCALL __MULW12U
	BRTC __MULW121
	RCALL __ANEGW1
__MULW121:
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__DIVW21:
	RCALL __CHKSIGNW
	RCALL __DIVW21U
	BRTC __DIVW211
	RCALL __ANEGW1
__DIVW211:
	RET

__MODW21:
	CLT
	SBRS R27,7
	RJMP __MODW211
	COM  R26
	COM  R27
	ADIW R26,1
	SET
__MODW211:
	SBRC R31,7
	RCALL __ANEGW1
	RCALL __DIVW21U
	MOVW R30,R26
	BRTC __MODW212
	RCALL __ANEGW1
__MODW212:
	RET

__CHKSIGNW:
	CLT
	SBRS R31,7
	RJMP __CHKSW1
	RCALL __ANEGW1
	SET
__CHKSW1:
	SBRS R27,7
	RJMP __CHKSW2
	COM  R26
	COM  R27
	ADIW R26,1
	BLD  R0,0
	INC  R0
	BST  R0,0
__CHKSW2:
	RET

__GETW1P:
	LD   R30,X+
	LD   R31,X
	SBIW R26,1
	RET

__GETW1PF:
	LPM  R0,Z+
	LPM  R31,Z
	MOV  R30,R0
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__EEPROMRDB:
	SBIC EECR,EEWE
	RJMP __EEPROMRDB
	PUSH R31
	IN   R31,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R30,EEDR
	OUT  SREG,R31
	POP  R31
	RET

__EEPROMWRB:
	SBIS EECR,EEWE
	RJMP __EEPROMWRB1
	WDR
	RJMP __EEPROMWRB
__EEPROMWRB1:
	IN   R25,SREG
	CLI
	OUT  EEARL,R26
	OUT  EEARH,R27
	SBI  EECR,EERE
	IN   R24,EEDR
	CP   R30,R24
	BREQ __EEPROMWRB0
	OUT  EEDR,R30
	SBI  EECR,EEMWE
	SBI  EECR,EEWE
__EEPROMWRB0:
	OUT  SREG,R25
	RET

__SAVELOCR6:
	ST   -Y,R21
__SAVELOCR5:
	ST   -Y,R20
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR6:
	LDD  R21,Y+5
__LOADLOCR5:
	LDD  R20,Y+4
__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
