%--------------------------------------------------------------------------
%  Programa: HMPanel
%--------------------------------------------------------------------------
%   Francisco Benavides Mart�n,  Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnolog�a Electr�nica - Universidad 
%   de M�laga
%--------------------------------------------------------------------------

close all; 
clear all; 

% -------------------------------------------------------------------------
whitebg('k'); 

global tiempollamada tiempoactualizacion actualiza actualiza1; 
global color_dibujos color_fondo; 
color_dibujos=[1 1 1];
color_fondo=[0 0 0]; 
global COLOR_FONDO_APLICACION COLOR_FONDO_TEXTOS COLOR_FONDO_PETICIONES COLOR_TEXTO_PETICIONES COLOR_TEXTO_MARCAS; 

COLOR_FONDO_APLICACION= [.5 .5 .5];
COLOR_FONDO_TEXTOS= [.5 .5 .5]; 
COLOR_FONDO_PETICIONES=[1 1 1]; 
COLOR_TEXTO_PETICIONES=[0 0 0];
COLOR_TEXTO_MARCAS=[0 0 0]; 

alt=0.5;

global fig_panel fig_sujeto;
global mundovirtual linea arbol coche coche_roto vision_coche; 
global obstaculomuro muro muro1;
global tecla movido pulsacion pulso; 
global inst_muro inst_tecla;

fig_panel=1; 

mundovirtual=vrworld('pruebaobstaculo4.wrl'); 

global posicion sujeto identificador ensayo num_ensayo fecha prueba1 cantidad1 ...
        Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo desc_ep_aleat d_descanso;
global ntot_pru  trayectoria; 

global manejador_sonido1 manejador_sonido2;

load coche1.mat;
manejador_sonido1=audioplayer(y,11025);
load cocheroto.mat;
manejador_sonido2=audioplayer(x,11025);

movido=0;
pulso=0;
pulsacion(1)=2; 
inst_muro=0; 
inst_tecla=0;
 
if exist('ensayo_config.mat')==2
    load ensayo_config;
else    
   unidades=get(0,'Units'); 
   set(0,'Units','cent');
   Screensize=get(0,'Screensize'); 
   posicion=[Screensize(3)/2-7.5 Screensize(4)/2-5] 
   screensize3=[960     0   960   720]; 
   set(0,'Units',unidades);  
   
   sujeto=''; 
   identificador=''; 
   ensayo=''; 
   num_ensayo=0;
   
   fecha=date;
   
   prueba1=1;		 		cantidad1=20;
  
   Fs=130; 
   tam_ventana=13; 
 
   t_cursor= 1; 
   t_objetivo=3; 
   t_analisis= 4; 
   d_analisis= 3; 
   d_prueba=8;
   desc_ep_fijo=2; 
   desc_ep_aleat=.5; 
   d_descanso= 60; 
   
end
   
set(0,'Units','pixels'),
Screensize=get(0,'Screensize'); 
Screensize=[Screensize(3) Screensize(4)]; 


open(mundovirtual);
figure('KeyPressFcn',@pulsar,'Position',[0 -200 0.1 0.1]);
fig_sujeto=vrfigure(mundovirtual,[4 75 1300 750]);
linea=vrnode(mundovirtual,'LINEA1');
arbol=vrnode(mundovirtual, 'Tree');
vision_coche=vrnode(mundovirtual, 'switch_coche');
coche=vrnode(mundovirtual, 'Octavia');
coche_roto=vrnode(mundovirtual, 'Octavia_choque');
obstaculomuro=vrnode(mundovirtual, 'OBSTACULOmuro');
muro=vrnode(mundovirtual, 'Muro');
muro1=vrnode(mundovirtual, 'Muro1');


figure(fig_panel);
set(figure(fig_panel), ...
	'NumberTitle','off', ...
	'Name','DTE - Proyecto IHMAN-BCI: Herramienta de Medida', ...
	'Resize','off', ...
	'MenuBar','none', ...
	'Units','cent', ...
	'Position',[posicion(1) posicion(2) 15 8.8], ...
   'Pointer','arrow');

frameHndl_sujeto=uicontrol( ...
   'Style','frame', ...
   'Units','cent', ...
   'Position',[.2 6.95 14.6 1.5], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'String','Frame');

textHndl_sujeto=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[.5 7.8 1 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Nombre del sujeto',...
   'String','Sujeto:');

