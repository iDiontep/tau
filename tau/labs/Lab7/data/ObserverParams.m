%задаем матрицы наблюдатель Люенбергера 
lab7.Observer.A = [0 1 0; 0 0 1; -1167 -167 -25];
lab7.Observer.B = [0; 0; 1167];
lab7.Observer.C = [0, 0, 7];
lab7.Observer.D = [0, 0, 0];
lab7.Observer.L = [-1;-1;-1];
% eig(lab7.Observer.A - [lab7.Observer.L, zeros(3, 2)])