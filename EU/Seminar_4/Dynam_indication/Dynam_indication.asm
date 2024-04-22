;*************************************
;* Designer        Mechtcherjakowa R.I.
;* Version:        1.0
;* Date            13.04.2020
;* Title:          Dynam_indication.asm
;* Device          ATmega16
;* Clock frequency:������� ��.���������� 8 ��� 
;*************************************
; �������
;*************************************
;��� ������� �� ������ "��������� �����" ����������� ��������� �����, ������� 
;��������� �� �������������� ����������. 
;������ "��������� �����" ���������� � ���������� � PD2(INT0),
;�������������� ���������� �  P�0-P�7 
;PC0-a,PC1-b,PC2-c,PC3-d,PC4-e,PC5-f,PC6-g,PC7-h
;������� ������ ���������� PB2 - �����,PB1-�������,PB0 - ������� - ������
;***********************************************
.include "m16def.inc"
;-----------------------------------------------
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def temp_L      =R16
.def temp_H      =R17
.def Random      =R24;����� ���������� �����
.def Hundreds    =R18;����� ��� ���������� "�����"
.def Tens        =R19;����� ��� ���������� "�������"
.def Ones        =R20;����� ��� ���������� "�������"
.def Disp_Numb   =R22;��������� ��������� ����������
.def Disp_Count  =R23;������� ������������ ���������� ��������� ������������ ���������
;-------------------------  
; Constants
;**************************
.equ Val_dispCount=100;�������� ���������,���. ����� ��� ����������            
;-------------------------
.dseg
Var_buffer: .BYTE 8
;***********************************
.cseg
.org $0000
rjmp Init
;***********************************
;������� ����������
;***********************************
.org  INT0addr;=$002	;External Interrupt0 Vector Address
rjmp  IN_INT0;
;-------------------
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
;***********************************
; Start Of Main Program
;***********************************
Init:
          ldi   temp_L,LOW(RAMEND);����� ������� �����
	      out   SPL, temp_L;��������� ����� 
	      ldi   temp_L,HIGH(RAMEND)
	      out   SPH,temp_L
; ------������������� ������ �/B

Init_B:	  ldi   temp_L,0b11111111;(PB1-PB7)-������,
          ldi   temp_H,0b00000100;������� ����� (1-� ���������)
          out   DDRB,temp_L        
	      out   PORTB,temp_h
;
Init_C:	  ser   temp_L;  (PC0-PC7) - ������
	      out   DDRC,temp_l
;
Init_D:   ldi   temp_L,0b11111011;,PD2-����,(PD4-PD6)-������,(PD3,PD7) �� ���
          ldi   temp_H,0b00000100;��� �������� �� �������. PD2
	      out   DDRD,temp_L  
	      out   PORTD,temp_H;
;
Init_A:   ldi   temp_L,0b00000000;�� ������������ ���������������� ��� �����
          ldi   temp_H,0b11111111;� �������������� ����������
	      out   DDRA,temp_L  
	      out   PORTA,temp_H;
;---------------------------------------
;�������������  �������� ���������� INT0          
          ldi   temp_L,(1<<ISC01); (1<<ISC01);���������� �� �����
	      out   MCUCR,temp_L
	      ldi   temp_L,(1<<INT0);INT0: External Interrupt Request 0 Enable 
	      out   GIMSK,temp_L
;������������� ������������ ���
          ldi   Disp_Count,Val_dispCount
	      clr   Disp_Numb 	    	     
	      ldi   Random,1     ;����� ����� � ������� Random (1);
	      clr   Hundreds;
          clr   Tens    ;(0) �������� �� �����������
          clr   Ones
		  ldi   YL,low(Var_buffer)
		  ldi   YH,high(Var_buffer)
;
          sei            ;��������� ���������� (I)
;**************************************************
;�������� ����
;==================================================
Start:    rcall  Display
	      rjmp   Start     
;==================================================
;��������� ��������� �����	      
;***************************************************	
; ������������ Display ������ � �������� (�����. ���������)
;==================================================   
Display:  dec   Disp_Count
          brne  ex_displ
;
          ldi   Disp_Count,Val_dispCount
;          
          inc   Disp_Numb
		  cpi   Disp_Numb,3
		  brne  Out_disp
		  clr   Disp_Numb
Out_disp: ldi   ZL,18;  ;��������� �� Hundreds ����� R18
          ldi   ZH,0
          add   ZL,Disp_Numb
		  ld    temp_L,Z; ������ ������-���������� ���,��� ������ �� ���������
;����������� � �������������� ���
          ldi   ZL,low(TABLE*2) ;��������� ����� ������ 
          ldi   ZH,high(TABLE*2);������� � ������ �������� (*2 - ��� �������� 
          add   ZL,temp_L       ;���������)
    	  clr   temp_L
          adc   ZH,temp_L                         
	      lpm   temp_L,Z    ;������ �������������� ��� �������� ; 
		  out   PortC,temp_L; ������� �� ����������
;����������� ���������
          in    temp_L,PINB
		  andi  temp_L,0b00000111

		  lsr   temp_L
		  brcc  PC+2
		  ldi   temp_L,0b00000100; � ������ (Hundreds)	   
		  out   PORTB,temp_L		   
;
ex_displ: ret
;
;==================================================
;------- ������� ������������� ��������
TABLE:    .db   0b00111111,0b00000110; ���� "0","1"
          .db   0b01011011,0b01001111; ���� "2","3"
          .db   0b01100110,0b01101101;;���� "4","5"
		  .db   0b01111101,0b00000111;;���� "6","7"
		  .db   0b01111111,0b01101111;;���� "8","9"      	   
;*******************************************************
;������������ ���������  �������� ���������� INT0
;*******************************************************
IN_INT0:   push   temp_L
           push   temp_H
           in     temp_L,SREG
		   push   temp_L 
;
           rcall  val_rand;��������� ��������� �����
           rcall  digitConvert;����������� �������� ����� � �������-����������

           ldi     temp_L,(1<<INTF0);
		   out     GIFR,temp_L
;
           pop     temp_L
           out     SREG,temp_L
           pop     temp_H
           pop     temp_L
		   reti
;===============================
val_rand:  mov     temp_L,Random 
           add     temp_L,Random 
		   add     temp_L,Random
		   ldi     temp_H,5
		   add     temp_L,temp_H
		   mov     Random,temp_L
		   st      Y+,temp_L
           ret
;===================================================
;������������ �������� 1-� ������� ����� � �������-���������� ��� 
;===================================================
digitConvert:
            clr   Hundreds
			clr   Tens  
			clr   Ones
;
FindHundreds:
            subi  temp_L,100
			brcs  FindTens
            inc   Hundreds
			rjmp  FindHundreds
;
FindTens:   subi  temp_L,-100
            subi  temp_L,10
            brcs  FindOnes
            inc   Tens 
			rjmp  FindTens+1
;
FindOnes:   subi  temp_L,-10
            mov   Ones,temp_L
            ret
;===================================================
          
          
