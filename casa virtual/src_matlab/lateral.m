function  [pSalida ,oSalida] = lateral(lado,pasos)
%AVANZAR Summary of this function goes here
%   Detailed explanation goes here


 if lado == 0  
     
    cambiarDireccion(0);
    cambiarDireccion(0);
    [pSalida ,oSalida] = avanzar(0,pasos);
    cambiarDireccion(1);
    cambiarDireccion(1);
    
 elseif lado == 1
     
    cambiarDireccion(1);
    cambiarDireccion(1);
    [pSalida ,oSalida] = avanzar(0,pasos);
    cambiarDireccion(0);
    cambiarDireccion(0);
 end,   