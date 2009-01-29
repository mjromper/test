%--------------------------------------------------------------------------
%  Programa: Medir (function Medir)
%--------------------------------------------------------------------------
%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad 
%   de Málaga
%--------------------------------------------------------------------------


function Medir 

global Fs duration tam pruebactual;%A1
global posicion_muro muro_der_izq; 
global bloque_dur_ana tipo_obstaculo bloque_posicion; 
global valor dio;
global manejador_sonido1;
     
global actualiza actualiza1;

                                 
n_tot_bloq_por_prueba=Fs*duration/tam;
  
valor=(128/4)*(tam/Fs);

bloque_posicion=fix(bloque_dur_ana*rand)+1;

posicion_muro=2.5-2*valor*(bloque_posicion);

tipo_obstaculo=fix(2*rand); 

muro_der_izq(pruebactual)=tipo_obstaculo; 

putvalue(dio,0);

tic;                 
tiempo_inicial=toc;

play(manejador_sonido1);

for i=1:n_tot_bloq_por_prueba
    t=clock;
    Prueba(tam);
    z=etime(clock,t);
    %if (z>=0.02)&(z<0.025)
    %    pause(0.01);
    %end
    %if (z<0.02)
    %    pause(0.015)
    %end
    if (z<=0.016)
        pause(0.015);
    end
    %l=etime(clock,t);
    actualiza(i)=z;
    %actualiza1(i)=l;
end           
   
tiempo_adquisicion=toc  



