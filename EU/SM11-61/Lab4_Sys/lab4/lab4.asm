;*************************************
;* Designer        Mechtcherjakowa R.I.
;* Version:        1.0
;* Date            08.04.2010
;* Title:          ADC_proj.asm
;* Device          ATmega16
;* Clock frequency:������� ��.���������� 8 mHz
;*************************************
; �������
;*************************************
;���������  ������������ ��������� ����������,���������� � 2-� ���������� ����������,
;������������ � ���� AREF=2,56B(����� 32)� ����� ����������� �������� �� ��������. ����������
;���������� ���������� �������� �� �� PA0 (ADC0) � PA3 (ADC3)
;����� ������, ���������� �� ���������� �������������� �������� ������ "����� ������",
;������������ � ������ PD3
;������ � ��� ����������� ����� ������������ (Val_N_ADC=1,2,4,8) ��� � ����������
;�������� ��������, ��������� ��� ������� ����� ������
;���������� �������� Vin=(ADC*2,56)/1024=ADC/400. ���������� ������ ����� ����� ���
;������ �� �������, �.�. Vin*100. ����� ������� ���������� �������� ����� ADC/4
;���������� � 100 ��� ��� ������ �� ������� ������������ ������� ����� � ������ ��.�����
;�������������� ���������� ���������� � PC0-PC7(������), 
;PC0-a,PC1-b,PC2-c,PC3-d,PC4-e,PC5-f,PC6-g,PC7-h
;������� ������ ���������� PB3-����� ������ ���,PB2 - �������,PB1-�������,PB0-����� (������)
;===================================================================================
;�������: ���������� ��������� � ���� VCC � �������� ����������� ��������� � ���.�����-�
;������������������ ������ ��������� �������� � ������
;���������� ��������� �� ���������� ������ ��������������
;***********************************************
.include "m16def.inc"
; ������������� ����� ��������; 
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def  temp_L     =R16
.def  temp_H     =R17
.def  Number     =R18 
.def  Hundreds   =R19;
.def  Tens       =R20
.def  Ones       =R21
.def  Disp_Numb  =R22
.def  Disp_Count =R23
.def  Time       =R24;������� ��������.�0(1024*255/8000000*Xotc=1cek(Xotc=30)
.def  ADC_h      =R3
.def  ADC_l      =R4
.def  cou_ADC    =R25
;-------------------
.def  byte_fl    =R9
;-------------------
.equ  F_iz_kan    =0;���� ��������� ������:0 2-� �����.1 6-� �����
.equ  F_end_ADC   =1;���� ���������� (Val_N_ADC) �������������� ���
.equ  Disab_Key   =2;��� ���������� ������ ������ "����� ������"
;******************* 
; Constants
;*******************
.equ   Val_dispCount=50
.equ   Val_N_ADC    =4;4;�����-�� �������������� ���(1,2,4,8.16..)
.equ   VAL_time =30;30 ������������ ������������� 1 ���
;***************************************
.cseg
.org $0000
rjmp Init
;****************
;****************
.org  INT0addr;=$002	;External Interrupt0 Vector Address
reti;
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
rjmp  time_d_k ;
.org  SPIaddr; =$014	;SPI Interrupt Vector Address
reti
.org  URXCaddr;=$016	;UART Receive Complete Interrupt Vector Address
reti
.org  UDREaddr;=$018	;UART Data Register Empty Interrupt Vector Address
reti
.org UTXCaddr; =$01A	;UART Transmit Complete Interrupt Vector Address
reti
.org ADCCaddr; =$01C	;ADC Interrupt Vector Address
rjmp  IN_ADC
.org ERDYaddr; =$01E	;EEPROM Interrupt Vector Address
reti
.org ACIaddr;  =$020	;Analog Comparator Interrupt Vector Address
reti
.org TWIaddr;  =$022    ;Irq. vector address for Two-Wire Interface
reti
.org INT2addr; =$024    ;External Interrupt2 Vector Address
reti
.org OC0addr;  =$026    ;Output Compare0 Interrupt Vector Address
reti
.org SPMRaddr; =$028    ;Store Program Memory Ready Interrupt Vector Address
reti
;***********************************
;***********************************
Init:
       ldi   temp_L,LOW(RAMEND);����� ������� �����
	   out   SPL, temp_L;��������� ����� 
	   ldi   temp_L,HIGH(RAMEND)
	   out   SPH,temp_L
	   ; ------������������� ������ �/B
;
	   ldi   temp_L,0b11111111;(PB1-PB7)-������,
       out   DDRB,temp_L
       ldi   temp_L,0b00001000;������� PB3-����� ����� (1-� ���������)
	   out   PORTB,temp_L
;
       ldi   temp_L,0b00000000;PD3-������ "����� ������" (����)
	   out   DDRD,temp_L
	   ldi   temp_L,0b00001000;��� �������� �� ������ PD3  
	   out   PORTD,temp_L;
;
       ldi   temp_L,0b11111111;(P�1-P�7)-������
       out   DDRC,temp_L
;Analog-to-digital
       ldi   temp_L,0x00
	   out   DDRA,temp_L; ����� ���
;       
;(Internal 2.56V Voltage Refer. with external capacitor at AREF pin)REFS1,REFS0=1
;0-� ����� ADC0
       ldi   temp_L,(0<<REFS1)|(0<<REFS0);
	   out   ADMUX,temp_L  
;
       ldi   temp_L,(1<<ADPS2)|(1<<ADPS1);
	   out   ADCSR,temp_L
;
       clr   byte_fl
	   clr   cou_ADC
;	      
	   clr   ADC_h;
       clr   ADC_l
;
       clr   Disp_Numb
	   clr    Hundreds;��������� ����������� 0 ����.
       clr    Tens
       clr    Ones
	   ldi    Number,0;0-� �����
	   ldi    Disp_Count,Val_dispCount
       sei	   
; 
;;==================================================
;������ ����� ���������
;==================================================
Start:    rcall  start_ADC
;
wait_ADC: rcall  Display
          sbrs   byte_fl,F_end_ADC
          rjmp   wait_ADC
		  rcall  out_ADC
          sbrc   Byte_fl,Disab_Key;
          rjmp   Start;   wait_ADC
          sbis   PinD,3;�������� ������� ������
          rcall  izm_Nkan;;�� ������� ������ ������������� ���� ��������� ������
          rjmp   Start;   wait_ADC
;==================================================	   
; ����� ����� ���������	   
;==================================================
; ������������ ����� ������ ��������������
;==================================================
izm_Nkan:   
			set
	   		bld    Byte_fl,Disab_Key; ��� ������. ������ ������ "����� ������" �� ��������
			
			clt
            sbrs  byte_fl,F_iz_kan
		    set
            bld   byte_fl,F_iz_kan
;�������� � ������ ���
            in     temp_L,ADMUX
            andi   temp_L,0b11100000
ch_mux_ADC: sbrs  byte_fl,F_iz_kan
            rjmp  kanN2
			ldi   Number,3;3-� ����� 
            ori   temp_L,(1<<MUX0)|(1<<MUX1)
ex_c_mux:	out   ADMUX,temp_L
            ldi   temp_L,(1<<CS02)|(1<<CS00);������� TCNT0 Clk/1024,(CS02,CS01,CS00) - 101
            out   TCCR0,temp_L
	        ldi   temp_L,(1<<TOIE0);TOIE0-Timer/Counter0 Overflow Interrupt Enable
	        out    TIMSK,temp_L; ��������� ���������� Tov0
            ret
;---------------
kanN2:      ldi   Number,0;0-� ����� 
            rjmp  ex_c_mux
;**************************************************
; ������������ ������� �������������� ���
;**************************************************
start_ADC:  ldi   temp_L,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1);�-�� ������.64(125���)
			out   ADCSR,temp_L
            ldi   temp_L,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADSC);
			out   ADCSR,temp_L
			ret 
