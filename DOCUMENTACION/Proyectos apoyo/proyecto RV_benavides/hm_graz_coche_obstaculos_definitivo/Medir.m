%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%
%  Programa: Medir (function Medir)
%
%Inicializa la tarjeta, llama a Prueba.m, y se queda esperando a que pase el tiempo
%que dura una prueba(esto puede modificarse-ver instrucciones dentro del programa).
%Para esperar utiliza por defecto(si no se hace la modificacion) un pause(d_prueba).
%Cuando pasa el tiempo que dura la prueba, borra el objeto de entrada analogica, es
%decir el identificador de la tarjeta, y devuelve el control al programa que lo
%llam�(Present).
%
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> Present --> MEDIR --> Prueba --> tiempo2frec --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%Vea tambi�n: HMPanel, Ensayo, Present, Prueba ..., ModelarFiltros, ...

%   Francisco Benavides Mart�n, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga
%------------------------------------------------------------------------------------


function Medir; %Antiguo Prueba1.m

global Prueba_terminada; %Lo usa Prueba.m para indicarle a Medir.m que ha terminado de
%                         coger todas las muestras que tiene una prueba, y ha echo todo
%                         lo que tenia que hacer(grabar y todo).
Prueba_terminada=0;
global t_objetivo t_analisis d_analisis inc Fs duration tam ntot_pru A1;
global no_portatil fig_tiempo fig_sujeto COLOR_C1 p%NV
%NV (Paco) Variables de posicion y escalado del charco. Variables de
%posici�n del muro. Variable para la elecci�n aleatoria del obstaculo.
global posicion_charco posicion_muro posicion_rampa;
global agua bloque_dur_ana tipo_obstaculo;
persistent n_frames n_bloques_objetivo d_objetivo scale_charco valor seguir;
%NV (Paco). Variables que controlan la elecci�n del obst�culo.
global boton_Ninguno boton_Muro boton_Rampa boton_Charco;
%%%%%%%NV
%NV (Paco).
global manejador_sonido1;

%if no_portatil==0
%    close(figure(fig_tiempo))
%end;
%%%%%%%NV
inc=0;  %Esta variable la inicializo a cero. Es la que producira el incremento del
        %desplazamiento del cursor. La voy a utilizar en la funcion descursor
        
seguir=0;       
        
         %%%%%%%%%%%%%%%%%%%%%%%NV GRAZ: ANTES DE EMPEZAR, DIBUJO LA CRUZ EN EL INSTANTE INICIAL
   % figure(fig_sujeto); 
    
    
    %hold on% Mantiene ese dibujo
     
     % plot([0 0],[-17 17],'EraseMode','none','color',COLOR_C1,'LineWidth',6);
      %plot([-17 17],[0 0],'EraseMode','none','color',COLOR_C1,'LineWidth',6);
     
      
    %%%%%%%%%%%%%%%%%%%%%%%NV GRAZ: ANTES DE EMPEZAR, DIBUJO LA CRUZ EN EL INSTANTE INICIAL  

%1- VOY A INICIALIZAR LAS VARIABLES DE LA TARJETA

    %%%%%A1=analoginput('winsound');
    %%%%%addchannel(A1,[1 2]);%2 canales (estereo)
   %Fs=8000; %S�lo para la tjeta de sonido
   %Fs maxima parece ser 1000muestras/sg y canal.-->Ejecutar: A1=analoginput('nidaq',1)
   %AYUDA: daqhelp, daqpropedit.
   A1=analoginput('nidaq','Dev1'); %=Muestrear con la tjeta de National Instruments
  set(A1,'InputType','SingleEnded',...%Para indicar donde est� el bit mas significativo
      'BufferingMode','auto');%Para que la reserva de memoria se haga automaticamente
      
  addchannel(A1,[0 1 2 3 4]); %Siempre deben muestrearse los 4 canales. El motivo es que, aunque
   %                          el panel si deja elegir cualesquiera canales de entre los cuatro
   %                          posibles, la tarjeta solo permite que se a�adan canales en orden.
   %                          Es decir, no puedo pedirle que muestree solo el canal 2, sino que
   %                          para muestrear el 2, se ve obligada a muestrear el 0 y el 1 tambien.
   
   set(A1,'SampleRate',Fs); %Configurar la frec. de muestreo
  
   set(A1,'SamplesPerTrigger',duration*Fs);  %Numero total de muestras a adquirir.
   
   %duration=duraci�n de una prueba(7sg) definida en Ensayo.m
   set(A1,'SamplesAcquiredFcnCount',tam);
   %%%%%%%%NVset(A1,'SamplesAcquiredActionCount',tam);  %Por cada bloque de 'tam' muestras se
   							%ejecuta el Trigger, que llama a la funcion "prueba"(antigua "respf2").
                        %Ej.: tam=13 muestras(definido en sesion.m), y muestreamos
                        %a Fs=130Hz, as� que se llama a "prueba" cada 10msg. <<---------
                                 
   n_tot_bloq_por_prueba=Fs*duration/tam;  %Numero de bloques que se muestrean en cada prueba
   set(A1,'SamplesAcquiredFcn',{'Prueba',tam});
   %%%%%%%%%%%NVset(A1,'SamplesAcquiredAction',{'Prueba',tam});  %Debo pasarle el "canal", 
   %la "Accion" que se va a llevar a cabo, que en este caso son cada bloque
   %de 'tam' muestras, y finalmente la "funcion a ejecutar" con sus parametros.
        
	set(gcf,'doublebuffer','on')  %Sirve para hacer animaciones sencillas libres del 
   %efecto pesta�eo(flash): Se construye el dibujo primero en una pantalla invisible,
   %y luego se lanza a la figura indicada --> Debe usarse con la propiedad 'Erasemode'
   %='normal'. --> set(fig_handler,'Doublebuffer','on'); 
  
