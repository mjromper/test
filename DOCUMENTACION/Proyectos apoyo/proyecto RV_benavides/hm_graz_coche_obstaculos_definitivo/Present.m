%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%
%  Programa: Present
%
%Es el encargado de realizar los últimos ajustes en las distintas figuras que hay 
%abiertas antes de llamar al programa Medir. Además una vez terminado éste, si la 
%prueba era de tipo jugar y hubo acierto hace el parpadeo correspondiente usando 
%el programa Parpadeo.
%
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> PRESENT --> Medir --> Prueba --> tiempo2frec --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%Vea también: HMPanel, Ensayo, ..., ModelarFiltros, ...

%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad de Málaga
%------------------------------------------------------------------------------------

%function present
global fig_sujeto fig_tiempo;
global color_dibujos color_fondo;
global COLOR_C1 COLOR_C2 COLOR_C3 COLOR_C4;
global p q pruebactual exito exitoar exitoab fallo objet ntot_pru h cuenta; %Vbles. de Ricardo
global t_cursor t_objetivo t_analisis d_analisis d_prueba tipologia grabar_c1 grabar_c2 grabar_c3 grabar_c4 c1 c2 c3 c4; %Vbles. de Juan

global metodoEE potencia_activa %NV
global ver_f ver_t%NV
global fig_frecuencia no_portatil%NV
    %p y q son las variables del plot del cursor y rectangulo
    %En pruebactual indico el numero de la prueba, y lo voy a utilizar para almacenar 
    % los resultados en diferentes ficheros.
   
    %objet viene de respf2 y es una variable que indica si el rectangulo está
    %  arriba(1) ó abajo(2)
    
%1º-  Abro una figura sin barra de menú ni nº de fig
  %CREO QUE ESTO NO HACE FALTA: GRAZ
     %figure(fig_sujeto); %Trabajaremos en la figura 3, a la que nos referiremos por la variable h
     %set(gcf,'MenuBar','none','NumberTitle','off'); %Quita barra de menú y deja el nº de Fig
     %whitebg('k');

%2- incremento en una unidad el numero de la prueba. 
    pruebactual=pruebactual+1
   
    %Preparacion de la ventana de analisis temporal
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV 
    %CAMBIO EL FORMATO DE LA FIGURA A TODA LA PANTALLA SI LO QUE VOY A VISUALIZAR 
    % ES SOLO LA RESPUESTA TEMPORAL. ES PARA VERSE MEJOR.
   
       if (ver_f==0) & (ver_t==1)
        figure(fig_tiempo); %FIGURA DEL DOMINIO DEL TIEMPO(Para representar la señal)
        set(gcf,'NumberTitle','off',... %La posición se esta dando en pixels
       'units','norm',...
        'menubar','none',...
       'Name','Señal en el tiempo e instrucciones para el monitor','Position',[0 0 1 1]);
  
  end;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV
     
     %figure(fig_frecuencia); %NV
     %hold off; %NV
if no_portatil     
    figure(fig_tiempo);  %Ventana de info adicional+dom. del tiempo del monitor del experimento
    hold off; %Tras cada prueba debemos borrar la figura  
    %set(gca,'Xlim',[0 d_prueba]);%Usando esto, al pasar a la prueba 2, se lian los limites horizontales(YLim)
    plot(0,0,'k');   plot(d_prueba,0,'k');
    hold on;
    %set(gcf,'EraseMode','Xor'); <<<<<---intento que esto funcione de alguna manera
   
      plot([t_cursor t_cursor],[-6 6],'y:');text(t_cursor,5.4,'Cursor');
      plot([t_objetivo t_objetivo],[-6 6],'y:');text(t_objetivo,5.4,'Objetivo');
      plot([t_analisis t_analisis],[-6 6],'y:');text(t_analisis,5.4,'Inicio Análisis');
      plot([t_analisis+d_analisis t_analisis+d_analisis],[-6 6],'y:');text(t_analisis+d_analisis,5.4,'Fin Análisis');
  
      
    xlabel('tiempo[sg]');   ylabel('amplitud');
    cabecera=['Prueba ',num2str(pruebactual)];
    leyenda=[]; trazo=[];
    if grabar_c1,  p1=plot(0,0,'Color',COLOR_C1); trazo=[trazo p1]; leyenda =strvcat(leyenda,c1); end; %Vamos a grabar solo los canales que se pida grabar
    if grabar_c2,  p2=plot(0,0,'Color',COLOR_C2); trazo=[trazo p2]; leyenda =strvcat(leyenda,c2); end;
    if grabar_c3,  p3=plot(0,0,'Color',COLOR_C3); trazo=[trazo p3]; leyenda =strvcat(leyenda,c3); end;
    if grabar_c4,  p4=plot(0,0,'Color',COLOR_C4); trazo=[trazo p4]; leyenda =strvcat(leyenda,c4); end;
    plot(0,0,'k'); %Para borrar el posible punto de color que hayan hecho los plot anteriores
    legend(trazo,leyenda,3);%Con '-1' la pone fuera, ver help legend
    
    %--------------------------------------fin de la preparacion
    cell_tipos={'No-feed' 'Feed-disc' 'Mover' 'Otro' 'Entrenar' 'Feed_cont'};
    tipo=str2num(tipologia(pruebactual));
    cabecera = [cabecera ' -' upper(char(cell_tipos(tipo)))];%Aqui estan guardados los tipos de prueba.
    
    set(gcf,'Name',cabecera); %Indica la prueba en que estamos