Accion_sujeto=['sujeto=get(editHndl_sujeto,''String'');'];
editHndl_sujeto=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[1.5 7.8 7.5 alt], ...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� el nombre del sujeto',...
   'String',sujeto, ...
   'CallBack',Accion_sujeto);

textHndl_identificador=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[9.5 7.7 1.8 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Nombre corto para referirse al sujeto(se usar� para crear directorios)',...
   'String','Identificador:');

Accion_identificador=['identificador=get(editHndl_identificador,''String'');'];
editHndl_identificador=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[11.3 7.7 3.2 alt], ...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... %Color del fondo
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� el identificador del sujeto',...
   'String',identificador, ...
   'CallBack',Accion_identificador);

textHndl_ensayo=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[.5 7.2 3 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Nombre corto para referirse al ensayo(se usar� para crear directorios)',...
   'String','Nombre del Ensayo:');

yaexiste=0;

Accion_ensayo=[...
      'ensayo=get(editHndl_ensayo,''String'');',...
      'directorio=[''Sesiones\'' identificador ''\sesion_'' fecha ''\'' ensayo];',...
      'if exist(directorio,''dir'')==7,',... 
      'Aviso(''Ese directorio ya existe, si prosigue borrara su contenido'');',...
      'yaexiste=1;',...
      'else,',...
      'num_ensayo=0;',...
      'yaexiste=0;',...
      'end;'];

if num_ensayo==0
   num_ensayo=1;
   ensayo=[ensayo '1'];
else
   quitar=length(num2str(num_ensayo));
   num_ensayo = num_ensayo+1;
   ensayo=[ensayo(1:end-quitar) num2str(num_ensayo)]; 
end
      
editHndl_ensayo=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[3.3 7.2 3 alt], ...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� el ensayo del sujeto',...
   'String',ensayo, ...
   'CallBack',Accion_ensayo);

textHndl_fecha=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[11 7.2 1 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Fecha del experimento',...
   'String','Fecha:');

fecha=date;
Accion_fecha=['fecha=get(editHndl_fecha,''String'');'];
editHndl_fecha=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[12 7.2 2.5 alt], ...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Compruebe que la fecha es correcta',...
   'String',fecha, ...
   'CallBack',Accion_fecha);


frameHndl_ensayo=uicontrol( ...
   'Style','frame', ...
   'Units','cent', ...
   'Position',[.2 5.45 14.6 1.45], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'String','Frame');

Accioncheck_prueba1=['prueba1 = get(check_prueba1,''Value'');',...
      'if prueba1==0, cantidad1=0; set(editHndl_cantidad1,''String'',[0]);',...
      'else,',...
      'cantidad1=1; set(editHndl_cantidad1,''String'',[1]);',...
      'end;'];
check_prueba1 = uicontrol( ...
   'Style','check', ...
   'Units','cent', ...
   'Position',[2.5 5.7 2.5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ... 
   'ForegroundColor',[1 1 1], ...
   'String','pruebas:', ...
   'ToolTipString','Marque esta opci�n para hacer pruebas del tipo 1',...
   'Value',prueba1, ...
   'CallBack',Accioncheck_prueba1);
     

Accion_cantidad1=['cantidad1=str2num(get(editHndl_cantidad1,''String''));',...
      'if cantidad1==0, prueba1=0; set(check_prueba1,''Value'',0);',...
      'else,',...
      'prueba1=1; set(check_prueba1,''Value'',1);',...
      'end;'];
editHndl_cantidad1=uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[4.5 5.7 1 alt], ...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� la cantidad de pruebas consecutivas del tipo 1',...
   'String',num2str(cantidad1), ...
   'CallBack',Accion_cantidad1);

Accion_push_cantidad1_mas=['if cantidad1>0,cantidad1=cantidad1+1; end;',...
      'if cantidad1==0,',...
      'cantidad1=1; prueba1=1; set(check_prueba1,''Value'',prueba1);',...
      'end;',...
      'set(editHndl_cantidad1,''String'',num2str(cantidad1));']; 
pushHndl_cantidad1_mas=uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[5.5 5.95 .25 .25], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ... 
    'ForegroundColor',[1 1 1], ...
    'String','+', ...
	'CallBack',Accion_push_cantidad1_mas);
Accion_push_cantidad1_menos=['if cantidad1>0,cantidad1=cantidad1-1; end;',...
      'if cantidad1==0,',...
      'prueba1 = 0; set(check_prueba1,''Value'',prueba1);',...
      'end;',...
      'set(editHndl_cantidad1,''String'',num2str(cantidad1));']; 
