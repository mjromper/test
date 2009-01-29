%
%  Programa: TIEMPO2FREC (function tiempo2frec)   
%
%Es el encargado de filtrar la señal y realizar su análisis en frecuencia(pero no
%interpretarlo, eso se deja a Desp_barra)
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: filter, desp_barra
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------

% m1, m2: son las muestras de los canales 1 a 2 en el dominio del tiempo.
% ini: como los datos se van pasando poco a poco, 'ini' indica la posicion
%      inicial de donde se ha almacenado el bloque de muestras tomadas(en 
%      el programa respf2.m 'ini' es 'inicial');
%
%----------------------------------------------------------------COMENTARIO
%Cuando llamo a esta funcion, se estima la respuesta en frecuencia de las
%muestras anteriores. La funcion es llamada por Prueba.m cada 'tam' muestras,
%osea cada tam/Fs segundos. 
%Wolpaw propone en su articulo "EEG-Based Communication and Control: Short-Term
%Role of Feedback", usar los siguientes valores:
%- Llamar a esta funcion cada 100ms(p. ej. cada tam=13 muestras muestreando a
%  Fs=130Hz).
%- En vez de usar Burg, usar FFT y llamar cada 0'5 segundos
%---------------------------------------------------------------------------

function tiempo2frec(m1,m2,ini)

global tam nump t_analisis d_analisis   % Variables definidas en Ensayo.m
global Fs solape                        % Se graban en los rfb.mat
global indice_dist                      % Para almacenar la variable dist DE desp_barra
global empiezo                          % variable para hacer un pause nada más empezar
global bloques_pausa espera fig_rueda_aux     %/ tiempo de pausa para ver la rueda
global A B                              % vble de filtrado
global vector_pot1 color_bar 

persistent cont_filt                    %NV VARIABLES PARA EL PLOT DE LAS TRAZAS FILTRADAS
persistent indice tiniburg indicetotalb
persistent ini_anterior P1_anterior P2_anterior    %NV


if isempty(indicetotalb),
   indicetotalb=0;          %Uso esta variable como indice para almacenar los espectros de potencia   
end                         %de todas las ventanas de toda la sesion en una variable "finaltotal1 finaltotal2"
if isempty(indice),
   indice=0;                %'indice' cuenta el nº de bloques que se capturan, por tanto llega
                            %hasta 40 en este caso(en 4s, bloques de 100ms)%%//(180 bloques, 5.6 s, cada bloque 31 ms)
   ini_anterior=t_analisis*Fs; %NV
   P1_anterior=0;           %NV
   P2_anterior=0;           %NV
end
if isempty(tiniburg),
   tiniburg=0;              %"tiniburg" almacena el instante en que se empiezan a procesar los datos
end
if isempty(espera),
   espera=0;                %"espera" almacena los bloques que lleva la pausa
end


%1- Preparación de Variables y Parámetros:
tiniburg(indice+1)=toc;      %instante de tiempo en que empiezo a procesar
   
nump2=floor(nump/2)+1;       %Es la longitud del vector devuelto por los metodos de Estim. Espectral.
tam2=solape+tam;             %Es el tamaño de la ventana
   
   %A continuacion definimos un solape adicional que tiene sentido para el filtrado:
solapef=130;      %[muestras]-Solape de filtrado
      
      %Este solape es necesario porque el filtrado tiene un transitorio, que depende 
      %entre otras cosas de: el orden(mayor orden=> mayor transitorio), de la fre-
      %cuencia(mayor frecuencia=> menor transitorio)... Todo ello se debe a la naturaleza
      %matematica del filtrado digital cuya ecuacion es bien conocida. Para evitar este
      %transitorio podiamos pasar el filtro a toda la señal, pero no queremos sobrecargar
      %el sistema con mucho procesado, por lo que nos gustaria pasarle un minimo de muestras
      %que sepamos es suficiente para que el transitorio no se note ya, de ahi este 'solapef'.
      %El procedimiento a seguir sera:
      %1º Filtramos la señal con el solapef: m1(primera_muestra-solapef:ultima_muestra)
      %2º Retiramos esas solapef primeras muestras que no interesan para el analisis en
      %  frecuencia de la ventana que queriamos.
      %3º Se analiza en frecuencia.
   %
   %Calculamos la primera y ultima muestra que delimitan nuestra ventana. Se supone que el analisis
   %se llama siempre cuando hay suficiente nº de muestras. Aqui no se tiene en cuenta el 'solapef',
   %(En total la ventana tiene 'solape+tam' muestras):

if 60>=ini,    %Al principio ini es 0, así que solape seria negativo, espero a que ini sea >60 para añadir el solape
    solape=0;
else
    solape=60;
end;

primera_muestra = ini-solape;    % primera muestra de la ventana.
ultima_muestra  = ini+tam-1;     % ultima muestra de la ventana.


if solapef<primera_muestra,      %Cogemos el 'solapef' completo:
    s1=m1(primera_muestra-solapef : ultima_muestra); 
    s2=m2(primera_muestra-solapef : ultima_muestra);
else                             %Cogemos el maximo solapef posible, que equivaldria a coger desde la muestra 1:
    s1=m1(1 : ultima_muestra); 
    s2=m2(1 : ultima_muestra);
end;

%2- Filtro las muestras:----------------------------------------------------------------------

s1= filter(B,A,s1);     %Filtrado del canal 1     
s2= filter(B,A,s2);     %Filtrado del canal 2     %/ B y A son variables q vienen de filtrado

%----------------------------------------------------------------------------------------------

%2'5- Quito el 'solapef':

