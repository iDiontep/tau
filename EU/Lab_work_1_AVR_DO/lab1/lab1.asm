;*************************************
;* Designer        Ionin D.A..
;* Version:        1.0
;* Date            11.03.2024
;* Title:          Countert.asm
;* Device          ATmega16
;* Clock frequency:������� ��.���������� 8 ��� 
;*************************************
; �������
;*************************************
;(���������� - ������� ����� ������� �� ������ (0-9 �������,�����,����������)
;� ������� �������� �� ����c��������� ���������).
;������ ���������� � PB4 (0V on pin when button is pressed), �������������� ��������� �  PA0-PA7 
;PC0-a,PC1-b,PC2-c,PC3-d,PC4-e,PC5-f,PC6-g,PC7-h,������ ��������� PB0(SW6-8)
; 
;�������: 1.����� ������ � ���������
;         2.��������� �������� ��� ���������� �������� ��������� ������ (< 50mkcek),
;           ��������� ������ �����.
;		  3.��������� ���������������� ������������ ��������,����������� ��� 
;	        ����������� ���������� �������� ���������
;         4.������������� ��������� ���, ����� ���� ���� ��� ������� ������ ��������
;           � ��������������� ����������� (�� 9 � 0).���������������� �� ������ 
;           � ��������� ������������ ������ ���������. 
;           
;*************************************
.include "m16def.inc"; ������������� ����� ��������; ������������� ����� ��������
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def temp     =R16
.def Counter  =R17
.def Delay1   =R18;��������
.def Delay2   =R19;�������� ���������� �������� ���������
.def Delay3   =R20;
;*****************
;***************** 
; Constants
;*****************
.equ Val_del1=0x40;0x80;�������� ��������� ��������
.equ Val_del2=0x1F;0x38;(�������� �����) 
.equ Val_del3=0x00;0x05;(������� 8���,5 ������,����� ���������� �������� ���������
;                  5����.���������� ������ 
;                  ����=8000 (001F40) (1/8000000)*5*����=0,05���) 
;		   
;***********************************
.cseg
.org $0000
rjmp Init
;****************
.org  INT0addr;=$002	;External Interrupt0 Vector Address
reti
.org  INT1addr;=$004	;External Interrupt1 Vector Address
reti
.org  OC2addr; =$006	;Output Compare2 Interrupt Vector Address
reti
.org  OVF2addr;=$008	;Overflow2 Interrupt Vector Address
reti 
.org  ICP1addr;=$00A	;Input Capture1 Interrupt Vector Address
reti
.org  OC1Aaddr;=$00C	;Output Compare1A Interrupt Vector Address
reti
.org  OC1Baddr;=$00E	;Output Compare1B Interrupt Vector Address
reti
.org  OVF1addr;=$010	;Overflow1 Interrupt Vector Address
reti
.org  OVF0addr;=$012	;Overflow0 Interrupt Vector Address
reti
.org  SPIaddr; =$014	;SPI Interrupt Vector Address
reti
.org  URXCaddr;=$016	;UART Receive Complete Interrupt Vector Address
reti
.org  UDREaddr;=$018	;UART Data Register Empty Interrupt Vector Address
reti
.org UTXCaddr; =$01A	;UART Transmit Complete Interrupt Vector Address
reti
.org ADCCaddr; =$01C	;ADC Interrupt Vector Address
reti
.org ERDYaddr; =$01E	;EEPROM Interrupt Vector Address
reti
.org ACIaddr;  =$020	;Analog Comparator Interrupt Vector Address
reti
.org TWIaddr;  =$022   ;Irq. vector address for Two-Wire Interface
reti
.org INT2addr; =$024   ;External Interrupt2 Vector Address
reti
.org OC0addr;  =$026   ;Output Compare0 Interrupt Vector Address
reti
.org SPMRaddr; =$028   ;Store Program Memory Ready Interrupt Vector Address
reti
;
;***********************************
; Start Of Main Program
;***********************************

Init:  	  ldi   temp,LOW(RAMEND);����� ������� �����
	      out   SPL, temp;��������� ����� 
	      ldi   temp,HIGH(RAMEND)
	      out   SPH,temp
;
; ------������������� ������ �/B
;
Init_B:   ldi   temp,0b11101111;PB4-����,��������� ������
          out   DDRB,temp
          ldi   temp,0b00010001;PB4 ����.��������,������ ��������� PB0=1 
	      out   PORTB,temp
;
Init_C:   ser   temp;  (P�0-P�7) - ������
	      out   DDRC,temp
	      ldi   temp,0b01101111;��� "9" ��� ���������	    
	      out   PORTC,temp;
;
Init_CNT: ldi   Counter, 9;����� �������� ��� ���������
;
;==================================================
;������ �����
;==================================================	  
Start:    sbic  PinB,4    ;������ ������?
          rjmp  Start     ;���, �������� � ����� 
	      dec   Counter   ;��, ����������� ������� �� 1
	   
          cpi   Counter,-1;Counter= - 1?
	      brne  PC+2      ;���, ���������� �������
		  ldi   Counter, 9;;��, ���������� ������� 


;	   
Read:     ldi   ZL,TABLE*2;��������� ����� ������ 
	      ldi   ZH,0x00   ;������� � ������ �������� (*2 - ��� �������� 
	      add   ZL,Counter;���������)
	      lpm   temp,Z    ;������ �������������� ��� �������� Counter
Write_A:  out   Portc,temp;�������� �� ���������   
delay_1:  rcall delay_DK  ;�������� ��� ������������������ ���������
;	   
Key_end:  sbis  PinB,4  ;�������� ���������� ������
          rjmp  Key_end	    
delay_2:  rcall delay_DK 
End_prog: rjmp  Start
;==================================================	   
; ����� �����	   
;==================================================	
; ������������ Delay_DK
;==================================================   
Delay_DK: ldi   Delay1,Val_del1;�������� ��������
          ldi   Delay2,Val_del2 
          ldi   Delay3,Val_del3

cycle:    subi  Delay1,1; ���� - 5 ������
          sbci  Delay2,0
	      sbci  Delay3,0
	      brcc  cycle
End_deley: ret 

;===================================================
;------- ������� ������������� ��������
TABLE:    .db   0b00111111,0b00000110; ���� "0","1"
          .db   0b01011011,0b01001111; ���� "2","3"
          .db   0b01100110,0b01101101;;���� "4","5"
		  .db   0b01111101,0b00000111;;���� "6","7"
		  .db   0b01111111,0b01101111;;���� "8","9"   
;****************************************************        

