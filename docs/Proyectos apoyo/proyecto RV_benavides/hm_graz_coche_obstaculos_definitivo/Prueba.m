%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%
%  Programa: Prueba (function Prueba)
%
%Junto a Medir y tiempo2frec forma el coraz�n de la Herramienta. Es el encargado de 
%hacer aparecer el cursor y el objetivo en el momento adecuado, recoge las muestras 
%de la tarjeta y las manda analizar(tiempo2frec) e interpretar (Descursor). Como 
%Descursor desplaza el cursor en funci�n de lo que interprete en el an�lisis en 
%frecuencia, al programa Prueba le resulta muy f�cil averiguar si el cursor ha 
%alcanzado al objetivo. En tal caso PARA la adquisici�n de muestras, y completa con 
%ceros el resto de los vectores de muestras hasta completar la longitud que debieran
%tener en funci�n de la duraci�n con que se defini� la prueba. Adem�s graba todas las
%muestras, utilizando un fichero 'rti.mat' por prueba, donde la 'i' representa el 
%n�mero de orden de la prueba en curso, y tambi�n graba los filtros que se han 
%dise�ado para el ensayo en ficheros 'filtro_chk.mat' donde la 'k' representa el 
%n�mero de orden del canal al que corresponde el filtro. (Mas info dentro del mismo
%programa).
%
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> Present --> Medir --> PRUEBA --> tiempo2frec --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%Vea tambi�n: HMPanel, Ensayo, Present, Medir ..., ModelarFiltros, ...

%   Francisco Benavides Mart�n, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnolog�a Electr�nica - Universidad de M�laga
%------------------------------------------------------------------------------------

