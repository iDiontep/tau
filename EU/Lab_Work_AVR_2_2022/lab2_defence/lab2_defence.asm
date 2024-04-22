;*************************************
;* Designer        Ionin D.A..
;* Version:        3.0
;* Date            21.04.2024
;* Title:          Countert.asm
;* Device          ATmega16
;* Clock frequency: 8 MHz Crystal Resonator
;*************************************

.include "m16def.inc"


.def tempL	  = R16				; registers
.def tempH    = R17             ; 
.def temp	  = R18				; 
.def Counter  = R15             ;
.def Delay1   = R20;
.def Delay2   = R21;counter for time delay
.def Delay3   = R22;
.def Delay4   = R23;
.def Random	  = R24;
.def CountX   = R14;

;***************** 
; Constants
;*****************
.equ Val_del1=0xAB;0x80;time delay time
.equ Val_del2=0x1A;0x38;
.equ Val_del3=0xF2;0x05;(������� 8���,����� �������� 2000 ��
.equ Val_del4=0x9E
.equ Val_del5=0x9E
;5����.���������� ������ 
;                  ����=6 222 222 222 (01 72 DF 35 56) <=>(1/8000000)*6*����=2000 ����) 
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
	ldi	   tempL, Low(RAMEND)	; vibor vershini steka
	ldi    tempH, High(RAMEND)  ; ukazatel steka
	out	   SPL, tempL           ; 
	out    SPH, tempH           ; 
; Initialize Ports
Init_A:    	ldi temp, 0b11111111    ; Set PortA as outputs
    		out DDRA, temp
    		ldi temp, 0b00000011    ; Set PB4 as input
    		out PORTA, temp
    
Init_B:	ldi temp, 0b00000000    ; Set PortA as outputs
    	out DDRB, temp
    	ldi temp, 0b00010000    ; Enable pull-up for PB4
    	out PORTB, temp

Init_D:	ldi temp, 0b00000000    ; Set PortA as outputs
    	out DDRD, temp
    	ldi temp, 0b00000100    ; Enable pull-up for PD2
    	out PORTD, temp
    
    	ldi Counter, 0x00 ; Initialize counter

MainLoop:
   KeyIsPress:  
	sbic  PinD, PD2				; �������� ������� ������
    rjmp  KeyIsPress		    ; ���� ������ �� ������, �� ������� �������
KeyIsRelease:  
	sbis  PinD, PD2				; �������� ���������� ������
    rjmp  KeyIsRelease			; ���� ������ �� ��������, �� ������� ����������
DelayAfterPress:  
	rcall Delay_DK	


Podschet:
    inc Counter        ; Increment counter

    cpi Counter, 4  ; Check if counter equals 3
    brne CheckCounter  ; If not 3, continue

    ldi Counter, 0  ; Reset counter after reaching 3

CheckCounter:
Read:     ldi   ZL,TABLE*2;load start adress
	      ldi   ZH,0x00   ;������� � ������ �������� (*2 - ��� �������� 
	      add   ZL,Counter;���������)
	      lpm   temp,Z    ;������ �������������� ��� �������� Counter
Write_A:  out   PORTA,temp;�������� �� ��������� 
 
delay:  rcall delay_dk 
;delay  rcall Rand_delay:
Continue:
KeyIsPressAgain:  
	sbic  PinD, PD2				; �������� ������� ������
    rjmp  Podschet		    ; ���� ������ �� ������, �� ������� �������
KeyIsReleaseAgain:  
	sbis  PinD, PD2				; �������� ���������� ������
    rjmp  KeyIsRelease			; ���� ������ �� ��������, �� ������� ����������
DelayAfterPressAgain:  
	rcall Delay_DK	
	rcall Rand_delay

End_prog:
    rjmp MainLoop      ; Continue looping

Delay:
    ldi   Delay1,Val_del1;
    ldi   Delay2,Val_del2 
    ldi   Delay3,Val_del3 
    ldi   Delay4,Val_del4    ; Load delay value
delay_loop:
        subi  Delay1,1; loop -6 counts
        sbci  Delay2,0;
	    sbci  Delay3,0;
		sbci  Delay4,0;
	    brcc  delay_loop
End_delay:    ret

Delay_DK: ldi   Delay1,0x40;�������� ��������
          ldi   Delay2,0x1F
          ldi   Delay3,0x00

cycle:    subi  Delay1,1; ���� - 6 ������
          sbci  Delay2,0
	      sbci  Delay3,0
	      brcc  cycle
End_delay_DK: ret 

Rand_delay:  
		  mov    temp,Random;��������� ��������� ��������� ����� 
          add    Random,temp;�������� �� 5 ���������
          add    Random,temp;��������� ����� � ���������(0-255)
          add    Random,temp
          add    Random,temp
          add    Random,temp
          inc    Random
;
          mov    temp,Random
		  					;�0 - 8 ���� ������. Counter0 �verflow ������������ 
		  					;������� 256*1024/8000000=0,033�.�������� (4...8,4�)->
							;��������� ��������(127+Random/2)
          lsr    temp; ������� �� 2
		             
	      subi   temp,-127;���������� ��������� ����� (�� 90 �� 256)
Rand_end: mov    CountX,temp

          ldi   temp,(1<<CS02)|(1<<CS00);������� TCNT0 Clk/1024,(CS02,CS01,CS00) ��������� ������������ �������
  	      out   TCCR0,temp;�������� ������

          ldi    temp,(1<<INTF0)
          out    GIFR,temp;���������� ���� ������.INT0 ������� 1

          ldi    temp,(1<<TOV0)
	      out    TIFR,temp;���������� ���� ������ TOV0 (���� ������. �� ������������) 

          sei             ;��������� ����������

		  rjmp	 Continue	          
		  ret
;------- ������� ������������� ��������
TABLE:    .db   0b00000011,0b00000110; ���� "0","1"
          .db   0b00001100,0b00000000; ���� "2","3"