pushHndl_cantidad1_menos=uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[5.5 5.7 .25 .25], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ...
    'ForegroundColor',[1 1 1], ...
    'String','-', ...
	'CallBack',Accion_push_cantidad1_menos);


Accion_push_crear= [...
        'dos([''md Sesiones'']);',...
        'dos([''md Sesiones\'' identificador]);',...
        'dos([''md Sesiones\'' identificador ''\sesion_'' fecha]);',...
        'dos([''md Sesiones\'' identificador ''\sesion_'' fecha ''\'' ensayo]);',...
        'dos([''notepad Sesiones\'' identificador ''\sesion_'' fecha ''\'' ensayo ''\ensayo_'' identificador ''.txt &'']);']; 

pushHndl_crear= uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[10 5.7 4.4 2*alt], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ...
    'ForegroundColor',[0.5 0.5 0.5], ...
    'ToolTipString','Crea un fichero para guardar info adicional del sujeto y la sesion',...
    'String','Crear fichero de info adicional', ...
	'CallBack',Accion_push_crear);


frameHndl_sesion = uicontrol( ...
   'Style','frame', ...
   'Units','cent', ...
   'Position',[.2 3.2 14.6 2.2], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'String','Frame');

textHndl_Fs = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[.3 3.9 4 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Frecuencia a que se muestrea cada canal[muestras/sg]',...
   'String','Frec. de muestreo[m/sg]:');

Accion_Fs=['Fs=str2num(get(editHndl_Fs,''String''));'];
editHndl_Fs=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[3.9 4 1 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� la cantidad de pruebas consecutivos del tipo 4',...
   'String',[Fs], ...
   'CallBack',Accion_Fs);

textHndl_tam_ventana = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[.3 3.4 4.3 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','tama�o que tendr� la ventana con que se llame al metodo de estimaci�n espectral',...
   'String','Tama�o ventana[muestras]:');


editHndl_tam_ventana=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[3.9 3.5 1 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','Escriba aqu� el tama�o de la ventana',...
   'String',[tam_ventana]);

textHndl_t_cursor = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[4.9 4.5 1.7 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Instante en que aparece el cursor(a partir de 0sg)',...
   'String','t_muro1[sg]:');

Accion_t_cursor=['t_cursor=str2num(get(editHndl_t_cursor,''String''));'];

editHndl_t_cursor=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[6.6 4.6 .5 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ...
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[t_cursor], ...
   'CallBack',Accion_t_cursor);

textHndl_t_objetivo = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[7.2 4.5 2 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Instante en que aparece el objetivo(a partir de 0sg)',...
   'String','t_muro2[sg]:');

Accion_t_objetivo=['t_objetivo=str2num(get(editHndl_t_objetivo,''String''));'];

editHndl_t_objetivo=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[9 4.6 .5 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[t_objetivo], ...
   'CallBack',Accion_t_objetivo);

textHndl_t_analisis = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[5.1 3.9 2.5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Instante en que se comienza el an�lisis en frecuencia',...
   'String','No lo uso:');

Accion_t_analisis=['t_analisis= str2num(get(editHndl_t_analisis,''String''));'];%,...
  
editHndl_t_analisis=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[6.5 4 .5 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[t_analisis], ...
   'CallBack',Accion_t_analisis);

textHndl_d_analisis = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[7.5 3.9 1.5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Tiempo que dura el an�lisis en cada prueba',...
   'String','t_colision:');

Accion_d_analisis=['d_analisis=str2num(get(editHndl_d_analisis,''String''));'];%,...
     
editHndl_d_analisis=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[8.9 4 .6 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[d_analisis], ...
   'CallBack',Accion_d_analisis);

textHndl_d_prueba = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[5.1 3.4 5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Tiempo que dura la prueba en total',...
   'String','Duraci�n de la prueba[sg]:');


Accion_d_prueba=['d_prueba=str2num(get(editHndl_d_prueba,''String''));'];
    
editHndl_d_prueba=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[8.5 3.5 1 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[d_prueba], ...
   'CallBack',Accion_d_prueba);

textHndl_desc_ep = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[9.6 4 4.5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Tiempo de descanso entre pruebas',...
   'String','Desc. entre pruebas[sg]:');

