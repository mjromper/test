%
%  Programa: Medir (function Medir) 
%
%Inicializa la tarjeta, llama a Prueba.m, y se queda esperando a que pulse una tecla ("pulsar") para parar el programa
%Cuando pulso, borra el identificador de la tarjeta, y devuelve el control al programa que lo llamó(Present).
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: prueba
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------


function Medir 

global Fs duration tam A1 acaba      
%1- VOY A INICIALIZAR LAS VARIABLES DE LA TARJETA

  
  A1=analoginput('nidaq','Dev1');       %=Muestrear con la tarjeta de National Instruments
  set(A1,'InputType','SingleEnded',...  %Para indicar donde está el bit mas significativo
      'BufferingMode','auto');          %Para que la reserva de memoria se haga automaticamente
      
  addchannel(A1,[0 1]);                 % muestreo dos canales
  
  set(A1,'SampleRate',Fs);              %Configurar la frec. de muestreo
  
  set(A1,'SamplesPerTrigger',duration*Fs);  %Numero total de muestras a adquirir.
                                            %duration=duración de una prueba definida en Ensayo.m
  set(A1,'SamplesAcquiredFcnCount',tam);
  %%%%%%NVset(A1,'SamplesAcquiredActionCount',tam);             %Por cada bloque de 'tam' muestras se
                                    %ejecuta el Trigger, que llama a la funcion "prueba"(antigua "respf2").
                                    %Ej.: tam=4 muestras(definido en sesion.m), y muestreamos
                                    %a Fs=128Hz, así que se llama a "prueba" cada 31msg. <<---------
                                 
   n_tot_bloq_por_prueba=Fs*duration/tam;  %Numero de bloques que se muestrean en cada prueba
   set(A1,'SamplesAcquiredFcn',{'Prueba',tam});
   %%%%%NVset(A1,'SamplesAcquiredAction',{'Prueba',tam});             %Debo pasarle el "canal", 
                                    %la "Accion" que se va a llevar a cabo, que en este caso son cada bloque
                                    %de 'tam' muestras, y finalmente la "funcion a ejecutar" con sus parametros.
        
   set(gcf,'doublebuffer','on')    %Sirve para hacer animaciones sencillas libres del efecto pestañeo(flash):
                                    % Se construye el dibujo primero en una pantalla invisible, y luego se lanza 
                                    %a la figura indicada --> Debe usarse con la propiedad 'Erasemode'
                                    %='normal'. --> set(fig_handler,'Doublebuffer','on'); 
  

%2- EMPIEZA A MUESTREAR

   tic;                 %Inicializo el reloj
   tiempo_inicial=toc;  %Calculo el tiempo inicial;(No puedo hacer 'tiempo_inicial=tic')
   
   start(A1);               %Lanzamos a la tarjeta la orden de muestrear y...

%---------------------------------------------------------------------------------------------

    while acaba==0;      %/ Este bucle es para q se haya una pausa hasta q pulse una tecla, 
                         %  ese evento se detecta en cualquier figura con la función pulsar y la variable acaba
       pause(0.03);      % va haciendo pequeñas pausas para captar si se ha pulsado una tecla   
    end,
    tiempo_adquisicion=toc  %Calculamos el tiempo real que hemos tardado, q nos gustaria
    %                        que fuese lo mas parecido posible a 'duration'.

    stop(A1);           % Para la tarjeta de adquisición de datos
    delete(A1);         % Es la forma aconsejada de borrar un identificador de tjeta de datos.


