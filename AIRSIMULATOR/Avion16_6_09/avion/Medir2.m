%
%  Programa: Medir2 (function Medir2) 
%
%Inicializa la tarjeta, llama a Prueba.m, y se queda esperando a que pulse una tecla ("pulsar") para parar el programa
%Cuando pulso, borra el identificador de la tarjeta, y devuelve el control al programa que lo llamó(Present).
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> aver --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Cadenas3 --> CreaCombianaciones --> Alg_Comprueba_Comb_válidas --> Escribe
%                      |                                  |                                           |
%                      ---> filtrar_eeg                   ---> filtrado                               ---> dibuja_cambio_predicción
%
% Vea tambien: pulsar
%
%
% Juan Antonio Lara Domínguez - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------


function Medir2 
global Fs duration tam closingTime succesNo;     

% Estadísticos
global num_vueltas t_total t_bloque num_eleccx t_invocaxRed t_invocaxGreen sujeto sesion t_pause tiempo_en_bloq path numColisiones
global commandTime commandTimeTot selectedOption commands explore ordenCom chair_rotation; 
%1- VOY A INICIALIZAR LAS VARIABLES DE LA TARJETA

  A1=analoginput('nidaq','Dev1');       %=Muestrear con la tarjeta de National Instruments 
  %A1=analoginput('nidaq','Dev2');
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
  
   set(A1,'SamplesAcquiredFcn',{'Prueba2',tam});   
   %%%%%NVset(A1,'SamplesAcquiredAction',{'Prueba',tam});             %Debo pasarle el "canal", 
                                    %la "Accion" que se va a llevar a cabo, que en este caso son cada bloque
                                    %de 'tam' muestras, y finalmente la "funcion a ejecutar" con sus parametros.
        
   set(gcf,'doublebuffer','on')    %Sirve para hacer animaciones sencillas libres del efecto pestañeo(flash):
                                    % Se construye el dibujo primero en una pantalla invisible, y luego se lanza 
                                    %a la figura indicada --> Debe usarse con la propiedad 'Erasemode'
                                    %='normal'. --> set(fig_handler,'Doublebuffer','on'); 
  

%2- EMPIEZA A MUESTREAR

   tic;                 %Inicializo el reloj  
   start(A1);               %Lanzamos a la tarjeta la orden de muestrear y...    
   timeControl();
   while closingTime == 0;      %/ Este bucle es solamente para q se quede parado hasta q pulse una tecla
       pause(0.03);
   end,
   tiempo_adquisicion=toc;  %Calculamos el tiempo real que hemos tardado, q nos gustaria
   %                        que fuese lo mas parecido posible a 'duration'.

   stop(A1);
   delete(A1); %Es la forma aconsejada de borrar un identificador de tjeta de datos.
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%ESTADISTICAS
   
  
   % hacemos la media por cada comando (independientemente de si fue un acierto o no)
   totalEleccx = num_eleccx(1) + num_eleccx(2) + num_eleccx(3) + num_eleccx(4);
   t_invocax = t_invocaxGreen + t_invocaxRed;
   t_invocaxMedia = sum(t_invocax) / totalEleccx;
   t_totalMedia = ( t_total(1) + t_total(2) + t_total(3) + t_total(4) ) / totalEleccx;      
   t_bloqueMedia = ( t_bloque(1) + t_bloque(2) + t_bloque(3) + t_bloque(4) ) / totalEleccx;
   
   t_bloque(1) = t_bloque(1) / num_eleccx(1);
   t_bloque(2) = t_bloque(2) / num_eleccx(2);
   t_bloque(3) = t_bloque(3) / num_eleccx(3);
   t_bloque(4) = t_bloque(4) / num_eleccx(4);
   
   t_total(1) = t_total(1) / num_eleccx(1);
   t_total(2) = t_total(2) / num_eleccx(2);
   t_total(3) = t_total(3) / num_eleccx(3); 
   t_total(4) = t_total(4) / num_eleccx(4); 
    
   t_bloque_acierto_media = 0;
   t_total_acierto_media = 0;
  
   succes = [0 0 0 0];
   t_bloque_acierto = [0 0 0 0];
   t_total_acierto = [0 0 0 0];
   if(explore == 1)% Modo Evaluación
       % Se hacen las estadísticas de los comandos acertados
       cadena = ['Comandos correctos: ' num2str(succesNo) '/' num2str(totalEleccx)];
       disp(cadena);      
       commandsNo = length(commands);
       for i=1:commandsNo       
           if(commands(i) == selectedOption(i))
               option = commands(i);
              succes(option) = succes(option) + 1;
              t_bloque_acierto(option) = t_bloque_acierto(option) + commandTime(i);
              t_total_acierto(option) = t_total_acierto(option) + commandTimeTot(i);
           end
       end
       t_bloque_acierto_media = sum(t_bloque_acierto) / sum(succesNo);
       t_total_acierto_media = sum(t_total_acierto) / sum(succesNo);
       t_bloque_acierto = t_bloque_acierto ./ succes;
       t_total_acierto = t_total_acierto ./ succes;
   end   
%    commands
%    selectedOption
%    commandTime
%    commandTimeTot
%    t_invocaxGreen
%    t_invocaxRed
   
   resultMatrix = [commands; selectedOption; commandTime; commandTimeTot; t_invocaxGreen; t_invocaxRed];
   comando1 = ['save ' 'ESTADISTICAS' '\estadisticos_' sujeto '_' num2str(sesion) '.mat num_vueltas t_total ' ...
       't_bloque num_eleccx t_totalMedia t_bloqueMedia tiempo_adquisicion t_invocax t_pause tiempo_en_bloq commands ' ...
       'commandTime commandTimeTot selectedOption succesNo t_bloque_acierto t_total_acierto succes resultMatrix ' ...
       't_bloque_acierto_media t_total_acierto_media t_invocaxMedia t_invocaxGreen t_invocaxRed path numColisiones ordenCom chair_rotation'];
   eval(comando1);         
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



