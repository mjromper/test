function ruedaCaminar()
clear;
close;
nombre = 'Caminar hacia...';
figureCaminar(nombre); % CIRCUNFERENCIAS CONCENTRICAS
global sig;
global camino;
sig=sig+1
%---------- LINEAS SEPARATORIAS DE LOS QUESITOS ------------------------------------%
separaciones=8;
separa1=360/separaciones;
     
j=-separa1/2-90;
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

acciones={'frente','derecha_45','derecha_90','derecha_135','Atras','izquierda_135','izquierda_90','izquierda_45'};

                        acciones{1} = [...,
                        'close;',...    
                        'clear;',...
                        'avanzar(0,30)',...
                        ];                     
                        acciones{2} = [...,
                        'close;',... 
                        'clear;',...
                        'girar(0,45,30);',...
                        ]; 
                        acciones{3} = ['clear;',...
                        'close;',... 
                        'girar(0,90,30);',...
                        ]; 
                        acciones{4} = ['clear;',...
                        'close;',...
                        'girar(0,135,30);',...
                        ]; 
                    
                        acciones{5} = [...
                        'clear;',...
                        'close;',... 
                        'girar(0,180,0);',...
                        ];   
                   acciones{6} = [...
                        'close;',...
                        'clear;',...
                        'girar(1,135,30);',...
                        ]; 
                   acciones{7} = [...
                        'clear;',...
                        'close;',... 
                       'girar(1,90,30);',...
                        ]; 
                   acciones{8} = [...
                        'clear;',...
                        'close;',... 
                        'girar(1,45,30);',...
                        ];  
                   

%----------SIMULACION DE BARRA DE CONCENRACION---------------------------%


color=[0 1 0];
concentracion=fix(random('unif',0,separaciones))+1;
%concentracion=camino(sig);
b=-separa1/2-90;
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
            x=2.4*cosd(-(bloque));          
            y=2.4*sind(-(bloque)); 
            set(flecha1,'XData',[0 x*0.8],'YData',[0 y*0.8],'color',color,'LineWidth',4); % dibujo raya
            break;
        end,
end, 

pause(1);
eval(acciones{concentracion});
