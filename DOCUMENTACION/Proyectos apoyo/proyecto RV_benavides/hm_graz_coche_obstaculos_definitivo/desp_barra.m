%--------------------------------------------------------------------------
% PROGRAMA: barra_lda
%--------------------------------------------------------------------------
% Francisco Benavides Martín, Mayo de 2007
%Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad de
%Málaga
%--------------------------------------------------------------------------
function barra_lda(pot1,pot2)

global fig_sujeto p pruebactual indice_dist dist_barra wo w1 w2
%NV (Paco) Para manejar el mundo virtual
global i linea arbol coche vision_coche coche_roto alzamiento;
global obstaculocharco charco charco1 posicion_charco;
global obstaculomuro muro muro1 posicion_muro colision salto;
global obstaculorampa rampa rampa1 posicion_rampa;
%NV (Paco) Variables de control para observar el tiempo de ejecucion del
%mundo virtual.
global tiempoactuanalisis tiempollamanalisis boton_Ninguno;
%NV (Paco).
global manejador_sonido1 manejador_sonido2;
persistent dist_der dist_izq;
%Introduzco los valores de los pesos obtenidos en gBSanalyze
%%%wo=0.420375; w1=0.290865; w2=-0.190795; 
%pesos mios para t=5.5
%%%%wo=-0.425202;   w1=-3.870791;   w2=10.885142;
%wo=0.280976; w1=-6.443965; w2=3.045529;  %BERNAL
%wo=-0.059974; w1=6.590245; w2=3.610665;  %MORENO
%wo=0.090074; w1=-1.766186; w2=-3.191553;  %ROMERO
 %wo=-0.090074;   w1=-1.766186;   w2=-3.191553;
%wo=0.042635; w1=-27.304587; w2=25.465340; % Cañada
%wo=-0.367104; w1=-4.939138; w2=31.742783; % GAGO
%wo=0.050559; w1=-1.490268; w2=0.951600; % CANO
%wo=0.054334; w1=11.15640; w2=-16.153375; % SANTAELLA
%wo=0.006006; w1=-5.574153; w2=2.906307;  %BAUDET
%wo=-0.027089; w1=-9.714888; w2=11.981482;   %LOPEZ
%wo=-0.280413; w1=-0.087064; w2=24.998425;   %MONAS
wo=0.280413; w1=0.087064; w2=24.998425;   %MONAS

Factor_der=100;
Factor_izq=100;
Cte_der=1;
Cte_izq=1;
%acierto=0;
%fallo=0;
indice_dist;
%preparo la figura del sujeto
 
 %switch indice_dist;
  %  case 0, dist=0; case 1, dist=0.5; case 2, dist=1; case 3, dist=1.5; case 4, dist=2; case 5, dist=2.5; case 6, dist=3;
  %  case 7, dist=2.5; case 8, dist=2; case 9, dist=1.5; case 10, dist=1; case 11, dist=0.5; case 12, dist=0; case 13, dist=-0.5;
  %  case 14, dist=-1; case 15, dist=-1.5; case 16, dist=-2; case 17, dist=-2.5; case 18, dist=-3; case 19, dist=-2.5; case 20, dist=-2;
  %  case 21, dist=-1.5; case 22, dist=-1; case 23, dist=-0.5; case 24, dist=0; case 25, dist=0.5; case 26, dist=1; case 27, dist=1.5;
  %  case 28, dist=2; case 29, dist=2.5; otherwise, dist=2.5;
 %end 
 
 %NV (Paco) Variable encargado de almacenar el tiempo en el que llega a
 %este punto.
 tiempollamanalisis(indice_dist+1)=toc;
 
 if (colision==0)
    for n_frames=1:2 %se realizan dos frames para que se vea la imagen de forma continua
        if (mod(i,20)~=0)
            linea.translation=[linea.translation(1:(length(linea.translation)-1)) mod(i,20)];
            arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) mod(i,20)];
        else
            linea.translation=[linea.translation(1:(length(linea.translation)-1)) 20];
            arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) 20];
        end
    
     if (boton_Ninguno==0)  
        % Actualización del charco derecho en la fase de análisis.
        if (obstaculocharco.whichChoice==0)
            posicion_charco=posicion_charco+1; %Para que desaparezca el charco completamente
            charco.translation=[charco.translation(1:(length(charco.translation)-1)) posicion_charco];           
        end
        %Actualización del charco izquierdo en al fase de análisis.
        if (obstaculocharco.whichChoice==1)
            posicion_charco=posicion_charco+1; %Para que desaparezca el charco completamente
            charco1.translation=[charco1.translation(1:(length(charco.translation)-1)) posicion_charco];
        end
        if (obstaculomuro.whichChoice==0)
            posicion_muro=posicion_muro+1;
            muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
        end
        if (obstaculomuro.whichChoice==1)
            posicion_muro=posicion_muro+1;
            muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
        end
        if (obstaculorampa.whichChoice==0)
            posicion_rampa=posicion_rampa+1;
            rampa.translation=[rampa.translation(1:(length(rampa.translation)-1)) posicion_rampa];
        end
        if (obstaculorampa.whichChoice==1)
            posicion_rampa=posicion_rampa+1;
            rampa1.translation=[rampa1.translation(1:(length(rampa1.translation)-1)) posicion_rampa];
        end
     end
        
        i=i+1;
        vrdrawnow;
    end
 end
 tiempoactuanalisis(indice_dist+1)=toc;

