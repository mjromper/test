%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%
%  Programa: TIEMPO2FREC (function tiempo2frec)
%
%Es el encargado de filtrar la señal y realizar su análisis en frecuencia(pero no
%interpretarlo, eso se deja a Descursor), asimismo representa gráficamente el 
%resultado de dicho análisis(si así se seleccionó en el panel) y graba el resultado
%de ese análisis en frecuencia en ficheros de la forma rfj.mat, donde la letra 'j' 
%identifica el orden de la prueba en curso.(Mas info sobre la funcion en si y como
%funciona dentro del programa).
%
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> Present --> Medir --> Prueba --> TIEMPO2FREC --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%Vea también: HMPanel, Ensayo, Present, Medir ..., ModelarFiltros, ...

%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad de Málaga
%------------------------------------------------------------------------------------

%tiempo2frec hace el estudio en frecuencia usando el algoritmo de estimación 
% espectral de burg y guarda todos los datos relativos a dicho estudio.
%
% Sintaxis: exito = frec2 (m1,m2,m3,m4,ini)
%
% exito: indica si se ha alcanzado el objetivo(obj=1) o no(obj=0);
%        (A partir de aqui no necesite usar la vble global EXITO, bastó 
%         con que fuera local).
% m1, m2, m3, m4: son las muestras de los canales 1 a 4 en el dominio del tiempo.
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

global duration tam nump;%Variables definidas en Ensayo.m
global pruebactual p objet mediavent1 mediavent2 tiempo1 ntot_pru;
global trayectoria t_cursor t_analisis d_analisis ver_f;
global sujeto ensayo Fs tam_ventana solape metodoEE orden grabar_c1 grabar_c2 grabar_c3 grabar_c4 c1 c2 c3 c4 tipologia; %Se graban en los rfb.mat
global fig_sujeto fig_frecuencia cell_metodosEE metodoEE;
global COLOR_C1 COLOR_C2 COLOR_C3 COLOR_C4;
global nmfltros nch Nums Dens;%Variables para el filtrado
global n_de_bloque;%Viene de Prueba.m(necesaria para saber cuando grabar)

%NV VARIABLE QUE VIENE DE HM_PANEL 
global potencia_activa
global indice_dist  %PARA ALMACENAR LA VARIABLE dist DE desp_barra

global ver_t t fig_tiempo COLOR_C1 COLOR_C2 COLOR_C3 COLOR_C4 %NV PARA DIBUJAR LOS PLOTS FILTRADOS
global perm_plot_prc1 perm_plot_prc2 %NV PARA DAR PERMISO A DIBUJAR LOS PLOTS FILTADOS

persistent cont_filt ti_filt s1_filt s2_filt %NV VARIABLES PARA EL PLOT DE LAS TRAZAS FILTRADAS


persistent indice final1 final2 final3 final4 fin1 fin2 vmax frecmax tiniburg indicetotalb
persistent ini_anterior P1_anterior  P2_anterior%NV

if isempty(indicetotalb),
   indicetotalb=0; %Uso esta variable como indice para almacenar los espectros de potencia   
   		%de todas las ventanas de toda la sesion en una variable "finaltotal1 finaltotal2"
end

if isempty(indice),
   indice=0; %'indice' cuenta el nº de bloques que se capturan, por tanto llega
   			 %hasta 40 en este caso(en 4s, bloques de 100ms)
   ini_anterior=t_analisis*Fs; %NV
   P1_anterior=0;%NV
   P2_anterior=0;%NV
  
end

if isempty(tiniburg),
   tiniburg=0; %"tiniburg" almacena el instante en que se empiezan a procesar los datos
end



