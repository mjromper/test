function turnPlainL()


global textura;
global avion;
global plano;
pausa=0.02;
texturaGiro = 0.002;
avionGiro = 0.01;
avanceRecto = 0.001;
avanceGiro = 0.0008;

    for i=0:20
        textura.rotation=textura.rotation+texturaGiro;
        textura.translation = textura.translation + [avanceGiro 0];
        avion.rotation = avion.rotation + [avionGiro 0 0 0];
        vrdrawnow;
        pause(pausa);
    
    end,