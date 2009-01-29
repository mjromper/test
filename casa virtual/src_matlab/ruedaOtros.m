function ruedaOtros()
clear;
close;
nombre = 'Otros movimientos...';
global sig;
global camino;
figureOtros(nombre); % CIRCUNFERENCIAS CONCENTRICAS
sig=sig+1
%---------- LINEAS SEPARATORIAS DE LOS QUESITOS ------------------------------------%
separaciones=6;
separa1=360/separaciones;
     
j=-90-separa1/2;
hold on;
color_aspa=[0 0 0];
for bloque=1:separaciones        
       
        x=2*cosd(-(j));   
        y=2*sind(-(j));          
        plot([(x)*0.8 x],[(y)*0.8 y],'color',color_aspa,'LineWidth',1);
        %plot([0 x],[0 y],'color',color_aspa,'LineWidth',1);
        color_aspa=[1 1 1];
        j=j+separa1;
        
end,     

%---------- OPCIONES DE NAVEGACION   ------------------------------------%
acciones={'vueltaIzq','vueltaDer','mirarAbajo','mirarArriba','lateralIzq','lateralDer'};
                    acciones{1} = [...,
                        'close;',...
                        'clear;',...
                        'ruedaOpciones;']; 
                    acciones{2} = [...,
                        'close;',...
                        'clear;',...
                       'lateral(0,30);']; 
                    acciones{3} = [...,
                       'close;',...
                        'clear;',...
                        'ruedaOpciones;']; 
                    acciones{4} = [...,
                        'close;',...
                        'clear;',...
                        'avanzar(1,30);',...
                        'ruedaOpciones;']; 
                   acciones{5} = [...,
                       'close;',...
                        'clear;',...
                        'ruedaOpciones;']; 
                   acciones{6} = [...,
                        'close;',...
                        'clear;',...
                       'lateral(1,30);'];
                   
                                     
              


% % %----------SIMULACION DE BARRA DE CONCENTRACION---------------------------%

 
color=[0 1 0];
concentracion=fix(random('unif',0,separaciones))+1;
%concentracion=camino(sig);
b=-90-separa1/2;
x=1*cosd(-(b));          
y=1*sind(-(b));  
flecha1=plot([0 x*0.8],[0 y*0.8],'color',color,'LineWidth',4); % dibujo raya
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



