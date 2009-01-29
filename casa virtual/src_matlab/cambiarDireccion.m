function cambiarDireccion(cambio)
%CAMBIARDIRECCION Summary of this function goes here
%   Detailed explanation goes here

global direccion;
% cambio = 0 ---> cambio de direccion a la derecha
% cambio = 1 ---> cambio de direccion a la izquierda
%
if (cambio==0)
    if (direccion == 1)
        direccion=1.5;
    elseif (direccion == 1.5)
        direccion=2;
    elseif (direccion == 2)
        direccion=2.5;
    elseif (direccion == 2.5)
        direccion=-1;
    elseif (direccion == -1)
        direccion=-2.5;
    elseif (direccion == -2.5)
        direccion=-2;
    elseif (direccion == -2)
        direccion=-1.5;
    elseif (direccion == -1.5)
        direccion=1;
    
    end,
elseif (cambio==1)
    if (direccion == 1)
        direccion=-1.5;
    elseif (direccion == -1.5)
        direccion=-2;
    elseif (direccion == -2)
        direccion=-2.5;
    elseif (direccion == -2.5)
        direccion=-1;
    elseif (direccion == -1)
        direccion=2.5;
    elseif (direccion == 2.5)
        direccion=2;
    elseif (direccion == 2)
        direccion=1.5;
    elseif (direccion == 1.5)
        direccion=1;
    
    end,
end,



