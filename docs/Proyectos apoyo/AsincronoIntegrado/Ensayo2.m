%
%  Programa: Ensayo2
%
%Se responsabiliza de la organización general del ensayo, llamando al
%programa Present
%tantas veces como pruebas haya, grabando la estadística de aciertos/fallos, y grabando
%la configuración tras el ensayo y antes de salir.(Para mas información mirar dentro
%de este mismo programa).
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Cadenas3 --> CreaCombianaciones --> Alg_Comprueba_Comb_válidas --> Escribe
%                      |                                  |                                           |
%                      ---> filtrar_eeg                   ---> filtrado                               ---> dibuja_cambio_predicción
%
% Vea tambien: pulsar
%
%
% Juan Antonio Lara Domínguez- Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
% Modificado: Francisco Velasco, Octubre 2008
%--------------------------------------------------------------------------------------------------------------
%

global duration tam nump; %Las propias de este Ensayo.m

%En realidad solo necesito las siguientes vbles del panel, pero como tb grabo aqui, pues las necesito todas:

global Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba;
%--------------------------------------------------------
global trigger long_minima long_max t_bloq %NV
global pausa bloques_pausa empiezo selec x y

global separaxx2
global laprimera

global ajustavelocidad

global bool1 bool2
global umbraldet t_bloq2 contador_reseteo

%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
umbraldet = 0.55;   %UMBRAL DE DETENCION DE LA BARRA!!!!!!!!!!!!!!!!!!!!!
t_bloq2 = 0;        %CONTADOR DE RESETEO DEL "TIEMPO DE SELECCION"   
contador_reseteo = 1; % INDICAR EL VALOR EN SEGUNDOS
contador_reseteo = round(contador_reseteo/0.031);
%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


x=0;
y=0;
selec=0;
t_bloq=0;       %/ tam bloques que debe estar en la casilla para ser seleccionada
long_minima=0.35;        %/ long minima de la flecha
long_max=0.95;          %/ long máxima de la flecha

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

separaxx2=0.025;

laprimera=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ajustavelocidad=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%ESTADISTICAS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cont_estadisticas3=0;
numvueltas=0;
estad3=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bool1=0;
bool2=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%NVNV-------------------------------------------------------------------- NUEVOS PARAMETROS:
%NV ESTOS PARAMETROS LOS UTILIZO PARA CONTROLAR LOS TIEMPOS A TRAVES DE LOS
%BLOQUES QUE VOY PROCESANDO Y NO CON EL TIEMPO DEL PROCESADOR QUE PUEDE VARIAR.

bloq_seg=Fs/tam_ventana;
bloque_analisis=t_analisis*bloq_seg; %NV
bloque_dur_ana=d_analisis*bloq_seg;
bloque_objetivo=t_objetivo*bloq_seg; %
bloque_cursor=t_cursor*bloq_seg;
bloque_beep=2*bloq_seg;  %NV ES EL BEEP DEL PARADIGMA DE GRAZ A LOS DOS SEGUNDOS
%bloque_fin_CUE=4.2*bloq_seg; %esto  es para Fs=130 y tam =26 o 13
bloque_fin_CUE=4.25*bloq_seg; %esto  es para Fs=128 y tam =4 
%bloque_fin_CUE=3.25*bloq_seg; %esto  es cuando la flecha aparece con el beep

%-------------------------------------------------------------------------PARAMETROS:
duration=d_prueba;      % Lo introduzcon en "Panel"
tam= tam_ventana;       % Lo introduzcon en "Panel" (standar= vent. de 100msg(13muestras)
nump= 4*Fs;             % Nº de puntos que se piden al metodo de estimacion espectral; Hay que tener cuidado con esto
%                       ya que los algoritmos calculan 'nump' puntos, pero al pedir nosotros los resultados 'onesided'
%                       (unilaterales-solo frecuencias positivas y el 0) solo se nos devuelven 'nump/2+1' puntos.
bloques_pausa=round(pausa/(tam/Fs));     %/     4 / (4/128) =128; el round es para aproximar al entero más cercano
empiezo=1;               %/ variable para hacer un pause nada más empezar

%--------------------------------------------------------Inicializacion de variables:


 %----------------------------------------------------------------Cuerpo del Programa:

trigger=0;      %NV GRAZ: SIRVE PARA CREAR UNA TRAZA DE TRIGGER

filtrar_eeg2;    %/ preparo el filtro y las variables A y B para el filtrado en "tiempo2frec"

Medir2;  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    Llamo a la funcion de adquisicion 

%----------------------------------------------------------------------------------------
close all;
clear all;

%Panel; %%//Al terminar 'Ensayo.m' volvemos a llamar al panel para que limpie todo y empiece de nuevo
                    