;**************************************************
;������������ out_ADC ��������� ������ ��������� �� �������
;**************************************************
;������ � ��� ����������� ����� ������������ (Val_N_ADC=1,2,4,8.16) ��� � ����������
;�������� ��������, ��������� ��� ������� ����� ������
;���������� �������� Vin=(ADC*2,54)/1024=ADC/400. ���������� ������ ����� ����� ���
;������ �� �������, �.�. Vin*100. ����� ������� ���������� �������� ����� ADC/4
;���������� � 100 ��� ��� ������ �� ������� ������������ ������� ����� � ������
; ��.�����
;���-�� ������� ������ ��� ���-� �����.��������
out_ADC:    ldi    temp_L,Val_N_ADC;
            cpi    temp_L,8; 8 ����������
			brne   ch_4izm
			ldi    temp_L,3
			rjmp   sh_ADC
ch_4izm:    cpi    temp_L,4; 4 ����������
			brne   ch_2izm
            ldi    temp_L,2
			rjmp   sh_ADC
ch_2izm:    cpi    temp_L,2; 2 ����������
			brne   ch_1izm 
			ldi    temp_L,1
			rjmp   sh_ADC  
ch_1izm:    cpi    temp_L,1
			breq   norm_ADC  
            rjmp   ex_out 
sh_ADC:		lsr    ADC_h 		   
            ror    ADC_l
		    dec    temp_L
		    cpi    temp_L,0x00
		    brne   sh_ADC;� ADC_h,ADC_l ������� ��������
;
norm_ADC:   lsr    ADC_h 		   
            ror    ADC_l
			;lsr    ADC_h 		   
            ;ror    ADC_l; � ADC_l ��������,����������� � 100 ���
;
            mov    temp_L,ADC_l
			mov    temp_H,ADC_h
            clr    ADC_h
       		clr    ADC_l
			rcall  digitConvert
			clt
			bld    byte_fl,F_end_ADC
ex_out:     ret
;**************************************************
; ������������ Display ������ � �������� (�����. ���������)
;**************************************************  
Display:   dec   Disp_Count
           brne  ex_displ
