clc;
ki = 1.8463;
kp = 1.1776;
kd = 0.48315;
wcr = 0.1;
open('lab4_3_.slx');

w = tf ([0.48315 1.1776 1.8463],[0.0000001 1 0])
Discr = c2d(w, wcr/10, 'tustin')
