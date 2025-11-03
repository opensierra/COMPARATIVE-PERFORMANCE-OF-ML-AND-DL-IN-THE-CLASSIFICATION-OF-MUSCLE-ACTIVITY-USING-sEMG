function features = extractEMGFeatures(envelope, fs, win_size, step_size, repeat_values, include_envelope)
% Extrae características Hjorth de una envolvente suavizada de EMG
% usando ventanas deslizantes, con normalización min-max.
%
% Inputs:
%   envelope: señal (envolvente suavizada), vector fila o columna
%   fs: frecuencia de muestreo (Hz)
%   win_size: tamaño de ventana (en muestras)
%   step_size: tamaño del paso (en muestras)
%   repeat_values (opcional): true para repetir valores dentro de ventana (default: true)
%   include_envelope (opcional): true para incluir la envolvente en la salida (default: true)
%
% Output:
%   features: matriz con columnas:
%       [envelope, activity, mobility, complexity] o
%       [activity, mobility, complexity]

    if nargin < 5
        repeat_values = true;
    end
    if nargin < 6
        include_envelope = true;
    end

    envelope = envelope(:);  % asegurar columna
    N = length(envelope);
    dt = 1 / fs;

    if repeat_values
        activity_vec   = NaN(N,1);
        mobility_vec   = NaN(N,1);
        complexity_vec = NaN(N,1);
        env_out = envelope;
    else
        num_windows = floor((N - win_size) / step_size) + 1;
        activity_vec   = NaN(num_windows,1);
        mobility_vec   = NaN(num_windows,1);
        complexity_vec = NaN(num_windows,1);
        env_out        = NaN(num_windows,1);
    end

    w = 1;
    for idx_start = 1:step_size:(N - win_size + 1)
        idx_end = idx_start + win_size - 1;
        segment = envelope(idx_start:idx_end);

        % Derivadas
        dx  = diff(segment) / dt;
        ddx = diff(dx) / dt;

        % Hjorth parameters
        var_x   = var(segment);
        var_dx  = var(dx);
        var_ddx = var(ddx);

        if var_x == 0
            mobility = 0;
            complexity = 0;
        else
            mobility = sqrt(var_dx / var_x);
            if var_dx == 0
                complexity = 0;
            else
                complexity = sqrt(var_ddx / var_dx) / mobility;
            end
        end

        if repeat_values
            activity_vec(idx_start:idx_end)   = var_x;
            mobility_vec(idx_start:idx_end)   = mobility;
            complexity_vec(idx_start:idx_end) = complexity;
        else
            activity_vec(w)   = var_x;
            mobility_vec(w)   = mobility;
            complexity_vec(w) = complexity;
            env_out(w)        = envelope(idx_start + floor(win_size/2));  % valor central
            w = w + 1;
        end
    end

    % Normalización min-max
    activity_vec   = normalizeVector(activity_vec);
    mobility_vec   = normalizeVector(mobility_vec);
    complexity_vec = normalizeVector(complexity_vec);

    % Construcción de la salida
    if include_envelope
        features = [ ...
            env_out, ...
            activity_vec, ...
            mobility_vec, ...
            complexity_vec ...
        ];
    else
        features = [ ...
            activity_vec, ...
            mobility_vec, ...
            complexity_vec ...
        ];
    end
end

% --- Normaliza un vector a [0, 1] ignorando NaNs ---
function vec_norm = normalizeVector(vec)
    min_val = min(vec(~isnan(vec)));
    max_val = max(vec(~isnan(vec)));
    
    if max_val > min_val
        vec_norm = (vec - min_val) / (max_val - min_val);
    else
        vec_norm = zeros(size(vec));
    end
end
