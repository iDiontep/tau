;*************************************
;* Designer        Mechtcherjakowa R.I.
;* Version:        1.0
;* Date            18.03.2009
;* Title:          Reaction.asm
;* Device          ATmega16
;* Clock frequency:������� ��.���������� 8 ��� 
;*************************************
; �������
;*************************************
;(���������� - ��������� ���������� ����� ������� ������������ � 
;���������� ����� ������� ������������ � ���� �� ������� (3 ����c������.����������).
;����� ������� ������ "����������" ����� ��������� ���������� ������� (4...12�)
;���������� ��������� (���),��� ��� ��������� ������������ ������
;������ ������ "�������")
;������ "����������" ���������� � PD1,������ "�������" ���������� � PD2(INT0) �����,
;C�������� ��� ���������� PB7 - �����
;�������������� ����������   PC0-PC7-������,�������������� ���������  
;PC0-a,PC1-b,PC2-c,PC3-d,PC4-e,PC5-f,PC6-g,PC7-h
;������� ������ ���������� PB2 - �����,PB1-�������,PB0 - ������� - ������
;***********************************************
;***********************************************
;�������
;1.��������� �������� ������ ��������� � ���������� AVR Studio.�������� � ����������
; �����,� ������� �������� ���������� �������  ������ �������������� ��������� 
;2.��������� ���������������� �������� �����. ��������� ������ ����� � 3-� �������:
;- ������ ������ PD1-"����������",����� ��������� C��(PB7) ������  PD2-"�������"
;- ������ ������ PD1-"����������",�� ��������� C��(PB7) ������  PD2-"�������"
;- ������ ������ PD1-"����������",����� ��������� C��(PB7) �� ��������  PD2-"�������"
;3.������� � ��������� ������ � ���������
;4.����������� ���������,�������� ������� ������� Disp_Count �� 2-� ���� � ������������
;��������� 0xFFFF,����� �������������� ���� Disp_CountH. ���������������� �����.�����
;5.��������� ������ �����.���������������� ��������� ��������� Val_dispCount,����-
;�������� ����� ���������  ����������, ����� ���� �� ������������ ������� �����������.
;***********************************************************************************
.include "m16def.inc";"C:\Program Files (x86)\Atmel\AVR Tools\AvrAssembler\Appnotes\m16def.inc"
; ������������� ����� ��������; 
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def temp       =R16
.def Random     =R15;����� ���������� �����
.def Hundreds   =R18;
.def Tens       =R19
.def Ones       =R20
.def CountX     =R14;������� ������������ ���������� ���������   
.def Disp_Numb  =R22;��������� ����������� ���������
.def Disp_Count =R23; ������� ���������� �������
.def TimeH      =R17;������� ������������ �0
.def TimeL      =R25
.def Count3     =R13
.def tempH      =R21
.def tempH2     =R26
.def temp2      =R27 
;*****************
.def Byte_fl    =R24;���� ������
;------------------
.equ F_ready        =1;��� ����� "����������" (��� 1 � ����� Byte_fl)
;***************** 
; Constants
;*****************
.equ Val_dispCount=50;�������� ���������,���. ����� ��� ���������� 
;***********************************
.cseg
.org $0000
rjmp Init
;****************
;****************
.org  INT0addr;=$002	;External Interrupt0 Vector Address
rjmp  IN_INT0;
;----------------
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
rjmp  IN_T0ovf
;--------------------
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
          ldi   temp,LOW(RAMEND);����� ������� �����
	      out   SPL, temp;��������� ����� 
	      ldi   temp,HIGH(RAMEND)
	      out   SPH,temp

; ------������������� ������ �/B

Init_B:	  ldi   temp,0b11111111;(PB1-PB7)-������,
          out   DDRB,temp
          ldi   temp,0b00000100;������� ����� (1-� ���������)
	      out   PORTB,temp

Init_C:	  ser   temp;  (PA0-PA7) - ������
	      out   DDRC,temp
;
Init_D:    ldi   temp,0b11111001;PD1,PD2-�����, ���������-������
	      out   DDRD,temp
	      ldi   temp,0b00000110;��� �������� �� �������.   
	      out   PORTD,temp;

; ---  �������������  ������� TCNT0
Init_T0:  ldi   temp,(1<<TOIE0);TOIE0-Timer/Counter0 Overflow Interrupt Enable
	      out   TIMSK,temp

; ---  �������������  �������� ���������� INT0
;
          ldi   temp,(1<<ISC01); ;���������� �� ����� ISC01=1 ISC00=0
	      out   MCUCR,temp
	      ldi   temp,(1<<INT0);INT0: External Interrupt Request 0 Enable 
	      out   GIMSK,temp
;
Init_R:   ldi   Disp_Count,Val_dispCount
	      clr   Disp_Numb 	    	     
          clr   Byte_fl
	      ldi   temp,1     ;����� �����
	      mov   Random,temp;� ������� Random (1)
	      clr    Hundreds;���������� �����������
          clr    Tens    ;(0)
          clr    Ones

