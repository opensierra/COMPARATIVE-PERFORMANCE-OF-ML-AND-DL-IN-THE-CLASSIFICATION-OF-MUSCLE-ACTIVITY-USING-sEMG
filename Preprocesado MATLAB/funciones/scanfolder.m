function [folderlist] = scanfolder(folder)
% SCANFOLDER Escanea una carpeta y devuelve la lista de rutas completas a los archivos o subcarpetas.
%
%   folderlist = SCANFOLDER(folder)
%
%   Parámetros:
%       folder (string o char) - Ruta del directorio a escanear.
%
%   Salida:
%       folderlist (string array) - Lista de rutas completas de los elementos contenidos
%                                   en la carpeta especificada. Excluye los dos primeros
%                                   elementos de 'dir' ('.' y '..').
%
%   Descripción:
%       Esta función obtiene todos los elementos dentro del directorio especificado
%       y devuelve un arreglo de strings con las rutas completas. Se omiten las entradas
%       especiales '.' y '..' que representan el directorio actual y el padre.
%
%   Ejemplo de uso:
%       lista = scanfolder('C:\MisDatos\EMG');
%

    subdirtemp = dir(folder);
    folderlist = [" "];  % Inicializa un string array
    for i = 3:length(subdirtemp)  % Empieza desde 3 para saltar '.' y '..'
        folderlist(i-2, 1) = fullfile(folder, subdirtemp(i).name);
    end
end