end;   %if no_portatil  

    
    %NV DESDE ESTA LINEA HASTA EL else ES NUEVO, Y ES PARA CAMBIAR LA
    %CONFIGURACION DE LA FIGURA CUANDO SELECCIONO LA REPRESENTACION DE LA
    %POTENCIA EN LA QUE ANTES ERA LA FIGURA DE LA RESPUESTA EN FRECUENCIA
     
    switch metodoEE,
       
        case 5          
            potencia_activa=1;
        end;
   
        if potencia_activa==1 & ver_f, 
         figure(fig_frecuencia)
         hold off; %Tras cada prueba debemos borrar la figura  
        plot([0 t_analisis+d_analisis],[-1 1],'Color','k')   
        set(gcf,'MenuBar','none','NumberTitle','off',... %La posición se esta dando en pixels
       'units','norm',...
       'Name','Análisis Frecuencial','Position',[0 .04 1 .45]);
        ylabel('Potencia(uV2)'); %(PSD Estimates)
        xlabel('Tiempo(seg)');
        title(['Calculo de la Potencia']);
        hold on;
        plot([0 t_analisis+d_analisis],[-1 1],'Color','k')
      end;
    %NV HASTA AQUI ES LO QUE INTRODUZCO 
    
    
    
   
   %  figure(fig_sujeto);  %Volvemos a la ventana del sujeto
    % hold off; %Tras cada prueba debemos borrar la figura; Unas lineas mas alante se hace el hold on
 
%3- Dibujar los ejes de la pantalla del sujeto:
%   Dibujo el cursor en medio de la pantalla, y le doy color negro para que no se vea
%   todavia(creo que esas dos lineas podrian borrarse):

   %p=plot([0 0],[0 0],'EraseMode','Xor','color',color_fondo,'LineWidth',6);
  % p=plot([0 0],[0 0],'color',color_fondo,'LineWidth',6);
   %axis ([-20 20 -20 20]); %Dibujo unos ejes
   %set(gca,'XColor',[0 0 0],'YColor',[0 0 0])   
   %hold on; 

   %NV p=plot(20,50,'EraseMode','Xor','LineStyle','none','Marker','square','MarkerSize',15);
   %NV set(gca,'Color',color_fondo,'XColor',color_dibujos,'YColor',color_dibujos)
   %NV set(p,'MarkerEdgeColor',color_fondo,'MarkerFaceColor',color_fondo);%Hago invisible el cursor(ANTES COLOR color_dibujos)
   %NV hold on; 
   %NV axis([0 40 0 100]); %Dibujo unos ejes
   
     
%4- Se llama la funcion que muestrea los datos. Cuado acabe la duracion de la prueba,
%   se devuelve el control a este punto del programa y se obverva si hay éxito o no:

    cuenta=0; %%%(INTRODUCIDO EL 12/4/02) SE UTILIZA EN DESCURSOR4
	Medir; 

%5- Comprobamos si ha habido exito:
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV

   %NV if ((get(p,'YData') > 99) & (objet== 1)) 
   %NV    exitoar=exitoar+1; %exito hacia arriba
   %NV    exito=exito + 1;
  %NV     parpadeo(q) %Llama a la función parpadeo que hace parpadear el cuadrado
      %disp('Entro en parpadeo del programa present.m, linea 76');
  %NV elseif ((get(p,'YData') < 1) & (objet == 2))
  %NV     exitoab=exitoab+1;  %exito hacia abajo
   %NV    exito=exito + 1;
   %NV    parpadeo(q) %Llama a la función parpadeo que hace parpadear el cuadrado
      %disp('Entro en parpadeo del programa present.m, linea 76');
  %NV  else,
   %NV    fallo =fallo + 1;% no se ha alcanzado el objetivo  
  %NV  end, %if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NV HASTA AQUI LO ANTIGUO, 
   
   
  
   
   
%6- Vuelvo a dejar la pantalla en negro para que el pause de espera sea de este color 
%Si quiero que el rectangulo siga 1 segundo despues de que desaparezca el cursor y
% antes de que la pantalla se ponga en negro, debo dejar las 3 lineas que vienen a 
% continuacion.

 %figure(fig_sujeto)
 %hold off
 %plot([0 0],[0 0],'EraseMode','Xor','color',color_fondo,'LineWidth',6)
%axis ([-20 20 -20 20]); %Dibujo unos ejes
 %  set(gca,'XColor',[0 0 0],'YColor',[0 0 0])   
  
 


