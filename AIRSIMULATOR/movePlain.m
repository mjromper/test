function movePlain(lado,avance)


global textura;
global avion;
global plano;
pausa=0.02;
texturaGiro = 0.002;
avionGiro = 0.01;
avanceRecto = 0.001;
avanceGiro = 0.0008;

if (lado=='d') %Girar derecha
    
    for i=0:20+avance
        textura.rotation=textura.rotation-texturaGiro;
        textura.translation = textura.translation + [avanceGiro 0];
        if (i<21)
          avion.rotation = avion.rotation + [avionGiro 0 0 0];
        end,  
        
        vrdrawnow;
        pause(pausa);
       
    end,
    for i=0:20
        textura.rotation=textura.rotation-texturaGiro;
        textura.translation = textura.translation + [avanceGiro 0];
         avion.rotation = avion.rotation - [avionGiro 0 0 0];
        vrdrawnow;
        pause(pausa);
       
    end,
    
elseif (lado=='i') %Girar izquierda
  
    for i=0:20+avance
         textura.rotation=textura.rotation+texturaGiro;
         textura.translation = textura.translation + [avanceGiro 0];
        if (i<21)
         avion.rotation = avion.rotation - [avionGiro 0 0 0];
        end,  
        vrdrawnow;
        pause(pausa);
            
       
    end,
     for i=0:20
         textura.rotation=textura.rotation+texturaGiro;
         textura.translation = textura.translation + [avanceGiro 0];
         avion.rotation = avion.rotation + [avionGiro 0 0 0];
         vrdrawnow;
         pause(pausa);
             
        
     end,
     
else %%   
  
    if (lado == 's')
        for i=0:avance+20
            if (i<21)
                avion.rotation = avion.rotation + [0 avionGiro avionGiro 0];    
            end,    
            textura.translation = textura.translation + [avanceGiro 0];
            plano.translation = plano.translation -[0 0.02 0];
            vrdrawnow;
            pause(pausa);
        end,
         for i=0:20
            avion.rotation = avion.rotation - [0 avionGiro avionGiro 0];    
            textura.translation = textura.translation + [avanceGiro 0];
            plano.translation = plano.translation - [0 0.02 0];
            vrdrawnow;
            pause(pausa);
        end,  
    elseif(lado == 'b')
        for i=0:avance+20
            if (i<21)
                avion.rotation = avion.rotation - [0 avionGiro avionGiro 0];    
            end,                    
            textura.translation = textura.translation + [avanceGiro 0];
            plano.translation = plano.translation + [0 0.02 0];
            vrdrawnow;
            pause(pausa);
        end,  
        
        for i=0:20
            avion.rotation = avion.rotation + [0 avionGiro avionGiro 0];    
            textura.translation = textura.translation + [avanceGiro 0];
            plano.translation = plano.translation + [0 0.02 0];
            vrdrawnow;
            pause(pausa);
        end,  
    end,        
    
    
end,
    