Accion_desc_fijo=['desc_ep_fijo=str2num(get(editHndl_desc_fijo,''String''));'];
editHndl_desc_fijo=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[12.8 4 .8 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','parte fija[segundos]',...
   'String',[desc_ep_fijo], ...
   'CallBack',Accion_desc_fijo);
Accion_desc_aleat=['desc_ep_aleat=str2num(get(editHndl_desc_aleat,''String''));'];
editHndl_desc_aleat=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[13.8 4 .8 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ... 
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','parte aleatoria[segundos]',...
   'String',[desc_ep_aleat], ...
   'CallBack',Accion_desc_aleat);

textHndl_d_descanso = uicontrol( ...
   'HorizontalAlignment','left',...
   'Style','text', ...
   'Units','cent', ...
   'Position',[9.6 3.5 5 alt], ...
   'BackgroundColor',COLOR_FONDO_TEXTOS, ...
   'ForegroundColor',[1 1 1], ...
   'ToolTipString','Tiempo que dura un descanso entre ensayos',...
   'String','Descanso entre ensayos[sg]:');

Accion_d_descanso=['d_descanso=str2num(get(editHndl_d_descanso,''String''));'];
editHndl_d_descanso=uicontrol( ...
   'HorizontalAlignment','right',...
   'Style','edit', ...
   'Units','cent', ...
   'Position',[13.6 3.5 1 alt], ...
   'Enable','off',...
   'BackgroundColor',COLOR_FONDO_PETICIONES, ...
   'ForegroundColor',COLOR_TEXTO_PETICIONES, ...
   'ToolTipString','tiempo en [segundos]',...
   'String',[d_descanso], ...
   'CallBack',Accion_d_descanso);


Accion_push_iniciar=[...
    'ntot_pru = cantidad1*prueba1;',...
        'if exist(''iniciar'',''var'')==1,',...
        '   trayectoria=[''Sesiones\'' identificador ''\sesion_'' fecha ''\'' ensayo],',...
        '   if yaexiste==1,',...
        '      delete([trayectoria ''\*.*'']),',...
        '      dos([''rd '' trayectoria]);',...
        '      num_ensayo=0;',...
        '   end;',...
        '   dos([''md Sesiones'']);',...
        '   dos([''md Sesiones\'' identificador]);',...
        '   dos([''md Sesiones\'' identificador ''\sesion_'' fecha]);',...
        '   dos([''md Sesiones\'' identificador ''\sesion_'' fecha ''\'' ensayo]);',...
        '',... 
        '   set(pushHndl_iniciar,''Fontsize'',26,''String'',''Iniciar Ensayo'');',...
        '   Ensayo;',...
        'else, iniciar=1;',... 
        ' set(pushHndl_iniciar,''Fontsize'',12,''String'',''Compruebe las conexiones y pulse de nuevo'');',...  
        'end;'];
pushHndl_iniciar=uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[.2 0.2 9 2.8], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ... 
    'ForegroundColor',[0.5 0.5 0.5], ...
    'FontSize',26,...
    'ToolTipString','Iniciar Ensayo con la configuraci�n establecida',...
    'String','Iniciar Ensayo', ...
	'CallBack',Accion_push_iniciar);


Accion_toggle_avanzada= [...
        'if get(pushHndl_avanzada,''Value'')==0,',... 
        'set(editHndl_Fs,''Enable'',''off'');',...
        'set(editHndl_tam_ventana,''Enable'',''off'');',...
        'set(editHndl_t_cursor,''Enable'',''off'');',...
        'set(editHndl_t_objetivo,''Enable'',''off'');',...
        'set(editHndl_t_analisis,''Enable'',''off'');',...
        'set(editHndl_d_analisis,''Enable'',''off'');',...
        'set(editHndl_d_prueba,''Enable'',''off'');',...
        'set(editHndl_desc_fijo,''Enable'',''off'');',...
        'set(editHndl_desc_aleat,''Enable'',''off'');',...
        'set(editHndl_d_descanso,''Enable'',''off'');',...
        'else,',...
        'set(editHndl_Fs,''Enable'',''on'');',...
        'set(editHndl_tam_ventana,''Enable'',''on'');',...
        'set(editHndl_t_cursor,''Enable'',''on'');',...
        'set(editHndl_t_objetivo,''Enable'',''on'');',...
        'set(editHndl_t_analisis,''Enable'',''on'');',...
        'set(editHndl_d_analisis,''Enable'',''on'');',...
        'set(editHndl_d_prueba,''Enable'',''on'');',...
        'set(editHndl_desc_fijo,''Enable'',''on'');',...
        'set(editHndl_desc_aleat,''Enable'',''on'');',...
        'set(editHndl_d_descanso,''Enable'',''on'');',...
        'end;']; 

