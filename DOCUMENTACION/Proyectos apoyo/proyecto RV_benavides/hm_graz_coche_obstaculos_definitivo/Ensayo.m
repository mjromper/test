%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%
%  Programa: Ensayo
%
%Se responsabiliza de la organización general del ensayo, llamando al programa Present
%tantas veces como pruebas haya, grabando la estadística de aciertos/fallos, y grabando
%la configuración tras el ensayo y antes de salir.(Para mas información mirar dentro
%de este mismo programa).
%
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> Present --> Medir --> Prueba --> tiempo2frec --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%Vea también: HMPanel, Present, ..., ModelarFiltros, ...

%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad de Málaga
%------------------------------------------------------------------------------------

%Ensayo.m --> (Antiguo medir.m)
%	Una SESIÓN está formada por un conjunto de ENSAYOS, cada uno de los cuales
%	está dividido a su vez en distintas PRUEBAS:
%	- Cada PRUEBA consiste en un ejercicio diferenciado para el sujeto, en el que
%	  se le pedirá que se concentre en realizar determinada ACTIVIDAD, que en
%     general será relajarse, pensar algo, o realizar algún movimiento. Así una
%     prueba suele durar unos pocos segundos.
%	- Cada prueba puede dividirse en INTENTOS, de los cuales no tiene porqué ser
%	  consciente el sujeto, generalmente:
%	  ·Cada Intento corresponde con una evaluación del EEG del sujeto, y 
%		determinará un movimiento del cursor(que se realimenta hacia el sujeto,
%		pues este ve el resultado de su esfuerzo en la pantalla)
%	- ENSAYO es un conjunto de pruebas que definen un experimento, podemos organizar
%	  las pruebas que forman cada ensayo de distinta manera:
%		·Ej.1: Pedir al sujeto que haga lo que quiera, se supone que no sabe nada
%		 acerca del funcionamiento del sistema y sólo pretendemos ver sus niveles
%		 de respuesta, o el BW de sus señales alpha. En este caso, quizá sea mejor
%		 que el sujeto no mire la pantalla, ni reciba estimulos externos.
%		·Ej.2: Pedir al sujeto que se concentre en una única Actividad, con el fin
%		 de que practique sÓlo esa.
%		·Ej.3: Organizar Pruebas con Actividades alternativas, para que el sujeto
%		 se esfuerze mas, al tener que cambiar de Actividad.
%	- Llamaremos SESIÓN al conjunto de ensayos que se realizan en un mismo día. 
%	  Generalmente guardaremos los distintos Ensayos en un directorio que indique
%	  datos sobre la sesión, con el formato Sujeto_Fecha_Actividad.
%--------> Esquema de un ENSAYO: 
% Los intentos están marcados con el carácter '^':
%
%  		Prueba 1			Prueba 2			Prueba 3								Prueba 20
%   |					|					|					|		...		 |					|
%	 ^ ^ ^ ^ ^ ^ ^... ^  ^ ^ ^ ^ ^ ^...  ^   ^ ^ ^ ^ ^ ^... ^  					  ^ ^ ^ ^ ^ ^ ... ^
%
% Un ENSAYO suele durar unos 3 minutos--> se divide en PRUEBAS de unos 8 sg, así que 
%  se hacen unas 20 pruebas/ensayo.
% ·Pfurtscheller hace 4 ensayos, 2 de cada lado del cerebro, y en cada ensayo hace 10
%  pruebas.
% · Wolpaw hace 8 ensayos, descansando 1 minuto después de cada ensayo. 

%Una prueba de 8 segundos, puede organizarse como sigue:
%[t_cursor=1; t_objetivo=3; t_analisis=4; d_analisis=3; d_prueba=8]
%	- [instante=0sg -> instante=1sg] Pantalla en negro
%	- En el instante=1sg aparece el cursor en el centro y se mantiene durante 2 sg
%	- En el instante=3sg aparece aleatoriamente(arriba/abajo) el rectángulo y se 
%     puede empezar a mover el cursor hasta el segundo 7.
%	- Cuando acaben los (t_analisis+d_analisis=7sg) se deja de analizar, pero se 
%     sigue muestreando hasta el final de la prueba.
%	- Sólo si ha habido éxito, el rectángulo parpadea durante 1 sg. al final de la 
%     prueba.
%	- Tanto si hubo éxito como si no, se hace un pause aleatorio entre 0.5 y 2.5 sg
%	0sg			1er.sg				3er.sg												7o. sg
%	|Pantalla negra|Aparece cursor	|	Aparece aleatoriamente el rectángulo	|
%
%[Intervalos de tiempo basados en el artículo 14 (Clasificación de Ricardo)]

