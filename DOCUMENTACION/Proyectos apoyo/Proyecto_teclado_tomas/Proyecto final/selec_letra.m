%
%  Programa: Selec_letra
%
%   Selecciono la letra una vez que he seleccionado el bloque, en caso de
%   selec "atras", lo escribo en la pantalla de comandos
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: Escribe
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------

global tecla mueve escribo mayus

%----------------------------------------

escribo=escribo+1;              %/ es un contador del nº de letras q escribo, la inicializo en "ensayo"

if mayus==1;                    % Grabamos en mayusculas y minusculas los caracteres correspondientes a cada cuarto
    cuarto1=('ADGJMPTW_');      % en cadenas de caracteres. Tienen que estar ordenados para escribir el caracter 
    cuarto2=('BEHKNQUX+');      % correspondiente a la posición que marca "tecla"
    cuarto3=('CFILÑRVY-');
    cuarto4=('----OS-Z#');      % Estos corresponden a los bloques de 4 letras
else
    cuarto1=('adgjmptw_');
    cuarto2=('behknqux+');
    cuarto3=('cfilñrvy-');
    cuarto4=('----os-z#');
end,

if (tecla==5) | (tecla==6) | (tecla==8) | (tecla==9)    % los bloques que contienen 4 letras
    if (18<mueve) & (mueve<91),   % 'mueve' indica el angulo donde hemos seleccionado, compruebo a que tecla corresponde
        escribe(cuarto1(tecla));                        % escribo el caracter del 'cuarto1' de la posición 'tecla'          
    elseif ((306<mueve) & (mueve<=360)) | ((0<=mueve) & (mueve<19)),
        escribe(cuarto2(tecla));
    elseif (234<mueve) & (mueve<307),
        escribe(cuarto3(tecla));
    elseif (162<mueve) & (mueve<235),
        escribe(cuarto4(tecla));
    else                                % Si no es ninguna letra, he seleccionado 'atras'
        disp('atras');
    end,
else                                    % los bloque restantes de 3 letras
    if (0<=mueve) & (mueve<91),
        escribe(cuarto1(tecla));
    elseif (270<mueve) & (mueve<=360),
        escribe(cuarto2(tecla));
    elseif (180<mueve) & (mueve<271),
        escribe(cuarto3(tecla));
    else
        disp('atras');
    end,
end,
