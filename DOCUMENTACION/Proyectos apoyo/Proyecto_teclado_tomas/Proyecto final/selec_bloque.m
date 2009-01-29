%
%  Programa: Selec_bloque
%
%   Una vez he selecionado un bloque, entro en Selec_bloque y pongo en
%   'tecla' el numero de bloque
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: selec_letra, pulsar
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------

global mueve fig_rueda_aux flecha2 tecla principal a_rueda borrar 

%----------------------------------------
if (90<mueve) & (mueve<121)         % si selecciono "borrar" 
    borrar=1;               % variable que se usa en 'escribe'
    escribe('');            % llama a 'escribe' pasandole un caracter en blanco
    tecla=10;               % la tecla 10 corresponde al último bloque
    a_rueda=0;              % para volver a la rueda pral.

else,           % si no es borrar, selecciona el bloque correspondiente, los nombramos con 'tecla'
    if (55<mueve) & (mueve<91),     % 'mueve' indica el angulo donde la flecha ha selecionado,
        tecla=1;                        % ABC
    elseif (22<mueve) & (mueve<56),     % DEF
        tecla=2;
    elseif ((0<mueve)&(mueve<23)) | ((348<mueve)&(mueve<361)),  % GHI
        tecla=3;
    elseif (314<mueve) & (mueve<349),   % JKL
        tecla=4;
    elseif (270<mueve) & (mueve<315),   % MNÑO
        tecla=5;
    elseif (225<mueve) & (mueve<271),   % PQRS
        tecla=6;
    elseif (191<mueve) & (mueve<226),   % TUV
        tecla=7;
    elseif (146<mueve) & (mueve<192),   % WXYZ
        tecla=8;
    elseif (120<mueve) & (mueve<147),   % caracteres
        tecla=9;
    end;   %/ end if

principal=0;                        % "principal=0" y 'a_rueda=1' indica que vamos a la rueda auxiliar
a_rueda=1;
fig_rueda_aux=open('rueda.fig');    % abro la rueda auxiliar       

figure(fig_rueda_aux);
set(figure(fig_rueda_aux), ...
	'NumberTitle','off', ...
	'Name','Seleccion de letra', ...
	'Resize','off', ...
	'MenuBar','none', ...
	'ToolBar','none', ...
    'Units','cent', ...
    'KeyPressFcn',@pulsar, ...
    'Position',[6.1 4.9 14 14], ...
    'Pointer','arrow');

dibujo(fig_rueda_aux)               % dibujo la rueda_auxiliar con el bloque selecionado
flecha2=plot([1 1],[1 1.45],'color',[1 0 0],'LineWidth',6); % flecha2 es la flecha de la rueda auxiliar

end,        % endif 'borrar'
