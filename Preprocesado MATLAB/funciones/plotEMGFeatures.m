function plotEMGFeatures(caracteristicas, nombres, n_filas)
% Visualiza características EMG en subplots individuales con colores distintos
%
% Inputs:
%   caracteristicas: matriz NxM (N muestras, M características)
%   nombres: celdas o strings con nombres de cada columna
%   n_filas: número de filas en la figura de subplots
%
% Ejemplo de uso:
%   nombres = ["Envolvente", "Activity", "Mobility", "Complexity"];
%   plotEMGFeatures(features, nombres, 2);

    if isstring(nombres)
        nombres = cellstr(nombres);  % convertir a cell array si es string
    end

    [~, M] = size(caracteristicas);
    n_cols = ceil(M / n_filas);     % calcular columnas automáticamente

    colors = lines(M);              % asignar M colores únicos

    figure;
    for i = 1:M
        subplot(n_filas, n_cols, i);
        plot(caracteristicas(:, i), 'Color', colors(i, :), 'LineWidth', 1.2);
        title(nombres{i}, 'Interpreter', 'none');
        grid on;
        xlabel('Muestras');
        ylabel('Valor');
    end
end
