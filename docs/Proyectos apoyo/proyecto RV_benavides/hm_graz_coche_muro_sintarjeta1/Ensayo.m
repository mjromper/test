%--------------------------------------------------------------------------
%  Programa: Ensayo
%--------------------------------------------------------------------------
%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad 
%   de Málaga
%--------------------------------------------------------------------------

global pruebactual duration tam; 

global posicion sujeto identificador ensayo num_ensayo fecha prueba1 cantidad1 ...
t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo...
desc_ep_aleat d_descanso Fs tam_ventana;    
global ntot_pru;
global izq der; 
global  bloques_proc_eje_tiempo eje_tiempo;
global bloque_analisis bloque_dur_ana bloque_objetivo bloque_cursor;
global dio manejador_sonido1;

pause(5);  
bloq_seg=Fs/tam_ventana;
bloque_analisis=t_analisis*bloq_seg; 
bloque_dur_ana=d_analisis*bloq_seg;
bloque_objetivo=t_objetivo*bloq_seg; 
bloque_cursor=t_cursor*bloq_seg;


bloques_proc_eje_tiempo=eje_tiempo*Fs/tam_ventana; 

duration= d_prueba;  
tam= tam_ventana; 

pruebactual=0;  

izq=0; 
der=0;

dio=digitalio('parallel','LPT1');
addline(dio,0:3,0,'out'); 

for np=1:ntot_pru,  
    if pruebactual <=ntot_pru,  
       
        Present;
        stop(manejador_sonido1);
        reload(mundovirtual);
            
        pause(desc_ep_fijo + rand*desc_ep_aleat); 
      
    end
   
    np = np + 1; 
end

save ensayo_config.mat posicion sujeto identificador ensayo num_ensayo fecha prueba1 cantidad1 ...
    Fs tam_ventana t_cursor t_objetivo t_analisis d_analisis d_prueba desc_ep_fijo desc_ep_aleat d_descanso ...
    
aviso('FIN DE LA EJECUCIÓN');

%----------------------------------------------------------------------------------------

close all;
%clear all;
                  

