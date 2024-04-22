;*************************************
;* Designer        Mechtcherjakowa R.I.
;* Version:        1.0
;* Date            15.03.2010
;* Title:          contr_UART.asm
;* Device          ATmega16
;* Clock frequency:������� ��.���������� 9,216 mHz
;*************************************
; �������
;*************************************
;���������  ������������ ����� �� ���������� RS-232 ����� ������������ �����������
;� �������� ������.� �������� ����� ��������������� ��������������� ATmega16
;� ��������������� ���������������� ������  USART. �������������� � ��������� 
;RS-232 ����������� ����������� Max232, ������������� � �������� �����.
;��������/����� ������ �� USART �������������� �� ���������� �����������:
;�)�������� ������ 19200���/���;
;�)������ ������� 11 ��� ����������:
;      -  �����-���;
;      -  8 ��� ������;
;      -  ��� �������� �������� - ���������� �� ����������;
;      -  ���� ���� ���.
;������ USART(RXD) PD0 (����),(TXD) PD1(�����)
;��� ������ ����� �������  ���������� ���������  ��� "������", ������������
;� PB7 ( �����)
;����� �������� � �������������� � ������ ������ ����� ����������� �� 
;�����������.����������� ��������������� ���� �� ������,������� ������
;"��������",������������ � PD4( ����1, ����2, ����3, ����4,����5,����6,����7,����1..).
;������� ����� ��������� ��������������� ����� ���������������� �����
;������ "�����", ���������������� �������� ������� ����������.���������� � PB7,��� ����
;��� ������ 
;�������������� ���������� ���������� � P�0-P�7-������,�������������� ��������� �  P�0-P�7 
;PC0-a,PC1-b,P�2-c,P�3-d,P�4-e,P�5-f,P�6-g,P�7-h
;������� ������ ���������� PB3-����� �����,PB2 - �����,PB1-�������,PB0 - �������- ������
;***********************************************
;***********************************************
.include "m16def.inc"
; ������������� ����� ��������; 
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def temp_L     =R16
.def temp_H     =R17
; 
.def Number     =R18 
.def Hundreds   =R19;
.def Tens       =R20
.def Ones       =R21
;
.def Disp_Numb  =R22
.def Disp_Count =R23
;
.def res_a_op   =R8;
.def Time       =R25;������� ��������.�0(1024*255/9216000*Xotc=1cek(Xotc=35) 
;
.def Cou_Rec    =R4;������� �������� ����
.def Cou_Tran   =R5;������� ���������� ����
.def c_sumREC   =R6;����� ����� ����. ����
.def c_sumTRAN  =R7;����� ����� ���������� ����
.def n_ar_op    =R24 
;*******************
.def Byte_fl    =R2; ���� ������
;-------------------
.equ   Disab_Key  =0; ��� ���������� ������ ������ "��������"
.equ   F_receive   =1;���� ��������� �������
.equ   F_trans    =2;���� ���������� �������� 
;******************* 
; Constants
;*****************
.equ Val_dispCount=50;�������� ���������,���. ����� ��� ���������� 
.equ CID          =7;PDB ����������� ��� 
.equ ENV          =7;������ "�����", ���������� � PD7
;========================================
;���������� ���� ������ � ����
;----------------------------------------
.equ   VAL_TR  =3
.equ   VAL_REC =4
.equ   VAL_time =35;35 ������������ ������������� 1 ���
;***************************************
;Variable
;***************************************
.DSEG 
;
varBuf_Rxd:    .BYTE 8;����� ������(4 �����)
;
varBuf_Txd:    .BYTE 8;����� �������� (3 �����)
;
varBuf_disp:   .BYTE 8;����� ������,��������� �� ������� (7 ����)
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
rjmp  Time_OUT
.org  OC1Baddr;=$00E	;Output Compare1B Interrupt Vector Address
reti
.org  OVF1addr;=$010	;Overflow1 Interrupt Vector Address
reti
.org  OVF0addr;=$012	;Overflow0 Interrupt Vector Address
rjmp  time_d_k ;
.org  SPIaddr; =$014	;SPI Interrupt Vector Address
reti
.org  URXCaddr;=$016	;UART Receive Complete Interrupt Vector Address
rjmp  REC_date
.org  UDREaddr;=$018	;UART Data Register Empty Interrupt Vector Address
rjmp  B_TRANS
.org UTXCaddr; =$01A	;UART Transmit Complete Interrupt Vector Address
rjmp  TRANdate
.org ADCCaddr; =$01C	;ADC Interrupt Vector Address
reti
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
; Start Of Main Program
;***********************************
Init:
       ldi   temp_L,LOW(RAMEND);����� ������� �����
	   out   SPL, temp_L;��������� ����� 
	   ldi   temp_L,HIGH(RAMEND)
	   out   SPH,temp_L
;
; ------������������� ������ �/B
;
	   ldi   temp_L,0b11111111;(PB1-PB7)-������,
       out   DDRB,temp_L
       ldi   temp_L,0b00001000;������� PB3-����� ����� (1-� ���������)
	   out   PORTB,temp_L
;
       ldi   temp_L,0b00000010;PD1-�����(Txd),(PD0,PD2-PD7)-�����
	   out   DDRD,temp_L
	   ldi   temp_L,0b11111111;��� �������� �� ������� PD0, PD2-PD7.   
	   out   PORTD,temp_L;
;
       ldi   temp_L,0b11111111;;(PC0-PC7)-������
	   out   DDRC,temp_L

;
;INIT USART
       ldi   temp_L,14;(������� ��. 9,216 ���,�������� ������ 19200),U2X0=0,������ ��� �� ������
       ldi   temp_H,00 
	   out   UBRRL,temp_L;
	   out   UBRRH,temp_H
	   ldi   temp_L,(1<<RXEN)|(1<<RXCIE);UCSZ2=0,UCSZ1=1,UCSZ0=1 - 8 bit
	   out   UCSRB,temp_L
	   ldi   temp_L,(1<<URSEL)|(1<<UCSZ0)|(1<<UCSZ1);- 1 stop bit,
	   out   UCSRC,temp_L;
	   
; ---  �������������  ������� TCNT0

;
;      �������������  ������� TCNT1 
       ldi   temp_L,00;compare A,(COM1A1,COM1A0=00) OC1A disconnect
       out   TCCR1A,temp_L;
	   ldi   temp_L,(1<<WGM12);WGM13=0,WGM12=1,WGM11=0,WGM10=0,����� CTC
;                             No clock source,CS42,CS41,CS40=000
	   out   TCCR1B,temp_L;(No prescaling CS10=1
	   ldi   temp_H,0xD8  ; time_out 6mcek - 0,006*9216000=55296(D800)
	   ldi   temp_L,0x00  ;
       out   OCR1AH,temp_H
	   out   OCR1AL,temp_L
;
       ldi   Disp_Count,Val_dispCount
	   clr   Disp_Numb 	    	     
       clr   Byte_fl
	   clr   Cou_Rec
	   clr   Cou_Tran
       clr   c_sumREC
	   clr   Time
	   ldi    Number,1
;��������� SRAM
       ldi    YL,low(varBuf_disp)  ; Y register low ����� ������,��������� �� �������
       ldi    YH,high(varBuf_disp) ; Y register high ����� ������,��������� �� �������
	   ldi    temp_L,0x00;��������� ��������� ������ ������,��������� �� �������
	   ldi    temp_H,VAL_TR + VAL_REC
LoadBdsp: st     Y+,temp_L
	   dec    temp_H
	   cpi    temp_H,0x00     
       brne   LoadBdsp
; 
	   ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
       ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
       ldi    temp_L,0x00
	   ldi    temp_H,VAL_REC
ld_b_r:st     Y+,temp_L;��������� ��������� ����� ������
       dec    temp_h
	   cpi    temp_H,0x00     
       brne   ld_b_r 
;

       ldi    YL,low(varBuf_Txd); Load Y register low ����� ��������
       ldi    YH,high(varBuf_Txd) ; Load Y register high ����� ��������
       ldi    temp_L,0x00
	   ldi    temp_H,VAL_TR
ld_b_t:st     Y+,temp_L;��������� ��������� ����� ��������
       dec    temp_h
	   cpi    temp_H,0x00     
       brne   ld_b_t 
;
       ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
       ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
;
       sei             ;��������� ����������

	   clr Hundreds
       clr Tens
       clr Ones
;==================================================
;������ ����� ���������
;==================================================
Start: rcall  Display
       sbrc   Byte_fl,F_receive;�������� ����� ��������� �������
	   rjmp   Receive
       sbrc   Byte_fl,Disab_Key; 
	   rjmp   Start
       sbic   PinD,4;�������� ������� ������
	   rjmp   Start
	   rcall  ch_pos_D	   
	   rjmp   Start       
Receive: 
       sbi    PORTB,CID
	   rcall  Wr_D_rec
       rcall  arifm_op
       rcall  pre_date
       rcall  Wr_D_tr
Wait:  sbis   PIND,ENV
       rjmp   Trans
       rcall  Display
       sbrc   Byte_fl,Disab_Key; 
	   rjmp   Wait
       sbic   PinD,4;�������� ������� ������
	   rjmp   Wait
       rcall  ch_pos_D
	   rjmp   wait
Trans: ldi    temp_L,(1<<TXEN)|(1<<UDRIE);UCSZ2=0,UCSZ1=1,UCSZ0=1 - 8 bit
	   out    UCSRB,temp_L;������� � �������� ����� ����� ���������� UDRE

Wait_tr: sbrs   Byte_fl,F_trans
       rjmp   Wait_tr
	   clt
	   bld    Byte_fl,F_trans
       rjmp   Start
;==================================================	   
; ����� ����� ���������	   
;==================================================
;**************************************************	
;������������ ��������� ������� ��������� �� ������
;**************************************************
ch_pos_D:
       cpi    Number,7;7 ������� ���������
	   brne   PC+2
       ldi    Number,0
       ldi    XL,low(varBuf_disp)  ; XL register low ����� ������,��������� �� �������
       ldi    XH,high(varBuf_disp) ; XH register high ����� ������,��������� �� �������
       ldi    temp_H,0x00
	   add    XL,Number 
	   adc    XH,temp_H
	   ld     temp_L,X
	   rcall  digitConvert
;      
       inc    Number
	   set
	   bld    Byte_fl,Disab_Key; ��� ������. ������ ������ "��������" �� ��������
	   ldi    temp_L,(1<<CS02)|(1<<CS00);������� TCNT0 Clk/1024,(CS02,CS01,CS00) - 101
       out    TCCR0,temp_L
	   in     temp_L,TIMSK;UDRIE 5 10
	   set
	   bld    temp_L,TOIE0 ;TOIE0-Timer/Counter0 Overflow Interrupt Enable
	   out    TIMSK,temp_L; ��������� ���������� Tov0
       ret
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

Out_disp:  
           clr   ZH
		   ldi   ZL,18;     ;��������� �� Number
           add   ZL,Disp_Numb
		   ld    temp_L,Z
;                           ����������� � �������������� ���
           ldi   ZL,low(TABLE*2);��������� ����� ������ 
	       ldi   ZH,high(TABLE*2);������� � ������ �������� (*2 - ��� �������� 
	       add   ZL,temp_L   ;���������)
	       lpm   temp_L,Z    ;������ �������������� ��� �������� ; 
		   out   PortC,temp_L; �������� �� ���������
;
           in    temp_L,PINB
		   in    temp_H,PINB
		   andi  temp_L,0b00001111
		   andi  temp_H,0b10000000
		   lsr   temp_L
		   brcc  PC+2
		   ldi   temp_L,0b00001000; � ������ (Number)
		   or    temp_L,temp_H	   
           out   PORTB,temp_L
		   
;
ex_displ:  ret
;
;==================================================
;------- ������� ������������� ��������
TABLE:    .db   0b00111111,0b00000110; ���� "0","1"
          .db   0b01011011,0b01001111; ���� "2","3"
          .db   0b01100110,0b01101101;;���� "4","5"
		  .db   0b01111101,0b00000111;;���� "6","7"
		  .db   0b01111111,0b01101111;;���� "8","9" 
		  .db   0b10000000,0b00000000; ���� " "," "
;==================================================
Wr_D_rec: ;������������ ������ �������� ������ � ����� �������
;**************************************************
            ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
            ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
            ldi    XL,low(varBuf_disp)  ; XL register low ����� ������,��������� �� �������
            ldi    XH,high(varBuf_disp)
			ldi    temp_H,VAL_REC
Loop_wD:	ld     temp_L,Y+
			st     X+,temp_L
			subi   temp_H,1
			breq   PC+2
            rjmp   Loop_wD
            ret
;**************************************************
arifm_op:;������������ ���������� �������������� ��������
;��������� ������� ����- temp_H,������� ���� - temp_L
;==================================================
            clr    res_a_op;���� ������������� ����������� 
            ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
            ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
			ld     temp_L,Y
			cpi    temp_L,0x01
			breq   add_1_b
			cpi    temp_L,0x02
			breq   sub_1_b
			cpi    temp_L,0x03
			breq   mul_1_b
			cpi    temp_L,0x04
			breq   div_1_b  
ex_ar_op:   ret
;------------------------
;�������� �������� �����
add_1_b:    ldd    temp_L,Y+1
            ldd    temp_H,Y+2
            add    temp_L,temp_H
			ldi    temp_H,0x00
			mov    res_a_op,temp_H
			adc    temp_H,res_a_op
            rjmp   ex_ar_op
;------------------------
;��������� �������� �����
sub_1_b:    ldd    temp_L,Y+1
            ldd    temp_H,Y+2
            sub    temp_L,temp_H
			ldi    temp_H,0x00
			sbci   temp_H,0x00  
            rjmp   ex_ar_op
;-------------------------
;��������� �������� �����
mul_1_b:    ldd    temp_H,Y+1;��������
            ldd    temp_L,Y+2;���������
			ldi    n_ar_op,8;��������������� �����
            clr    res_a_op

cycle_m:    sbrc   temp_L,0
			add    res_a_op,temp_H
			lsr    res_a_op
			ror    temp_L
			subi   n_ar_op,1
			brne   cycle_m
            mov    temp_H,res_a_op 
            rjmp   ex_ar_op
;-------------------------
;������� �������� �����
div_1_b:    ldd    temp_H,Y+1;�������
            ldd    temp_L,Y+2;��������
Divide:     sub    temp_H,temp_L
            brcs   DoneDividing
		    inc    res_a_op 
		    rjmp   Divide
DoneDividing:
            neg    temp_L
			sub   temp_H,temp_L
			mov    temp_L,temp_H
            mov    temp_H,res_a_op  
            rjmp   ex_ar_op
;****************************************************
pre_date:;������������ ���������� ������ � ��������
;****************************************************
            ldi    YL,low(varBuf_Txd); Load Y register low ����� ��������
            ldi    YH,high(varBuf_Txd) ; Load Y register high ����� ��������
            clr    c_sumTRAN
			add    c_sumTRAN,temp_H
			st     Y+,temp_H
            add    c_sumTRAN,temp_L
			st     Y+,temp_L
			com    c_sumTRAN
			st     Y+,c_sumTRAN 
            ret
;****************************************************
Wr_D_tr:;������������ ������  ������  �������� � ����� �������
;****************************************************            
            ldi    YL,low(varBuf_Txd); Load Y register low ����� ��������
            ldi    YH,high(varBuf_Txd) ; Load Y register high ����� ��������
            ldi    temp_L,VAL_REC; �������� 4
			ldi    temp_H,0x00			
            ldi    XL,low(varBuf_disp);XL register low ����� ������,��������� �� �������
            ldi    XH,high(varBuf_disp)
            add    XL,temp_L
			adc    XH,temp_H
			ldi    temp_H,VAL_TR
            rcall  Loop_wD
            ret
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
;Subroutine interrupt Overflow 0
;(�������������� ������������ �� �������� ��������� ������ "��������")  
;������������ ��������� ���������� ������������ ������� �0
;�0 - 8 ���� ������. Counter0 �verflow ������������ ������� 
;�� 1c�� =(1024/9216000)*256*N_��������(������������)=35 ������������
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
;Subroutine interrupt USART RX Complete
;***********************************
REC_date: push   temp_L
          push   temp_H 
          in     temp_L,SREG
          push   temp_L
;
		  in    temp_H,UCSRA
rd_UDR:	  in    temp_L,UDR
		  rjmp   rt_rec
;
pop_rec: 
          pop    temp_L
		  out    SREG,temp_L
		  pop    temp_H
		  pop    temp_L
		  reti
;***********************************
rt_rec: 
          andi   temp_H,(1<<FE)|(1<<DOR)|(1<<PE)
          breq   USART2NoError
          rjmp   pop_rec
USART2NoError:            
		  st     Y+,temp_L
		  inc    Cou_Rec
		  mov    temp_H,Cou_Rec
		  cpi    temp_H,0x01
		  breq   rec_1_b
		  cpi    temp_H,VAL_REC
		  breq   rec_end
		  add    c_sumREC,temp_L
		  rjmp   pop_rec
rec_1_b:  add    c_sumREC,temp_L
          in     temp_L,TIMSK
		  set
		  bld    temp_L,OCIE1A;OCIE1A ��������� ����������
		  out    TIMSK,temp_L
		  ldi    temp_L,(1<<WGM12)|(1<<CS10);WGM3=0,WGM2=1,WGM1=0,WGM0=0,����� CTC
;                             clkI/O/1 (No prescaling),CS2,CS1,CS0=001
	      out    TCCR1B,temp_L;(No prescaling CS0=1 
          rjmp   pop_rec
rec_end: 
		  com    temp_L;�������� ��������� �����
          cp     temp_L,c_sumREC; �������� ����� �����
		  brne   ex_rec
		  set
		  bld    Byte_fl,F_receive;����� ������ ������
;          
ex_rec:   in     temp_L,TIMSK
          clt
		  bld    temp_L,OCIE1A;OCIE1A ��������� ����������
          out    TIMSK,temp_L
		  ldi    temp_L,(1<<WGM12);WGM3=0,WGM2=1,WGM1=0,WGM0=0,����� CTC
;                             clkI/O/1 (stop TCNT1),CS2,CS1,CS0=000
          out    TCCR1B,temp_L
		  ldi    temp_L,0x00
		  ldi    temp_H,0x00
		  out    TCNT1H,temp_H
		  out    TCNT1L,temp_L
		  clr    Cou_Rec
		  clr    c_sumREC
		  ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
          ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
          rjmp   pop_rec
;***********************************        
;Subroutine interrupt USART Data register Empty
;***********************************
B_TRANS:  push   temp_L
          in     temp_L,SREG
          push   temp_L
;
		  ldi    temp_L,(1<<TXEN)|(1<<TXCIE);��������� ���������� TXC
	      out    UCSRB,temp_L
          ldi    YL,low(varBuf_Txd); Load Y register low ����� ��������
          ldi    YH,high(varBuf_Txd); Load Y register high ����� ��������
		  ld     temp_L,Y+
		  clt
          bld    Byte_fl,F_receive;
		  out    UDR,temp_L
;
          pop    temp_L
		  out    SREG,temp_L
		  pop    temp_L
          reti 
;***********************************
;Subroutine interrupt USART, Tx Complete
;***********************************
TRANdate: push   temp_L
          in     temp_L,SREG
          push   temp_L
		  push   temp_H
          rjmp   r_trans
;
pop_tran:
		  pop    temp_H
		  pop    temp_L
		  out    SREG,temp_L
		  pop    temp_L
;
          reti
;
r_trans:  inc    Cou_Tran
		  mov    temp_L,Cou_Tran
		  cpi    temp_L,VAL_TR 
          breq   end_tr
          ld     temp_L,Y+
          out    UDR,temp_L
		  rjmp   pop_tran
		  
end_tr:   clr    Cou_Tran
		  ldi    temp_L,(1<<RXEN)|(1<<RXCIE);
	      out    UCSRB,temp_L
		  ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
          ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������
		  cbi    PORTB,CID
		  set
		  bld    Byte_fl,F_trans
		  rjmp   pop_tran
;**********************************
;Subroutine interrupt OC1A
;**********************************
Time_OUT:  push   temp_L
           push   temp_H 
           in     temp_L,SREG
		   push   temp_L
;
           ldi    temp_L,(1<<WGM12);WGM13=0,WGM12=1,WGM11=0,WGM10=0,����� CTC
;                             No clock source,CS42,CS41,CS40=000 
           out    TCCR1B,temp_L;
		   in     temp_L,TIMSK
           clt
		   bld    temp_L,OCIE1A;OCIE1A ��������� ����������
           out    TIMSK,temp_L
           ldi    temp_H,0x00
		   ldi    temp_L,0x00  ;
           out    TCNT1H,temp_H;����� ��������
		   out    TCNT1L,temp_L
		   clr    Cou_Rec
		   clr    c_sumREC
		   ldi    YL,low(varBuf_Rxd)  ; Load Y register low ����� ������
           ldi    YH,high(varBuf_Rxd) ; Load Y register high ����� ������		   
;
		   pop    temp_L
		   out    SREG,temp_L
		   pop    temp_H 
           pop    temp_L
           reti
;**********************************
