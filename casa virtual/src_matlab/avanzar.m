function  [pSalida ,oSalida] = avanzar(retroceder, pasos)
%AVANZAR Summary of this function goes here
%   Detailed explanation goes here

% pasos ---> cantidad de pasos que hay que avanzar despues de girar
% retrocer ---> indica si el avance hay que hacer restando, esto es
%               retroceder, ir de espaldas

global cam; %%camara
global yo;  %%yo
global direccion; %%direccion 
global player;


if pasos > 0

    if retroceder == 1; 
        for i=1:4  
            cambiarDireccion(0); 
        end,
    end,
   
    play(player);

    if (direccion == 1) %% AVANCES DIRECCION +X
        for i=1:(pasos)


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)+1 cam.position(1,2) cam.position(1,3)];
            yo.translation=[yo.translation(1,1)+1 yo.translation(1,2) yo.translation(1,3)];
            vrdrawnow;
            pause(0.05);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,1);
                end,
                
                break;
            end,


        end
    elseif (direccion == 1.5)  %% AVANCES DIRECCION -X
        for i=1:2*(pasos)


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)+0.5 cam.position(1,2) cam.position(1,3)+0.5];
            yo.translation=[yo.translation(1,1)+0.5 yo.translation(1,2) yo.translation(1,3)+0.5];
            vrdrawnow;
            pause(0.025);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,0.5);
                end,
                
                break;
            end,


        end
    elseif (direccion == 2)  %%AVANCES DIRECCION +Y
        for i=1:pasos


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1) cam.position(1,2) cam.position(1,3)+1];
            yo.translation=[yo.translation(1,1) yo.translation(1,2) yo.translation(1,3)+1];
            vrdrawnow;
            pause(0.05);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,1);
                end,
                
                break;
            end,


        end
    elseif (direccion == 2.5)  %% AVANCES DIRECCION -X
        for i=1:2*(pasos)


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)-0.5 cam.position(1,2) cam.position(1,3)+0.5];
            yo.translation=[yo.translation(1,1)-0.5 yo.translation(1,2) yo.translation(1,3)+0.5];
            vrdrawnow;
            pause(0.025);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                   avanzar(1,0.5);
                end,
               
                break;
            end,


        end

    elseif (direccion == -1)  %% AVANCES DIRECCION -X
        for i=1:pasos


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)-1 cam.position(1,2) cam.position(1,3)];
            yo.translation=[yo.translation(1,1)-1 yo.translation(1,2) yo.translation(1,3)];
            vrdrawnow;
            pause(0.05);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,1);
                end,
                
                break;
            end,



        end
    elseif (direccion == -2.5)  %% AVANCES DIRECCION -X
        for i=1:2*(pasos)


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)-0.5 cam.position(1,2) cam.position(1,3)-0.5];
            yo.translation=[yo.translation(1,1)-0.5 yo.translation(1,2) yo.translation(1,3)-0.5];
            vrdrawnow;
            pause(0.025);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,0.5);
                end,
                
                break;
            end,


        end


    elseif (direccion == -2)  %% AVANCES DIRECCION -Y
        for i=1:pasos

            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1) cam.position(1,2) cam.position(1,3)-1];
            yo.translation=[yo.translation(1,1) yo.translation(1,2) yo.translation(1,3)-1];
            vrdrawnow;
            pause(0.05);

            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,1);
                end,
               
                break;
            end,


        end
    elseif (direccion == -1.5)  %% AVANCES DIRECCION -X
        for i=1:2*(pasos)


            %% Actualizo punto de vista (posicion de la camara) y pinto
            %% escenario
            cam.position=[cam.position(1,1)+0.5 cam.position(1,2) cam.position(1,3)-0.5];
            yo.translation=[yo.translation(1,1)+0.5 yo.translation(1,2) yo.translation(1,3)-0.5];
            vrdrawnow;
            pause(0.025);
            %%Compruebo si debo ofrecer la rueda de opciones y esi es asi
            %%la pinto y no muevo más la camara
            [c,l]=cuadricula;
            if (c==1)
                if (l==1)
                    avanzar(1,0.5);
                end,
                
                break;
            end,


        end


    end
    if retroceder == 1; 
        for i=1:4 
            cambiarDireccion(1);
        end,
    end,
    stop(player);
    
end,     
pSalida = cam.position
oSalida = cam.orientation
ruedaOpciones;    

