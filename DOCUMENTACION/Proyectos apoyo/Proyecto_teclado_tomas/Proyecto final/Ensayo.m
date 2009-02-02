%
%  Programa: Ensayo
%
%Se responsabiliza de la organizaci�n general del ensayo, llamando al programa Present
%tantas veces como pruebas haya, grabando la estad�stica de aciertos/fallos, y grabando
%la configuraci�n tras el ensayo y antes de salir.(Para mas informaci�n mirar dentro
%de este mismo programa).
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: filtrar_eeg, Medir
%
%
% Tomas Perez Lisbona - Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga - 2007
%--------------------------------------------------------------------------------------------------------------
%

global fig_sujeto duration tam nvent nump exito exitoar exitoab fallo per1 per2; %Las propias de este Ensayo.m

%En realidad solo necesito las siguientes vbles del panel, pero como tb grabo aqui, pues las necesito todas:

global Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba;
global izq der trigger long_minima long_max t_bloq tiempo_en_bloq
global bloque_analisis bloque_dur_ana bloque_objetivo bloque_cursor bloque_beep bloque_fin_CUE bloq_seg
global pausa bloques_pausa empiezo borrar a_rueda selec x y
global escribo estilo grosor cod_estilo cod_grosor          % la uso en "selec_letra"

x=0;
y=0;
a_rueda=0;              % variable para comprobar el paso de la aplicaci�n donde estoy
selec=0;                % variable para comprobar el paso de la aplicaci�n donde estoy
t_bloq=0;               %/ tam bloques que debe estar en la casilla para ser seleccionada
long_minima=0.35;       %/ long minima de la flecha
long_max=0.95;          %/ long m�xima de la flecha
escribo=0;              %/ para contar las letras que escribo
borrar=0;               %/ para q "desp_barra" sepa si he borrado
tiempo_en_bloq=round(tiempo_en_bloq/0.031);    %/ calculo el n� de tam para q un bloq sea seleccionado 
%NVNV-------------------------------------------------------------------- NUEVOS PARAMETROS:
%NV ESTOS PARAMETROS LOS UTILIZO PARA CONTROLAR LOS TIEMPOS A TRAVES DE LOS
%BLOQUES QUE VOY PROCESANDO Y NO CON EL TIEMPO DEL PROCESADOR QUE PUEDE VARIAR.

bloq_seg=Fs/tam_ventana;
bloque_objetivo=t_objetivo*bloq_seg; 
bloque_beep=2*bloq_seg;  %NV ES EL BEEP DEL PARADIGMA DE GRAZ A LOS DOS SEGUNDOS
bloque_fin_CUE=4.25*bloq_seg; %esto  es para Fs=128 y tam =4 

%-------------------------------------------------------------------------PARAMETROS:
duration=d_prueba;      % Lo introduzcon en "Panel"
tam= tam_ventana;       % Lo introduzcon en "Panel" (standar= vent. de 100msg(13muestras)
nump= 4*Fs;             % N� de puntos que se piden al metodo de estimacion espectral; Hay que tener cuidado con esto
%                       ya que los algoritmos calculan 'nump' puntos, pero al pedir nosotros los resultados 'onesided'
%                       (unilaterales-solo frecuencias positivas y el 0) solo se nos devuelven 'nump/2+1' puntos.
bloques_pausa=round(pausa/(tam/Fs));     %/     4 / (4/128) =128; el round es para aproximar al entero m�s cercano
empiezo=1;               %/ variable para hacer un pause nada m�s empezar

%----------------------------------------------------------------Cuerpo del Programa:

trigger=0;      %NV GRAZ: SIRVE PARA CREAR UNA TRAZA DE TRIGGER

if estilo==2,                   %/ estilo de texto
    cod_estilo='italic';
else    
    cod_estilo='normal';
end,
if grosor==2,
    cod_grosor='bold';
else    
    cod_grosor='normal';
end,

figure(fig_texto);              %/ si he modificado el color de la ventana texto aqui lo actualizo
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
   'Position',[.6 .6 25.7 2], ...
   'BackgroundColor',cod_colorf{colorf}, ... %Color del fondo
   'ForegroundColor',cod_color{color}, ...
   'ToolTipString','Escriba aqu� el texto');


filtrar_eeg;    %/ preparo el filtro y las variables A y B para el filtrado en "tiempo2frec"

Medir;  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Llamo a la funcion de adquisicion 
     
clear muestra1 muestra2;%Es lo mejor para evitar efectos imprevisibles.

%Guardo todas las variables del panel:
screensize3=get(figure(fig_sujeto),'Position'); %Para obtener la posicion y dimensiones de la figura3

aviso(['Fin del ensayo'],figure(fig_sujeto));
%----------------------------------------------------------------------------------------
close all;
clear all;
Panel;      % Al terminar 'Ensayo.m' volvemos a llamar al panel para que limpie todo y empiece de nuevo
                    
