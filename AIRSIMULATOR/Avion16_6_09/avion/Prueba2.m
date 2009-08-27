%
%  Programa: Prueba (function Prueba)

%Junto a Medir y tiempo2frec forma el coraz�n de la Herramienta. Es el encargado de 
%hacer aparecer el cursor y el objetivo en el momento adecuado, recoge las muestras 
%de la tarjeta y las manda analizar(tiempo2frec) e interpretar (Des_barra). Como 
%Des_barra desplaza el cursor en funci�n de lo que interprete en el an�lisis en 
%frecuencia, al programa Prueba le resulta muy f�cil averiguar si el cursor ha 
%alcanzado al objetivo. En tal caso PARA la adquisici�n de muestras, y completa con 
%ceros el resto de los vectores de muestras hasta completar la longitud que debieran
%tener en funci�n de la duraci�n con que se defini� la prueba. 
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> aver --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Cadenas3 --> CreaCombianaciones --> Alg_Comprueba_Comb_v�lidas --> Escribe
%                      |                                  |                                           |
%                      ---> filtrar_eeg                   ---> filtrado                               ---> dibuja_cambio_predicci�n
%
% Vea tambien: pulsar
%
%
% Juan Antonio Lara Dom�nguez - Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga - 2007
%--------------------------------------------------------------------------------------------------------------
%
%Llamada por Medir.m con la linea "set(A1,'SamplesAcquiredFcn',{'Prueba',tam});",
%asi que supongo que los campos obj y event los rellena Matlab.
%
%Como vemos este programa se llama cada vez que Medir.m coge 'tam' muestras. Como ese
%numero de muestras equivale a un intervalo de tiempo(en funcion de la frecuencia de
%muestreo, este programa debe llevar la cuenta del tiempo dentro de cada prueba(duraba
%d_prueba sg), pues sabemos que seg�n el intervalo de tiempo se hac�a una cosa u otra.
%Finalmente graba las variables muestra1..muestra4, y tiempo en un fichero.



function Prueba2(obj, event, tambloque)
%'obj' y 'event' son parametros que rellena Matlab, pues 
%esta funcion se usa como 'SamplesAcquiredAction' de la 
%tarjeta. El programa que define dicha funcion es el Medir.m
%
%'tambloque' es el 'tam' con que se llama la funcion
%que se ha dicho antes: 'SamplesAcquiredAction'

global tiempo1 Fs 
global trigger      %PARA CONTROLAR EL NUMERO DE VECES QUE SALE CADA FLECHA.
global t            %%%%%NV   
%Las variables 'persistent' son locales dentro de la funcion que las declara pero, 
%su valor se conserva entre llamada y llamada que se haga a esa funcion:
global n_de_bloque
global n_tot_bloq_por_prueba; %% // esta vble es para q deje de muestrear cuando alcance el objetivo
persistent tiempo muestra1 muestra2 trig trigtot
persistent tiempototal muestratotal1 muestratotal2 n_de_bloque_tot
persistent tiempofinal inst_muestra tcapmuestra 
persistent bloques_tiempo  %NV PARA VARIAR EL EJE DE TIEMPO

%NV ESTOS PARAMETROS LOS CREO EN ENSAYO Y SON PARA CONTROLAR EL 
%INSTANTE DE TIEMPO EN EL QUE DEBO PROCESAR O CAMBIAR EL MUNDO.
global bloque_objetivo bloque_beep bloque_fin_CUE

tiempo1=toc;  %Doy un valor inicial a la variable tiempo de inicio de captura de muestra

if isempty(n_de_bloque),	%n_de_bloque = n�mero de bloque
   n_de_bloque=0;           %lleva la cuenta del n� de bloques de info �til, osea los que
end;                        %trascurren entre el 3er. y el 7� segundo.(1 bloque = 1 ventana)
if isempty(n_de_bloque_tot),%Se hace la primera vez que se llama a Prueba(una vez por ensayo)  
   n_de_bloque_tot=0;       %La uso para llevara la cuenta de todas las ventanas de un ensayo
end
if isempty(bloques_tiempo), 
    bloques_tiempo=0;
end;
if n_de_bloque==(bloque_beep)
    trigger=1;
end;
     
%1A - Cuando tiempo1 > 't_objetivo' sg dibujo la flecha en color verde-objetivo ----------------------------------
if n_de_bloque==(bloque_objetivo-1) %NVNV
    t_obj=tiempo1;
end 
if n_de_bloque==(bloque_fin_CUE)
   trigger=0;
end;

%2- Saco las muestras de la tarjeta --------------------------------------------------------------------------

inst_muestra(n_de_bloque+1)=toc; %Guarda justo el instante en que se captan las muestras(ANTIGUO PRUEBA.M)
tcapmuestra(n_de_bloque+1)=toc-tiempo1;  %Guardo la duracion de la adquisicion para cada prueba
[d,t] = getdata(obj,tambloque); %Guarda en 'd' las 'tambloque' muestras y en 't' el eje de tiempos
                              
%3- Almaceno las muestras en variables para su posterior tratamiento ------------------------------------------- 
%En muestra1, muestra2 y tiempo voy a�adiendo el bloque de tambloque muestras que me dan
%cada vez que se llama este programa.
tiempoi = toc; %Me indica el instante de tiempo en que adquiero el bloque de muestras.
					 %(Coincide con tiempo1)
inicio = n_de_bloque*tambloque + 1;  %Es la posicion de la 1� muestra a almacenar
   %CUIDADO: las vbles muestra1 y muestra2, se sobreescriben tras cada prueba, no 
   %         se inicializan nunca(son 'persistent'), a menos que quieras hacerlo
   %         en algun sitio usando un clear.
muestra1(inicio : inicio + tambloque-1)= d(:,1);%*500; %muestra1 es el canal 1
muestra2(inicio : inicio + tambloque-1)= d(:,2);%*200; %muestra2 es el canal 2
tiempo(inicio : inicio + tambloque-1)= t;

    %NV GRAZ: CREO UNA TRAZA DEL TRIGGER
if trigger==0
    trig(inicio : inicio + tambloque-1)=0;
else
    trig(inicio : inicio + tambloque-1)=1;
end
    
%En muestratotal almaceno tobas las muestras de todo el ensayo(Un ensayo esta formado en
%general por 20 pruebas que se hacen seguidas
inicio_ensayo = n_de_bloque_tot * tambloque + 1;
muestratotal1(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,1);%*500; %muestra1 es el canal 1
muestratotal2(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,2);%*200; %muestra2 es el canal 2
tiempototal(inicio_ensayo : inicio_ensayo + tambloque-1)=t;
   


%NV GRAZ: CREO UNA TRAZA DEL TRIGGER TOTAL
if trigger==0
    trigtot(inicio_ensayo : inicio_ensayo + tambloque-1)=0;
else
    trigtot(inicio_ensayo : inicio_ensayo + tambloque-1)=1;
end
    
%Una vez captado un bloque, incremento el indice para el siguiente bloque:
n_de_bloque = n_de_bloque + 1;          %Cuidado con cambiarlo de sitio, pues afecta a la grabacion en 'tiempo2frec.m'
n_de_bloque_tot = n_de_bloque_tot+1; 
   
%4-Hago el analisis en frecuencia---------------------------------------------------------------------------------------

%Ahora llamo a la funcion tiempo2frec, que va a calcular la FFT. Le paso las muestras y 
%la posicion inicial de donde acabo de almacenar el bloque. Hasta aqui, y desde que inicialice 
%la variable tiempo1, este instante de tiempo es practicamente nulo.

retardo= (tambloque/Fs)/2;      %(La duracion de media ventana)Si no, no analiza la ultima ventana en:

tiempo2frec2(muestra1,muestra2,inicio);  %------------------------------------------------------- PROCESO EL CANAL UNO y DOS


tiempofinal(n_de_bloque)= toc-tiempo1;  %"tiempofinal" es el tiempo que tarda en captar un bloque de muestras

   %NV---------------------------------------------------------------------
   %NV VOY A SUPRIMIR LO DE GRABAR CADA rt.mat. REALMENTE LO QUE ME
   %INTERESA ES EL RTOTAL
if n_de_bloque == n_tot_bloq_por_prueba, %Cuando se han capturado todos los bloques de una prueba,
    n_bloque
   %Inicializo la variable n_de_bloque:
    n_de_bloque=0;
      %%%%%% /// aqui estaba toda la parte de grabacion de datos
end
   