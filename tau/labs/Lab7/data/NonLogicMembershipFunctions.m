% Создание нечёткой системы управления
fuzzy_lab7 = mamfis('Name', 'fuzzy_lab7');

% Добавление входных и выходных переменных к системе
fuzzy_lab7 = addInput(fuzzy_lab7, [-10 10], 'Name', 'PositionError');
fuzzy_lab7 = addOutput(fuzzy_lab7, [-12 12], 'Name', 'ControlVoltage');

% Функции принадлежности для ошибки по положению
fuzzy_lab7 = addMF(fuzzy_lab7, 'PositionError', 'trapmf', [-10 -10 -pi -0.5*pi], 'Name', 'BigNegativeError');
fuzzy_lab7 = addMF(fuzzy_lab7, 'PositionError', 'trimf', [-pi -0.1*pi 0], 'Name', 'NegativeError');
fuzzy_lab7 = addMF(fuzzy_lab7, 'PositionError', 'trimf', [-0.25*pi 0 0.25*pi], 'Name', 'Zero');
fuzzy_lab7 = addMF(fuzzy_lab7, 'PositionError', 'trimf', [0 0.1*pi pi], 'Name', 'PositiveError');
fuzzy_lab7 = addMF(fuzzy_lab7, 'PositionError', 'trapmf', [0.5*pi pi 10 10], 'Name', 'BigPositiveError');

% Функции принадлежности для выходного напряжения
fuzzy_lab7 = addMF(fuzzy_lab7, 'ControlVoltage', 'trimf', [-12 -12 -9], 'Name', 'HighNegativeVoltage');
fuzzy_lab7 = addMF(fuzzy_lab7, 'ControlVoltage', 'trimf', [-9 -8 -5], 'Name', 'NegativeVoltage');
fuzzy_lab7 = addMF(fuzzy_lab7, 'ControlVoltage', 'trimf', [-3.3 0 3.3], 'Name', 'Zero');
fuzzy_lab7 = addMF(fuzzy_lab7, 'ControlVoltage', 'trimf', [5 8 9], 'Name', 'PositiveVoltage');
fuzzy_lab7 = addMF(fuzzy_lab7, 'ControlVoltage', 'trimf', [9 12 12], 'Name', 'HighPositiveVoltage');

% Создание правил управления и добавление их к системе 
fuzzy_lab7 = addRule(fuzzy_lab7, ["If (PositionError is BigNegativeError) then (ControlVoltage is HighPositiveVoltage)", ...
    "If (PositionError is NegativeError) then (ControlVoltage is PositiveVoltage)", ...
    "If (PositionError is Zero) then (ControlVoltage is Zero)", ...
    "If (PositionError is PositiveError) then (ControlVoltage is NegativeVoltage)", ...
    "If (PositionError is BigPositiveError) then (ControlVoltage is HighNegativeVoltage)"]);
