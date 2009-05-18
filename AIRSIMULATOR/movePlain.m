function movePlain(lado,avance)


global textura;
global avion;
global plano;
pausa=0.02;
texturaGiro = 0.002;
avionGiro = 0.01;
avanceRecto = 0.001;
avanceGiro = 0.0008;

if (lado=='i') %Girar derecha
    
    turnPlainL();
    goLeft(avance);
    turnPlainL2R();
    
elseif (lado=='d') %Girar izquierda
    turnPlainR();
    goRight(avance);
    turnPlainR2L();
     
else %%   
  
    if (lado == 'b')
        turnPlainD();
        goDown(avance);
        turnPlainD2U();
    elseif(lado == 's')
       turnPlainU();
       goUp(avance);
       turnPlainU2D();
    end,        
    
    
end,
    







