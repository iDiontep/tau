;*************************************
;* Designer        Faller VV.
;* Version:        5.0
;* Date            08.05.2024
;* variant		   7
;* Title:          Countert.asm
;* Device          ATmega16
;* Clock frequency: 8 MHz Crystal Resonator
;*************************************

.include "m16def.inc"


.def tempL	  = R16				; registers
.def tempH    = R17             ; 
.def temp	  = R18				; 
.def Counter  = R19             ;
.def Delay1   = R20;
.def Delay2   = R21;counter for time delay
.def Delay3   = R22;
.def Delay4   = R23;
.def timtime  = R24;

;***************** 
; Constants
;*****************
.equ Val_del1=0x00;0x00;time delay time 1.5 sec
.equ Val_del2=0x94;0x94;
.equ Val_del3=0x35;0x35;(������� 8���,����� �������� 1500 ��
.equ Val_del4=0x77;0x77 5����.���������� ������ 
;                  ����=2000000000 (77359400) <=>(1/8000000)*6*����=1500 ����) 
;			   
;***********************************
.cseg
.org $0000
rjmp Init

;****************
;init basic comands
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
Init:
	ldi	   tempL, Low(RAMEND)	; ����� ������� �����
	ldi    tempH, High(RAMEND)  ; ��������� �����
	out	   SPL, tempL           ; �� ��������� ����� ����
	out    SPH, tempH           ; 
; Initialize Ports
Init_A:    	ldi temp, 0b11111111    ; PortA ������ ������
    		out DDRB, temp
    		ldi temp, 0b00001000    ; ������ pa3
    		out PORTB, temp
    
Init_B:	ldi temp, 0b00000000    ;PortB ������ �����
    	out DDRD, temp
    	ldi temp, 0b00010000    ;pb4 ������ ��������� ������� ������
    	out PORTD, temp
    
    	ldi Counter, 0x00 ; ������������� ��������



Start:
    sbic PIND, 4       ; �������� ������� PB4
    rjmp Start      ; ���� �� ������ - �������
delay_0:  rcall delay_DK; ���������� ��������
Otpuskanie:				; �������� ���������� �������
	sbis PIND, 4;		; ������ ������? 
	rjmp Otpuskanie;	; ���� �� ������ - �������
MainCycle:
    inc Counter        ; ��������� ������� ��������� ����������

    cpi Counter, 4  ; �������� ������������ (�� �� ����� 4 ���������)
    brne CheckCounter  ; ��������� ������� ���� ��� ������������

    ldi Counter, 0  ; ����� ����� �� ������������

CheckCounter:
	      ldi   ZL,TABLE*2;��������� �������
	      ldi   ZH,0x00   ;������� � ������ �������� (*2 - ��� �������� 
	      add   ZL,Counter;���������)
	      lpm   temp,Z    ;������ �������������� ��� �������� Counter
		  out   PORTB,temp;�������� �� ���������   
delay_long:  rcall Delay  ;�������� 1.5 sec
    	  sbic PIND, 4       ; �������� ������� PB4
   		  rjmp MainCycle      ; e��� �� ������ - �������

;	  ���������� �������� ������� ���������� ������ ��������
delay_2:  rcall delay_DK ;���������� ��������
  Otpuskaniie:
  	sbis PIND, 4;
	rjmp Otpuskaniie;	; ���� �� ������ - �������		;
	rcall delay_DK
    rjmp Start      ; � ������
;************
;������������ �������� �� ��������� ��������
;************
Delay:
    ldi   Delay1,Val_del1;
    ldi   Delay2,Val_del2 
    ldi   Delay3,Val_del3 
    ldi   Delay4,Val_del4    ; ���� ��� 1.5 sec
delay_loop:
        subi  Delay1,1; ���� - 5 ������
        sbci  Delay2,0;
	    sbci  Delay3,0;
		sbci  Delay4,0;
	    brcc  delay_loop
End_delay:    ret
;************
;������������ �������� ���������� �������� ���������
;************
Delay_DK: ldi   Delay1,0x40;�������� �������� ����� �������� 0.05 ���
          ldi   Delay2,0x1F
          ldi   Delay3,0x00

cycle:    subi  Delay1,1; ���� - 5 ������
          sbci  Delay2,0
	      sbci  Delay3,0
	      brcc  cycle
End_delay_DK: ret 

	
;------- ������� ������������� ��������
TABLE:    .db   0b00001000,0b00000100; ���� "0","1"
          .db   0b00000010,0b00000001; ���� "2","3"