;
           ldi   Disp_Count,Val_dispCount
;           
		   inc   Disp_Numb
		   cpi   Disp_Numb,4
		   brne  Out_disp
		   clr   Disp_Numb

;
Out_disp:  
           ldi   ZL,18;     ;��������� �� Number
		   ldi   ZH,00
           add   ZL,Disp_Numb
		   ld    temp_L,Z
		   cpi   Disp_Numb,1;������� Hundreds
		   breq  sym_toch
;                           ����������� � �������������� ���
           ldi   ZL,low(TABLE*2);��������� ����� ������ 
	       ldi   ZH,high(TABLE*2);������� � ������ �������� (*2 - ��� �������� 
out_date:  add   ZL,temp_L   ;���������)
	       lpm   temp_L,Z    ;������ �������������� ��� �������� ; 
		   out   PortC,temp_L; �������� �� ���������
;
           in    temp_L,PINB
		   lsr   temp_L
		   brcc  PC+2
		   ldi   temp_L,0b00001000; � ������ (Number)	   
           out   PORTB,temp_L
		   ;
ex_displ:  ret
;________________________________
sym_toch:  ldi   ZL,low(TABLE1*2);��������� ����� ������ 
	       ldi   ZH,high(TABLE1*2);������� � ������ �������� (*2 - ��� �������� �����.
           rjmp  out_date
;==================================================
;------- ������� ������������� ��������
TABLE:    .db   0b00111111,0b00000110; ���� "0","1"
          .db   0b01011011,0b01001111; ���� "2","3"
          .db   0b01100110,0b01101101;;���� "4","5"
		  .db   0b01111101,0b00000111;;���� "6","7"
		  .db   0b01111111,0b01101111;;���� "8","9" 
;==================================================
;------- ������� ������������� �������� c ������, ���������� ����� ����� �� �������
TABLE1:   .db   0b10111111,0b10000110; ���� "0","1"
          .db   0b11011011,0b11001111; ���� "2","3"
          .db   0b11100110,0b11101101;;���� "4","5"
		  .db   0b11111101,0b10000111;;���� "6","7"
		  .db   0b11111111,0b11101111;;���� "8","9" 
;==================================================
;****************************************************
;������������ �������� 1-e ������� ����� � �������-���������� ��� 
;===================================================
digitConvert:
            clr   Hundreds
			clr   Tens  
			clr   Ones
;
FindHundreds:
            subi  temp_L,100
			sbci  temp_H,0;
			brcs  FindTens
            inc   Hundreds
			rjmp  FindHundreds
;
FindTens: 
            subi  temp_L,-100
            subi  temp_L,10
            brcs  FindOnes
            inc   Tens 
			rjmp  FindTens+1
;
FindOnes:
            subi  temp_L,-10
            mov   Ones,temp_L
            ret
;*******************************************
;Subroutine interrupt ADC
;***********************************
IN_ADC:    push   temp_L
           push   temp_H
           in     temp_L,SREG
		   push   temp_L
;            
rd_ADC:	   in     temp_L,ADCL
		   in     temp_H,ADCH
		   add    ADC_l,temp_L
		   adc    ADC_h,temp_H 
           inc    cou_ADC
           cpi    cou_ADC,Val_N_ADC;�����-�� �������������� ���
           breq   end_ADC
           ldi   temp_L,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADSC);;start convers.
           out    ADCSR,temp_L
ex_INADC:  pop    temp_L         
           out    SREG,temp_L
		   pop    temp_H
		   pop    temp_L
           reti
;-------------------------
end_ADC:   clr    cou_ADC
           set
		   bld    byte_fl,F_end_ADC
		   rjmp   ex_INADC
;*******************************************
;Subroutine interrupt Overflow 0  
;������������ ��������� ���������� ������������ ������� �0
;�0 - 8 ���� ������. Counter0 �verflow ������������������� 256*1024/8000000=0,033�
;�� 1c�� =(1024/8000000)*256*N_��������(������������)=30 ������������
;(�������������� ������������ �� �������� ��������� ������ "��������")
;*********************************************
time_d_k:  push   temp_L
           in     temp_L,SREG
		   push   temp_L 
;            
           inc    Time
		   cpi    Time,VAL_time 
		   brne   ex_timDK
		   clt
		   bld    Byte_fl,Disab_Key; ��� ����. ������ ������ "��������" �� ��������
	       ldi    temp_L,0x00;(1<<CS02)|(1<<CS00);No clock source,(CS02,CS01,CS00) - 000
           out    TCCR0,temp_L
	       in     temp_L,TIMSK
	       clt
	       bld    temp_L,TOIE0 ;TOIE0-Timer/Counter0 Overflow Interrupt Enable
	       out    TIMSK,temp_L; ���������� ���������� Tov0
		   clr    Time
;
ex_timDK:  pop    temp_L         
           out    SREG,temp_L
		   pop    temp_L
           reti
;***********************************