;==================================================
;������ �����
;==================================================
Start:    rcall  Display
          sbrc   Byte_fl,F_ready
	      rjmp   Start     ;���������� ����
	      sbic   PIND,1    ;���� ������� ������ "�����" 
	      rjmp   Start
;
Rand_st:  mov    temp,Random;��������� ��������� ��������� ����� 
          add    Random,temp;�������� �� 5 ���������
          add    Random,temp;��������� ����� � ���������(0-255)
          add    Random,temp
          add    Random,temp
          add    Random,temp
          inc    Random
;
          mov    temp,Random;�0 - 8 ���� ������. Counter0 �verflow ������������
          lsr    temp;������� 256*1024/8000000=0,033�.�������� (4...8,4�)->
		             ;                                ��������� ��������(127+Random/2)
	      subi   temp,-127;��������� ����� (90 - 256)
Rand_end: mov    CountX,temp
	          

          ldi   temp,(1<<CS02)|(1<<CS00);������� TCNT0 Clk/1024,(CS02,CS01,CS00)
  	      out   TCCR0,temp;�������� ������

          ldi    temp,(1<<INTF0)
          out    GIFR,temp;���������� ���� ������.INT0 ������� 1

          ldi    temp,(1<<TOV0)
	      out    TIFR,temp;���������� ���� ������ TOV0 

          sei             ;��������� ����������

          clr    TimeH   ;����� �������� ������������ �0
          clr    Hundreds;���������� �����������
          clr    Tens
          clr    Ones
	      set
          bld    Byte_fl,F_ready;���� F_ready (���1) � ����� Byte_fl ���������� � 1
	      rjmp   Start
;==================================================	   
; ����� �����
;==================================================	
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
          rjmp  Out_disp

Out_disp: ldi   ZL,18;     ;��������� �� Hundreds
          ldi   ZH,0;
          add   ZL,Disp_Numb
		  ld    temp,Z
;                           ����������� � �������������� ���
;---------------------------------------------------- 
         ; ldi   ZL,TABLE*2;��������� ����� ������ 
 	     ; ldi   ZH,0x00   ;������� � ������ �������� (*2 - ��� �������� 
	    ;  add   ZL,temp   ;���������)

 ldi   ZL,low(TABLE*2);��������� ����� ������ 
 ldi   ZH,high(TABLE*2);������� � ������ �������� (*2 - ��� ��������
 add   ZL,temp   ;���������)
 clr   temp
 adc   ZH,temp
	      lpm   temp,Z    ;������ �������������� ��� �������� ; 
		  out   PortC,temp; �������� �� ���������
;
          in    temp,PINB
		  in    temp2,PINB
		  andi  temp,0b00000111;��������� ���� ������ �����.PB2 - �����,PB1-�������,PB0 - ����.
		  andi  temp2,0b10000000;��������� ��� ���������� (���)
		  lsr   temp
		  brcc  PC+2
		  ldi   temp,0b00000100; � ������ (Hundreds)	   
          or    temp, temp2;��������������� ���
		  out   PORTB,temp
		   
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
		  .db   0b01111100,0b01110111; ���� "b","A"
		  .db   0b01011110,0b01000000; ���� "d","-"
		  .db   0b01110110,0b00110000; ���� "H","I"	 
      	   
;================================================== 
;������������ ���������  �������� ���������� INT0
;�0 - 8 ���� ������. Counter0 �verflow ������������������� 256*1024/8000000=0,033�
;1����=7,8125�������. �.� �� ��������� �������� ������� �� ����� 7812,5 ������� ��� �����
;��� �������������� � ���� �����  �� 7,8125 (��� *0,128) ��� ����� �������� (16/125)
;-> (8/125)*2)
;�� 3 �����������. ���������� ����� ������� ������������ ����� 999,����� �������������
; ����������� � �������� 
;�� ����� 999���� ����� �_����*(16/125), ��� �_����=7804 (1E7C)h. ������������ ���� ������� ����
; TimeH (1Fh), ������� 84h,� ����� ������� ��� �� ����������.
;.
;===================================================
IN_INT0:   push   temp
           in     temp,SREG
		   push   temp 
;
           sbis   PINB,7;��������� ���
           rjmp   Cheat
           clr    temp
		   out    TCCR0,temp;���a��� �0
		   in     TimeL,TCNT0
		   in     temp,TIFR  ;��������� �0 �� ������������
           sbrc   temp,1
		   inc    TimeH
		   subi   TimeL,0x84 ;�������� 84h
		   sbci   TimeH,0


           ldi    temp,4 
           mov    Count3,temp; �������� ����� ������� �� 16.���������� ������� ����� 4 ����
		   clr    tempH2
		   mov    temp,TimeL
		   mov    tempH,TimeH
