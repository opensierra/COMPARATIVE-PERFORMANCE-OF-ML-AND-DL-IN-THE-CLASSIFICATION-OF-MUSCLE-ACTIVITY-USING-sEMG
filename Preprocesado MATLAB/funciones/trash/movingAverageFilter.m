function y = movingAverageFilter(x, win_size)
% Aplica un filtro de media móvil simple a una señal
%
% Inputs:
%   x: señal de entrada (vector fila o columna)
%   win_size: tamaño de la ventana (número de muestras)
%
% Output:
%   y: señal filtrada (misma longitud que x)
%
% Nota:
%   Usa padding reflejado para mantener la longitud de la señal.

    % Asegurar que x sea un vector columna
    x = x(:);
    N = length(x);

    % Validar tamaño de ventana
    if win_size <= 1
        y = x;
        return;
    end

    % Verificar si win_size es mayor que la longitud de la señal
    if win_size > N
        warning('El tamaño de la ventana (%d) es mayor que la señal (%d). Ajustando al tamaño de la señal.', win_size, N);
        win_size = N;
    end

    % Calcular el padding necesario
    pad = floor(win_size / 2);

    % Crear padding reflejado
    x_padded = [flipud(x(1:min(pad, N))); x; flipud(x(end - min(pad, N) + 1:end))];

    % Filtro de media móvil
    kernel = ones(win_size, 1) / win_size;
    y_padded = conv(x_padded, kernel, 'same');

    % Extraer la parte central (longitud original)
    start_idx = pad + 1;
    end_idx = pad + N;
    y = y_padded(start_idx:end_idx);

    % Asegurar que y tenga la misma longitud que x
    if length(y) ~= N
        warning('Ajustando longitud de salida para coincidir con la entrada.');
        y = y(1:N);
    end

    % Restaurar la orientación original (si x era fila)
    if size(x, 2) > 1
        y = y.';
    end
end