%Funcion prueba(obj, event, tambloque)
%
%Llamada por Medir.m con la linea "set(A1,'SamplesAcquiredAction',{'respf2',tam});",
%asi que supongo que los campos obj y event los rellena Matlab.
%
%Como vemos este programa se llama cada vez que Medir.m coge 'tam' muestras. Como ese
%numero de muestras equivale a un intervalo de tiempo(en funcion de la frecuencia de
%muestreo, este programa debe llevar la cuenta del tiempo dentro de cada prueba(duraba
%d_prueba sg), pues sabemos que seg�n el intervalo de tiempo se hac�a una cosa u otra.
%Finalmente graba las variables muestra1..muestra4, y tiempo en un fichero.



function prueba(obj, event, tambloque)
%'obj' y 'event' son parametros que rellena Matlab, pues 
%esta funcion se usa como 'SamplesAcquiredAction' de la 
%tarjeta. El programa que define dicha funcion es el Medir.m
%
%'tambloque' es el 'tam' con que se llama la funcion
%que se ha dicho antes: 'SamplesAcquiredAction'


global num_canales_procesar %NV ESTA VARIABLE LA DECLARO EN HM_PANEL Y DETERMINA EL NUMERO DE
                            %CANALES QUE VOY A PROCESAR (EMPEZANDO SIEMPRE DESDE EL PRIMER CANAL)

global A1; %Es el identificador del objeto tarjeta de adquisicion de datos.
global Prueba_terminada; %Lo usa Prueba.m para indicarle a Medir.m que ha terminado de
%                         coger todas las muestras que tiene una prueba, y ha echo todo
%                         lo que tenia que hacer(grabar y todo).
global fig_sujeto fig_tiempo;
%NV (Paco) Varibles correspondientes al mundo virtual. Corresponden a los
%objetos animados manualmente.
global linea arbol obstaculocharco charco charco1;
global obstaculomuro muro muro1;
global obstaculorampa rampa rampa1;
global pruebactual p q objet tiempo1 per1 per2 fallo exito;%Original
global trayectoria grabar_c1 grabar_c2 grabar_c3 grabar_c4 grabar_c5 c1 c2 c3 c4 c5 Fs duration ntot_pru ver_t; %NV grabar_c5
global sujeto ensayo Fs tipologia t_cursor t_objetivo t_analisis d_analisis d_prueba d_descanso; %Se graban en los rti.mat
global COLOR_C1 COLOR_C2 COLOR_C3 COLOR_C4 COLOR_C5; %NV COLOR_C5
global Nums Dens;
global color_dibujos color_fondo; %Son los colores de la pantalla del sujeto bajo experimento

global perm_plot_c1 perm_plot_c2 perm_plot_c3 perm_plot_c4 perm_plot_c5 %NV PARA HACER UN PLOT DE LOS CANALES GRABADOS
global no_portatil %NV ES PARA CANCELAR POR COMPLETO fig_tiempo
global izq der trigger%PARA CONTROLAR EL NUMERO DE VECES QUE SALE CADA FLECHA.
global bloques_proc_eje_tiempo aquisic_normal %NV PARA CAMBIO DE EJE TEMPORAL

global dist_barra wo w1 w2

%NV (Paco). HE CREADO DOS VARIABLES DE CONTROL PARA OBSERVAR LOS TIEMPOS DE
%ACCESO Y ACTUALIZACI�N EN ESTE SUBPROGRAMA.
global tiempollamada tiempoactualizacion tipologia boton_Ninguno tipo_prueba;

    % 'pruebactual' indica el numero de la prueba actual;
 global t %%%%%NV   
%Las variables 'persistent' son locales dentro de la funcion que las declara pero, 
%su valor se conserva entre llamada y llamada que se haga a esa funcion:
%NV (Paco) Variables encargadas del movimiento del mundo virtual. Colision
%es la encargada de parar el movimiento del mundo cuando el coche colisiona
%con el muro. tipo_obstaculo es la encargada de la elecci�n del obstaculo
%para la prueba que se est� desarrollando. Salto es la variable que
%controla el salto de la rampa. Se activa cuando el coche se encuentra
%dentro de los umbrales de salto en el eje X.
global i posicion_charco posicion_muro posicion_rampa; 
global n_de_bloque colision salto tipo_obstaculo coche coche_roto;
persistent j x angulo alzamiento modoejecucion controlejecucion;%NV (Paco) Variables relativas al salto del coche.
persistent tiempo muestra3 muestra4 muestra5 trig trigtot z%NV muestra5
persistent tiempototal muestratotal3 muestratotal4 muestratotal5 n_de_bloque_tot %NV MUESTRATOTAL5
persistent tiempofinal posicion inst_muestra tcapmuestra %('posicion' tambien se usa en hm_panel para otra cosa, pero no parece haber problema)
%persistent tiempofinal posicion inst_muestra tiempototaln  
persistent ti d1 d2 d3 d4 d5%NV %NV ESTO LO INTRODUZCO PORQUE EL PLOT LO HACIA MAL. 
%CADA VEZ QUE DIBUJABA UNA TRAZA NO CONECTABA CON LA ANTERIOR. UTILIZO ESTAV VARIABLES PARA ESO.  
%CADA PAR DE VARIABLES ES PARA CADA CANAL
global muestratotal1 muestratotal2 muestra1 muestra2;

persistent bloques_tiempo %NV PARA VARIAR EL EJE DE TIEMPO

%NV ESTOS PARAMETROS LOS CREO EN ENSAYO Y SON PARA CONTROLAR EL 
%INSTANTE DE TIEMPO EN EL QUE DEBO PROCESAR O CAMBIAR EL MUNDO.
global bloque_analisis bloque_dur_ana bloque_objetivo bloque_cursor bloque_beep bloque_fin_CUE

    %El vector 'posicion' guarda si el rectangulo se ha cargado arriba(1) o abajo(2)
    %'n_de_bloque' era el antiguo 'index'. 'inst_muestra' no esta en el respf2.m orginal(actual prueba.m)
%A esta funcion se llega tras haber adquirido el primer bloque, osea, si el tama�o
%del bloque es de 10msg p.ej., tiempo1 valdra ya 10msg.
tiempo1=toc;  %Doy un valor inicial a la variable tiempo de inicio de captura de muestra

if isempty(n_de_bloque),	%n_de_bloque = n�mero de bloque
   n_de_bloque=0; %lleva la cuenta del n� de bloques de info �til, osea los que
   	i=0;				%trascurren entre el 3er. y el 7� segundo.(1 bloque = 1 ventana)
    colision=0; %Se inicializa la varible.
    salto=0;
    j=1; %Se inicia la variable de control del movimiento del coche saltando.
end;
if isempty(n_de_bloque_tot),%Se hace la primera vez que se llama a Prueba(una vez por ensayo)  
   n_de_bloque_tot=0;  %La uso para llevara la cuenta de todas las ventanas de un ensayo
   tipo_prueba=zeros(1,ntot_pru);
   tiempofinal=zeros(1,ntot_pru);
   z=zeros(2,ntot_pru);
end

if isempty(bloques_tiempo),  %NV ESTA VARIABLE ES PARA CUANDO aquisic_normal ESTA DESACTIVA
    bloques_tiempo=0;
end

%NV (Paco) Inicializo la variable j encargada del movimiento de los
%obstaculos. Se inicializa en la primera llamada a Prueba.
%if (obstaculoder.whichChoice==-1)&(obstaculoizq.whichChoice==-1)
 %   j=0;
%end

%NV (Paco) Variable array que sirve para comprobar si la frecuencia de las
%llamadas a prueba por parte de la tarjeta de adquisicion sufre retrasos.
%Ya que si se produjesen el programa se retardar�a y se ejecutaria mal.
tiempollamada(n_de_bloque+1)=tiempo1;
 
%Se ejecuta en este punto hasta que comience el analisis. La ejecuci�n
%difiere entre el modo de ejecuci�n 6 (jugar, feedback continuo), con
%respecto al resto de modos de ejecuci�n (1 al 5).
%Cuando se est� en feedback continuo, en el intervalo de an�lisis el mundo
%se actualiza en desp_barra. En cambio, en el resto de los modos como solo
%se mueven los �rboles y las l�neas del suelo, se actualiza todo aqu�.
modoejecucion=str2num(tipologia(pruebactual));
switch modoejecucion; %Sirve para tener una variable de control en el modo
    case {1,2,3,4,5}  %de ejecuci�n
        controlejecucion=0;
    case 6
        controlejecucion=1;
end
if ((n_de_bloque<=bloque_analisis)|(n_de_bloque>(bloque_analisis+bloque_dur_ana)))&(colision==0)&...
        (controlejecucion==1)|(controlejecucion==0)
%NV (Paco)En el portatil HP tengo 128 Hz 16 muestras porque es el unico caso en
    %el que el programa procesa todos los bloques de informacion por este
    %motivo finalmente programa se simulara en un ordemar de mejores
    %caracteristicas, en concreto mejor tarjeta grafica.
 for n_frames=1:2 %se realizan dos frames para que se vea la imagen de forma continua en el caso de 128 Hz y 4 muestras
    %Producen la sensacion de desplazamiento hacia delante, realizando el
    %movimiento de las lineas discontinuas del suelo y de los arboles.
     if (mod(i,20)~=0)
         %Realmente solo se realiza el movimiento de dos objeto en el mundo
         %virtual linea y arbol, ya que el resto de lineas y arboles son
         %usos (USE) de los anteriores.
        linea.translation=[linea.translation(1:(length(linea.translation)-1)) mod(i,20)];
        arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) mod(i,20)];
     else
       linea.translation=[linea.translation(1:(length(linea.translation)-1)) 20];
       arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) 20];
     end
    % Se encarga de mover los obst�culos desde qie aparece hasta que comienza la
    % fase de an�lisis, a partir de aqui se actualizar� en desp_barra. Y al
    % finalizar desp_barra se encargar� de nuevo de la actualizaci�n de los
    % obst�culos.
     if (n_de_bloque>=bloque_objetivo+1)&(controlejecucion==1)&(boton_Ninguno==0)
        %Mueve el charco derecho.
        if (obstaculocharco.whichChoice==0)
            posicion_charco=posicion_charco+1; %Para que el charco desaparezca
            charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
        end
        %Mueve el charco izquierdo.
        if (obstaculocharco.whichChoice==1)
            posicion_charco=posicion_charco+1; %Para que el charco desaparezca
            charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
        end
        %Mueve el muro derecho.
        if (obstaculomuro.whichChoice==0)
            posicion_muro=posicion_muro+1;
            muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
        end
        %Mueve el muro izquierdo.
        if (obstaculomuro.whichChoice==1)
            posicion_muro=posicion_muro+1;
            muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
        end
        %Mueve la rampa derecha.
        if (obstaculorampa.whichChoice==0)
            posicion_rampa=posicion_rampa+1;
            rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
        end
        %Mueve la rampa izquierda.
        if (obstaculorampa.whichChoice==1)
            posicion_rampa=posicion_rampa+1;
            rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
        end
        %El salto del coche dura 1 segundo.(32 bloques).
        if ((n_de_bloque>(bloque_analisis+bloque_dur_ana))&(salto==1)&(j<=32))
            %Realiza el c�lculo de los �ngulos y desplazamientos del coche en el ascenso.          
            switch j; %(As� es como se va a hacer realmente)
                case {1,2,3,4},
                    x=j*sin(2*pi*10/360);
                    angulo=asin(x/3.5);
                    alzamiento=sin(angulo)*6.5;
                case {5,6,7,8,9},
                    alzamiento=sin(angulo)+coche.translation(2);
                case 10,
                    x=(11.5-j)*sin(2*pi*10/360);
                    angulo=asin(x/3.5);
                    alzamiento=6.5*(-sin(2*pi*10/360)+sin(angulo))+coche.translation(2);
                case 11,
                    x=(11.5-j)*sin(2*pi*10/360);
                    angulo=asin(x/3.5);
                    alzamiento=6.5*(-sin(angulo))+coche.translation(2);
                case 12,
                    angulo=0;
                    alzamiento=coche.translation(2);%(sin(2*pi*10/360))/2+
                case 32,
                    alzamiento=0;
               %switch j;% Es un switch de prueba, el que vale es el anterior.
                   %case 1,
                     %  angulo=(2*pi*10/360);
                    %   alzamiento=sin(angulo)*6.25;
                   %otherwise
                      % alzamiento=sin(2*pi*10/360)*8;
                     %  angulo=0;
               %end 
            end
            %Para que la rotaci�n sea sobre el eje x. Siguiendo la
            %regla de la mano derecha.
            coche.rotation=[1 0 0 angulo];
            %Desplazamiento en el eje Y. Para que el coche vaya
            %ascendiendo.
            coche.translation=[coche.translation(1) alzamiento coche.translation(3)];  
            j=j+1;
        end
        
    end
    i=i+1; % Es la variable global encargada de que se ejecuten el numero de frames
    %necesarios por cada llamada a Prueba.
    vrdrawnow;
 end