%1- Preparación de Variables y Parámetros:
	%orden={max posible para que funcione burg}=floor(tam_ventana/2)=floor(tam/2)---> Se escribe en el panel de control;
   tiniburg(indice+1)=toc;  % instante de tiempo en que empiezo a procesar
   %nump=4*Fs; %nº puntos q. pido al met.de Estim. Espectral.(Se define en Ensayo.m)
   nump2=floor(nump/2)+1;%Es la longitud del vector devuelto por los metodos de Estim. Espectral.
   tam2=solape+tam;%Es el tamaño de la ventana
   %A continuacion definimos un solape adicional que tiene sentido para el filtrado:
      solapef=130;%[muestras]-Solape de filtrado<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
   if solape>=ini,
      error('Error en tiempo2frec.m - linea 105): El solape es demasiado grande para el inicio del analisis elegido');
   end;
   primera_muestra = ini-solape;% primera muestra de la ventana.
   ultima_muestra  = ini+tam-1; % ultima muestra de la ventana.
   
   if solapef<primera_muestra, %Cogemos el 'solapef' completo:
      s1=m1(primera_muestra-solapef : ultima_muestra); 
      s2=m2(primera_muestra-solapef : ultima_muestra);
      %NV s3=m3(primera_muestra-solapef : ultima_muestra);
      %NV s4=m4(primera_muestra-solapef : ultima_muestra);
   else, %Cogemos el maximo solapef posible, que equivaldria a coger desde la muestra 1:
       s1=m1(1 : ultima_muestra); 
      s2=m2(1 : ultima_muestra);
      %NV s3=m3(1 : ultima_muestra);
      %NV s4=m4(1 : ultima_muestra);
   end;
   %length(s1)
   
%2- Filtro las muestras:
   %Primero hay que calcular el filtro:
   Numtotal1=1;   Numtotal2=1;   Numtotal3=1;   Numtotal4=1;
   Dentotal1=1;   Dentotal2=1;   Dentotal3=1;   Dentotal4=1;
   for nf=1:nmfltros,
      if grabar_c1,
         Numtotal1= conv(Numtotal1,Nums.ch1(nf,:));
         Dentotal1= conv(Dentotal1,Dens.ch1(nf,:));
      end;
      if grabar_c2,
         Numtotal2= conv(Numtotal2,Nums.ch2(nf,:));
         Dentotal2= conv(Dentotal2,Dens.ch2(nf,:));
      end;
      if grabar_c3,
         Numtotal3= conv(Numtotal3,Nums.ch3(nf,:));
         Dentotal3= conv(Dentotal3,Dens.ch3(nf,:));
      end;
      if grabar_c4,
         Numtotal4= conv(Numtotal4,Nums.ch4(nf,:));
         Dentotal4= conv(Dentotal4,Dens.ch4(nf,:));
      end;
   end;
   while Numtotal1(1)==0, Numtotal1 = Numtotal1(2:end);	end;
   while Dentotal1(1)==0, Dentotal1 = Dentotal1(2:end);	end;
   while Numtotal2(1)==0, Numtotal2 = Numtotal2(2:end);	end;
   while Dentotal2(1)==0, Dentotal2 = Dentotal2(2:end);	end;
   %NVwhile Numtotal3(1)==0, Numtotal3 = Numtotal3(2:end);	end;
   %NVwhile Dentotal3(1)==0, Dentotal3 = Dentotal3(2:end);	end;
   %NVwhile Numtotal4(1)==0, Numtotal4 = Numtotal4(2:end);	end;
   %NVwhile Dentotal4(1)==0, Dentotal4 = Dentotal4(2:end);	end;
   %Filtrado promiamente dicho:
      
   s1= filter(Numtotal1,Dentotal1,s1); %Filtrado propiamente dicho del canal 1
   s2= filter(Numtotal2,Dentotal2,s2); %Filtrado propiamente dicho del canal 2  
   %NVs3= filter(Numtotal3,Dentotal3,s3); %Filtrado propiamente dicho del canal 3
   %NVs4= filter(Numtotal4,Dentotal4,s4); %Filtrado propiamente dicho del canal 4
   
  
