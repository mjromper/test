%
%  Programa: Escribe
%
%   A�ade la letra seleccionada a la cadena de texto anterior
%   Selec_letra le pasa una letra "cad" que se a�ade a la palabra antigua
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
% Vea tambien: pulsar
%
%
% Tomas Perez Lisbona - Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga - 2007
%--------------------------------------------------------------------------------------------------------------

function escribe(cad)


global colorf cod_colorf color cod_color tamano cod_estilo cod_grosor
global fig_texto
global palabra_nueva palabra_ant
global borrar


if borrar==1,                       % compruebo si he seleccionado borrar
    palabra_nueva=palabra_ant;      % para borrar, copiamos la palabra_anterior como palabra_nueva
    palabra_ant=palabra_ant(1:(length(palabra_ant)-1));     % cuando borro, escribo la palabra anterior, y la anterior la recalculo
    borrar=0;                       % ponemos la variable a cero
else
    palabra_ant=palabra_nueva;              % no hay que borrar, en la palabra_anterior copio la nueva
    palabra_nueva=strcat(palabra_ant,cad);  % concateno el nuevo caracter a la palabra
end,
    
figure(fig_texto);                  % nos vamos a la ventana de texto y escribimos
set(figure(fig_texto), ...
	'NumberTitle','off', ...
	'Name','Ventana de texto', ...
	'Resize','off', ...
	'MenuBar','none', ...
	'Units','cent', ...
    'KeyPressFcn',@pulsar, ...
	'Position',[0.05 0.9 26.95 3.2], ...
    'Pointer','arrow');

editHndl_texto=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'FontAngle', cod_estilo, ...
   'FontWeight', cod_grosor, ...
   'Position',[.6 .6 25.7 2], ...
   'BackgroundColor',cod_colorf{colorf}, ... %Color del fondo
   'ForegroundColor',cod_color{color}, ...
   'FontSize',tamano,...
   'String',palabra_nueva);