end

%NV (Paco)Din�mica de la colisi�n del coche contra el muro.
if (colision==1)
    if (j==16)
        alzamiento=0; %Hay que desplazar el coche en el
        %sentido negativo del eje Y, para que el coche quede a ras de suelo.
        coche_roto.translation=[coche_roto.translation(1) alzamiento coche_roto.translation(3)];
        coche_roto.rotation=[1 0 0 0]; %Se roto con respecto al eje X 
        %5 grados, pero expresado en radianes.
    end
    j=j+1;%Reutilizo esta variable de control, porque o se est� saltando o
    %se colisiona.
end
 
 % NV (Paco) Variable array que sirve para controlar que la actualizacion
 % del mundo virtual no introduce mas retrasos de los estrictamente
 % necesarios.
 tiempoactualizacion(n_de_bloque+1)=toc;
%n_de_bloque

%1- [segundo 0 al segundo 't_cursor']-->Llegando al segundo 't_cursor', dibujo el cursor en el centro;--
  
    %if n_de_bloque==(bloque_cursor-1) %NV
       
       %NV DIBUJO UNA CRUZ ROJA PARA GRAZ
       
     %tiempo_cruz=tiempo1
      %figure(fig_sujeto); 
      
      %set(p,'XData',[-10 10],'YData',[0 0],'EraseMode','none','color',COLOR_C1);
      %set(p,'XData',[0 0],'YData',[-10 10],'EraseMode','none','color',COLOR_C1);
     
      %hold on  % Mantiene ese dibujo
      %end %if

   
 %NV INTRODUZCO EL BEEP A LOS DOS SEGUNDOS
 %if n_de_bloque==(bloque_beep-1)
    
  %   beep on
   %  beep
    % soni= tiempo1
 %end;
 
 %if n_de_bloque==(bloque_beep)
  %  trigger=1;
%end;
     
   
   
