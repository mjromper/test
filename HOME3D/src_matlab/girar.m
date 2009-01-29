function  [pSalida ,oSalida] = girar(lado,grados,pasos)
%AVANZAR Summary of this function goes here
%   Detailed explanation goes here
 
% lado = 0 ---> cambio de direccion a la derecha
% lado = 1 ---> cambio de direccion a la izquierda
% grados ---> Numero de grados que hay que girar
% pasos ---> cantidad de pasos que hay que avanzar despues de girar

radianes = grados * pi / 180;
incremento=grados/10*2;
global cam;


    if (grados==45)
        cambiarDireccion(lado);
    elseif (grados == 90)
        cambiarDireccion(lado);
        cambiarDireccion(lado);
    elseif (grados == 135)
        cambiarDireccion(lado);
        cambiarDireccion(lado);
        cambiarDireccion(lado);
    elseif (grados == 180)
        cambiarDireccion(lado);
        cambiarDireccion(lado);
        cambiarDireccion(lado);
        cambiarDireccion(lado);
    end,   
    
if lado == 0   

    for i=1:incremento
        cam.orientation=[cam.orientation(1,1) cam.orientation(1,2) cam.orientation(1,3) cam.orientation(1,4)+radianes/incremento];
        
        vrdrawnow;
        pause(0.05);
    end
 
elseif lado == 1
   
      for i=1:incremento
        cam.orientation=[cam.orientation(1,1) cam.orientation(1,2) cam.orientation(1,3) cam.orientation(1,4)-radianes/incremento];
       
        vrdrawnow;
        pause(0.05);
      end
end,    
    

[pSalida ,oSalida]= avanzar(0,pasos);
    
    

    