%pot1
    dist=pot1*w1+pot2*w2+wo;
    %%%%dist=50/toc;
    
    %He quitado temporalmente esto no olvidar (PACO)
    %dist=20*(pot1*w1+pot2*w2+wo); %modificada dia 19/5/03 a 17:15 pm !!! OJO
    
    dist_barra(pruebactual,indice_dist+1)=dist; %Variable que almacena los valores de la barra
 
%NV (Paco)Obtiene la posición del coche en el semieje positivo de la escena virtual.
if (dist>0)
    dist_der=dist*Factor_der*Cte_der;
    if (dist_der>3)
        dist_der=3;
    end
end
%NV (Paco)Obtiene la posición del coche en el semieje negativo de la escena virtual.
if (dist<0)
    dist_izq=dist*Factor_izq*Cte_izq;
    if (dist_izq<-3)
        dist_izq=-3;
    end
end
if (posicion_muro<2.5)
    %NV (Paco) Realiza el desplazamiento del coche
    if (dist>0)
        coche.translation=[dist_der coche.translation(2:(length(coche.translation)))];
    else
        coche.translation=[dist_izq coche.translation(2:(length(coche.translation)))];
    end
end

%NV (Paco) Ahora misms no hace mucho porque el muro es fijo al final del
%charco. Cuando sea movil tendrá más sentido. En estos momentos, solo sirve
%para que al final quede parado.
    if (posicion_muro==2.5)
        if (obstaculomuro.whichChoice==0)&(dist_der>1)&(dist_der<=3)
            colision=1; %Se detiene la actualización del mundo virtual
            alzamiento=-3*sin(2*pi*5/360); %Hay que desplazar el coche en el
            %sentido negativo del eje Y, para que el coche quede a ras de suelo.
            coche_roto.translation=[dist_der alzamiento coche_roto.translation(3)];
            coche_roto.rotation=[1 0 0 -2*pi*5/360]; %Se roto con respecto al eje X 
            %5 grados, pero expresado en radianes.
            %coche_roto.translation=[dist coche_roto.translation(2:length(coche_roto.translation))];
            %Se ubica el coche roto en la posición del anterior.
            vision_coche.whichChoice=0;%Conmuta la imagen habitual del
            %coche de después de la colisión.
            stop(manejador_sonido1);%Para el sonido del motor del coche.
            play(manejador_sonido2);%Reproduce el sonido de la colisión.
        end
        if (obstaculomuro.whichChoice==1)&(dist_izq<-1)&(dist_izq>=-3)
            colision=1; %Se detiene la actualización del mundo virtual
            alzamiento=-3*sin(2*pi*5/360); %Hay que desplazar el coche en el
            %sentido negativo del eje Y, para que el coche quede a ras de suelo.
            coche_roto.translation=[dist_izq alzamiento coche_roto.translation(3)];
            coche_roto.rotation=[1 0 0 -2*pi*5/360]; %Se roto con respecto al eje X 
            %5 grados, pero expresado en radianes.
            %coche_roto.translation=[dist coche_roto.translation(2:length(coche_roto.translation))];
            %Se ubica el coche roto en la posición del anterior.
            vision_coche.whichChoice=0;% Muestra la imagen del coche
            %colisionado.
            stop(manejador_sonido1);%Para el sonido del motor del coche.
            play(manejador_sonido2);%Reproduce el sonido de la colisión.
        end
    end
%NV (Paco) Ahora mismos no hace mucho porque la rampa es fija al final del
%charco. Cuando sea movil tendrá más sentido. En estos momentos, solo sirve
%para que el usuario tenga una motivación al final de la simulación.
    if (posicion_rampa==-1.5)
        if (obstaculorampa.whichChoice==0)&(dist_der>0.8)&(dist_der<=3)
            salto=1; %Permite al coche que realice la maniobra de salto.
            coche.translation=[2.5 coche.translation(2:length(coche.translation))];
            %Se coloca el coche en el centro de la rampa para que salte
            %correctamente.Esa posición es 2.5 en el semieje positivo X.
        end
        if (obstaculorampa.whichChoice==1)&(dist_izq<-0.8)&(dist_izq>=-3)
            salto=1; %Permite al coche que inicie la maniobra 
            %correspondiente al salto de la rampa.
            coche.translation=[-2.5 coche.translation(2:length(coche.translation))];
            %Se coloca el coche en el centro de la rampa para que salte
            %correctamente. Es -2.5.
        end
    end
    if indice_dist==119
     tempp=toc
     %posicion_rampa
    end
    %d(i)=dist;
    %if (dist>0 & clase(i)==1) | (dist<0 & clase(i)==0)  %foot or right
    %    acierto=acierto+1;
    %else 
    %    fallo =fallo +1;
    %end
   % figure(fig_sujeto)
    %axis([-20 20 -20 20]);
    %hold on
  
    %set(p,'XData',[0 dist],'YData',[0 0],'color',[0 0 1],'LineWidth',6);
   
    %pause
    %hold off
    %p=plot([0 0],[0 0],'color',color_fondo)
    
    %save estadis.mat acierto fallo