shl3:	   lsl    temp
		   rol    tempH
		   rol    tempH2
           dec    Count3
		   brne   shl3   
;
           clr    TimeL
		   clr    TimeH
;
Divide12:  subi   temp,125;������� ����������
           sbci   tempH,0
		   sbci   tempH2,0
           brcs   DoneDividing
		   inc    TimeL 
		   brne   Divide12
		   inc    TimeH
		   rjmp   Divide12
; 
DoneDividing:
           rcall  digitConvert		   		   		    
;		     
ex_INT0:   clt
		   bld    Byte_fl,F_ready
		   clr    TimeH   ;����� �������� ������������ �0
		   clr    temp
		   out    TCCR0,temp;���a��� �0
		   cbi    PORTB,7;��������� ���
           pop    temp         ;����� ��� ���������� ����. ����������
           out    SREG,temp
		   pop    temp
           ret
;================================================= 
Cheat:     ldi    Hundreds,10;���� "b",
           ldi    Tens,11    ;     "A"
           ldi    Ones,12    ;     "d"
           rjmp   ex_INT0
;
;===================================================
;������������ �������� 2-� ������� ����� � �������-���������� ��� 
;===================================================
digitConvert:
            clr   Hundreds
			clr   Tens  
			clr   Ones
;
FindHundreds:
            subi  TimeL,100
			sbci  TimeH,0
			brcs  FindTens
            inc   Hundreds
			rjmp  FindHundreds
;
FindTens:   subi  TimeL,-100
            subi  TimeL,10
            brcs  FindOnes
            inc   Tens 
			rjmp  FindTens+1
;
FindOnes:   subi  TimeL,-10
            mov   Ones,TimeL
            ret
;=================================================== 
;������������ ��������� ���������� ������������ ������� �0
;�0 - 8 ���� ������. Counter0 �verflow ������������������� 256*1024/8000000=0,033�
;1c�� =(1024/8000000)*N_��������.(N ���� =7812,5 �� �������)
;1����=7,8125�������. �.� �� ��������� �������� ������� �� ����� 7812,5 ������� ��� �����
;��� �������������� � ���� �����  �� 7,8125 (��� *0,128) ��� ����� �������� (16/125)
;�� ����� 999���� ����� �_����*(16/125), ��� �_����=7804 (1E7C)h. ������������ TimeH (1Fh)
; ������� 84h,� ����� �������.
;===================================================
IN_T0ovf:  push   temp
           in     temp,SREG
		   push   temp 
;            
           sbic   PINB,7;��������� ���
           rjmp   LEDon
		   dec    CountX
		   brne   ex_T0ovf
Start_m:   ldi    temp,0x84
		   out    TCNT0,temp
		   sbi    PORTB,7;�������� ���
;
ex_T0ovf:  pop    temp         ;����� c ���������tv ����. ����������
           out    SREG,temp
		   pop    temp
           reti
;
LEDon:     inc    TimeH         ;�������������� �� ����
           cpi    TimeH,0x1F    ;��������� �� ������������ �����   
		   brlo   ex_T0ovf
;                              ��������� ������� > 999 ����
out_HI:    clt
		   bld    Byte_fl,F_ready 
		   clr    temp
		   out    TCCR0,temp;���a��� �0
           ldi    Hundreds,13 ;"-"
		   ldi    Tens,14     ;"H" 
		   ldi    Ones,15     ;"I"
		   cbi    PORTB,7;��������� ���
		   pop    temp
           out    SREG,temp
		   pop    temp
		   ret                 ;����� ��� ���������� ����. ����������
;=====================================================


;****************************************************  
;          ldi   ZL,18;     ;��������� �� Hundreds
;		   ldi   ZH,0
;----------------------------------------------------
;          ldi   ZL,low(TABLE*2);��������� ����� ������ 
;	       ldi   ZH,high(TABLE*2);������� � ������ �������� (*2 - ��� �������� 
;	       add   ZL,temp   ;���������)
;		   clr   temp
;          adc   ZH,temp
;*******************************************************
;.def Disp_CountH=R1
;---------------------
; Constants
;*****************
;.equ Val_dispCountH=255;�������� ���������,���. ����� ��� ����������  
;*****************
;          ldi   Disp_Count,Val_dispCount
;          ldi   temp,Val_dispCountH
;          mov   Disp_CountH,temp
;          
;----------------------------------------
;          subi  Disp_Count,0x01
;          ldi   temp,0x00
;   	  sbc   Disp_CountH,temp
;		  ldi   temp,0x00
;		  cp    Disp_Count,temp
;		  brne  ex_displ 
;		  cp    Disp_CountH,temp
;		  brne  ex_displ
;
;          ldi   Disp_Count,Val_dispCount
;          ldi   temp,Val_dispCountH
;          mov   Disp_CountH,temp
;          
;----------------------------------------
