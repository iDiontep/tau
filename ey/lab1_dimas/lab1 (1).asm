;================================================================================================== 
; �������
;================================================================================================== 
; �����:				������� �. �.
; ������:				1.0
; ����:					13.04.2024
; ��������:				Rain
; ���������������:		ATmega16
; �������� �������:		8 ��� 
;==================================================================================================

;==================================================================================================  
; ����������
;================================================================================================== 
; 1) ����������� ������� ����� ������� �� ������ �� 0 �� 9;
; 2) ����� ���������� ������� �� �������������� ���������.
;================================================================================================== 

;================================================================================================== 
; ������� ����������
;================================================================================================== 
; 1) ������ ���������� � PB4 (1 - ������ ������, 0 - ������ ������);
; 2) �������������� ��������� ��������� � ����� PC0-PC7: 
;    PC0-a, PC1-b, PC2-c, PC3-d, PC4-e, PC5-f, PC6-g, PC7-h;
; 3) ����������� ���������� ��������������� ���������� ��������� � PB0.
;================================================================================================== 

;==================================================================================================  
; �������
;================================================================================================== 
;10) ����� �� �����������. ��� ������� �� ������ PA0 ������������ 
;��������� �����, ������� ������ ����� ������� ����������� ������ 
;�������. ����� ��� ������ ����� ������� ���������� ���������� ����� A, 
;����� ��� �� ���������� ����� B, � �� ����� A ����� ��������������� �����, 
;����� � ����� B �� ���� C, � ����� A �� ���� B, � � ���� A ����� 
;��������������� ����� � ��� ����� �� ����� D, c ����� D ����� ������ �� 
;���������, � ������ ��������. ����� ��� �� ���������� ������� �� ������. 
;����� ������� ����� ������������, �.�. ��� ���������� ��������. ��� 
;����������� ������� ����� ������������ � ���� �����, ��� ��� ����������. 
;������� 0-� ����������� �� ������ ������.
         
;================================================================================================== 

.include "m16def.inc"			; ������������� ����� ��������
.list							; ��������� ��������                                                                      
;================================================================================================== 

;==================================================================================================
; �������� ����������
;==================================================================================================
.def tempL	  = R16				; ������� ����������� �������
.def tempH    = R17             ; ������� ����������� �������
.def counter  = R18				; ������� ��������
.def delay1   = R19				; ������� ������� ��������
.def delay2   = R20				; ������� ������� ��������
.def delay3   = R21				; ������� ������� ��������
.def random   = R22             ; ��������� �����
;==================================================================================================

;==================================================================================================
; ���������
;==================================================================================================
.equ ValueDelay1 = 0x00			; 0x00 �������� �������� �������� ��������
.equ ValueDelay2 = 0x6a			; 0x6a �������� �������� �������� �������� 
.equ ValueDelay3 = 0x18			; 0x18 �������� �������� �������� �������� 
;==================================================================================================

;==================================================================================================
; �������� ��������
;==================================================================================================
; 1) ������� 8 ��� = 8000000 ��;
; 2) 5 ������ �� ���� ����;
; 3) ����� 1 �������
; 4) ���������� ������ � = 1 / [(1 / 8000000) * 5] = 1600000 = 0x186a00).   
;==================================================================================================

;================================================================================================== 
; �������������
;================================================================================================== 
.cseg							; ������� ������ ���������
.org	$0000					; ������ ������ �� ������ 0
rjmp	Init                    ; ������ � ������������ �������������
;==================================================================================================

;==================================================================================================
; ����������
;==================================================================================================
.org  INT0addr					; $0002	������� ���������� �������� 0
reti							; � ������� ���������� ��� ������������ ���������

.org  INT1addr					; $0004	������� ���������� �������� 1
reti							; � ������� ���������� ��� ������������ ���������

.org  OC2addr					; $0006	���������� �� ������ �������-�������� 2
reti							; � ������� ���������� ��� ������������ ���������

.org  OVF2addr					; $0008	������-������� 2 ����������
reti							; � ������� ���������� ��� ������������ ���������

.org  ICP1addr					; $000A	������ ������� ��������-��������� 1
reti							; � ������� ���������� ��� ������������ ���������

.org  OC1Aaddr					; $000C	���������� �� ������ A �������-�������� 1
reti							; � ������� ���������� ��� ������������ ���������

.org  OC1Baddr					; $000E	���������� �� ������ B �������-�������� 1
reti							; � ������� ���������� ��� ������������ ���������

.org  OVF1addr					; $0010	������-������� 1 ����������
reti							; � ������� ���������� ��� ������������ ���������

.org  OVF0addr					; $0012	������-������� 0 ����������
reti							; � ������� ���������� ��� ������������ ���������

.org  SPIaddr					; $0014	�������� �� ����������������� ���������� ���������
reti							; � ������� ���������� ��� ������������ ���������

.org  URXCaddr					; $0016	���� �� �����-����������� ��������
reti							; � ������� ���������� ��� ������������ ���������

