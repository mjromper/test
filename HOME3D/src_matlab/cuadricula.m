function [activar,limite]=cuadricula()
%CUADRICULA Summary of this function goes here
%   comprobamos cuadricula para dar opciones de navegacion

global cam;
global direccion;
x=cam.position(1,1);
y=cam.position(1,3);
activar=0;
limite=0;
lugar = '';








if ((direccion == 1)||(direccion == -1)||(direccion == 2.5)||(direccion == 1.5)||(direccion == -1.5)||(direccion == -2.5)) %% DIRECCION  +X -X
    
    
                                   
      if ( (x < 49)||(x>182) ) %% extremos 
            activar=1;
            limite=1;
            lugar = 'extremos'
      end,
      if (x == 54) %% cruce pasillo horizontal
            activar=1;
            lugar = 'cruce pasillo horizontal'
      end, 
      
      if (((x == 102)||(x==101.5))&&((y == -1)||(y==0)||(y==-1.5))) %% cruce puerta dormitorio
        activar=1;
            lugar = 'cruce puerta dormitorio'
      end, 
      if ((x == 141)&&(y == -1))  %%puerta baño
        activar=1;
        lugar = 'puerta baño'
      end,  
      if ((x == 82)&&(y>20)&&(y<=70)) %% pared salon sur (interior)
            activar=1;
            limite=1;
             lugar = 'pared salon sur (interior)'
      end, 
      if ((x == 83)&&(y==20)) %% puerta salon (interior)
            activar=1;
             lugar = 'puerta salon (interior)'
            
      end,
      
      if ((x == 60)&&(y>20)&&(y<=70)) %% pared salon sur ( exterior)
            activar=1;
            limite=1;
            lugar = 'pared salon sur ( exterior)'
      end,
      
      if ((x == 61)&&(y==20)) %% puerta salon ((exterior)
            activar=1;
             lugar = 'puerta salon ((exterior)'
      end,
      
      if ((x <= 101)&&(x>=90)) %% pared sur dormitorio
          if (y<-5)
            activar=1;
            limite=1;
            lugar = 'pared sur dormitorio'
          end, 
      end,
      
       if ((x >= 148)&&(x<162)) %% pared norte dormitorio
           if (y<-5)
             activar=1;
             limite=1;
             lugar = 'pared norte dormitorio'
           end, 
       end,
       if ((x <= 165)&&(x>=153)) %% pared sur baño
           if (y<-5)
             activar=1;
             limite=1;
             lugar = 'pared sur baño'
           end, 
       end,
      
       
       
end,
if ((direccion == 2)||(direccion == -2)||(direccion == 2.5)||(direccion == 1.5)||(direccion == -1.5)||(direccion == -2.5)) %% DIRECCION  +Y
     
                                         if ((y>-20)&&(y <= -1))

                                                 %if ((direccion == -2)||(direccion == -2.5)||(direccion == -1.5))

                                                            if (x<101)||((x>102)&&(x<163))   %% puerta dormitorio
                                                                                                                        %% permiso para el baño direccion oeste
                                                                activar=1;
                                                                limite=1;
                                                                lugar = 'puerta dormitorio y permiso para el baño direccion oeste'
                                                          
                                                                
                                                            end,    

                                                 %end,
                                        end,
                                    if ((y>0)&&(y<10))
                                                 if ((direccion == 2)||(direccion == 2.5)||(direccion == 1.5))

                                                            if (x>62)   %% pared derecha del pasillo vertical y baño derecha
                                                                activar = 1;
                                                                limite = 1;
                                                                lugar = 'pared derecha del pasillo vertical y baño derecha'
                                                            end, 

                                                 end,
                                    end,
       if (y == -1) %% cruce pasillo vertical
           activar = 1;
           lugar = 'cruce pasillo vertical'
       end,
      
       
      if ( (y >= 71)&&(y<86)) %% pared este salon
        
            if ((x >82)&&(x <=182 ))
                 activar = 1;
                 limite = 1;
                 lugar = 'pared este salon'
            end;    
      end, 
      
            
      if ( (y == 87)) %% cruce puerta salon 
        activar = 1;
        lugar = 'cruce puerta salon'
      end, 
      if ( (y <= 86)&&(y>70)) %%pared este terraza
        
            if ((x >=82)&&(x <=182 )) 
                limite=1;
                activar=1;
                lugar = 'pared este terraza'
            end;  
     end,
      
      if ( (y <= 19)&&(y>0)) %%pared oeste salon
        
            if ((x >=82)&&(x <=182 )) 
                limite=1;
                activar=1;
                lugar = 'pared oeste salon'
            end;  
      end,
      
      if ( (y == 20)) %% cruce puerta salon 
        activar=1;
        lugar = 'cruce puerta salon'
      end, 
       
      if ( (y>126)||(y<-52)) %% extremos laterales
            activar=1;
            limite=1;
            lugar = 'extremos laterales'
      end,

end,


  

 



 


