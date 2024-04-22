;*************************************
;* Designer        Ionin D.A..
;* Version:        1.0
;* Date            13.03.2024
;* Title:          Countert.asm
;* Device          ATtiny2313
;* Clock frequency:������� ��.���������� 8 ��� 
;*************************************
; �������
;*************************************
;�������: 1.�������� � ��� 8 ������� ��������� �����
;         2.�������������� 8 �������� ��������� �����
;		  3.����� ������� �������� ��������� �����         
;*************************************
.include "m16def.inc"	;������������� ����� ��������
.list                   ;��������� ��������                                                                      
;*******************
;*******************
; Register Variables
;*******************
.def temp_L   =R16;  ��������
.def Random	  =R17;  ��������
.def cou_rand =R18;  ��������
.def temp_H   =R19;  ��������
.def data	  =R20;  ��������
;*****************
;***************** 
; Variable
;*****************
.DSEG;
;
varBufer:		.BYTE 8; ������ � SRAM
; Variable
;***********************************		   
;***********************************
.cseg;
.org $0000;
rjmp Init;
;****************

;***********************************
; Start Of Main Program
;***********************************

Init:  	  ldi   temp_L, LOW(RAMEND);
          out   SPL, temp_L;
          ldi   Random, 10;
;--------------------------------------------------
begin:	  ldi 	cou_rand,8;
		  ldi 	YL,low(varBufer);
		  ldi 	YH,high(varBufer);
		  rcall Random_to_SRAM;
;
		  ldi 	cou_rand,8;
		  ldi 	YL,low(varBufer);
		  ldi 	YH,high(varBufer);
		  rcall val_midl;
;
		  rjmp 	begin
;==================================================
;������ �����
;==================================================	  

;==================================================	   
; ����� �����	   
;==================================================	
;
;
;
; ������������ Random_to_SRAM
;==================================================   
Random_to_SRAM: rcall val_rand;
			st 		Y+,temp_L;
			dec 	cou_rand;
			cpi 	cou_rand, 0;
			brne 	Random_to_SRAM;

 ret 
; ������������ val_midl
;==================================================   
val_midl: 
			clr 	temp_L;
			clr 	temp_H;
			ldi		cou_rand, 8;	
cyc_v_r: 	ld 		data,Y+;
			add 	temp_L, data;
			clr 	data;
			adc 	temp_H, data;
			dec		cou_rand;
			cpi 	cou_rand, 0;
			brne 	Cyc_v_r
			ldi 	cou_rand, 3;
cyc_sh_r:	lsr 	temp_H;
			ror		temp_L;
			dec		cou_rand;
			brne	cyc_sh_r;
			mov		data, temp_H;

 ret 
; ������������ val_rand
;==================================================   
val_rand: 
			mov 	temp_L,Random;
			add 	temp_L,Random;
			add 	temp_L,Random;
			ldi 	temp_H,5
			add 	temp_L, temp_H;
			mov 	Random, temp_L; 

 ret 