pushHndl_avanzada= uicontrol( ...
    'Style','toggle', ...
    'Units','cent', ...
    'Position',[9.4 1.2 5.35 2*alt], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ... 
    'ForegroundColor',[0.5 0.5 0.5], ...
    'ToolTipString','Nos permite modificar los parametros sombreados',...
    'String','Configuraci�n Avanzada', ...
    'Value',0,...
	'CallBack',Accion_toggle_avanzada);

Accion_push_resetear=[...
      '[ntot_pru = cantidad1*prueba1];',...
      'if get(radio_seguro,''Value'')==1,',...
      'set(radio_seguro,''Value'',0);',...
      'sujeto='''';			set(editHndl_sujeto,''String'',sujeto);',...
      'identificador='''';	set(editHndl_identificador,''String'',identificador);',...
      'ensayo='''';         set(editHndl_ensayo,''String'',ensayo);',...
      'num_ensayo=0;',...
      'fecha=date;			set(editHndl_fecha,''String'',fecha);',...
      'prueba1=1;		set(check_prueba1,''Value'',prueba1);',...
      'cantidad1=20;	set(editHndl_cantidad1,''String'',cantidad1);',...
      'Fs=130;				            set(editHndl_Fs,''String'',num2str(Fs));',...
      'tam_ventana=13;	            set(editHndl_tam_ventana,''String'',num2str(tam_ventana));',...
      't_cursor= 1;		set(editHndl_t_cursor,''String'',num2str(t_cursor));',...  
      't_objetivo= 3;	set(editHndl_t_objetivo,''String'',num2str(t_objetivo));',... 
      't_analisis= 4;	set(editHndl_t_analisis,''String'',num2str(t_analisis));',... 
      'd_analisis= 3;	set(editHndl_d_analisis,''String'',num2str(d_analisis));',...  
      'd_prueba=8;      set(editHndl_d_prueba,''String'',num2str(d_prueba));',...     
      'd_descanso= 60;	set(editHndl_d_descanso,''String'',num2str(d_descanso));',...
      'else disp(''No puedo borrar sin el seguro''); end'...
   ]; 

radio_seguro = uicontrol( ... 
	'Style','radiobutton', ...
        'Units','cent', ...
        'Position',[9.4 .2 0.35 2*alt], ...
        'BackgroundColor',[1 0 0], ...
        'ForegroundColor',[1 1 1], ...
        'Value',0, ...
        'ToolTipString','Pulse para quitar el seguro de la tecla borrar',...
        'CallBack','');

pushHndl_resetear=uicontrol( ...
    'Style','pushbutton', ...
    'Units','cent', ...
    'Position',[9.75 0.2 5 2*alt], ...
    'BackgroundColor',COLOR_FONDO_TEXTOS, ... 
    'ForegroundColor',[0.5 0.5 0.5], ...
    'ToolTipString','Resetear parametros',...
    'String','Resetear parametros', ...
	'CallBack',Accion_push_resetear);

labels = str2mat( ...
     '&Salir', ...
     '>&Salir de Sesion^s', ...
     '>-------', ...
     '>&Salir de Matlab^m', ...
     '&Ayuda' ...
     ); 
 
 call_Salir=[...
     'posicion = get(figure(fig_panel),''Position'');',...
     'posicion = posicion(1,1:2);',...
     'save ensayo_config.mat posicion sujeto identificador ensayo num_ensayo prueba1 cantidad1 ',...
     'Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo desc_ep_aleat d_descanso ',...
     'Sesion_Salir;'...
  ]; 

 call_SalirDeMatlab=[...
     'posicion = get(figure(fig_panel),''Position'');',...
     'posicion = posicion(1,1:2);',...
     'save ensayo_config.mat posicion sujeto identificador ensayo num_ensayo prueba1 cantidad1 ',...
     'Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo desc_ep_aleat d_descanso ',...
     'SalirDeMatlab;'...
  ];

calls = str2mat( ...
     '', ...
     call_Salir, ...	
     '', ...
     call_SalirDeMatlab, ... 
     'Sesion_Ayuda' ... 
     );
 
handles = makemenu(gcf, labels, calls);   