%Con global indico que cuando use esos nombres, estoy haciendo referencia a variables
%globales que ya haya definido antes como tales:
global fig_sujeto fig_tiempo pruebactual duration tam nvent nump exito exitoar exitoab fallo per1 per2; %Las propias de este Ensayo.m
global texto_flecha_dcha texto_flecha_izda;
%En realidad solo necesito las siguientes vbles del panel, pero como tb grabo aqui, pues las
%necesito todas:
%global Fs tam_ventana orden t_cursor t_analisis d_analisis d_descanso ntot_pru %Variables del Panel
global posicion sujeto identificador ensayo num_ensayo fecha prueba1 tipo1 cantidad1 ...
    prueba2 tipo2 cantidad2 prueba3 tipo3 cantidad3 prueba4 tipo4 cantidad4 ...
    Fs tam_ventana solape metodoEE orden t_cursor t_objetivo t_analisis d_analisis d_prueba ...
    desc_ep_fijo desc_ep_aleat d_descanso ...
    grabar_c1 grabar_c2 grabar_c3 grabar_c4 c1 c2 c3 c4 c5 ver_t ver_f;
global trayectoria ntot_pru;

global no_portatil izq der trigger%NV
global  bloques_proc_eje_tiempo eje_tiempo %NV
global bloque_analisis bloque_dur_ana bloque_objetivo bloque_cursor bloque_beep bloque_fin_CUE%NV
%NV (Paco).
global manejador_sonido1;
global muestratotal1 muestratotal2 muestra1 muestra2;
global tiempollamada tiempoactualizacion tiempollamanalisis tiempoactuanalisis;

%NVNV-------------------------------------------------------------------- NUEVOS PARAMETROS:
%NV ESTOS PARAMETROS LOS UTILIZO PARA CONTROLAR LOS TIEMPOS A TRAVES DE LOS
%BLOQUES QUE VOY PROCESANDO Y NO CON EL TIEMPO DEL PROCESADOR QUE PUEDE
%VARIAR.
pause(5);  %%%DEJO 5 SEGUNDOS PARA MAXIMIZAR LA PANTALLA DEL SUJETO
bloq_seg=Fs/tam_ventana;
bloque_analisis=t_analisis*bloq_seg; %NV
bloque_dur_ana=d_analisis*bloq_seg;
bloque_objetivo=t_objetivo*bloq_seg; %
bloque_cursor=t_cursor*bloq_seg;
bloque_beep=2*bloq_seg;  %NV ES EL BEEP DEL PARADIGMA DE GRAZ A LOS DOS SEGUNDOS
%bloque_fin_CUE=4.2*bloq_seg; %esto  es para Fs=130 y tam =26 o 13
bloque_fin_CUE=4.25*bloq_seg; %esto  es para Fs=128 y tam =4 

