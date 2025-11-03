function features = extractEMGFeatures(envelope, fs, win_size, step_size)
% Extrae características Hjorth y Hudgins (sin ZC) de una envolvente suavizada de EMG
% usando ventanas deslizantes, con normalización min-max
%
% Inputs:
%   envelope: señal (envolvente suavizada), vector fila o columna
%   fs: frecuencia de muestreo (Hz)
%   win_size: tamaño de ventana (en muestras)
%   step_size: tamaño del paso (en muestras)
%
% Output:
%   feature_matrix: matriz Nx7 con columnas:
%     [envelope, activity, mobility, complexity, mav, ssc, wl]

    envelope = envelope(:);  % asegurar columna
    N = length(envelope);
    
    % Inicializar vectores con NaN
    activity_vec   = NaN(N,1);
    mobility_vec   = NaN(N,1);
    complexity_vec = NaN(N,1);
    mav_vec        = NaN(N,1);
    ssc_vec        = NaN(N,1);
    wl_vec         = NaN(N,1);

    dt = 1 / fs;

    % Recorrer ventanas deslizantes
    for idx_start = 1:step_size:(N - win_size + 1)
        idx_end = idx_start + win_size - 1;
        segment = envelope(idx_start:idx_end);

        % Derivadas
        dx  = diff(segment) / dt;
        ddx = diff(dx) / dt;

        % Hjorth: Activity, Mobility, Complexity
        var_x  = var(segment);
        var_dx = var(dx);
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

        % Hudgins: MAV, SSC, WL
        mav = mean(abs(segment));
        wl  = sum(abs(diff(segment)));
        ssc = sum( ...
            ((diff(segment(2:end)) .* diff(segment(1:end-1))) < 0) ...
        );

        % Expandir valores en la ventana
        activity_vec(idx_start:idx_end)   = var_x;
        mobility_vec(idx_start:idx_end)   = mobility;
        complexity_vec(idx_start:idx_end) = complexity;
        mav_vec(idx_start:idx_end)        = mav;
        ssc_vec(idx_start:idx_end)        = ssc;
        wl_vec(idx_start:idx_end)         = wl;
    end

    % Normalización Min-Max (cada característica individual)
    activity_vec   = normalizeVector(activity_vec);
    mobility_vec   = normalizeVector(mobility_vec);
    complexity_vec = normalizeVector(complexity_vec);
    mav_vec        = normalizeVector(mav_vec);
    ssc_vec        = normalizeVector(ssc_vec);
    wl_vec         = normalizeVector(wl_vec);

    % Construir matriz final de características
    features = [ ...
        envelope, ...
        activity_vec, ...
        mobility_vec, ...
        complexity_vec, ...
        mav_vec, ...
        ssc_vec, ...
        wl_vec ...
    ];
end

% --- Función auxiliar para normalizar a [0, 1] ---
function vec_norm = normalizeVector(vec)
    min_val = min(vec(~isnan(vec)));
    max_val = max(vec(~isnan(vec)));
    
    if max_val > min_val
        vec_norm = (vec - min_val) / (max_val - min_val);
    else
        vec_norm = zeros(size(vec)); % en caso de vector constante
    end
end