%1A - Cuando tiempo1 > 't_objetivo' sg dibujo la flecha en color verde-objetivo ----------------------------------
 if n_de_bloque==(bloque_objetivo-1)&(controlejecucion==1)&(boton_Ninguno==0) %NVNV
  
 %  figure(fig_sujeto);
   
   %Generamos un n� aleatorio entre 0 y 1, y en funcion de el, decidimos si el rectangulo va arriba o abjo:
   if rand<0.5,  %flecha a la izquierda
       if izq<ntot_pru/2  %mitad de pruebas con cada estado mental
          izq=izq+1;
          
          switch tipo_obstaculo;
              case 0, % Aparece el charco.
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
              case 1, % Aparece el muro.
                muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
                obstaculomuro.whichChoice=1;
              case 2, % Aparece el charco y el muro.
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                obstaculomuro.whichChoice=1;
              case 3, % Aparece la rampa.
                rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                obstaculorampa.whichChoice=1; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
              case 4,
                rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                obstaculorampa.whichChoice=0; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
          end
 
 
        
        
      %     plot([-17 0],[0 0],'color',COLOR_C2,'LineWidth',6);
       %    plot([-7 -17],[5 0],'color',COLOR_C2,'LineWidth',6);
       %    plot([-7 -17],[-5 0],'color',COLOR_C2,'LineWidth',6);
          objet=1; %Indica que el rect�ngulo est� arriba
          posicion(pruebactual)=1; %almaceno en "posicion" que el rectangulo es arriba 
          z(:,pruebactual)=[0;1]; %NV Esta variable el para gBSanalyze. El "0" seria para el C1, osea C3
          % y el 1 para C2, osea C4. En este caso al ser la clase "izquierda",
          %  asigno un 1 a C4, que es el que supuestamente se  activa.
          tipo_prueba(pruebactual)=tipo_obstaculo;
          
       else %    SI IZQ HA LLEGADO A 20, DIBUJO UNA FLECHA DE DERECHA
           der=der+1;
           
           switch tipo_obstaculo;
              case 0, % Aparece el charco.
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                obstaculocharco.whichChoice=0;
              case 1, % Aparece el muro.
                muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
                obstaculomuro.whichChoice=0;
              case 2, % Aparece el charco y el muro.
                muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                obstaculomuro.whichChoice=0;
                obstaculocharco.whichChoice=0;
              case 3, % Aparece la rampa.
                rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                obstaculorampa.whichChoice=0; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla. 
              case 4,
                rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=0; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                obstaculorampa.whichChoice=1; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
           end

           
      %  plot([0 17],[0 0],'color',COLOR_C2,'LineWidth',6);
      %  plot([7 17],[5 0],'color',COLOR_C2,'LineWidth',6);
      %  plot([7 17],[-5 0],'color',COLOR_C2,'LineWidth',6);
        objet=2; %Indica que el rect�ngulo est� abajo
        posicion(pruebactual)=2; %almaceno en "posicion" que el rectangulo es abajo
        z(:,pruebactual)=[1;0];
        tipo_prueba(pruebactual)=tipo_obstaculo;
       end
          
          
          
   else,  %flecha a la derecha
       if der<ntot_pru/2 %mitad de pruebas con cada estado mental
          der=der+1;
          switch tipo_obstaculo;
              case 0, % Aparece el charco.
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                obstaculocharco.whichChoice=0;
              case 1, % Aparece el muro.
                muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
                obstaculomuro.whichChoice=0;
              case 2, % Aparece el charco y el muro.
                muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                obstaculomuro.whichChoice=0;
                obstaculocharco.whichChoice=0;
              case 3, % Aparece la rampa.
                rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                obstaculorampa.whichChoice=0; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
              case 4,
                rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=0; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                obstaculorampa.whichChoice=1; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
           end
       %   plot([0 17],[0 0],'color',COLOR_C2,'LineWidth',6);
       %   plot([7 17],[5 0],'color',COLOR_C2,'LineWidth',6);
       %   plot([7 17],[-5 0],'color',COLOR_C2,'LineWidth',6);
          objet=2; %Indica que el rect�ngulo est� abajo
          posicion(pruebactual)=2; %almaceno en "posicion" que el rectangulo es abajo
          z(:,pruebactual)=[1;0]; %NV Esta variable el para gBSanalyze. El "1" seria para el C1, osea C3
          % y el 0 para C2, osea C4. En este caso al ser la clase "derecha",
          %  asigno un 0 a C4, que es el que supuestamente se  activa.
          tipo_prueba(pruebactual)=tipo_obstaculo;
      else
          izq=izq+1;
          switch tipo_obstaculo;
              case 0, % Aparece el charco.
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
              case 1, % Aparece el muro.
                muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
                obstaculomuro.whichChoice=1;
              case 2, % Aparece el charco y el muro.
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
                obstaculomuro.whichChoice=1;
              case 3, % Aparece la rampa.
                rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                obstaculorampa.whichChoice=1; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
              case 4,
                rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
                %Determina la posici�n de la rampa
                charco1.translation=[charco1.translation(1:(length(charco1.translation)-1)) posicion_charco];
                %Se escalan las dimensiones del charco en funci�n del n�mero de bloques que
                %se tienen que procesar en el intervalo de tiempo dado.
                obstaculocharco.whichChoice=1; %NV(Paco) Campo del 
                %obstaculo encargado de mostrarlo por pantalla.
                obstaculorampa.whichChoice=0; %NV(Paco) Campo del obstaculo
                %que se encargado de mostrarlo por pantalla.
          end
        %   plot([-17 0],[0 0],'color',COLOR_C2,'LineWidth',6);
        %   plot([-7 -17],[5 0],'color',COLOR_C2,'LineWidth',6);
         %  plot([-7 -17],[-5 0],'color',COLOR_C2,'LineWidth',6);
          objet=1; %Indica que el rect�ngulo est� arriba
          posicion(pruebactual)=1; %almaceno en "posicion" que el rectangulo es arriba 
          z(:,pruebactual)=[0;1];
          tipo_prueba(pruebactual)=tipo_obstaculo;
      end
   end; 
   t_obj=tiempo1