if solapef<=primera_muestra,    %Se pudo coger el 'solapef' completo, ahora se quita:
      s1= s1(solapef+1 : solapef+solape+tam);
      s2= s2(solapef+1 : solapef+solape+tam);
else                %Se cogio desde la muestra 1, asi que la vble. 'primera_muestra' sigue teniendo sentido:
      s1= s1(primera_muestra : ultima_muestra);
      s2= s2(primera_muestra : ultima_muestra);
end;

%----------------------------------------------------------------------------------------------

%3- Calculo la Estimacion Espectral para 'tam2=tam+solape' muestras:
      
%NV CALCULO LA POTENCIA MULTIPLICANDO AL CUADRADO CADA MUESTRA, NV LUEGO LO SUMO Y LO 
%DIVIDO POR EL NUMERO DE MUESTRAS.

P1=(sum(s1.*s1))/length(s1);
vector_pot1(ultima_muestra)=P1;         %NV VOY CREANDO UN VECTOR CON TODOS LOS VALORES DE POTENCIA CALCULADO EN CADA
                                        %NV INSTANTE ini QUE ES LA POSICION DE LA PRIMERA MUESTRA DE VENTANA 
                                        %LA QUE SE VA DESPLAZANDO.
P2=(sum(s2.*s2))/length(s2);
vector_pot2(ultima_muestra)=P2;
      
   %El tamaño de estos vectores es de nump/2+1, porque las señales pasadas son reales   
   %Paso los vectores a formato fila:
P1y=P1(:)';
P2y=P2(:)';

f=0:Fs/nump:Fs/2;
    
   %En finaltotal almaceno todas las respuestas en frec de toda la sesion
inicialtotal=indicetotalb*nump2+1;
 
   
       %Hay que tener en cuenta dos cosas:
       %(1) 'tiempo2frec' se llama solo en el intervalo (t_analisis+tambloque/Fs,t_analisis+d_analisis+retardo)
       %    donde el 'retardo=(tambloque/Fs)/2' se añade para que le de tiempo a coger la última ventana.
       %    [Ver si se quiere Prueba.m]
       %(2) 'tiempo2frec' es el que llama a 'Desp_barra', asi que 'Desp_barra' no podrá ejecutarse
       %    si previamente no ha sido llamado 'tiempo2frec'.
       %Podemos encontrarnos dos situaciones:
       %(A) (t_analisis > t_cursor)--> Esta situacion, era considerada en principio la 
       %    única posibilidad.
       %(B) (t_cursor > t_analisis)--> En este caso se comenzara el análisis de la señal
       %    antes incluso de que aparezca el cursor, pero claro no se podrá intentar mover 
       %    el cursor hasta que este no haya aparecido.
       %Asi que el 'if' correcto que cubriria los dos casos(A y B), y teniendo en cuenta (1) y (2), seria:
                            
       
if empiezo>0,                           %/ hace una pausa cuando sale la rueda 
    color_bar=[1 0 0];                  % cuando selecciono cambio el color de la flecha
    if (espera==1) & (empiezo==1);,     % inicio de la aplicación
        desp_barra(P1,P2);              %/ llamo a "desp_barra" para q pinte la primera traza y luego hace la pausa
        espera=espera+1;
    elseif espera==bloques_pausa,       %/ bloques_pausa la defino en el panel, es el tiempo de pausa antes de iniar el giro
        if empiezo==3;                  % Ajusto las variables para ejecutar la función siguiente, dependiendo en que
            close(fig_rueda_aux);       % parte del programa esté
            espera=1;
            empiezo=1;
        else
            empiezo=0;
            espera=0;
        end,
    else                                % aumento la variable que hace la pausa al inicio de la aplicación
        espera=espera+1;
    end,
else,                                   %/ desplaza normal
    color_bar=[0 0 1];                  % mientras está girando, la flecha está de color azul, si selecciono la cambio a rojo
    indice_dist=indice;                 % indice_dist está en desp_barra (%%//ahora como comentario)
    desp_barra(P1,P2)
end;
  

%En tiempoBURG indico el tiempo que se ha tardado en calcular la FFT de cada ventana.
tiempoBURG(indice+1)=toc-tiniburg(indice+1);
indice=indice+1;
indicetotalb=indicetotalb+1;

num_bloques_prueba=d_analisis* Fs/tam;
if indice==num_bloques_prueba;  %Son 40 bloques los que voy a obtener(4 segundos a 0.1s cada bloque)
     indice=0;
     ini_anterior=t_analisis*Fs; %NV
     P1_anterior=0;%NV
     P2_anterior=0;%NV
     cont_filt=0;%%NV
end

%-------------------------------------------------------------------------------------------
%NOTA AL FINAL:
%Cuidado con Burg:
%pburg(señal,orden,n_puntos)*pi = pburg(señal,orden,n_puntos,Fs,'onesided')*Fs/2;
%ES NECESARIO MULTIPLICAR por esos factores para que el resultado sea correcto
%La comprobacion se ha hecho con un seno sin ruido, y asi se obtiene lo mismo que 
%con pwelch, que es el metodo de referencia que propone Matlab.
%ANTIGUAMENTE USABAMOS: pburg(señal,orden,n_puntos), y NO SE MULTIPLICABA POR pi
%ASI QUE SI SE QUIERE ADAPTAR LO MEDIDO AHORA A LO QUE SE MEDIA ANTES, SOLO HAY QUE
%DESPEJAR EN LA ECUACION ANTERIOR: ANTES*pi=AHORA*Fs/2 => ANTES=(AHORA*Fs/2)/pi
%Con PMCOV pasa lo mismo, pero no se puede comprobar con una sinusoide sin ruido
%ya que el metodo se vuelve inestable.