.org  UDREaddr					; $0018	������� ������ �����-����������� ����
reti							; � ������� ���������� ��� ������������ ���������

.org UTXCaddr					; $001A	�������� �� �����-����������� ���������
reti							; � ������� ���������� ��� ������������ ���������

.org ADCCaddr					; $001C ���������-�������� �������������� ���������
reti							; � ������� ���������� ��� ������������ ���������

.org ERDYaddr					; $001E	���������� ����������������� ������
reti							; � ������� ���������� ��� ������������ ���������

.org ACIaddr					; $0020	���������� ����������
reti							; � ������� ���������� ��� ������������ ���������

.org TWIaddr					; $0022 ������������� ���������������� ���������
reti							; � ������� ���������� ��� ������������ ���������

.org INT2addr					; $0024 ������� ���������� �������� 2
reti							; � ������� ���������� ��� ������������ ���������

.org OC0addr					; $0026 ���������� �� ������ �������-�������� 0
reti							; � ������� ���������� ��� ������������ ���������

.org SPMRaddr					; $0028 ���������� ������ � ������ ��������
reti							; � ������� ���������� ��� ������������ ���������
;==================================================================================================

;==================================================================================================
; ������ �������������
;================================================================================================== 
Init:

;==================================================================================================
; ������������� �����
;================================================================================================== 
InitStack:  	  
	ldi	   tempL, Low(RAMEND)	; �������� �������� ����� ������ ������� ����� 
	ldi    tempH, High(RAMEND)  ; �������� �������� ����� ������ ������� �����
	out	   SPL, tempL           ; ������������� �������� ����� ������ ������� �����
	out    SPH, tempH           ; ������������� �������� ����� ������ ������� ����� 
;==================================================================================================

;==================================================================================================
; ������������� ����� �
;================================================================================================== 
InitPortA: 
	ldi	   tempL, 0b11111110	; PB0 - ����� �� ����������, PB4 - ���� �� ������,
								; ������ (PB1-PB3, PB5-PB7) �� ������������ 
	ldi    tempH, 0b00000001	; PB4 - ���� � ������������� ����������, PB0 - ����� �����
								; ������� �������, ������ (PB1-PB3, PB5-PB7) ����� ������ ������           
	out    DDRA, tempL			; ������� ������������ ����� ����� B (0 - ����, 1 - �����)  
	out    PortA, tempH			; ������� ������� �������� �� ������� ����� B (0 - LOW, 1 - HIGH) 
								; � ������������� ���������� ��� ������ (0 - ��� R, 1 - c R)     
;==================================================================================================

;================================================================================================== 
; ������������� ����� B
;================================================================================================== 
InitPortB: 
	ldi	   tempL, 0b11111111	; PB0 - ����� �� ����������, PB4 - ���� �� ������,
								; ������ (PB1-PB3, PB5-PB7) �� ������������ 
	ldi    tempH, 0b00000000	; PB4 - ���� � ������������� ����������, PB0 - ����� �����
								; ������� �������, ������ (PB1-PB3, PB5-PB7) ����� ������ ������           
	out    DDRB, tempL			; ������� ������������ ����� ����� B (0 - ����, 1 - �����)  
	out    PortB, tempH			; ������� ������� �������� �� ������� ����� B (0 - LOW, 1 - HIGH) 
								; � ������������� ���������� ��� ������ (0 - ��� R, 1 - c R)   
;==================================================================================================

;==================================================================================================
; ������������� ����� C
;==================================================================================================
InitPortC: 
	ldi	   tempL, 0b11111111	; PB0 - ����� �� ����������, PB4 - ���� �� ������,
								; ������ (PB1-PB3, PB5-PB7) �� ������������ 
	ldi    tempH, 0b00000000	; PB4 - ���� � ������������� ����������, PB0 - ����� �����
								; ������� �������, ������ (PB1-PB3, PB5-PB7) ����� ������ ������           
	out    DDRC, tempL			; ������� ������������ ����� ����� B (0 - ����, 1 - �����)  
	out    PortC, tempH			; ������� ������� �������� �� ������� ����� B (0 - LOW, 1 - HIGH) 
								; � ������������� ���������� ��� ������ (0 - ��� R, 1 - c R)     
;================================================================================================== 

;==================================================================================================
; ������������� ����� D
;==================================================================================================
InitPortD: 
	ldi	   tempL, 0b11111111	; PB0 - ����� �� ����������, PB4 - ���� �� ������,
								; ������ (PB1-PB3, PB5-PB7) �� ������������ 
	ldi    tempH, 0b00000000	; PB4 - ���� � ������������� ����������, PB0 - ����� �����
								; ������� �������, ������ (PB1-PB3, PB5-PB7) ����� ������ ������           
	out    DDRD, tempL			; ������� ������������ ����� ����� B (0 - ����, 1 - �����)  
	out    PortD, tempH			; ������� ������� �������� �� ������� ����� B (0 - LOW, 1 - HIGH) 
								; � ������������� ���������� ��� ������ (0 - ��� R, 1 - c R) 