%2'5- Quito el 'solapef':
   if solapef<=primera_muestra, %Se pudo coger el 'solapef' completo, ahora se quita:
      s1= s1(solapef+1 : solapef+solape+tam);
      s2= s2(solapef+1 : solapef+solape+tam);
     %NV s3= s3(solapef+1 : solapef+solape+tam);
      %NVs4= s4(solapef+1 : solapef+solape+tam);
   else, %Se cogio desde la muestra 1, asi que la vble. 'primera_muestra' sigue teniendo sentido:
      s1= s1(primera_muestra : ultima_muestra);
      s2= s2(primera_muestra : ultima_muestra);
     %NV s3= s3(primera_muestra : ultima_muestra);
     %NV s4= s4(primera_muestra : ultima_muestra);
   end;
   
   
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
   %VOY A DIBUJAR LAS TRAZAS FILTRADAS.
 
 if ver_t==1, 
     
 if isempty(cont_filt),	 %NV ESTA VARIABLE LA CREO PARA INDICAR QUE ES LA PRIMERA TRAZA A DIBUJAR
   cont_filt=0; 
  
end;
 
%NV AHORA EMPIEZO A DIBUJAR SI HE ACTIVADO LA OPCION DE DIBUJAR
    figure(fig_tiempo);hold on; %%%%NV
    ss1=s1((length(s1)-tam+1):length(s1));
    ss2=s2((length(s2)-tam+1):length(s2));
    if cont_filt==0  %NV CON ESTO DIBUJO LA PRIMERA TRAZA TAL CUAL
       if perm_plot_prc1, plot(t,ss1,'Color',COLOR_C1,'EraseMode','none');  end;
       if perm_plot_prc2, plot(t,ss2,'Color',COLOR_C2,'EraseMode','none');   end;
    cont_filt=1;  %NV CAMBIO LA VARIABLE cont_filt PARA QUE EN LA SIGUIENTES TRAZAS DIBUJE CONECTANTO
      else           %NV CON LA TRAZA ANTERIOR
        tt=t';
          if perm_plot_prc1, plot([ti_filt,tt],[s1_filt,ss1],'Color',COLOR_C1,'EraseMode','none');  end;
          if perm_plot_prc2, plot([ti_filt,tt],[s2_filt,ss2],'Color',COLOR_C2,'EraseMode','none');  end;
    end; 
    ti_filt=t(tam);   %NV ESTAS VARIABLES SON PARA LA CONEXION ENTRE TRAZAS
    s1_filt=ss1(tam);
    s2_filt=ss2(tam);
end;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
   
   
   
   
   %------------------------------------------------------------------------------------------->>>
   %PARA HACER COMPROBACIONES(compara lo que analiza Herr.Medida con lo que analiza Herr-Analisis):
   %comando=['save ' trayectoria '\v' , num2str(n_de_bloque) , '.mat s1'];  eval(comando);
   %-------------------------------------------------------------------------------------------<<<

   
