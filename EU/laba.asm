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
.equ Val_del3=0x35;0x35;(частота 8мГц,время задержки 1500 мс
.equ Val_del4=0x77;0x77 5мсек.Количество циклов 
;                  Хотч=2000000000 (77359400) <=>(1/8000000)*6*Хотч=1500 мсек) 
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
	ldi	   tempL, Low(RAMEND)	; выбор вершины стека
	ldi    tempH, High(RAMEND)  ; указатель стека
	out	   SPL, tempL           ; на последний адрес ОЗУС
	out    SPH, tempH           ; 
; Initialize Ports
Init_A:    	ldi temp, 0b11111111    ; PortA теперь выходы
    		out DDRB, temp
    		ldi temp, 0b00001000    ; зажечь pa3
    		out PORTB, temp
    
Init_B:	ldi temp, 0b00000000    ;PortB теперь входы
    	out DDRD, temp
    	ldi temp, 0b00010000    ;pb4 теперь выполняет функцию кнопки
    	out PORTD, temp
    
    	ldi Counter, 0x00 ; инициализация счетчика



Start:
    sbic PIND, 4       ; проверка нажатия PB4
    rjmp Start      ; исли не нажата - возврат
delay_0:  rcall delay_DK; подавление дребезка
Otpuskanie:				; проверка отпускания клавиши
	sbis PIND, 4;		; кнопка отжата? 
	rjmp Otpuskanie;	; если не отжата - возврат
MainCycle:
    inc Counter        ; увеличить счетчик состояния индикатора

    cpi Counter, 4  ; проверка переполнения (по ТЗ всего 4 состояния)
    brne CheckCounter  ; косвенный переход если нет переполнения

    ldi Counter, 0  ; иначе сброс по переполнению

CheckCounter:
	      ldi   ZL,TABLE*2;обработка таблицы
	      ldi   ZH,0x00   ;таблицы в памяти программ (*2 - для байтовой 
	      add   ZL,Counter;адресации)
	      lpm   temp,Z    ;читаем семисегментный код значения Counter
		  out   PORTB,temp;передаем на индикатор   
delay_long:  rcall Delay  ;задержка 1.5 sec
    	  sbic PIND, 4       ; проверка нажатия PB4
   		  rjmp MainCycle      ; eсли не нажата - возврат

;	  выполнение ожидания нажатия выключения режима счетчика
delay_2:  rcall delay_DK ;подавление дребезга
  Otpuskaniie:
  	sbis PIND, 4;
	rjmp Otpuskaniie;	; если не отжата - возврат		;
	rcall delay_DK
    rjmp Start      ; в начало
;************
;подпрограмма задержки на задданный интервал
;************
Delay:
    ldi   Delay1,Val_del1;
    ldi   Delay2,Val_del2 
    ldi   Delay3,Val_del3 
    ldi   Delay4,Val_del4    ; хекс код 1.5 sec
delay_loop:
        subi  Delay1,1; Цикл - 5 тактов
        sbci  Delay2,0;
	    sbci  Delay3,0;
		sbci  Delay4,0;
	    brcc  delay_loop
End_delay:    ret
;************
;подпрограмма задержки подавления дребезга контактов
;************
Delay_DK: ldi   Delay1,0x40;загрузка констант время задержки 0.05 сек
          ldi   Delay2,0x1F
          ldi   Delay3,0x00

cycle:    subi  Delay1,1; Цикл - 5 тактов
          sbci  Delay2,0
	      sbci  Delay3,0
	      brcc  cycle
End_delay_DK: ret 

	
;------- Таблица перекодировки символов
TABLE:    .db   0b00001000,0b00000100; коды "0","1"
          .db   0b00000010,0b00000001; коды "2","3"
