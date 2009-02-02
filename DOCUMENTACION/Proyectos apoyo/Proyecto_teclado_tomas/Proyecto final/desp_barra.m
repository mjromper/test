%
%  Programa: Desp_barra
%
%   En Desp_barra se calcula la distancia de la barra, si se ha producido
%   una selecci�n o no, y ejecuta la llamada a la siguiente funci�n dependiendo 
%   de el suceso anterior (selecci�n o desplazamiento)
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: desplaza, selec_letra
%
%
% Tomas Perez Lisbona - Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga - 2007
%--------------------------------------------------------------------------------------------------------------

function Desp_barra(pot1,pot2)

global w0 w1 w2 fact_der dist long_minima long_max bar a_rueda
global tecla selec mueve vel empiezo flecha1 flecha2 tiempo_en_bloq t_bloq        
global fig_rueda fig_rueda_aux umbral                                    


dist=pot1*w1+pot2*w2+w0;    % Se calcula la distancia de la barra.

if dist>0                   % Si la dist es positiva, el sujeto est� realizando la tarea de seleccionar.  
    dist=dist*fact_der;     % Ajusto la distancia de la barra multiplicando por el factor derecho
    bar=umbral*dist;        % Multiplico la barra por un umbral q hemos calculado q depende de 0.7(dist de selec) 
                            % y la mitad de la dist_media, esto lo hacemos para ampliar el rango de selecci�n
else
    bar=long_minima;        % si se est� realizando el otro estado mental, la barra tendr� una longitud minima(0,35)
end;

%/----------------------------------------------------------------------------------------

if bar<=0.35            % si el tama�o de barra (dist) es minimo, la barra tiene q medir una long minima (0,35)
    bar=long_minima;        
    t_bloq=0;
elseif bar>0.7          % la "dist" supera el umbral del bloque, inicio el contador    
    t_bloq=t_bloq+1;    % incremento el contador de tiempo en bloque
    if bar>1            % compruebo si el tama�o de la barra es el m�ximo, es decir sobrepasa la circunferencia exterior
        bar=long_max;   % si la "dist" es m�s grande de la cuenta, pongo una long m�xima para el tama�o de la flecha
    end,
    mueve=mueve+vel;    % si entro en el limite de la rueda, paro la flecha para poder seleccionarla bien. 
                        % Para parar el desplazamiento, se suma la velocidad para anular la resta que se har� posteriormente
else                    
    t_bloq=0;           % si la dist es menor q el umbral del bloque pongo a cero la variable.   
end,

if t_bloq==tiempo_en_bloq,   % si he estado el suficiente tiempo en el bloque, lo selecciono
    selec=1;
    t_bloq=0;           % inicializo la variable de tiempo en bloque      
    if a_rueda==0,      % cambio el color de la barra para destacar que ha habido un selecci�n.
        figure(fig_rueda);      %primero compruebo en que rueda estamos trabajando.
        set(flecha1,'color',[1 0 0],'LineWidth',10);    % cuando selecciono cambio el color y el grosor de la flecha1
    else
        figure(fig_rueda_aux);
        set(flecha2,'color',[1 0 0],'LineWidth',10);    % cuando selecciono cambio el color y el grosor de la flecha2
    end,
end,

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
if (selec==0) & (a_rueda==0)            % desplazo la flecha en la rueda pral
    desplaza(fig_rueda,flecha1);
elseif (selec==1) & (a_rueda==0)        % voy a seleccionar el bloque en la rueda pral
    a_rueda=1;                          % marco que voy a la rueda auxiliar(a_rueda=1)
    desplaza(fig_rueda,flecha1);        % llamo a 'desplaza' para ir a 'selec_bloque'
    mueve=90-vel;                       % para desplazar la barra en la rueda auxiliar empiezo en 90�(menos la velocidad)
    empiezo=2;                      %%// esta variable es para q haga un pause al entrar en la rueda_aux("tiempo2frec")
elseif (selec==0) & (a_rueda==1)        % desplazo la flecha en la rueda auxiliar
    desplaza(fig_rueda_aux,flecha2); 
elseif (selec==1) & (a_rueda==1)        % selecciono la letra en la rueda auxiliar
    selec_letra;                        % llamo a selec_letra
    a_rueda=0;                          % el siguiente paso voy a la rueda principal (a_rueda=0)
    selec=0;                            % reinicio selecci�n para la proxima vez
    mueve=90-vel;                       % prepara la barra en la posici�n de 90� menos la velocidad elegida
    tecla=1;                            % reinicio tambi�n la variable tecla, que indica el bloque al que voy                
    empiezo=3;                      %%// esta variable es para q haga un pause al entrar en la rueda("tiempo2frec")
end;     
   


      
    