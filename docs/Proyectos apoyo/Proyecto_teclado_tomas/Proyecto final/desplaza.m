%
%  Programa: Desplaza
%
%   Muevo la flecha segun donde este, hay que pasarle la figura (principal o auxiliar) y la flecha (1=pral o 2=aux)
%   si "selecciono==1" entro en el bloque correspondiente, pasandole a "selec_bloque" la variable "mueve"
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: selec_bloque
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------

function desplaza(fig,flec)

global mueve selec bar vel flecha rueda x y selec 

%----------------------------------------
rueda=fig;      % grabamos en una vble local la figura que hemos pasado
flecha=flec;    % grabamos en una vble local la flecha

figure(rueda);
hold on
if selec==0,            % compruebo que no he seleccionado ningun bloque 
    mueve=mueve-vel;    % 'mueve' lo decremento según la velocidad elegida en el panel (1,2 o 3)
    if mueve <= 0,      % si 'mueve' llega a 0 lo actualizo a 360 antes de que sea negativo
        mueve=360;
    end;
    x=(bar)* cosd(mueve);      % modifico la flecha segun 'mueve'(posición de la barra) y la longitud 'bar'
    y=(bar)* sind(mueve);
    set(flecha,'XData',[1 1+x],'YData',[1 1+y],'color',[0 0 1],'LineWidth',6);
else
    selec_bloque;       % he seleccionado un bloque, llamo a 'selec_bloque' y vuelvo 'selec' a cero
    selec=0;
end;    %/ end if selec

