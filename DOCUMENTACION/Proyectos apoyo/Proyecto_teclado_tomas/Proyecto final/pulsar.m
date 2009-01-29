%
%  Funci�n: Pulsar
%
%   Pulsar se ejecuta en cada figura, y su funci�n es comprobar si se ha
%   pulsado alguna tecla (evnt.Key). Si es as� pongo acaba=1, y termino la
%   ejecuci�n de la aplicaci�n


function pulsar (src,evnt)
global tecla A1 fig_sujeto acaba

tecla(1)=evnt.Key(1);           % comprueba si hay evento en alguna tecla
if tecla>0;
    acaba=1;                    % si he pulsado, acaba=1 para terminar la aplicaci�n en Medir
end,
