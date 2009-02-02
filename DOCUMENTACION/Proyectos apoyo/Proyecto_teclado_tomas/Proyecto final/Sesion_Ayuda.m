%
% Sesion_Ayuda: 
%
%   programa que gestiona la ayuda del Panel de Control de Sesiones
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


figs(8)=figure(8);
set(figs(8), ...
	'NumberTitle','off', ...
	'Name','Editor de Texto controlado por se�ales EEG - Ayuda de Sesi�n', ...
	'Resize','off', ...
	'MenuBar','none', ...
	'Units','cent', ...
	'Position',[5 2 17.1 9], ...
   'Pointer','arrow');
%'Position',[posicion(1) posicion(2) 15 10], ...
frameHndl_mensaje=uicontrol( ...
   'Style','frame', ...
   'Units','cent', ...
   'Position',[.5 .5 16.1 7], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'String','Frame');

%-------------------------------------------------------------------Tama�o de la Ventana
mensaje0=[...
'                                                                                                    ';...%linea siguiente
'                                                                                                    ';...        
'                          PROCESADOR DE TEXTO CONTROLADO POR SE�ALES EEG                            ';...
'                                                                                                    ';...
'                             Escuela T�cnica Superior de Ingenieros de Telecomunicaci�n             ';...
'                                        Departamento  de Tecnolog�a Electr�nica 2007                ';...
'                                                       Universidad de M�laga                        ';...        
'                                                                                                    ';...
'                                            Profesor tutor: Ricardo Ron Angev�n                     ';...
'                                                Alumno: Tom�s P�rez Lisbona                         ';...
'                                                                                                    '];
mensaje1=[...
'     El usuario debe configurar la aplicaci�n con los siguientes par�metros personales:             ';...%linea siguiente
'                                                                                                    ';...
' -Fc.Inf y Fc.Sup: Son las frecuencias de corte inferior y superior. Se usan para dise�ar el filtro.';...
' -F.Der y F.Izq: Factor multiplicativo derecha e izquierda. Adaptan los valores del usuario a los   ';...
'que necesita la aplicaci�n para su funcionamiento correcto.                                         ';...
' -w0, w1 y w2: Son unos pesos obtenidos previamente por LDA que necesita el clasificador de se�ales.';...
' -Umbral del usuario: Valor personal por el que se multiplica D� para adaptar el tama�o de la barra.';...
' -T.Pausa: Tiempo que transcurre entre que se ha realizado un evento y un nuevo proceso de selecci�n';...
' -Velocidad de rotaci�n: Velocidad con la que se desplaza de la flecha. Se va a medir en grados.    ';...
' -T. de selecci�n: Tiempo que el usuario debe permanecer dentro de un bloque para que se seleccione.';...
'                                                                                                    '];
mensaje2=[...
'      El m�todo para seleccionar las letras del alfabeto ha sido distribuir los caracteres entre 10 ';...
' bloques situados de forma circular donde se podr�n seleccionar con una flecha m�vil.               ';...
'      Para selecci�nar una letra, existe una flecha en el centro del c�rculo que apunta hacia los   ';...
' bloques. Al ejecutar un estado mental determinado la flecha gira en sentido horario, y al imaginar ';...
' el otro la flecha empieza a extenderse hasta alcanzar el bloque. Si esto sucede durante un periodo ';...
' de tiempo establecido (T.selecci�n), el bloque ser� seleccionado.                                  ';...
'      En ese momento se abrir� una nueva rueda donde solamente aparezcan las letras del bloque selec';...
'cionado. En esta rueda se realizar� un proceso de selecci�n para eleg�r la letra deseada.           ';...
'      Existe la opci�n de BORRAR una letra, la cual se podr� seleccionar en la rueda principal.     ';...
'      Una vez se haya seleccionado una letra, �sta se representar� en la ventana de texto.          ';...
'                                                                                                    '];


mensaje=[mensaje0 mensaje1 mensaje2]; %Concatenamos todos los msjs para tratarlos mas comodamente

