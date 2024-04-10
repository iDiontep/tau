clc
clear all
close all



W = tf(7, [0.005 0.15 1 0]);
% рассмотрим построение графика функции
x = 1.5:0.01:50;
qa = (15.28./x./x).*sqrt((x.*x)-(2.25));
qa_ =-((22.91./x)./x); 
f = -20 .*log10((1./x).^2.*sqrt((233.4.*(x.^2-2.25)+524.9)));
f4h = - pi+atan(1.5./sqrt(x.*x-2.25));

figure;

plot(x, qa, 'LineWidth',2, 'Color', 'r');
title('q(a)')
yline(4.29);
grid on;

figure;
plot(x, qa_, 'LineWidth',2, 'Color', 'r');
title('q`(a)')
yline(4.29);
grid on;


figure;
bode(W); 
xline(-0.94);
grid on;
figure;
subplot(2,1,1)
plot(x, f, 'LineWidth',2, 'Color', 'r');
yline(-17);
title('20 lg⁡(W_L (jw))');
grid on;
% 
subplot(2,1,2)
plot(x, f4h, 'LineWidth',2, 'Color', 'r');
title('arg⁡〖W_L (jw)〗');
yline(-pi);
grid on;




% %  