;================================================================================================== 

;==================================================================================================  
; ������������� ����������
;==================================================================================================  
InitVar: 
	clr counter				; ����� �������� ��� ���������
	ldi tempL, 0
	mov random, tempL
;================================================================================================== 

;==================================================================================================
; ����� �������������
;==================================================================================================

;==================================================================================================
; ������ �����
;==================================================================================================  
Start: 
 

KeyIsPress:  
	sbic  PinA, PA0				; �������� ������� ������
    rjmp  KeyIsPress		    ; ���� ������ �� ������, �� ������� �������
	
IncreaseConter:
	inc   counter				; ������������� �������� �� 1  
    cpi   counter, 3			; ��������� �������� � 3
	brne  RainGo	    ; ���� ������� �� ����� 3, �� ������� ��� �� �������
	clr   counter				; ����� �������� �� 0 
	   
RainGo:    
    ldi   ZL, PortC            ; �������� �������� ����� ������� ������� (2 - �����������) 
    ldi   ZH, PortC                ; �������� �������� ����� ������� �������
    add   ZL,  tempL             ; �������� ������ ������� �� �������� �������� ��������
    lpm   tempL, Z                ; �������� ��������������� ���� �������� ��������
    out   PortD, tempL			; ����� ��������������� ���� �� ���������       
    ldi   ZL, PortB            ; �������� �������� ����� ������� ������� (2 - �����������) 
    ldi   ZH, PortB                ; �������� �������� ����� ������� �������
    add   ZL,  tempL             ; �������� ������ ������� �� �������� �������� ��������
    lpm   tempL, Z                ; �������� ��������������� ���� �������� ��������
    out   PortC, tempL			; ����� ��������������� ���� �� ���������
	ldi   ZL, PortA            ; �������� �������� ����� ������� ������� (2 - �����������) 
    ldi   ZH, PortA                ; �������� �������� ����� ������� �������
    add   ZL,  tempL             ; �������� ������ ������� �� �������� �������� ��������
    lpm   tempL, Z                ; �������� ��������������� ���� �������� ��������
    out   PortB, tempL			; ����� ��������������� ���� �� ���������
	ldi   ZL, Rand            ; �������� �������� ����� ������� ������� (2 - �����������) 
    ldi   ZH, Rand                ; �������� �������� ����� ������� �������
    add   ZL,  tempL             ; �������� ������ ������� �� �������� �������� ��������
    lpm   tempL, Z                ; �������� ��������������� ���� �������� ��������
    out   PortA, tempL

DelayAfterPress:  
	rcall Delay					; ����� ������������ �������� ��� ���������� �������� ���������
								; ����� ������� ������
   
KeyIsRelease:  
	sbis  PinA, PA0				; �������� ���������� ������
    rjmp  KeyIsRelease			; ���� ������ �� ��������, �� ������� ����������
	    
DelayAfterRelease:				
	rcall Delay					; ����� ������������ �������� ��� ���������� �������� ���������
								; ����� ������� ������

End: 
    rjmp  Start                    ; ����������� � ������ �����
;==================================================================================================
; ����� �����
;==================================================================================================
  
;==================================================================================================

;==================================================================================================	
; ������������ ��������
;==================================================================================================  
Delay: 
	ldi   delay1, ValueDelay1	; �������� �������� �������� �������� ��������
    ldi   delay2, ValueDelay2	; �������� �������� �������� �������� ��������
    ldi   delay3, ValueDelay3	; �������� �������� �������� �������� ��������

DelayCycle:						; ���� - 5 ������
	subi  delay1, 1				; ������������� �������� �������� ��������
    sbci  delay2, 0				; ���������� �� �������� �������� �������� �������� ��������
	sbci  delay3, 0				; ���������� �� �������� �������� �������� �������� ��������
	brcc  DelayCycle			; ���� ������� ����� ���� ����������� � ������ �����,
								; ����� ����� �� �����

DelayEnd: 
	ret							; ����� �� ������������ ��������

;================================================================================================== 
; ������������ ������������ ���������� �����
;================================================================================================== 
Rand:
 mov tempL,Random ; �������� � ����������� ������� ���������� ����� 
 add tempL,Random ; ������������: tempL=tempL+Random 
 add tempL,Random ; ������������: tempL=tempL+Random 
 ldi tempH,5 ; �������� � ����������� ������ ����� 5
 add tempL, tempH ; ������������: tempL=tempL+tempH 
 mov Random, tempL ; �������� � ��������� ����� ������������ �������� 
 ret 
;================================================================================================== 

;==================================================================================================

;==================================================================================================
; ������� ������������� ��������
;==================================================================================================
TABLE:    
	.db   0b00111111, 0b00000110		; ���� "0", "1"
    .db   0b01011011, 0b01001111		; ���� "2", "3"
    .db   0b01100110, 0b01101101		; ���� "4", "5"
	.db   0b01111101, 0b00000111		; ���� "6", "7"
	.db   0b01111111, 0b01101111		; ���� "8", "9"   
;==================================================================================================       



