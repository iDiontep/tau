clc;
i = 8; %8
K_p = 5 * abs(2*i*i -1*i -20); %500
K_i = 0.005 * abs(i-10); %0.0100
T1 = i; %8
T2 = 0.01 * i; %0.0800
T3 = power(i, -2); %0.0156
zeta = 0.5 + (i-10)/40; %0.4500
A = power(T3, 2) %2.4414e-04
B = 2 * T3 * zeta %нахождение констант

W1 = K_p
W2 = tf([K_i], [1 0])
F1 = parallel(W1, W2)

W3 = tf([1], [T1 1]);
W4 = tf([1], [T2 1]);
F2 = feedback (W3, W4, -1)

W5 =  tf([1], [A B 1])

r1 = series(F1, F2);
ans1 = series(r1, W5)
ans2 = feedback(ans1, 1, -1)

% subplot(1, 2, 1)
% impulse(ans2)
% subplot(1, 2, 2)
% step(ans2)

% pzmap(ans2)

% subplot(1, 2, 1)
% bode(ans1)
% subplot(1, 2, 2)
% nyquist(ans1)

rlocus(ans1)
