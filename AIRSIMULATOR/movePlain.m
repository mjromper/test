function movePlain(lado,avance)


global textura;
global avion;
global camara;
pausa=0.02;
texturaGiro = 0.001;
avionGiro = 0.01;
avanceRecto = 0.001;
avanceGiro = 0.0005;

if (lado=='d') %Girar derecha
    
    for i=0:20+avance
        textura.rotation=textura.rotation+texturaGiro;
       %textura.translation = textura.translation + [0 avanceGiro];
        if (i<21)
          %avion.rotation = avion.rotation - [avionGiro avionGiro 0 0];
        end,  
        
        vrdrawnow;
        pause(pausa);
       
    end,
%     for i=0:20
%         textura.rotation=textura.rotation-texturaGiro;
%         textura.translation = textura.translation + [0 2*avanceGiro];
%          avion.rotation = avion.rotation + [avionGiro 0 0 0];
%         vrdrawnow;
%         pause(pausa);
%        
%     end,
    
elseif (lado=='i') %Girar izquierda
  
    for i=0:20+avance
         textura.rotation=textura.rotation+texturaGiro;
         textura.translation = textura.translation + [0 avanceGiro];
        if (i<21)
         avion.rotation = avion.rotation + [avionGiro 0 0 0];
        end,  
        vrdrawnow;
        pause(pausa);
            
       
    end,
     for i=0:20
         textura.rotation=textura.rotation+texturaGiro;
         textura.translation = textura.translation + [0 avanceGiro];
         avion.rotation = avion.rotation - [avionGiro 0 0 0];
         vrdrawnow;
         pause(pausa);
%             
%        
     end,
     
else %%   
  
    if (lado == 's')
        for i=0:avance
            textura.translation = textura.translation + [0 avanceRecto];
            camara.position = camara.position +[0 2 0];
            avion.translation = avion.translation +[0 2 0];
            vrdrawnow;
            pause(pausa);
        end,
    elseif(lado == 'b')
        for i=0:avance
            textura.translation = textura.translation + [0 avanceRecto];
            camara.position = camara.position - [0 2 0];
            avion.translation = avion.translation - [0 2 0];
            vrdrawnow;
            pause(pausa);
        end,  
    end,        
    
    
end,
    