bloques_proc_eje_tiempo=eje_tiempo*Fs/tam_ventana; %NV NUMERO DE BLOQUES QUE SE PROCESAN EN TODO EL EJE DE TIEMPO
%EN CASO DE DESACTIVAR LA VARIALE aquisic_normal EN HM_PANEL
%-------------------------------------------------------------------------PARAMETROS:
duration= d_prueba;  %Me lo da PaneldeControl_Sesion(standar=3+4sg)
tam= tam_ventana; %Me lo da PaneldeControl_Sesion(standar= vent. de 100msg(13muestras)
nump= 4*Fs;  %Nº de puntos que se piden al metodo de estimacion espectral; (Lo usan tiempo2frec y
%             descursor). Hay que tener cuidado con esto, ya que los algoritmos calculan 'nump'
%             puntos, pero al pedir nosotros los resultados 'onesided'(unilaterales-solo frecuen-
%             cias positivas y el 0) solo se nos devuelven 'nump/2+1' puntos.
%ntot_pru: al haberlo definido como global ya ha cogido el valor que le di en el Panel de Cntrl.
%--------------------------------------------------------Inicializacion de variables:
nvent=1;%Inicializo el nº de ventana por el que voy
exito=0; %Para ir llevando la cuenta del nº de éxitos a lo largo de cada ensayo
exitoar=0; %inicializa el numero de exitos hacia arriba
exitoab=0; %inicializa el numero de exitos hacia abajo
fallo=0; %fallo es el numero de fallos
pruebactual=0;  %Esta variable me indicara el numero de la prueba actual

izq=0; %NV ESTAS VARAIBLES SON PARA CONTAR EL NUMERO DE VECES QUE SALE CADA FLECHA
der=0;
%--------------------------------------------------Borramos los botones de figure(fig_sujeto):
%NV delete(texto_flecha_dcha); 
%NV set(pushHndl_disminuirX,'visible','off');%Bastaria con borrarlos tambien
%NV set(pushHndl_aumentarX,'visible','off');
%NV delete(texto_flecha_izda);
%NV set(pushHndl_disminuirY,'visible','off');
%NV set(pushHndl_aumentarY,'visible','off');
%----------------------------------------------------------------Cuerpo del Programa:
muestratotal1=zeros(1,(Fs*duration*ntot_pru));
muestratotal2=zeros(1,(Fs*duration*ntot_pru));

for np=1:ntot_pru, %np llevará la cuenta del nº de prueba 
    if pruebactual <=ntot_pru,  %Siempre que no llegue al numero final de pruebas
        per1=0; %Se utilizan estas variables para que en respf2 se dibujen ...
        per2=0; %...el cursor y rectangulo una sola vez
        trigger=0;  %NV GRAZ: SIRVE PARA CREAR UNA TRAZA DE TRIGGER
        tiempollamada=zeros(1,(Fs*d_prueba/tam));
        tiempoactualizacion=zeros(1,(Fs*d_prueba/tam));
        tiempollamanalisis=zeros(1,(Fs*d_analisis/tam));
        tiempoactuanalisis=zeros(1,(Fs*d_analisis/tam));
        muestra1=zeros(1,(Fs*d_prueba));
        muestra2=zeros(1,(Fs*d_prueba));
        Present;          %Llamo a la funcion de adquisicion
        stop(manejador_sonido1);%Para el sonido del motor del coche, debido
        %a que ha finalizado una prueba.
        reload(mundovirtual);
        if no_portatil %NV
        set(fig_tiempo,'Name',['Prueba ' num2str(pruebactual) '(Descansando...)']);
        end
      
        pause(desc_ep_fijo + rand*desc_ep_aleat); %Entre prueba y prueba hago una pausa de duración aleatoria entre 0'5 y 2'5 sg.
      
    end, %if
    clear muestra1 muestra2 muestra3 muestra4;%Es lo mejor para evitar efectos imprevisibles.
    np = np + 1; %Actualizo nº de prueba
end, %for

%Al terminar Ensayo:
comando=['save ' trayectoria '\estadistica.mat fallo exito exitoar exitoab;'];
eval(comando)  %Se almacenan datos relativos a la estadistica de aciertos y fallos en los juegos
%Guardo todas las variables del panel:
%screensize3=get(figure(fig_sujeto),'Position'); %Para obtener la posicion y dimensiones de la figura3
save ensayo_config.mat posicion screensize3 sujeto identificador ensayo num_ensayo fecha prueba1 tipo1 cantidad1 ...
    prueba2 tipo2 cantidad2 prueba3 tipo3 cantidad3 prueba4 tipo4 cantidad4 ...
    boton_Ninguno boton_Muro boton_Rampa boton_Charco ...
    Fs tam_ventana solape metodoEE orden t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo desc_ep_aleat d_descanso ...
    filtroi modof fltrdo_algoritmo fltrdo_tipo fltrdo_orden fltrdo_rizo_c fltrdo_fc1 fltrdo_fc2 ...
    fltrdo_wp1 fltrdo_wp2 fltrdo_ws1 fltrdo_ws2 fltrdo_rizo_p fltrdo_rizo_s Nums Dens ...
    grabar_c1 grabar_c2 grabar_c3 grabar_c4 c1 c2 c3 c4 ver_t ver_f;

aviso(['Indíquele al sujeto que descanse ' num2str(d_descanso) ' sg. antes del siguiente ensayo']);

%----------------------------------------------------------------------------------------

close all;
%clear all;
%PanelDeControl_Sesion; %Al terminar 'Ensayo.m' volvemos a llamar al panel para que limpie
                       %todo y empiece de nuevo---->>>PARECE QUE DA UN ERROR!!!!!!!!!
                    