%Antes de comenzar a muestrear, se establece la ubicaci�n y dimensi�n del
%charco, para que de tiempo a rebasar el charco en el intervalo temporal
%indicado con t_analisis.

%El Charco comienza a moverse en el instante t_objetivo. Por esto, para la
%dimensionar el charco hay que tenerlo en cuenta. Con este intervalo
%temporal solo se tocar� sus dimensiones. No se emplear� para ubicar el
%charco, ya que este intervalo generalmente ser� de 1 o 2 segundos.

d_objetivo=t_analisis-t_objetivo; %Se obtiene la duraci�n del intervalo en el que el
%charco est� moviendose, pero el usuario no tiene control sobre el coche.

n_bloques_objetivo=Fs*d_objetivo/tam; %Se obtiene el n�mero de bloques.

%n_bloques_analisis= Fs*d_analisis/tam; %con esto se obtiene el n�mero de bloques que se procesan.

%Por cada bloque se desplazar� el charco 2 unidades al igual que sucede con
%las l�neas discont�nuas del suelo y los �rboles. Para el caso de 128 Hz y
%4 muestras, en otras condiciones el n�mero de bloques a procesar ser�
%menor, pero el n�mero de frames por cada bloque procesado ser� mayor.

valor=(128/4)*(tam/Fs); %Se emplea para dimensionar el charco correctamente
%Se toma como referencia el caso mejor 128 Hz y 4 muestras. 

n_frames=2*valor*bloque_dur_ana; % Para 128 Hz y 4 muestras. Valor=1.
%El n�mero de frames por bloque procesado (llamada al subprograma
%Prueba.m) es 2*valor. Cada 15mseg aproximadamente se va a ejecutar un
%frame. Cubre con creces los 20 mseg. exigidos como m�nimo.

%scale_charco=(valor*(n_bloques_objetivo+n_bloques_analisis))/64; (no vale) 
scale_charco=n_frames/64;
%64 unidades es la dimensi�n inicial del charco. 
%A partir de 64 y el n�mero de bloques se obtiene la escala.

agua.scale=[agua.scale(1:(length(agua.scale)-1)) 10*scale_charco];
% 10 es el valor de Z en el campo scale del nodo agua.
%Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
%se tienen que procesar en el intervalo de tiempo dado.

%Para el programa el tama�o del charco va a ser igual al doble del n�mero de
%bloques que se pretende analizar.
 
%posicion_charco=6+(valor*n_bloques_analisis/2)-n_frames+80;(no vale) 
posicion_charco=80-valor*bloque_dur_ana-2*valor*n_bloques_objetivo+2.5;
%Posicion del charco. El 2.5 es el momento en el que el charco est� justo a
%la altura del morro del coche.
%El 80 es porque el obstaculo en el mundo virtual inicialmente est�
%colocado en la posici�n -80, y sobre esta posici�n est� referenciado el
%desplazamiento del charco.
%n_bloque_analisis y n_bloques_objetivo, se emplea en el calculo del 
%offset necesario. Para que la posici�n del charco sea correcta.

posicion_muro=2.5-2*valor*(bloque_dur_ana+n_bloques_objetivo);
%posicion_muro=-10;
%Con esto se coloca el muro al final del charco.

posicion_rampa=2.5-2*valor*(bloque_dur_ana+n_bloques_objetivo)-4;
%El -4 se debe a que la rampa se sit�a en 0, y la pendiente es de 8, por
%tanto llega hasta la posici�n 4.
%Con esto se coloca la rampa al final del charco.

%NV (Paco). Se testean los valores del panel que selecciona los obst�culos.
%boton_Ninguno=get(push_Charco,'Value');
%boton_Muro=get(push_Rampa,'Value');
%boton_Rampa=get(push_Muro,'Value');
%boton_Charco=get(push_Charco,'Value');

