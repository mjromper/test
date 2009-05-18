function goUp(avance)

global textura;
global avion;
global plano;
pausa=0.02;
texturaGiro = 0.002;
avionGiro = 0.01;
avanceRecto = 0.001;
avanceGiro = 0.0008;

for i=0:avance
             
            textura.translation = textura.translation + [avanceGiro 0];
            plano.translation = plano.translation - [0  0 0.05];
            vrdrawnow;
            pause(pausa);
end,  