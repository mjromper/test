function  [pSalida ,oSalida] = saltar(saltos)
%AVANZAR Summary of this function goes here
%   Detailed explanation goes here


global cam;
global direccion;

   
oSalida = cam.orientation;
pSalida = cam.position;


 for x=1:(saltos)

    if (direccion == 1) %% AVANCES DIRECCION +X
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
    elseif (direccion == 1.5)  %% AVANCES DIRECCION -X
       for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)+0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)-0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
        
        
    elseif (direccion == 2)  %%AVANCES DIRECCION +Y
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 

    elseif (direccion == 2.5)  %% AVANCES DIRECCION -X
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)+0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)-0.5 cam.position(1,3)+1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
        
        
    elseif (direccion == -1)  %% AVANCES DIRECCION -X
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
    elseif (direccion == -2.5)  %% AVANCES DIRECCION -X
         for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)+0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)-1 cam.position(1,2)-0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
        


    elseif (direccion == -2)  %% AVANCES DIRECCION -Y
         for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
        
    elseif (direccion == -1.5)  %% AVANCES DIRECCION -X
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)-0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)+0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:10
            cam.position=[cam.position(1,1)+1 cam.position(1,2)-0.5 cam.position(1,3)-1];
            vrdrawnow;
            pause(0.02);
        end, 
        for i=1:5
            cam.position=[cam.position(1,1) cam.position(1,2)+0.5 cam.position(1,3)];
            vrdrawnow;
            pause(0.05);
        end, 
        

    end
 end,    