%задаем матрицы линейно-квадратичного управления
lab7.LQRParams.A = [0 1 0; 0 0 1; -1167 -167 -25];
lab7.LQRParams.B = [0; 0; 1167];
lab7.LQRParams.C = [0, 0, 7];
lab7.LQRParams.D = [0, 0, 0];
lab7.LQRParams.Q = 25*lab7.LQRParams.C'*lab7.LQRParams.C;
lab7.LQRParams.R = 1;
[lab7.LQRParams.K,lab7.LQRParams.S,lab7.LQRParams.P] = lqr(lab7.LQRParams.A,lab7.LQRParams.B,lab7.LQRParams.Q,lab7.LQRParams.R);