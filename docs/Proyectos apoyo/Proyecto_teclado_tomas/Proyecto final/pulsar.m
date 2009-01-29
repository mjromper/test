%
%  Función: Pulsar
%
%   Pulsar se ejecuta en cada figura, y su función es comprobar si se ha
%   pulsado alguna tecla (evnt.Key). Si es así pongo acaba=1, y termino la
%   ejecución de la aplicación


function pulsar (src,evnt)
global tecla A1 fig_sujeto acaba

tecla(1)=evnt.Key(1);           % comprueba si hay evento en alguna tecla
if tecla>0;
    acaba=1;                    % si he pulsado, acaba=1 para terminar la aplicación en Medir
end,