%3- En 'fini' almaceno todas las muestras enventanadas desde que he llamado 
    %a esta funcion(-->Esto creo que se usa para nada, pero no es seguro).
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV LO VOY A SUPRIMIR. CREO QUE NO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%SIRVE PARA NADA
    %NVfin1(indice*tam2+1:(indice+1)*tam2)= s1;
    %NVfin2(indice*tam2+1:(indice+1)*tam2)= s2;
    %NVfin3(indice*tam2+1:(indice+1)*tam2)= s3;
    %NVfin4(indice*tam2+1:(indice+1)*tam2)= s4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
    
 %4- Calculo la Estimacion Espectral para 'tam2=tam+solape' muestras:
   switch metodoEE,
   case 1,%La FFT no es una estimacion de la DEP, sino de la DFT.
      %Ahora se calcula la FFT 'onesided'(unilateral) segun propone MATLAB en su web:
      P1= abs(fft(s1,nump))/length(s1);%Para que no dependa de la longitud de s1.
      P1= P1(1:floor(nump/2)+1);%Nos quedamos solo las frecuencias '0' a 'Fs/2'
      P1= 2*P1; %Estamos dando todos los resultados 'onesided' osea con toda la potencia
      %          en el lado positivo, por eso multiplicamos por 2. Sin embargo hay que 
      %          arreglar dos puntos(0Hz, y Fs/2 Hz) ya que la fft.m si da la potencia total
      %          en ellos. Con las otras frecuencias si da dos puntos(entre los que reparte
      %          la potencia), pero con esas dos frecuencias solo da un punto para cada una.
      P1(1)= P1(1)/2; %(frecuencia 0Hz)Leer arriba
      if rem(nump,2)==0,%si no es cero(nump impar, no habra frecuencia Fs/2, sino Fs/2-1)
         P1(end)= P1(end)/2; %(frecuencia Fs/2)Leer arriba
      end;
      %Puesto que fft.m siempre da el resultado 'twosided', y que nosotros queremos dar el resultado
      %'onesided', debemos quitar los puntos del final. Asi solo son significativos los 'floor(nump/2)+1'
      %primeros puntos. Por ejemplo:
      %nump=128 => 65 puntos significativos.
      %nump=127 => 64 puntos significativos.
      P2= abs(fft(s2,nump))/length(s2);%Para que no dependa de la longitud de s2.
      P2= P2(1:floor(nump/2)+1);%Nos quedamos solo las frecuencias '0' a 'Fs/2'
      P2= 2*P2; %Estamos dando todos los resultados 'onesided' osea con toda la potencia...
      P2(1)= P2(1)/2; %(frecuencia 0Hz)Leer arriba
      if rem(nump,2)==0,   P2(end)= P2(end)/2; end; %Si no es cero(nump impar, ...
      
      %NVP3= abs(fft(s3,nump))/length(s3);%Para que no dependa de la longitud de s3.
      %NVP3= P3(1:floor(nump/2)+1);%Nos quedamos solo las frecuencias '0' a 'Fs/2'
      %NVP3= 2*P3; %Estamos dando todos los resultados 'onesided' osea con toda la potencia...
      %NVP3(1)= P3(1)/2; %(frecuencia 0Hz)Leer arriba
      %NVif rem(nump,2)==0,   P3(end)= P3(end)/2; end; %Si no es cero(nump impar, ...
      
      %NVP4= abs(fft(s4,nump))/length(s4);%Para que no dependa de la longitud de s4.
     %NV P4= P4(1:floor(nump/2)+1);%Nos quedamos solo las frecuencias '0' a 'Fs/2'
     %NV P4= 2*P4; %Estamos dando todos los resultados 'onesided' osea con toda la potencia...
      %NVP4(1)= P4(1)/2; %(frecuencia 0Hz)Leer arriba
      %NVif rem(nump,2)==0,   P4(end)= P4(end)/2; end; %Si no es cero(nump impar, ...
      
   case 2,
      %Periodogram usando ventana cuadrada. Para una secuencia tan corta de señal, creo
      %que no merece la pena usar pwelch.m(promediado de periodogramas de Welch)
      P1= periodogram(s1,ones(size(s1)),nump,Fs,'onesided')/(length(s1)/Fs);%Dividir por el nº de segundos
      P2= periodogram(s2,ones(size(s2)),nump,Fs,'onesided')/(length(s2)/Fs);%Dividir por el nº de segundos
      %NVP3= periodogram(s3,ones(size(s3)),nump,Fs,'onesided')/(length(s3)/Fs);%Dividir por el nº de segundos
      %NVP4= periodogram(s4,ones(size(s4)),nump,Fs,'onesided')/(length(s4)/Fs);%Dividir por el nº de segundos      
   case 3,%CUIDADO: pburg devuelve la potencia escalada segun la frecuencia que se le da:
      %Por eso hay que hacer P1=pi*pburg(s1,orden,nump), o P1=Fs/2*pburg(s1,orden,nump,Fs)
      %Usar 'onesided' no es necesario pq s1..s4 son reales, lo pongo por seguridad.
      %Para 3 parametros, hay que usar pi: P1 = pi*pburg(s1,orden,nump);
      %VER NOTA AL FINAL!!!!!!!!!!!!!!!!
      P1= pburg(s1,orden,nump,Fs,'onesided')*(Fs/2);
      P2= pburg(s2,orden,nump,Fs,'onesided')*(Fs/2);
      %NVP3= pburg(s3,orden,nump,Fs,'onesided')*(Fs/2);
      %NVP4= pburg(s4,orden,nump,Fs,'onesided')*(Fs/2);
   case 4,
      %Tiene el mismo problema que Burg:
      P1= pmcov(s1,orden,nump,Fs,'onesided')*(Fs/2);
      P2= pmcov(s2,orden,nump,Fs,'onesided')*(Fs/2);
      %NVP3= pmcov(s3,orden,nump,Fs,'onesided')*(Fs/2);
      %NVP4= pmcov(s4,orden,nump,Fs,'onesided')*(Fs/2);
   case 5,%AHORA MISMO NO ESTA ACTIVADO COMO OPCION POSIBLE
       %Algoritmo de Burg con Enventanado(de la energia de los errores):
      %Devuelve siempre un resultado 'onesided' y NO TIENE EL PROBLEMA 
      %de tener que multiplicar por 'pi' ni por 'Fs/2':
      %NVventana='kavehlippert';
      %NVP1= pburgw(s1,orden,nump,ventana,Fs);%Funciona, solo queda comprobar q se introducen bien los parametros en el panel de control
      %NVP2= pburgw(s2,orden,nump,ventana,Fs);
      %NVP3= pburgw(s3,orden,nump,ventana,Fs);
      %NVP4= pburgw(s4,orden,nump,ventana,Fs);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
      %NV  EN ESTE CASO VOY A CALCULAR LA POTENCIA DE LA SEÑAL EN LUGAR DEL
      %ALGORITMO QUE HABIA ANTES.
       
       %NV CALCULO LA POTENCIA MULTIPLICANDO AL CUADRADO CADA MUESTRA, NV LUEGO LO SUMO Y LO 
       %DIVIDO POR EL NUMERO DE MUESTRAS.
      P1=(sum(s1.*s1))/length(s1);
      vector_pot1(ultima_muestra)=P1; %NV VOY CREANDO UN VECTOR CON TODOS LOS VALORES DE POTENCIA CALCULADO EN CADA
                             %NV INSTANTE ini QUE ES LA POSICION DE LA PRIMERA MUESTRA DE VENTANA 
                             %LA QUE SE VA DESPLAZANDO.
      P2=(sum(s2.*s2))/length(s2);
      vector_pot2(ultima_muestra)=P2;
      
      
      
   end;
   %El tamaño de estos vectores es de nump/2+1, porque las señales pasadas son reales   
   %Paso los vectores a formato fila:
   P1y=P1(:)';
   P2y=P2(:)';
   %NVP3y=P3(:)';
   %NVP4y=P4(:)';
   
   f=0:Fs/nump:Fs/2;
   if (ver_f==1) 
       if (potencia_activa==0), %NV AQUI SOLO ENTRA SI NO SE PIDE CALCULAR LA POTENCIA, 
       %QUE ES LO QUE HABIA INICIALMENTE 
      figure(fig_frecuencia);
      clf;  hold on
      set(gcf,'Name', ['Prueba ',num2str(pruebactual) '-Análisis Frecuencial-bloque' num2str(n_de_bloque)] ); %Indica en el membrete de la figure, la prueba en que estamos
      set(gca,'XLim',[0 Fs/2]);
      ylabel('DEP[w/sg]'); 
      xlabel('Frequencia (Hz)');
      title(['Estima de la D.E.P. usando: ' char(cell_metodosEE(metodoEE))]);
      %NV ESTAS 4 INSTRUCCIONES LAS VOY A CAMBIAR DIRECTAMENTE POR DIBUJAR
      %EL CANAL PROCESADO.
      %NV if grabar_c1,   plot(f,P1y,'Color',COLOR_C1);     end;
      %NVif grabar_c2,   plot(f,P2y,'Color',COLOR_C2);     end;
      %NVif grabar_c3,   plot(f,P3y,'Color',COLOR_C3);     end;
      %NVif grabar_c4,   plot(f,P4y,'Color',COLOR_C4);     end;  
      plot(f,P1y,'Color',COLOR_C1);   %NV
      plot(f,P2y,'Color',COLOR_C2);    %NV
      hold off
      
       else %NV AQUI ENTRO SI DEBO REPRESENTAR LA POTENCIA
         figure(fig_frecuencia);
      
         plot([(ini_anterior/Fs) (ultima_muestra /Fs)],[P1_anterior P1],'Color',COLOR_C1); 
         plot([(ini_anterior/Fs) (ultima_muestra /Fs)],[P2_anterior P2],'Color',COLOR_C2); 
         hold on;
         ini_anterior=ultima_muestra ;
         P1_anterior=P1;
         P2_anterior=P2;
          
       end;   
   end;    
   
   %NV figure(fig_sujeto); %Hay que volver a figure(fig_sujeto)
  


%5- En "final1" y "final2" almaceno el resultado de la BURG de todas las ventanas
    %desde el momento en que he empezado a llamar a la funcion
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 
    %NV TODO ESTO DE ASIGNAR RESULTADOS LO VOY A QUITAR. NO CREO QUE SEA NECESARIO
    %GRABAR TODAS ESTAS RESPUESTAS FRECUENCIALES. ADEMAS DE CONSUMIR
    %MEMORIA ME CONSUME TIEMPO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %NVfinal1(indice*nump2+1:(indice+1)*nump2)=P1y;
    %NVfinal2(indice*nump2+1:(indice+1)*nump2)=P2y; 
    %NVfinal3(indice*nump2+1:(indice+1)*nump2)=P3y;
    %NVfinal4(indice*nump2+1:(indice+1)*nump2)=P4y;
    
    %En finaltotal almaceno tdas las respuestas en frec de toda la sesion
    inicialtotal=indicetotalb*nump2+1;
    %NVfinaltotal1(inicialtotal:(indicetotalb+1)*nump2)=P1y; 
    %NVfinaltotal2(inicialtotal:(indicetotalb+1)*nump2)=P2y;
    %NVfinaltotal3(inicialtotal:(indicetotalb+1)*nump2)=P3y; 
    %NVfinaltotal4(inicialtotal:(indicetotalb+1)*nump2)=P4y;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 
    
    
%6- La funcion descursor va a desplazar el cursor. Ademas me va a calcular
    %la media de los valores entre 8 y 12Hz.
    %Jorge quiere que pueda analizarse en cualquier momento, incluso antes 
    %de que aparezca el objetivo, asi que el if que habia antes hay que 
    %modificarlo:
    %if (tiempo1>t_analisis & str2num(tipologia(pruebactual))==6), %Jugar
    %   descursor(P1y,P2y,indice);
    %end;    
    if str2num(tipologia(pruebactual))==6, %(Solo se llama a Descursor si la prueba es tipo JUGAR)
       %Hay que tener en cuenta dos cosas:
       %(1) 'tiempo2frec' se llama solo en el intervalo (t_analisis+tambloque/Fs,t_analisis+d_analisis+retardo)
       %    donde el 'retardo=(tambloque/Fs)/2' se añade para que le de tiempo a coger la última ventana.
       %    [Ver si se quiere Prueba.m]
       %(2) 'tiempo2frec' es el que llama a 'Descursor', asi que 'Descursor' no podrá ejecutarse
       %    si previamente no ha sido llamado 'tiempo2frec'.
       %Podemos encontrarnos dos situaciones:
       %(A) (t_analisis > t_cursor)--> Esta situacion, era considerada en principio la 
       %    única posibilidad.
       %(B) (t_cursor > t_analisis)--> En este caso se comenzara el análisis de la señal
       %    antes incluso de que aparezca el cursor, pero claro no se podrá intentar mover 
       %    el cursor hasta que este no haya aparecido.
       %Asi que el 'if' correcto que cubriria los dos casos(A y B), y teniendo en cuenta (1) y (2), seria:
       if tiempo1>t_cursor,
          %NV descursor4(P1y,P2y,indice);
          
          %NV GRAZ: VOY A HACER UNA FUNCION NUEVA QUE DESPLAZE UNA BARRA EN
          %HORIZONTAL EN FUNCION DEL CLASIFICADOR  Y LAS POTENCIAS DE CADA CANAL.
          indice_dist=indice;
          desp_barra(P1,P2)
          
          
       end;
    else, %Cualquier otro tipo de prueba
       %No se analiza nunca       
    end;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV ESTE TROZO LO QUITO PORQUE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AHORA MISMO NO ES IMPORTANTE
%7- Calcula el valor maximo de BURG en cada ventana y su frecuencia.
    %Para cada ventana, 'vmax' e 'ymax' son los vectores donde se introducen esos datos.
    %Tambien obtenemos la media de esos valores maximos para toda la sesion.
    %Ahora mismo solo está hecho para el C3.
    
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 
    %NV ESTO DE CALCULAR EL MAXIMO DE LA CAMPANA DE BURG TAMPOCO ES
    %NECESARIO AHORA MISMO
    
    %NV[ymax,xmax]=max(P1y);
                           
    %NVvmax(indice+1)=ymax;
    %NVmedvmax=mean(vmax);
    %NVfrecmax(indice+1)=f(xmax);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 

%En tiempoBURG indico el tiempo que se ha tardado en calcular la FFT de cada ventana.
    tiempoBURG(indice+1)=toc-tiniburg(indice+1);
    indice=indice+1; 
    indicetotalb=indicetotalb+1;


%8- Almacenamos los resultados en un fichero:
%Compruebo el número de prueba por el que voy, para almacenar los resultados
%en el fichero correspondiente:
%Se graban los siguientes campos: El nombre del individuo(variable sujeto), el nombre 
%del ensayo(vble ensayo), la frecuencia de muestreo(Fs), la resp en frec(final1..final4)
%de los canales que correspondan en funcion de los que se solicito grabar, su nombre(c1..c4),
%el tipo de prueba(Relajarse, Pensar, Movimiento, u Otro-->esto lo hago a traves de una vble
%que creo en el Panel de control, y que se llama 'tipologia'), el tamaño de la ventana, y el
%orden del metodo de EEP(Estimacion Espectral Parametrica)
   n_tot_bloq_por_prueba= duration * Fs/tam; 
   %  Una vez que 'n_de_bloque' es igual al numero de bloques a adquirir por cada prueba,
   %  lo reseteo. Cuando acabe una prueba, habré guardado 'duration' sg (standar=7sg) usando
   %  ventanas de tam muestras(=10msg a Fs=130Hz(standar)), así que en total tendré:
   %       nºtotal de bloques = duration * Fs/tam = {standar} = 7 * 130/13
   %'objet' existe siempre pq esta declarada como global, lo que hay que hacer es comprobar
   %que no este vacia
   if exist('p','var') & (isempty(objet)==0),
      %Puede ser q se haya empezado el analisis pero todavia no hayan aparecido
      acierto = (get(p,'YData') > 99) & (objet== 1) | ((get(p,'YData') < 1) & (objet == 2));
   else,
      acierto = 0;
   end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ESTE COMANDO LO PONGO POR QUE LO QUE HACE ES DEJAR DE GRABAR LAS MUESTRAS 
%CUANDO SE ALCANZA EL OBJETIVO, Y ESO NO INTERESA (11/07/02) (LO QUE HAGO ES ASIGNAR ACIRTO SIEMPRE A 0)
      acierto=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 
 %NV TODO LO DE ALMACENAR LO VOY A QUITAR. NO CREO QUE SEA NECESARIO
    %GRABAR TODAS ESTAS RESPUESTAS FRECUENCIALES. ADEMAS DE CONSUMIR
    %MEMORIA ME CONSUME TIEMPO.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %NVif (n_de_bloque == n_tot_bloq_por_prueba) | acierto, %Cuando se han capturado todos los bloques de una prueba,
      %(Cuando hay acierto se graba lo que se tenga en ese momento).
      
  
   
      %Grabo la prueba completa:
      %NVcomando=['save ' trayectoria '\rfb' int2str(pruebactual) '.mat sujeto ensayo Fs tam_ventana orden'];
      %NVif grabar_c1, comando=[comando ' final1 c1']; end
      %NVif grabar_c2, comando=[comando ' final2 c2']; end
      %NVif grabar_c3, comando=[comando ' final3 c3']; end
      %NVif grabar_c4, comando=[comando ' final4 c4']; end
      %NVtipo=str2num(tipologia(pruebactual)); %Lo guardare como un numero
      %NVcomando=[comando ' f tipo'];
      %NVeval(comando); %Grabamos un fichero 'rti.mat' por cada prueba
      %NVdisp(['prueba.m: ' num2str(ntot_pru)]) %La sabe pero dice que no
      
      %NVif pruebactual==ntot_pru, 
          
 
         %Grabamos un fichero rtotal.m conteniendo todas las pruebas juntas:
         %NVcomando=['save ' trayectoria '\rfbtotal.mat sujeto ensayo Fs tam_ventana orden'];
         %NVif grabar_c1, comando=[comando ' finaltotal1']; end
         %NVif grabar_c2, comando=[comando ' finaltotal2']; end
         %NVif grabar_c3, comando=[comando ' finaltotal3']; end
         %NVif grabar_c4, comando=[comando ' finaltotal4']; end
         %NVcomando=[comando ' finaltotal1'];  %%%%%%%%%%%%NV
         %NVcomando=[comando ' finaltotal2'];  %%%%%%%%%%%%NV
         %NVcomando=[comando ' finaltotal3'];  %%%%%%%%%%%%NV
         %NVcomando=[comando ' finaltotal4'];  %%%%%%%%%%%%NV
         %NVcomando=[comando ' f tipologia'];
         %NVeval(comando);
      %NVend %if
   %NVend; % if n_de_bloque==n_tot_bloq_por_prueba,
   
   
%Una vez que ese indice iguala al numero total de ventanas a adquirir para hacer su
%estimacion espectral por Burg, lo reseteo para empezar la siguiente prueba o adquisicion:
%NV n_tot_bloq_por_prueba= duration * Fs/tam; %duration=(duracion de la prueba: se define en Ensayo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
  %RESULTA QUE indice ERA IGUAL QUE indicetotalb Y NO SE RESETEABA AL
  %ACABAR UNA PRUEBA. YO CREO QUE ESO ERA UN FAALO DE JUAN, ASI QUE LO VOY
  %A ARREGLAR
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
%DESPEJAR EN LA ECUACION ANTERIOR: ANTES*pi=AHORA*Fs/2 => ANTES= AHORA*Fs/2/pi
%Con PMCOV pasa lo mismo, pero no se puede comprobar con una sinusoide sin ruido
%ya que el metodo se vuelve inestable.





