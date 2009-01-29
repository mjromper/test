function ruedaOpciones()
clear;
close;
global player;
global sig;
global camino;
nombre = 'Selección de Navegación';
figureOpciones(nombre);
stop(player);
sig=sig+1

%---------- LINEAS SEPARATORIAS DE LOS QUESITOS ------------------------------------%
separaciones=4;
separa1=360/separaciones;
     
j=-90;
hold on;
color_aspa=[0 0 0];
for bloque=1:separaciones        
       
        x=2*cosd(-(j));   
        y=2*sind(-(j));          
        plot([(x) x*0.8],[(y) y*0.8],'color',color_aspa,'LineWidth',1);
        %plot([0 x],[0 y],'color',color_aspa,'LineWidth',1);
        color_aspa=[1 1 1];
        j=j+separa1;
        
end,     

%---------- OPCIONES DE NAVEGACION   ------------------------------------%
acciones={'Girar','Caminar','Otras','Cancelar'};
                    acciones{1} = [...,
                        'close;',...
                        'clear;',...
                        'ruedaGirar;']; 
                    acciones{2} = [...,
                        'close;',...
                        'clear;',...
                       'ruedaCaminar;']; 
                    acciones{3} = [...,
                        'close;',...                        
                        'clear;',...
                       'ruedaOtros']; 
                    acciones{4} = [...,
                        'close;',...
                        'clear;',...
                       'ruedaOpciones;'];
                   
                                     


% % %----------SIMULACION DE BARRA DE CONCENTRACION---------------------------%
 
color=[0 1 0];
hold on;
concentracion=fix(random('unif',0,separaciones))+1;
%concentracion=camino(sig);
b=-90;
x=1*cosd(-(b));          
y=1*sind(-(b));  
flecha1=plot([0 x*0.8],[0 y*0.8],'color',color,'LineWidth',4,'Visible','on'); % dibujo raya
pause(2);
for bloque=b+1:b+360       
        ampl=random('unif',0.5,2);
        x=ampl*cosd(-(bloque));          
        y=ampl*sind(-(bloque));   
        set(flecha1,'XData',[0 x*0.8],'YData',[0 y*0.8],'color',color,'LineWidth',4); % dibujo raya
        pause(0.1); 
        if (bloque>=(b+concentracion*separa1-separa1/2))
            x=2.5*cosd(-(bloque));          
            y=2.5*sind(-(bloque)); 
            set(flecha1,'XData',[0 x*0.8],'YData',[0 y*0.8],'color',color,'LineWidth',4); % dibujo raya
            break;
        end,
end, 

pause(1);
eval(acciones{concentracion});



