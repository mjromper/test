% filtrar_eeg
%
% Esta funcion junto con la de filtrado me van a preparar el filtro
% los parametros son los que se eligen a continuacion
%
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: filtrado
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------


global tiempo secmuestras_filt fc1 fc2 Fs

%preparo las variables del filtrado

filtrado_algoritmo=2;   %(1=>Ninguno,2=>Butterworth,3=>Chebyshev,4=>Elíptico)
filtrado_orden=5;       % Orden del filtro(CUIDADO: Puede no ser estable!!!!!)
filtrado_rizado=1;      % Decibelios en la banda de paso(solo util para metodos de Chebyshev/Eliptico.
filtrado_tipo=3;        % (1=>Pasobajo, 2=>Pasoalto, 3=>PasoBanda, 4=>Rechazobanda)

%llamo a la funcion que filtrar realiza el filtro

filtrado(filtrado_algoritmo,filtrado_orden,filtrado_rizado,filtrado_tipo,[fc1 fc2]/(Fs/2));