%----------------------------------------------------------------------------UICONTROLS:
%------------------------------------------------------------Cuadro de texto para el msj
textHndl_mensaje = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'FontSize', 10, ...
   'Position',[.8 .8 15.7 6.4], ...
   'BackgroundColor',[0.5 0.5 0.5], ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','',...
   'String',mensaje0);

%------------------------------------------------------------------------ Bot�n Anterior
Accion_anterior= [...
        'ayuda = get(popup_ayuda,''Value'');',... %Se movera entre 1 y el numero de ayudas
        '',...                                    %que debera ser igual a length(mensaje)/100
        '',...                                    %Cada mensaje es una matriz 30*100
        'ayuda = ayuda -1;',... %Se movera entre 0 y length(mensaje)/100 - 1
        'if ayuda==0, ayuda=length(mensaje)/100; end;',...%Si es 0, hay que rotar y volver al ultimo
        'set(popup_ayuda,''Value'',ayuda);',...
        'set(textHndl_mensaje,''String'',mensaje(:,(ayuda-1)*100+1:ayuda*100));',...
    ]; 

pushHndl_anterior= uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[0.5 8 2 alt], ...
    'BackgroundColor',[0.5 0.5 0.5], ... %Color del fondo
    'ForegroundColor',[0 0 0], ...
    'ToolTipString','Ver ayuda anterior',...
    'String','<< Anterior', ...
	'CallBack',Accion_anterior);


%----------------------------------------------------------------------- Bot�n Siguiente
Accion_siguiente= [...
        'ayuda = get(popup_ayuda,''Value'');',... %Se movera entre 1 y el numero de ayudas
        '',...                                    %que debera ser igual a length(mensaje)/100
        '',...                                    %Cada mensaje es una matriz 30*100
        'ayuda = ayuda +1;',... %Se movera entre 0 y length(mensaje)/100 - 1
        'if ayuda==length(mensaje)/100+1, ayuda=1; end;',...%Si es 0, hay que rotar y volver al ultimo
        'set(popup_ayuda,''Value'',ayuda);',...
        'set(textHndl_mensaje,''String'',mensaje(:,(ayuda-1)*100+1:ayuda*100));',...
    ]; 
pushHndl_siguiente= uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[2.6 8 2 alt], ...
    'BackgroundColor',[0.5 0.5 0.5], ... %Color del fondo
    'ForegroundColor',[0 0 0], ...
    'ToolTipString','Ver siguiente ayuda',...
    'String','Siguiente >>', ...
	'CallBack',Accion_siguiente);

%--------------------------------------------------------------------------- Menu Pop-up
Accionpopup_ayuda=[...
        'ayuda = get(popup_ayuda,''Value'');',...
        'if ayuda==1, set(textHndl_mensaje,''String'',mensaje0);',...
        'elseif ayuda==2, set(textHndl_mensaje,''String'',mensaje1);',...
        'elseif ayuda==3, set(textHndl_mensaje,''String'',mensaje2);',...
        'else,',... %supongo que quiere salir
        'close gcf; end;',...
    ];
popup_ayuda = uicontrol( ...
   'Style','popup', ...
   'Units','cent', ...
   'Position',[5.1 8 4.4 alt], ...
   'BackgroundColor',[0.9 0.9 0.9], ...
   'ForegroundColor',[0 0 0], ...
   'String','Miscelanea|Par�metros a introducir|Funcionamiento General|Salir', ...
   'ToolTipString','Elija la ayuda',...
   'Value',1, ...
   'CallBack',Accionpopup_ayuda);


%--------------------------------------------------------------- Bot�n Salir de la Ayuda
Accion_salir= [...
        'close gcf;'
    ]; 
pushHndl_salir= uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[10 8 2 alt], ...
    'BackgroundColor',[0.5 0.5 0.5], ... %Color del fondo
    'ForegroundColor',[0 0 0], ...
    'ToolTipString','Salir de la Ayuda',...
    'String','Salir', ...
	'CallBack',Accion_salir);