%Realiza el bucle hasta que la variable tipo_obstaculo, tenga un valor que
%coincida con los permisos dados por el panel de control.
while (seguir==0)&(boton_Ninguno==0)
%Para la elecci�n aleatoria de los obstaculos. Se plantear�n 5
%posibilidades: 1.- Aparece de un charco (a izquierda o derecha). Se le va
%               a asignar el valor 0.
%               2.- Aparece de un muro. idem. Se le va a asignar el valor 1
%               3.- Aparece del muro y el charco simultaneamente, pero
%               siempre en el mismo lado de la calzada. Se le va a asignar
%               el valor 2. 
%               4.- Aparece una rampa. Se le va
%               a asignar el valor 3.
%               5.- Aparece la rampa y el charco, pero la rampa debe estar
%               en el carril contrario al charco. Se le asigna el valor 4.

    tipo_obstaculo=fix(5*rand); % Se trata de una variable que genera valores
%de forma aleatoria en el intervalo de valores enteros de 0 a 4.

    switch tipo_obstaculo,
        case 0,
            if (boton_Charco==1)&(boton_Muro==0)&(boton_Rampa==0)
                seguir=1;
            end
        case 1,
            if (boton_Muro==1)
                seguir=1;
                tipo_obstaculo=2; %Para que aparezca siempre el charco
            end
        case 2,
            if (boton_Charco==1)&(boton_Muro==1)
                seguir=1;
            end
        case 3,
            if (boton_Rampa==1)
                seguir=1;
                tipo_obstaculo=4; %Para que aparezca siempre el charco
            end
        case 4,
            if (boton_Charco==1)&(boton_Rampa==1)
                seguir=1;
            end
    end
       %Se emplea para evitar entrar en un bucle infinito.Testea si no se
       %ha pulsado ning�n bot�n, y si es as� se le asigna lo opci�n de que
       %no aparezca ning�n obst�culo.
    if (boton_Charco==0)&(boton_Muro==0)&(boton_Rampa)&(boton_Ninguno==0)
        boton_Ninguno=1
    end
end
%2- EMPIEZA A MUESTREAR

   
      
    
    
   tic;                 %Inicializo el reloj
   tiempo_inicial=toc;  %Calculo el tiempo inicial;(No puedo hacer 'tiempo_inicial=tic')
   play(manejador_sonido1); %Inicia el sonido del motor porque comienza la
   %prueba.
   start(A1);           %Lanzamos a la tarjeta la orden de muestrear y...
   pause(duration+tam/Fs+0.4);
   %while strcmp(A1.running,'on'),
      %Solucion de Matlab para saber cuando ha acabado la recogida de datos.
      %Da fallos porque parece que a veces se para un poquito la tarjeta.
   %end; 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%MODIFICACION:
   %Cuando se alcanza el objetivo, el programa se da cuenta en 'Prueba.m', y completa
   %con ceros lo que queda sin rellenar de los vectores muestra1 a muestra4. Llegados
   %aqui, existen dos opciones: (1) esperar el tiempo normal que hubiera durado la
   %prueba, aunque ya no se mida mas, o (2) simplemente parar esa prueba.
   %Por defecto, se elige la opcion (1), pero si quiere cambiarse a la (2), hay que 
   %hacer la siguiente modificacion:
   %  Sustituirse el 'pause(duration)' de mas arriba por el codigo de mas abajo.
   %  Este pause(duration) de mas arriba, dejaba al programa trabajar mientras Matlab
   %  hacia un pause de duracion la de la prueba. El while de abajo, idealmente haria
   %  pauses del tama�o de una ventana, asi tras cada ventana, se comprobaria si el 
   %  programa habia terminado ya o no. El problema es que estos pauses entretienen
   %  mucho la ejecucion, ENLENTECIENDO EL FUNCIONAMIENTO, asi que en vez de hacer un
   %  pause(tam/Fs), se hace uno fijo de un segundo, es decir, pause(1). De este modo, 
   %  una vez alcanzdo el objetivo, como maximo pasara un segundo antes de que se pare 
   %  la ejecucion del programa. 
   %pause(t_analisis); %Durante este tiempo no se hace analisis nunca.
   %while Prueba_terminada==0,%Prueba_terminada depende del programa Prueba.m
   %   pause(1);
   %end;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%FIN DE LA MODIFICACION
   
   tiempo_adquisicion=toc  %Calculamos el tiempo real que hemos tardado, q nos gustaria
   %                        que fuese lo mas parecido posible a 'duration'.
   delete(A1); %Es la forma aconsejada de borrar un identificador de tjeta de datos. Lo
   %           borramos tras cada prueba para liberar memoria, pues de todas formas, al
   %           volverse a llamar a este programa, se vuelve a definir. Si se quita de 
   %           aqui, habra que ponerlo en Ensayo, mas que nada para evitar cosas raras 
   %           en Matlab.


