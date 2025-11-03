% FILTERING Procesa una señal EMG aplicando filtros y calcula su envolvente.
%
%   [emg_envelope, figs] = FILTERING(EMG) toma una señal EMG normalizada
%   (entre -1 y 1) y aplica una cadena de preprocesamiento: filtros notch a
%   60 Hz y 120 Hz, filtro pasa-banda Butterworth (20-150 Hz), envolvente
%   Hilbertiana y suavizado con media móvil. Genera figuras individuales para
%   cada etapa, respuestas en frecuencia de los filtros (notch, Butterworth y
%   media móvil), y una figura compuesta con las cuatro etapas de procesamiento
%   en una grilla 2x2.
%
%   Entradas:
%       EMG - Señal de entrada normalizada (vector).
%
%   Salidas:
%       emg_envelope - Señal EMG procesada y suavizada.
%       figs - Cell array con handles de las figuras generadas (9 figuras).
%
%   Dependencias: DSP System Toolbox.
%
function [emg_envelope, figs] = FILTERING(EMG)
    Fs = 2000;                  % Frecuencia de muestreo (Hz)
    low_cut = 20;               % Filtro pasa-banda - corte inferior (Hz)
    high_cut = 150;             % Filtro pasa-banda - corte superior (Hz)
    order = 6;                  % Orden del filtro Butterworth
    window_size = 50;           % Ventana de media móvil (50 muestras = 25 ms)

    t = (0:length(EMG)-1)/Fs;   % Vector de tiempo

    % --- Filtro Notch a 60 Hz ---
    f0_60 = 60; Q1 = 50;
    w0_60 = f0_60 / (Fs/2);
    bw_60 = w0_60 / Q1;
    [b_notch1, a_notch1] = iirnotch(w0_60, bw_60);
    emg_notched_60 = filtfilt(b_notch1, a_notch1, EMG);

    % --- Filtro Notch a 120 Hz ---
    f0_120 = 120; Q2 = 50;
    w0_120 = f0_120 / (Fs/2);
    bw_120 = w0_120 / Q2;
    [b_notch2, a_notch2] = iirnotch(w0_120, bw_120);
    emg_notched = filtfilt(b_notch2, a_notch2, emg_notched_60);

    % --- Filtro pasa-banda Butterworth 20–150 Hz ---
    [b_band, a_band] = butter(order, [low_cut, high_cut] / (Fs / 2), 'bandpass');
    emg_filtered = filtfilt(b_band, a_band, emg_notched);

    % --- Envolvente de Hilbert ---
    analytic_signal = hilbert(emg_filtered);
    emg_envelope = abs(analytic_signal);
    emg_envelope = emg_envelope ./ max(emg_envelope);  % Normalización

    % --- Filtro de Media Móvil ---
    kernel = ones(1, window_size) / window_size;
    emg_envelope = filtfilt(kernel, 1, emg_envelope);

    % --- Generación de Figuras Individuales ---
    figs = cell(1, 9); % Almacena handles de 9 figuras

    % Figura 1: Señal original
    figs{1} = figure('Name', 'EMG Original', 'NumberTitle', 'off');
    plot(t, EMG, 'b');
    title('Señal EMG Original', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 10); 
    ylabel('Amplitud', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 2: Después de filtros Notch
    figs{2} = figure('Name', 'EMG tras Filtros Notch', 'NumberTitle', 'off');
    plot(t, emg_notched, 'b');
    title('Señal EMG tras Filtros Notch (60 y 120 Hz)', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 10); 
    ylabel('Amplitud', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 3: Después del filtro pasa-banda
    figs{3} = figure('Name', 'EMG Filtrado', 'NumberTitle', 'off');
    plot(t, emg_filtered, 'b');
    title('Señal EMG Filtrada (20–150 Hz)', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 10); 
    ylabel('Amplitud', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 4: Envolvente + media móvil
    figs{4} = figure('Name', 'Envolvente EMG', 'NumberTitle', 'off');
    plot(t, emg_envelope, 'r', 'LineWidth', 1.5);
    title('Envolvente Hilbertiana con Media Móvil', 'FontSize', 12);
    xlabel('Tiempo (s)', 'FontSize', 10); 
    ylabel('Amplitud (normalizada)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 5: Respuesta en frecuencia - Notch 60 Hz
    [h1, f1] = freqz(b_notch1, a_notch1, 1024, Fs);
    figs{5} = figure('Name', 'Respuesta Notch 60 Hz', 'NumberTitle', 'off');
    subplot(2, 1, 1);
    plot(f1, 20*log10(abs(h1)), 'b');
    title('Filtro Notch 60 Hz - Magnitud', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Magnitud (dB)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);
    subplot(2, 1, 2);
    plot(f1, angle(h1), 'b');
    title('Filtro Notch 60 Hz - Fase', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Fase (rad)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 6: Respuesta en frecuencia - Notch 120 Hz
    [h2, f2] = freqz(b_notch2, a_notch2, 1024, Fs);
    figs{6} = figure('Name', 'Respuesta Notch 120 Hz', 'NumberTitle', 'off');
    subplot(2, 1, 1);
    plot(f2, 20*log10(abs(h2)), 'b');
    title('Filtro Notch 120 Hz - Magnitud', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Magnitud (dB)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);
    subplot(2, 1, 2);
    plot(f2, angle(h2), 'b');
    title('Filtro Notch 120 Hz - Fase', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Fase (rad)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 7: Respuesta en frecuencia - Butterworth 20–150 Hz
    [h3, f3] = freqz(b_band, a_band, 1024, Fs);
    figs{7} = figure('Name', 'Respuesta Butterworth', 'NumberTitle', 'off');
    subplot(2, 1, 1);
    plot(f3, 20*log10(abs(h3)), 'b');
    title('Filtro Butterworth 20–150 Hz - Magnitud', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Magnitud (dB)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);
    subplot(2, 1, 2);
    plot(f3, angle(h3), 'b');
    title('Filtro Butterworth 20–150 Hz - Fase', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Fase (rad)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);

    % Figura 8: Grilla 2x2 con las cuatro etapas de procesamiento
    figs{8} = figure('Name', 'Etapas de Preprocesamiento EMG', 'NumberTitle', 'off');
    % Subplot 1: Señal original
    subplot(2, 2, 1);
    plot(t, EMG, 'b');
    title('Señal EMG Original', 'FontSize', 10);
    xlabel('Tiempo (s)', 'FontSize', 8); 
    ylabel('Amplitud', 'FontSize', 8); 
    grid on;
    set(gca, 'FontSize', 8);
    % Subplot 2: Después de filtros Notch
    subplot(2, 2, 2);
    plot(t, emg_notched, 'b');
    title('Tras Filtros Notch (60 y 120 Hz)', 'FontSize', 10);
    xlabel('Tiempo (s)', 'FontSize', 8); 
    ylabel('Amplitud', 'FontSize', 8); 
    grid on;
    set(gca, 'FontSize', 8);
    % Subplot 3: Después del filtro pasa-banda
    subplot(2, 2, 3);
    plot(t, emg_filtered, 'b');
    title('Filtrada (20–150 Hz)', 'FontSize', 10);
    xlabel('Tiempo (s)', 'FontSize', 8); 
    ylabel('Amplitud', 'FontSize', 8); 
    grid on;
    set(gca, 'FontSize', 8);
    % Subplot 4: Envolvente + media móvil
    subplot(2, 2, 4);
    plot(t, emg_envelope, 'r', 'LineWidth', 1.5);
    title('Envolvente con Media Móvil', 'FontSize', 10);
    xlabel('Tiempo (s)', 'FontSize', 8); 
    ylabel('Amplitud (normalizada)', 'FontSize', 8); 
    grid on;
    set(gca, 'FontSize', 8);
    % Ajustar diseño
    sgtitle('Etapas de Preprocesamiento de la Señal EMG', 'FontSize', 12);

    % Figura 9: Respuesta en frecuencia - Media Móvil
    [h4, f4] = freqz(kernel, 1, 1024, Fs);
    figs{9} = figure('Name', 'Respuesta Media Móvil', 'NumberTitle', 'off');
    subplot(2, 1, 1);
    plot(f4, 20*log10(abs(h4)), 'b');
    title('Filtro Media Móvil (50 muestras) - Magnitud', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Magnitud (dB)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);
    subplot(2, 1, 2);
    plot(f4, angle(h4), 'b');
    title('Filtro Media Móvil (50 muestras) - Fase', 'FontSize', 12);
    xlabel('Frecuencia (Hz)', 'FontSize', 10); 
    ylabel('Fase (rad)', 'FontSize', 10); 
    grid on;
    set(gca, 'FontSize', 10);
end