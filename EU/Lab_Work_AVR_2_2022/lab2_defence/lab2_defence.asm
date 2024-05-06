;*************************************
;* Designer        Ionin D.A..
;* Version:        5.0
;* Date            06.05.2024
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
.def RANDOM   = R25;
.def CountX   = R26;
;***************** 
; Constants
;*****************
;equ Val_del1=0xAB;0x80;time delay time
;equ Val_del2=0x1A;0x38;
;equ Val_del3=0xF2;0x05;(������� 8���,����� �������� 2000 ��
;equ Val_del4=0x9E;5����.���������� ������ 
;                  ����=2666666667 (9EF21AAB) <=>(1/8000000)*6*����=2000 ����) 
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
    
Init_D:	ldi temp, 0b00000000    ; Set PortA as outputs
    	out DDRD, temp
    	ldi temp, 0b00000100    ; Enable pull-up for PB4
    	out PORTD, temp
    
    	ldi Counter, 0x00 ; Initialize counter
		ldi timtime, 0b00000100
init_timer:
		ldi temp, (1<<ISC01)
		out MCUCR, temp;
		ldi temp, (1<<INT0)
		out GIMSK, temp;
		sei
		clr temp;



MainLoop:
    sbic PIND, 2       ; Check if button on PB4 is pressed
    rjmp MainLoop      ; Button not pressed, continue loop
MainCycle:
    inc Counter        ; Increment counter

    cpi Counter, 4  ; Check if counter equals 3
    brne CheckCounter  ; If not 3, continue

    ldi Counter, 0  ; Reset counter after reaching 3

CheckCounter:
	      ldi   ZL,TABLE*2;load start adress
	      ldi   ZH,0x00   ;������� � ������ �������� (*2 - ��� �������� 
	      add   ZL,Counter;���������)
	      lpm   temp,Z    ;������ �������������� ��� �������� Counter
		  out   PORTA,temp;�������� �� ���������   
delay_1:  rcall delay  ;�������� ��������
;	   
Key_end:  sbis  PIND,2  ;�������� ���������� ������
          rjmp  delay_1
    	  sbic PIND, 2       ; Check if button on PB4 is pressed
   		  rjmp MainCycle      ; Button not pressed, continue cycle
delay_2:  rcall delay_DK 
restart:
	sbic PINB, 4;
	rjmp restart;
delay_3:  rcall delay_DK
key_end_2:sbis  PinD,2  ;�������� ���������� ������
          rjmp  key_end_2
End_prog:
    rjmp MainLoop      ; Continue looping

Delay:
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
end_ddelay: ret

Delay_DK: ldi   Delay1,0x40;�������� ��������
          ldi   Delay2,0x1F
          ldi   Delay3,0x00

cycle:    subi  Delay1,1; ���� - 6 ������
          sbci  Delay2,0
	      sbci  Delay3,0
	      brcc  cycle
End_delay_DK: ret 

	
;------- ������� ������������� ��������
TABLE:    .db   0b00000011,0b00000110; ���� "0","1"
          .db   0b00001100,0b00000000; ���� "2","3"