end %(if (tiempo1>t_objetivo) & (tiempo1<t_objetivo+0.5)) 


%NV ELIMINO EL CUE. IMPORTANTE: PARA QUE FUNCIONE BIEN EL TAM_DE_VENTANA
%DEBE SER 26 O 13 MUESTRAS en caso de seleccionar Fs=130Hz, 
% if n_de_bloque==(bloque_fin_CUE-1)
 %    finCUE= tiempo1
    
  %  figure(fig_sujeto)
  %  hold off
  %  p=plot([0 0],[0 0],'EraseMode','Xor','color',color_fondo,'LineWidth',6);
  % axis ([-20 20 -20 20]); %Dibujo unos ejes
  % set(gca,'XColor',[0 0 0],'YColor',[0 0 0])
  % hold on
 %end;
 
 %if n_de_bloque==(bloque_fin_CUE)
 %  trigger=0;
%end;



%NV ESTA VARIABLE DECLARADA EN HM_PANEL ES PARA NO REPRESENTAR NADA DE fig_sujeto
%NV ESTO SERIA UTIL EN EL PORTATIL DONDE SOLO SE DISPONE DE UNA PANTALLA.
if no_portatil %NV
 if (tiempo1>t_analisis+tambloque/Fs) & (tiempo1<t_analisis+d_analisis),
     
   %Se supone que t_analisis siempre es mayor o igual que t_objetivo y t_cursor
   set(figure(fig_tiempo),'Name', ['Prueba ',num2str(pruebactual) '(Analizando muestras...)' ]); %Indica la prueba en que estamos
   %COMO LOS TIEMPOS NO SON EXACTOS, PUEDE SALIR UN MENSAJE ANTES DE TIEMPO 
 elseif (tiempo1>t_analisis+d_analisis) & (tiempo1<d_prueba),
   %Esperamos a que termine la prueba sin hacer nada mas
   set(figure(fig_tiempo),'Name', ['Prueba ',num2str(pruebactual) '...' ]);
 end; 
end; %NV no_portatil

%2- Saco las muestras de la tarjeta ---------------------------------------------------
   inst_muestra(n_de_bloque+1)=toc; %Guarda justo el instante en que se captan las muestras(ANTIGUO PRUEBA.M)
   
   tcapmuestra(n_de_bloque+1)=toc-tiempo1;  %Guardoo la duracion de la adquisicion para cada prueba
   
   [d,t] = getdata(obj,tambloque); %Guarda en 'd' las 'tambloque' muestras y en 't' el eje de tiempos
                           
                              
%3- Almaceno las muestras en variables para su posterior tratamiento ------------------ 
%En muestra1, muestra2 y tiempo voy a�adiendo el bloque de tambloque muestras que me dan
%cada vez que se llama este programa.
	
    tiempoi = toc; %Me indica el instante de tiempo en que adquiero el bloque de muestras.
				 %(Coincide con tiempo1)
	inicio = n_de_bloque*tambloque + 1;  %Es la posicion de la 1� muestra a almacenar
   %CUIDADO: las vbles muestra1...muestra4, se sobreescriben tras cada prueba, no 
   %         se inicializan nunca(son 'persistent'), a menos que quieras hacerlo
   %         en algun sitio usando un clear.
	muestra1(inicio : inicio + tambloque-1)= d(:,1);%*500; %muestra1 es el canal 1
	muestra2(inicio : inicio + tambloque-1)= d(:,2);%*200; %muestra2 es el canal 2
	%muestra3(inicio : inicio + tambloque-1)= d(:,3);%*100; %muestra3 es el canal 3
	%muestra4(inicio : inicio + tambloque-1)= d(:,4);%*50; %muestra4 es el canal 4
    %muestra5(inicio : inicio + tambloque-1)= d(:,5);%%NV*50; %muestra5 es el canal 5
	tiempo(inicio : inicio + tambloque-1)= t;

    %NV GRAZ: CREO UNA TRAZA DEL TRIGGER
 %   if trigger==0
  %      trig(inicio : inicio + tambloque-1)=0;
   % else
   %     trig(inicio : inicio + tambloque-1)=1;
  %  end
        
    
    
    %t1=t(tambloque);   %NV
    %d1=d(tambloque,1);  %NV
