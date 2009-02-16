function movePlain(lado)


global textura;
global avion;

x=0.001;

if (lado==0)
    %Girar derecha
    for i=0:20
        textura.translation = [textura.translation(1)+x textura.translation(2)+x];
        avion.rotation=[avion.rotation(1)-0.01 avion.rotation(2) avion.rotation(3) avion.rotation(4)];
        vrdrawnow;
       
    end,
    for i=0:0.001:0.2   
        textura.translation = [textura.translation(1)+x textura.translation(2)+x];
        vrdrawnow;
       
    end,   
    for i=0:20
        textura.translation = [textura.translation(1)+x textura.translation(2)+x];
        avion.rotation=[avion.rotation(1)+0.01 avion.rotation(2) avion.rotation(3) avion.rotation(4)];
        vrdrawnow;
      
    end,

elseif (lado==1)

    %Girar izquierda
    for i=0:20
        textura.translation = [textura.translation(1)-x textura.translation(2)+x];
        avion.rotation=[avion.rotation(1)+0.01 avion.rotation(2) avion.rotation(3) avion.rotation(4)];
        vrdrawnow;
       
    end,
    for i=0:0.001:0.2
        textura.translation = [textura.translation(1)-x textura.translation(2)+x];
        vrdrawnow;
       
    end,  
    for i=0:20
        textura.translation = [textura.translation(1)-x textura.translation(2)+x];
        avion.rotation=[avion.rotation(1)-0.01 avion.rotation(2) avion.rotation(3) avion.rotation(4)];
        vrdrawnow;
       
    end,
    
else
    
    %Avanzar
    for i=0:0.001:0.2
        textura.translation = [0 textura.translation(2)+x];
        vrdrawnow;
        pause(0.02);
    end,  
    
end,
    







