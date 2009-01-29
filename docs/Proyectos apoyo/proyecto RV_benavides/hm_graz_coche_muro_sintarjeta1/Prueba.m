%--------------------------------------------------------------------------
%  Programa: Prueba (function Prueba)
%--------------------------------------------------------------------------
%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad 
%   de Málaga
%--------------------------------------------------------------------------


function prueba(tambloque)%(obj, event, tambloque)

global linea arbol; 
global obstaculomuro muro muro1;
global coche coche_roto vision_coche;
global tiempo1 objet;
global ntot_pru pruebactual Fs duration; 
global izq der muro_der_izq t_muro pulsacion pulso trayectoria; 
global inst_muro inst_tecla dif_tiempo;
global tiempollamada tiempoactualizacion tecla dist movido valor;
global dio;
global i posicion_muro bloque_posicion;  
global n_de_bloque colision tipo_obstaculo;

global manejador_sonido1 manejador_sonido2;
persistent n_de_bloque_tot;
persistent aparece bloques_aparece;

global bloque_objetivo bloque_cursor; 

tiempo1=toc;  

figure(2); 

if isempty(n_de_bloque),
   n_de_bloque=0; 
   i=0;				
   colision=0; 
   dist=0;
end
if isempty(n_de_bloque_tot),  
   n_de_bloque_tot=0; 
end
   
if (n_de_bloque==0)
    
  
   if rand<0.5,  
       if izq<ntot_pru/2  
          izq=izq+1;
          
          if (tipo_obstaculo==1)  
              muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
          else
              muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
          end
               
          aparece=bloque_objetivo;
          objet=2;  
          
       else 
           der=der+1;
           
           if (tipo_obstaculo==1) 
               muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
           else
               muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
           end
                
           aparece=bloque_cursor;
           objet=1; 
        
       end    
          
   else  
       if der<ntot_pru/2
          der=der+1;
         
          if (tipo_obstaculo==1)  
              muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
          else
              muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
          end
               
          aparece=bloque_cursor;
          objet=1; 
             
       else
          izq=izq+1;
          
          if (tipo_obstaculo==1)  
              muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
          else
              muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
          end
                
          aparece=bloque_objetivo;
          objet=2; 
             
       end
   end
   
   if ((bloque_posicion-aparece)<=0)
        bloques_aparece=0;
   else
        bloques_aparece=bloque_posicion-aparece-1;
   end
    
end  


tiempollamada(n_de_bloque+1)=tiempo1;

if (colision==0)
 for n_frames=1:2*valor 
    
     if (mod(i,20)~=0)
       linea.translation=[linea.translation(1:(length(linea.translation)-1)) mod(i,20)];
       arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) mod(i,20)];
     else
       linea.translation=[linea.translation(1:(length(linea.translation)-1)) 20];
       arbol.translation=[arbol.translation(1:(length(linea.translation)-1)) 20];
     end
      
     if (n_de_bloque==(bloques_aparece))
        if (tipo_obstaculo==0)
             obstaculomuro.whichChoice=0;
             inst_muro=toc;
        else
             obstaculomuro.whichChoice=1;
             inst_muro=toc;
        end
        
        if (objet==1)
             putvalue(dio.Line(1),1);
             t_muro(pruebactual)=0;
        else
             putvalue(dio.Line(2),1);
             t_muro(pruebactual)=1;
        end
        
        bloques_aparece=bloques_aparece-1;
     end 
        
     if (tipo_obstaculo==0)
        posicion_muro=posicion_muro+1;
        muro.translation=[muro.translation(1:(length(muro.translation)-1)) posicion_muro];
     end
     
     if (tipo_obstaculo==1)
        posicion_muro=posicion_muro+1;
        muro1.translation=[muro1.translation(1:(length(muro1.translation)-1)) posicion_muro];
     end
        
    i=i+1;
    
    if (movido==0)
        if (tecla=='r')&(dist==0)
            dist=2.5;
            movido=1;
        end
        if (tecla=='r')&(dist==-2.5)
            dist=0;
            movido=1;
        end
        if (tecla=='l')&(dist==0)
            dist=-2.5;
            movido=1;
        end
        if (tecla=='l')&(dist==2.5)
            dist=0;
            movido=1;
        end
    end    
    coche.translation=[dist coche.translation(2:(length(coche.translation)))];

    if (posicion_muro==2.5)
        if (obstaculomuro.whichChoice==0)&(dist>=0)&(dist<=3)
            colision=1; 
            coche_roto.translation=[dist coche_roto.translation(2:length(coche_roto.translation))];
            vision_coche.whichChoice=0;
            stop(manejador_sonido1);
            play(manejador_sonido2);
        end
        if (obstaculomuro.whichChoice==1)&(dist<=0)&(dist>=-3)
            colision=1; 
            coche_roto.translation=[dist coche_roto.translation(2:length(coche_roto.translation))];
            vision_coche.whichChoice=0;
            stop(manejador_sonido1);
            play(manejador_sonido2);
        end
    end
    
    vrdrawnow;
 end
else
    pause(0.018);
end

 tiempoactualizacion(n_de_bloque+1)=toc;

 n_de_bloque = n_de_bloque + 1; 
 n_de_bloque_tot = n_de_bloque_tot+1; 
   

n_tot_bloq_por_prueba= duration * Fs/tambloque;

if n_de_bloque == n_tot_bloq_por_prueba,      
    
      n_de_bloque=0;
      colision=0;
      i=0;
      dist=0;
      tecla='u';
      pulso=0;
      dif_tiempo(pruebactual)=inst_tecla-inst_muro;
      
      if pruebactual==ntot_pru, 
         
         comando1=['save ' trayectoria '\clase_muro.mat muro_der_izq t_muro'];
         eval(comando1);
         comando1=['save ' trayectoria '\clase_teclado.mat pulsacion dif_tiempo inst_tecla inst_muro'];
         eval(comando1);
        
      end

end
   
   
   
   