%En muestratotal almaceno tobas las muestras de todo el ensayo(Un ensayo esta formado en
%general por 20 pruebas que se hacen seguidas
   inicio_ensayo = n_de_bloque_tot * tambloque + 1;
   muestratotal1(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,1);%*500; %muestra1 es el canal 1
   muestratotal2(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,2);%*200; %muestra2 es el canal 2
   %muestratotal3(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,3);%*100; %muestra3 es el canal 3
   %muestratotal4(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,4);%*50; %muestra4 es el canal 4
   %muestratotal5(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,5);%%NV*50; %muestra4 es el canal 4
	%tiempo_ultimamuestra = 6.992*(pruebactual-1); 
	%tiempototal(inicio_ensayo : inicio_ensayo + tambloque-1) = t+tiempo_ultimamuestra;
	%tiempototaln(inicio_ensayo : inicio_ensayo + tambloque-1) = t;
    %(En "tiempototal" el tiempo se incrementa y en "tiempototaln" se repite)%
   tiempototal(inicio_ensayo : inicio_ensayo + tambloque-1)=t;
   
   %NV GRAZ: CREO UNA TRAZA DEL TRIGGER TOTAL
  % if trigger==0
   %     trigtot(inicio_ensayo : inicio_ensayo + tambloque-1)=0;
   % else
   %     trigtot(inicio_ensayo : inicio_ensayo + tambloque-1)=1;
   % end
    
    
   
%Una vez captado un bloque, incremento el indice para el siguiente bloque:
	n_de_bloque = n_de_bloque + 1; %Cuidado con cambiarlo de sitio, pues afecta a la grabacion en 'tiempo2frec.m'
	n_de_bloque_tot = n_de_bloque_tot+1; 
   
%4-Hago el analisis en frecuencia------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>
%Ahora llamo a la funcion tiempo2frec, que va a calcular la FFT usando el algoritmo de 
%Burg. Le paso las muestras y la posicion inicial de donde acabo de almacenar el bloque. 
%Hasta aqui, y desde que inicialice la variable tiempo1, este instante de tiempo es
%practicamente nulo.
retardo= (tambloque/Fs)/2; %(La duracion de media ventana)Si no no analiza la ultima ventana en:
%NVNVVNif (tiempo1>t_analisis+tambloque/Fs) & (tiempo1<=t_analisis+d_analisis+retardo), %usar tiempo2frec antes no merece la pena
  if (n_de_bloque>bloque_analisis) & (n_de_bloque<=bloque_analisis+bloque_dur_ana), 
      %tiempo_analasis=tiempo1
    %tiempo2frec(muestra1,muestra2,muestra3,muestra4,inicio); %EL ERROR divide by cero, lo da en estos programas
    if num_canales_procesar==1, tiempo2frec_1c(muestra1,inicio); end; %NV PROCESO EL CANAL UNO
    if num_canales_procesar==2, tiempo2frec_2c(muestra1,muestra2,inicio); end; %NV PROCESO EL CANAL UNO y DOS
    if num_canales_procesar==3, tiempo2frec_3c(muestra1,muestra2,muestra3,inicio); end; %NV PROCESO EL CANAL UNO, DOS Y TRES
    if num_canales_procesar==4, tiempo2frec_4c(muestra1,muestra2,muestra3,muestra4,inicio); end; %NV PROCESO EL CANAL UNO, DOS, TRES Y CUATRO
  
end;%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%Compruebo si se ha alcanzado el objetivo y en tal caso termino la toma de muestras:
   %Hay otro 'if' con la misma condicion que este pero en PRESENT.m; Es mejor tenerlos
   %separados por cuestion de tiempos. El parpadeo se hace en PRESENT.m y es mejor 
   %dejarlo alli, porque aqui el tiempo afecta a la duracion de la prueba en la que se
   %produzca acierto(si eso nos da igual, podemos cambiarlo de sitio porque a los datos
   %no afecta).
%Al declarar una vble como global, ya existe, pero esta vacia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTE TROZO LO PONGO COMO COMENTARIO POR QUE LO QUE HACE ES DEJAR DE MUESTREAR LAS 
%SE�ALES CUANDO SE ALCANZA EL OBJETIVO, Y ESO NO INTERESA (11/07/02)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if exist('p','var') & (isempty(objet)==0),
%   if (get(p,'YData') > 99) & (objet== 1) | ((get(p,'YData') < 1) & (objet == 2)),%Quiere decir que se alcanzo el objetivo
%      %set(A1,'StopAction','FuncionParar'); %Podemos programar aqui lo que queramos que se haga al hacer stop.
%      stop(A1); %Paramos la adquisicion de Datos.
%      flushdata(A1,'all');%Borra todos los datos de la tarjeta
%      %Sino es suficiente con stop y flushdata probar delete(A1) o daqreset.
%      
%      %Completamos las variables:
%      = duration * Fs/tambloque; %Lo uso en la siguiente instruccion
%      parchetiempo= tiempo(end)+1/Fs : 1/Fs: duration-1/Fs;
%      
%      tiempo= [tiempo parchetiempo];%Como si la prueba hubiera terminado sin alcanzar el objetivo
%      muestra1(inicio+tambloque+1:*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestra2(inicio+tambloque+1:n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestra3(inicio+tambloque+1:n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestra4(inicio+tambloque+1:n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      n_de_bloque= n_tot_bloq_por_prueba;%Para mas abajo poder entrar en 'grabar muestras'.
%      
%      tiempototal= [tiempototal parchetiempo];
%      muestratotal1(inicio_ensayo+tambloque+1:pruebactual*n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestratotal2(inicio_ensayo+tambloque+1:pruebactual*n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestratotal3(inicio_ensayo+tambloque+1:pruebactual*n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      muestratotal4(inicio_ensayo+tambloque+1:pruebactual*n_tot_bloq_por_prueba*tambloque)=zeros(1,n_tot_bloq_por_prueba*tambloque-(inicio+tambloque));
%      n_de_bloque_tot= pruebactual*n_tot_bloq_por_prueba;
%   end;
%end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_tot_bloq_por_prueba= duration * Fs/tambloque;

%5- Dibujo el bloque de muestras adquiridas.------------------------------------------

if (ver_t==1) & (aquisic_normal==1), %Si esta pulsado el boton 'ver_t' del panel, se muestra la reprsnt. temp.
   
    figure(fig_tiempo);hold on;
      
    %No queda mas remedio que rprsentar por separado para poder elegir los canales, y
    %la verdad es que no retarda tanto la ejecucion:
    %El 'EraseMode' sirve para que no parpadeen los ejes en cada representacion
   if n_de_bloque==1 %NV 
      
    %NV LO DE perm_plot ES NUEVO  
    if (grabar_c1) & (perm_plot_c1), plot(t,d(:,1),'Color',COLOR_C1,'EraseMode','none');    end; %Vamos a grabar solo los canales que se pida grabar
    if (grabar_c2) & (perm_plot_c2), plot(t,d(:,2),'Color',COLOR_C2,'EraseMode','none');    end;
    if (grabar_c3) & (perm_plot_c3), plot(t,d(:,3),'Color',COLOR_C3,'EraseMode','none');    end;
    if (grabar_c4) & (perm_plot_c4), plot(t,d(:,4),'Color',COLOR_C4,'EraseMode','none');    end;
    if (grabar_c5) & (perm_plot_c5), plot(t,d(:,5),'Color',COLOR_C5,'EraseMode','none');    end;  %NV
else %NV ESTO ES NUEVO Y LO QUE HAGO ES INTRODUCIR UNA VARIABLE QUE CONECTE CON LA TRAZA ANTERIOR.
 
    if (grabar_c1) & (perm_plot_c1), plot([ti;t],[d1;d(:,1)],'Color',COLOR_C1,'EraseMode','none');    end; %Vamos a grabar solo los canales que se pida grabar
    if (grabar_c2) & (perm_plot_c2), plot([ti;t],[d2;d(:,2)],'Color',COLOR_C2,'EraseMode','none');    end;
    if (grabar_c3) & (perm_plot_c3), plot([ti;t],[d3;d(:,3)],'Color',COLOR_C3,'EraseMode','none');    end;
    if (grabar_c4) & (perm_plot_c4), plot([ti;t],[d4;d(:,4)],'Color',COLOR_C4,'EraseMode','none');    end;
    if (grabar_c5) & (perm_plot_c5), plot([ti;t],[d5;d(:,5)],'Color',COLOR_C5,'EraseMode','none');    end; %NV
end;    %%%%%NV
%%%%%NV ESTAS VARAIBLES SON LAS QUE SIRVEN PARA CONECTAR LAS TRAZAS.
ti=t(tambloque);   %NV
d1=d(tambloque,1);d2=d(tambloque,2);d3=d(tambloque,3);d4=d(tambloque,4); d5=d(tambloque,5); %NV

end;

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
%NV ESTE TROZO DE PROGRAMA SIRVE PARA HACER UNA REPRESENTACION TEMPORAL
%MANTENIENDO EL EJE DE TIEMPO CONSTANTE Y DE eje_tiempo SEGUNDOS.

if (ver_t==1) & (aquisic_normal==0), %Si esta pulsado el boton 'ver_t' del panel, se muestra la reprsnt. temp.
    figure(fig_tiempo);hold on;
    permiso=1;
      if (n_de_bloque==1) | (n_de_bloque==bloques_tiempo+1) 
             bloques_tiempo=bloques_tiempo + bloques_proc_eje_tiempo;
             hold off
             permiso=0;       
             axis ([((n_de_bloque-1)*tambloque/Fs) ((n_de_bloque-1+bloques_proc_eje_tiempo)*tambloque/Fs) -6 6])
             hold on
             if  (grabar_c1) & (perm_plot_c1), plot(t,d(:,1),'Color',COLOR_C1,'EraseMode','none');    end; %Vamos a grabar solo los canales que se pida grabar
             if (grabar_c2) & (perm_plot_c2), plot(t,d(:,2),'Color',COLOR_C2,'EraseMode','none');    end;
             if (grabar_c3) & (perm_plot_c3), plot(t,d(:,3),'Color',COLOR_C3,'EraseMode','none');    end;
             if (grabar_c4) & (perm_plot_c4), plot(t,d(:,4),'Color',COLOR_C4,'EraseMode','none');    end;
             if (grabar_c5) & (perm_plot_c5), plot(t,d(:,5),'Color',COLOR_C5,'EraseMode','none');    end;
       end
    %No queda mas remedio que rprsentar por separado para poder elegir los canales, y
    %la verdad es que no retarda tanto la ejecucion:
    %El 'EraseMode' sirve para que no parpadeen los ejes en cada representacion
  
     if permiso==1 %NV ESTO ES NUEVO Y LO QUE HAGO ES INTRODUCIR UNA VARIABLE QUE CONECTE CON LA TRAZA ANTERIOR.
   
        if (grabar_c1) & (perm_plot_c1), plot([ti;t],[d1;d(:,1)],'Color',COLOR_C1,'EraseMode','none');    end; %Vamos a grabar solo los canales que se pida grabar
        if (grabar_c2) & (perm_plot_c2), plot([ti;t],[d2;d(:,2)],'Color',COLOR_C2,'EraseMode','none');    end;
        if (grabar_c3) & (perm_plot_c3), plot([ti;t],[d3;d(:,3)],'Color',COLOR_C3,'EraseMode','none');    end;
        if (grabar_c4) & (perm_plot_c4), plot([ti;t],[d4;d(:,4)],'Color',COLOR_C4,'EraseMode','none');    end;
        if (grabar_c5) & (perm_plot_c5), plot([ti;t],[d5;d(:,5)],'Color',COLOR_C5,'EraseMode','none');    end; %NV
     end;    %%%%%NV
%%%%%NV ESTAS VARAIBLES SON LAS QUE SIRVEN PARA CONECTAR LAS TRAZAS.
ti=t(tambloque);   %NV
d1=d(tambloque,1);d2=d(tambloque,2);d3=d(tambloque,3);d4=d(tambloque,4); d5=d(tambloque,5); %NV

end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV




%"tiempofinal" es el tiempo que tarda en captar un bloque de muestras, y en
%llamar la funcion "frec2", que obtiene la FFT o BURG:
%EN GENERAL ESTA DURACION ESTA ENTRE 0 Y 0.06 SEGUNDOS, ES DECIR POR DEBAJO
%DE LOS 100ms DE CADA ADQUISICION.
	tiempofinal(n_de_bloque)= toc-tiempo1; 
    

%6- Almacenamiento de resultados -----------------------------------------------------
%Compruebo el n�mero de prueba por el que voy, y en funcion de �l, almaceno los
%resultados en su fichero correspondiente:
%Se graban los siguientes campos: El nombre del individuo(variable sujeto), el nombre 
%del ensayo(vble ensayo), la frecuencia de muestreo(Fs), las muestras(muestra1..muestra4)
%que correspondan en funcion de los que se solicito grabar, su nombre(c1..c4), el tipo
%de prueba(Relajarse, Pensar, Movimiento, u Otro-->esto lo hago a traves de una vble que
%creo en el Panel de control, y que se llama 'tipologia'), y los tiempos que definen la 
%prueba(t_cursor, t_analisis, d_analisis, d_descanso);
  
   %  Una vez que 'n_de_bloque' es igual al numero de bloques a adquirir por cada prueba,
   %  lo reseteo. Cuando acabe una prueba, habr� guardado 'duration' sg (standar=7sg) usando
   %  ventanas de tambloque muestras(=10msg a Fs=130Hz(standar)), as� que en total tendr�:
   %       n�total de bloques = duration * Fs/tambloque = {standar} = 7 * 130/13
   
   
   
   
   %NV---------------------------------------------------------------------
   %NV VOY A CUPRIMIR LO DE GRABAR CADA rt.mat. REALMENTE LO QUE ME
   %INTERESA ES EL RTOTAL
   if n_de_bloque == n_tot_bloq_por_prueba, %Cuando se han capturado todos los bloques de una prueba,
      %Grabo la prueba completa:
      %NV comando=['save ' trayectoria '\rt' int2str(pruebactual) '.mat sujeto ensayo Fs'];
      %NVif grabar_c1, comando=[comando ' muestra1 c1']; end;
      %NVif grabar_c2, comando=[comando ' muestra2 c2']; end;
      %NVif grabar_c3, comando=[comando ' muestra3 c3']; end;
      %NVif grabar_c4, comando=[comando ' muestra4 c4']; end;
      %NVif grabar_c5, comando=[comando ' muestra5 c5']; end; %NV
      %NVtipo=str2num(tipologia(pruebactual)); %Lo guardare como un numero
      %NVcomando=[comando ' tipo tiempo objet t_cursor t_objetivo t_analisis d_analisis d_descanso'];
      %NVeval(comando);
      
    %NV---------------------------------------------------------------------  
      %Inicializo la variable n_de_bloque, la variable colision, la variablesalto, 
      %la variable encargada del movimiento en el salto y la variable
      %encargada del movimiento de la carretera.
      n_de_bloque=0;
      colision=0;
      salto=0;
      i=0;
      j=1;
      
      if pruebactual==ntot_pru, 
         %Grabamos un fichero rtotal.m conteniendo todas las pruebas juntas:
         comando1=['save ' trayectoria '\rtotal.mat sujeto ensayo Fs'];
         if grabar_c1, 
            comando1=[comando1 ' muestratotal1'];
            Num=Nums.ch1;  Den=Dens.ch1;
            comando2=['save ' trayectoria '\filtro_ch1.mat Num Den']; eval(comando2);         
         end;
         if grabar_c2, comando1=[comando1 ' muestratotal2'];
            Num=Nums.ch2;  Den=Dens.ch2; 
            comando2=['save ' trayectoria '\filtro_ch2.mat Num Den']; eval(comando2); 
         end;
         if grabar_c3, comando1=[comando1 ' muestratotal3'];
            Num=Nums.ch3;  Den=Dens.ch3;
            comando2=['save ' trayectoria '\filtro_ch3.mat Num Den']; eval(comando2);             
         end;
         if grabar_c4, comando1=[comando1 ' muestratotal4'];
            Num=Nums.ch4;  Den=Dens.ch4;
            comando2=['save ' trayectoria '\filtro_ch4.mat Num Den']; eval(comando2);             
         end;
         %%%%%%%NV
         if grabar_c5, comando1=[comando1 ' muestratotal5'];            
         end;
         %%%%%%%NV
         %%%%%%%NV GRABO LA TRAZA TRIG_TOTAL
         comando1=[comando1 ' trigtot']; 
         comando1=[comando1 ' tipologia tiempototal posicion t_cursor t_objetivo t_analisis d_analisis d_descanso dist_barra wo w1 w2'];
         %Como vemos se ha introducido tb la vble posicion
         eval(comando1);
         
         %NV VOY A CREAR UNA VARIABLE y CON LAS TRAZAS EEL Y EL TRIGGER
         %PARA SER EVALUADO POR gBSanalyze
         y=[muestratotal1',muestratotal2',trigtot'];
         y(257,3)=0;  %NV ESTO VALOR LO PONGO A CERO PORQUE PARECE QUE EN LA PRIMERA TRAZA, ANTES
         %DEL TRIGGER NO HAY 256 MUESTRAS A CERO SINO QUE 255.
         comando1=['save ' trayectoria '\sesion.mat y'];
         eval(comando1);
         comando1=['save ' trayectoria '\clase.mat z tipo_prueba']; %Almaceno z en clase, para gBSanalyze
         eval(comando1);
         
         tipo_prueba=zeros(1,ntot_pru);
         tiempofinal=zeros(1,ntot_pru);
         z=zeros(2,ntot_pru);
         %NV
      end %if n_de_bloque == n_tot_bloq_por_prueba      
      Prueba_terminada=1;%Sirve para que Medir.m pare(ahora mismo no se usa)
   end
   
   
   
   