function timeControl
global closingTime idleState;
global world;
global barThreshold;
global chair vr_bar vr_barMaterial vr_feedback vr_barWheel vr_barWheelMaterial vr_point;
global vr_wheel vr_goalArrow
global vr_trnukSignallingMaterial vr_tipSignallingMaterial
global inerciaActiva;
global barra_min;
global metodo vel seleccion2 umbral_selec2 t_reset tiempo_en_bloq t_pause giro explore;

% Nº de aciertos
global succesNo;
succesNo = 0;

global feedbackColor;
feedbackColor = [0 0 1];
global barColor;
barColor = [0 0 1];

%Cuando se seleccione avanzar, se darán 10 pequeños pasos, la distancia a
%avanzar en cada selección será por tanto 10*stepSize
global stepSize;
stepSize = .1;
vr_point.translation = [0 0.05 10*stepSize];

global loopCont; % para deterner el bucle de espera con loopCont = 1
loopCont = 0;

% tamaño de la barra, se actualiza en "tiempo2frec"
global barSize;
barSize = 0.;

% Ángulo de la flecha
global arrowAngle;
% posición inicial
arrowAngle = 60;

% Indica si se está contando tiempo en la opción señalada
global busyTimerActive;
busyTimerActive = 0;

% Vble que indica si se está realizando una acción
global moving;
moving = 0;

% Indica el tamaño de la barra para el método 2, en que se hace mayor que
% el real si se supera cierto umbral
global barSize2;
barSize2 = 0;

% Umbral a tener en cuenta para la elección en la rueda; si es método 1 es
% el umbral de selección; si es el método 2 es el umbral de detención
global threshold2;
threshold2 = 0;


%indica cuál de las opcioens está siendo seleccionada, para que cuando se
%detecte un cambio antes del reseteo, se reinicien los contadores
global option;
option = 1;

% Cuando se está avanzando en modo coontinuo, indica una espera hasta que
% se resetee el contador
global contMovWaiting;
contMovWaiting = 0;

% temporizador que controla cuánto tiempo se mantiene la pausa
pauseTimer = timer('TimerFcn', @pauseTimerOut, 'StartDelay',t_pause);
% booleano que indica si se está esperando
global pauseTime;
pauseTime = 0;

% temporizador que controla la pausa aleatoria previa a la invocación
global randomTime t_random min_t_random max_t_random;
% randomTime indica si se está en el periodo en que el sujeto debe esperar
randomTime = 1;
min_t_random = 2;
max_t_random = 5;
% t_random cambiará cada vez
t_random = random('unif', min_t_random, max_t_random);
% guarda el inicio del timepo aleatorio
global t_iniRandom;
t_iniRandom = toc;
% Estadísticos
global num_vueltas t_total t_bloque num_eleccx t_invocaxRed t_invocaxGreen;

% Vbles temporales para guardar una vez se elija un comando
num_vueltasTemp = 0;
global t_totalTemp t_bloqueTemp t_invocaxTemp;
t_totalTemp = 0;
t_bloqueTemp = 0;
t_invocaxTemp = 0;
t_invocaxGreen = [];
t_invocaxRed = [];

global t_active;
t_active = 0;
t_iniActive = 0;
t_reseting = 0;
t_iniReset = 0;

% Se comienza suponiendo que la barra no ha superado el nivel
idleTimerActive = 0;

% se pone inerciaActiva a 1 para que sea necesario bajar el nivel siempre
% antes de que empiece a seleccionarse una tarea; evita la inercia de la
% tarea mental activa para invocar a la rueda
inerciaActiva = 1;

% "commands" es un array con los comandos para el modo "Evaluación". 1 == avanzar, 2
% dcha, 3 izqd

global commands commandIndex commandNo selectedOption commandTime commandTimeTot

% Se obtienen todos los nodos para luego buscar los sensores de proximidad
myNodes = get(world, 'Nodes');
% Número de nodos
nodesNo = size(myNodes);
% vector en el que se guardan los índices de los nodos que son sensores de
% proximimdad
proxSensIndices = [];
for i=1:nodesNo
    if(strcmp( get( myNodes(i), 'Type') , 'ProximitySensor') )
        proxSensIndices = [proxSensIndices, i];
    end
end
sensorsNo = length(proxSensIndices);
commandNo = 0;
commands = [];
if(explore == 1) % Modo Evaluación
    % Se impone el modo de avance y de giro discreto
    giro = 2;
    metodo = 2;
    %sensorsNo = 0;
    % se eligen , aleatoriamente, 'commandNo' comandos de cada tipo
    commandNo = 3;
    commands = zeros(1,3*commandNo);
    selectedOption = zeros(1,3*commandNo);
    commandTime = zeros(1,3*commandNo);
    commandTimeTot = zeros(1,3*commandNo);
    
    selectedCommands = [0 0 0];
    sequence = rand(1,commandNo*3);
    for i=1:(commandNo*3)
        if( sequence(i) <= 1/3 )
            if( selectedCommands(1) < commandNo )
                commands(i) = 1;
                selectedCommands(1) = selectedCommands(1) + 1;
            elseif ( selectedCommands(2) < commandNo )
                commands(i) = 2;
                selectedCommands(2) = selectedCommands(2) + 1;
            else            
                commands(i) = 3;
                selectedCommands(3) = selectedCommands(3) + 1;
            end
        elseif ( sequence(i) <= 2/3 )
            if( selectedCommands(2) < commandNo )
                commands(i) = 2;
                selectedCommands(2) = selectedCommands(2) + 1;
            elseif ( selectedCommands(3) < commandNo )
                commands(i) = 3;
                selectedCommands(3) = selectedCommands(3) + 1;
            else
                commands(i) = 1;
                selectedCommands(1) = selectedCommands(1) + 1;
            end

        else
            if( selectedCommands(3) < commandNo )
                commands(i) = 3;
                selectedCommands(3) = selectedCommands(3) + 1;
            elseif ( selectedCommands(1) < commandNo )
                commands(i) = 1;
                selectedCommands(1) = selectedCommands(1) + 1;
            else
                commands(i) = 2;
                selectedCommands(2) = selectedCommands(2) + 1;
            end

        end
    end
end
commandIndex = 1;

% Se llama a la función que presenta la flecha indicando la dirección a
% seguir
signalling();

% Bucle que testea continuamente el estado de barSize y actúa en
% consecuencia, hasta que se termina la aplicación mediante closingTime=1
t_invocaxTemp = toc;
while(closingTime == 0)
    while(loopCont == 0)
        % Nos quedamos en un bucle hasta que habiéndose procesado datos
        % nuevos se haga una nueva iteración; al ser Fs = 128, habrá datos
        % cada 1/128 = 0.0078 s., pero se agrupan de 4 en 4 para hacer la
        % estimación espectral, por lo que la ejecución se hace cada
        % 0.03125 s. Hacemos una pausa menor, de modo que haga solo una
        % parada entre cada dos iteraciones
        % loopCont se actualiza en "tiempo2frec2"

        % mueve la flecha objetivo
        vr_goalArrow.translation = [0 0.5*sin(4*toc) 0];
        pause(0.02);
    end
    loopCont = 0; % para que en la siguiente ejecución vuelva a pararse

    if(idleState)

        if( t_pause == 0 &&  inerciaActiva == 1 && barSize < barThreshold )
            inerciaActiva = 0;
            t_invocaxTemp = toc;
            t_random = random('unif', min_t_random, max_t_random);
            t_iniRandom = toc;
        elseif (t_pause > 0 && pauseTime == 0 && inerciaActiva == 1)
            stop(pauseTimer);
            start(pauseTimer);
            pauseTime = 1;
            idleTimerActive = 0;
        end;
        
        if(explore == 1)%Modo evaluación
            if(randomTime == 1 && pauseTime == 0) 
                if( (toc - t_iniRandom) > t_random )
                    % la flecha se pone verde
                    vr_trnukSignallingMaterial.emissiveColor = [0 .3 0];
                    vr_tipSignallingMaterial.emissiveColor = [0 .5 0];
                    vr_trnukSignallingMaterial.diffuseColor = [0 .85 0];
                    vr_tipSignallingMaterial.diffuseColor = [0 .85 0];
                    t_invocaxTemp = toc;
                    randomTime = 0;
                end
            end
        else
            % Modo objetivo
            randomTime = 0;
        end

        if(barSize < barThreshold && inerciaActiva == 0)
            if (idleTimerActive)
                % acaba de pasar el umbral
                idleTimerActive = 0;
                t_reseting = 0;
                t_iniReset = toc;
            end
            if(t_active > 0)
                t_reseting = t_reseting + (toc-t_iniReset);
                t_iniReset = toc;
                if(t_reseting >= t_reset) % hay que resetear
                    feedbackColor = [0 0 1];
                    t_active = 0;
                    t_reseting = 0;
                end
            end
            vr_bar.scale = [1 barSize 1];
        elseif( inerciaActiva == 0) % barSize >= barThreshold
            if (idleTimerActive == 0)
                % acaba de pasar el umbral
                t_iniActive = toc;
                % comienza a contarse el tiempo que debe estar activa para
                % invocar la rueda
                idleTimerActive = 1;
                if(feedbackColor == [0 0 1]) % si está azul, se pone amarillo
                    feedbackColor = [1 1 0];
                end
            end
            t_active = t_active + (toc - t_iniActive);
            t_iniActive = toc;
            % se actualiza el color
            feedbackColor = [1 1-(t_active/tiempo_en_bloq) 0];
            if(feedbackColor(2) < 0)
                feedbackColor = [1 0 0];
            end
            if(t_active >= tiempo_en_bloq)
                t_invocaxTemp = toc - t_invocaxTemp;  
                % Si la flecha está verde (randomTime == 0), se guarda el tiempo de
                % invocación en un array; si estaba en rosa, se guarda en
                % otro, indicando que no era una invocación deseada
                if(randomTime == 1)
                    t_invocaxRed = [t_invocaxRed t_invocaxTemp];
                    t_invocaxGreen = [t_invocaxGreen 0];
                else
                    t_invocaxGreen = [t_invocaxGreen t_invocaxTemp];
                    t_invocaxRed = [t_invocaxRed 0];
                end                               
                vr_feedback.translation = vr_feedback.translation + [0 1 0];
                vr_wheel.translation = vr_wheel.translation - [0 1 0];
                idleState = 0;
                feedbackColor = [0 0 1];
                t_active = 0;
                inerciaActiva = 1;
                option = 1;
            end
            vr_bar.scale = [1 barSize 1];
        end
        vr_barMaterial.diffuseColor = feedbackColor;

    else %idleState == 0, estará presente la rueda

        if (barSize < barra_min)
            barSize = barra_min;
        end
        if(seleccion2 == 2)
            threshold2 = umbral_selec2;
        else
            threshold2 = barThreshold;
        end;
        if( t_pause == 0 && (barSize < threshold2) && inerciaActiva == 1)
            inerciaActiva = 0;
            % aquí es donde empieza a girar, ponemos a 0 el contador de
            % tiempo, o lo que es lo mismo, guardamos el valor actual de toc para luego
            % restarlo al hacer la elección del comando
            t_totalTemp = toc;
            t_bloqueTemp = toc;

        elseif (t_pause > 0 && pauseTime == 0 && inerciaActiva == 1)
            stop(pauseTimer);
            start(pauseTimer);
            pauseTime = 1;
        end;
        if(moving == 0 && inerciaActiva == 0)

            if(seleccion2 == 2 && barSize > threshold2)
                x = ( (1-threshold2) / (tiempo_en_bloq * 16) );
                barSize2 = barSize2 + x;
            else
                barSize2 = barSize;
            end
            if(barSize2 < threshold2)
                if (busyTimerActive)
                    busyTimerActive = 0;
                    t_reseting = 0;
                    t_iniReset = toc;
                end
                % se mueve la flecha si no se supera el umbral
                %Aquí es donde se determina la velocidad de giro de la
                %flecha, que deberá ajustarse según el tamaño de la barra
                %(método 2) y la vble "vel"
                angleOffset = 5*(vel/2.);
                % si el método de selección es 1 ó 2, la velocidad de giro una
                % vez que la barra supera el umbral2 se para
                velScale = 1;
                if (seleccion2 == 1 && barSize > umbral_selec2)
                    velScale = 0;
                elseif(seleccion2 == 2 && barSize > umbral_selec2)
                    %velScale = 1 - ( (barSize-umbral_selec2) / (barThreshold-umbral_selec2) );
                    velScale = 0;
                end
                arrowAngle = arrowAngle - velScale*angleOffset;
                if(arrowAngle < 0)
                    arrowAngle = arrowAngle + 360;
                end
                if(t_active > 0)
                    t_reseting = t_reseting + (toc-t_iniReset);
                    t_iniReset = toc;
                end
                reset = 0;
                if (t_reseting >= t_reset)
                    reset = 1;
                end
                if ( (arrowAngle <= 60) && option == 3)
                    % se resetea
                    reset = 1;
                    option = 1;
                    t_bloqueTemp = toc;
                    num_vueltasTemp = num_vueltasTemp + 1;
                elseif ( (arrowAngle <= 300 && arrowAngle >= 180) && option == 1 )
                    % se resetea
                    reset = 1;
                    t_bloqueTemp = toc;
                    option = 2;
                elseif ( (arrowAngle <= 180) && option == 2 )
                    % se resetea
                    reset = 1;
                    t_bloqueTemp = toc;
                    option = 3;
                end

                if(reset)
                    barColor = [0 0 1];
                    vr_barWheelMaterial.diffuseColor = barColor;
                    t_reseting = 0;
                    t_active = 0;
                end;
                t_iniActive = toc;
            else % se supera el umbral
                if (busyTimerActive == 0)
                    busyTimerActive = 1;
                    t_iniActive = toc;
                    if( barColor == [0 0 1])
                        barColor = [1 1 0];
                    end
                end
                barColor = [1 1-(t_active/tiempo_en_bloq) 0];
                if(barColor(2) < 0)
                    barColor = [1 0 0];
                end
                vr_barWheelMaterial.diffuseColor = barColor;
                % si ya estaba activo, no se hace nada
            end

            t_active = t_active + (toc - t_iniActive);
            t_iniActive = toc;

            vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
            vr_barWheel.scale = [1 barSize2 1];
            if(t_active >= tiempo_en_bloq)
                % Se ha elegido un comando, debemos guardar los
                % estadísticos
                t_bloqueTemp = toc - t_bloqueTemp;
                t_totalTemp = toc - t_totalTemp;
                % en estos cálculos no se tiene en cuenta si se ha
                % acertado o no, eso sí se puede considerar analizando los
                % arrays "selectedOption, commandTime y CommandTimeTot"
                t_total(option) = t_total(option) + t_totalTemp;
                t_bloque(option) = t_bloque(option) + t_bloqueTemp;                
                num_eleccx(option) = num_eleccx(option) + 1;
                num_vueltas(option) = num_vueltas(option) + num_vueltasTemp;
                num_vueltasTemp = 0;
                moving = 1;
                busyTimerActive = 0;
                contMovWaiting = 0;   
                if(explore == 1)
                    selectedOption(commandIndex) = option;                
                    commandTime(commandIndex) = t_bloqueTemp;
                    commandTimeTot(commandIndex) = t_totalTemp;
                    if(option == commands(commandIndex))
                        succesNo = succesNo + 1;
                    end
                end                
            end
        elseif (moving) % en movimiento

            if ( option == 1 )

                % se avanza, si se colisiona se vuelve a la posición
                % anterior y al estado de no movimiento
                rot = chair.rotation(4);
                x = stepSize*sin(rot);
                z = stepSize*cos(rot);

                if(metodo == 1 && moving)%avance continuo
                    if(barSize < threshold2)
                        vr_barWheel.scale = [1 barSize 1];
                        if(contMovWaiting == 0)
                            contMovWaiting = 1;
                            t_reseting = 0;
                            t_iniReset = toc;
                        end
                        t_reseting = t_reseting + (toc - t_iniReset);
                        t_iniReset = toc;
                        if(t_reseting >= t_reset)
                            t_reseting = 0;
                            %t_invocaxTemp = toc;
                            % se para el movimiento y se vuelve a idle
                            idleState = 1;
                            reinicio();
                        end
                    else
                        % se sigue avanzando
                        vr_barWheel.scale = [1 barSize2 1];
                        if(contMovWaiting == 1)
                            contMovWaiting = 0;
                        end
                        previousPosition = chair.translation;
                        chair.translation = previousPosition + [x 0 z];
                        vrdrawnow;

                        % Se testean los sensores de proximimdad hasta que
                        % alguno detecte colisión
                        i = 1;
                        while( moving && i<=sensorsNo)
                            if(myNodes(proxSensIndices(i)).isActive == 1)
                                %disp('colisión, posición anterior');
                                chair.translation = previousPosition;
                                moving = 0;
                                % se reinicia la posición de la flecha
                                arrowAngle = 60;
                                vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
                                inerciaActiva = 1;
                                barColor = [0 0 1];
                                vr_barWheel.scale = [1 1 1];
                                vr_barWheelMaterial.diffuseColor = barColor;
                                if(strcmp( get( myNodes(proxSensIndices(i)), 'Name') , 'goalProximitySensor') )
                                    closingTime = 1;
                                    disp('FIN');
                                end
                            end
                            i = i+1;
                        end
                        % Se llama a la función que presenta la flecha indicando la dirección a
                        % seguir
                        signalling();
                    end

                else % avance discreto
                    maxJ=10;
                    % maxJ = 10 pequeños pasos
                    j = 1;
                    while (moving && j <= maxJ)

                        previousPosition = chair.translation;
                        chair.translation = previousPosition + [x 0 z];
                        vrdrawnow;

                        % Se testean los sensores de proximidad hasta que
                        % alguno detecte colisión
                        i = 1;
                        while( moving && i<=sensorsNo)
                            if(myNodes(proxSensIndices(i)).isActive == 1)
                                chair.translation = previousPosition;
                                moving = 0;
                                if(strcmp( get( myNodes(proxSensIndices(i)), 'Name') , 'goalProximitySensor') )
                                    closingTime = 1;
                                    disp('FIN');
                                end
                            end
                            i = i+1;
                        end
                        j = j+1;
                        % Se llama a la función que presenta la flecha indicando la dirección a
                        % seguir
                        signalling();
                        pause(0.1);
                    end
                    % se para el movimiento y se vuelve a idle
                    idleState = 1;
                    reinicio();
                    %t_invocaxTemp = toc;
                    if(explore == 1)
                        commandIndex = commandIndex + 1;
                        if (commandIndex > 3*commandNo)
                            closingTime = 1;
                        else
                            signalling();
                        end
                    end
                end

            else
                % giro dcha o izqd
                if(giro == 2) %giro discreto
                    if ( option == 2 )
                        % j <= 20 pequeños pasos
                        j = 1;
                        while ( j <= 20)
                            chair.rotation = chair.rotation - [0 0 0 pi/(2*20)];
                            j = j+1;
                            % Se llama a la función que presenta la flecha indicando la dirección a
                            % seguir
                            signalling();
                            %vrdrawnow;
                            pause(0.05);
                        end
                    else %( option == 3)
                        % j <= 20 pequeños pasos
                        j = 1;
                        while j <= 20
                            chair.rotation = chair.rotation + [0 0 0 pi/(2*20)];
                            j = j+1;
                            %vrdrawnow;
                            % Se llama a la función que presenta la flecha indicando la dirección a
                            % seguir
                            signalling();
                            pause(0.05);
                        end
                    end
                    if(chair.rotation(4) < -pi)
                        chair.rotation = chair.rotation + [0 0 0 2*pi];
                    elseif(chair.rotation(4) > pi)
                        chair.rotation = chair.rotation - [0 0 0 2*pi];
                    end
                    % se para el movimiento y se vuelve a idle
                    idleState = 1;
                    reinicio();
                    %t_invocaxTemp = toc;
                    if(explore == 1)
                        commandIndex = commandIndex + 1;
                        if (commandIndex > 3*commandNo)
                            closingTime = 1;
                        else
                            signalling();
                        end;
                    end
                elseif (moving) % giro continuo
                    if(barSize < threshold2)
                        vr_barWheel.scale = [1 barSize 1];
                        if(contMovWaiting == 0)
                            contMovWaiting = 1;
                            t_reseting = 0;
                            t_iniReset = toc;
                        end
                        t_reseting = t_reseting + (toc - t_iniReset);
                        t_iniReset = toc;
                        if(t_reseting >= t_reset)
                            %se estaba girando y hay que parar
                            %t_invocaxTemp = toc;
                            % se para el movimiento y se vuelve a idle
                            idleState = 1;
                            reinicio();
                        end
                    else
                        % se sigue girando
                        vr_barWheel.scale = [1 barSize2 1];
                        if(contMovWaiting == 1)
                            contMovWaiting = 0;
                        end
                        velScale = .3;
                        if(option == 2)
                            chair.rotation = chair.rotation - [0 0 0 pi*velScale/(2*20)];
                        else % option == 3
                            chair.rotation = chair.rotation + [0 0 0 pi*velScale/(2*20)];
                        end
                        if(chair.rotation(4) < -pi)
                            chair.rotation = chair.rotation + [0 0 0 2*pi];
                        elseif(chair.rotation(4) > pi)
                            chair.rotation = chair.rotation - [0 0 0 2*pi];
                        end
                        % Se llama a la función que presenta la flecha indicando la dirección a
                        % seguir
                        signalling();
                        %vrdrawnow;
                    end
                end
            end
        end
    end
end

close(world);
delete(world);




%---------------------------------------------------
function reinicio
global  arrowAngle vr_barWheel  vr_barWheelMaterial vr_wheel vr_feedback t_active barra_min vr_bar vr_trnukSignallingMaterial vr_tipSignallingMaterial
global t_iniRandom inerciaActiva moving randomTime
moving = 0;
% se reinicia la posición de la flecha en la rueda
arrowAngle = 60;
vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
inerciaActiva = 1;
barColor = [0 0 1];
vr_barWheel.scale = [1 barra_min 1];
vr_barWheelMaterial.diffuseColor = barColor;
vr_feedback.translation = vr_feedback.translation - [0 1 0];
vr_wheel.translation = vr_wheel.translation + [0 1 0];
t_active = 0;
vr_bar.scale = [1 barra_min 1];
vr_trnukSignallingMaterial.emissiveColor = [0.3 0 0];
vr_tipSignallingMaterial.emissiveColor = [0.5 0 0];
vr_trnukSignallingMaterial.diffuseColor = [.85 0 0];
vr_tipSignallingMaterial.diffuseColor = [.85 0 0];
randomTime = 1;
%vrdrawnow;



% ----------------------------------------
function signalling
% Actualiza la dirección a la que apunta la flecha que indica el camino
% hacia el objetivo; hace que desaparezca si el objetivo está dentro del
% campo de visión del sujeto
global vr_goal chair vr_viewPoint vr_signallingArrow commandIndex explore commandNo closingTime commands

% En modo objetivo, la flecha indica hacia el objetivo, en modo evaluación,
% la flecha indica uno de los 3 comandos a ejecutar
if(explore == 1)    
    if(commands(commandIndex) == 1)
        gamma = 0;
    elseif(commands(commandIndex) == 2)
        gamma = -pi/2;
    else
        gamma = pi/2;
    end
    vr_signallingArrow.rotation = [0 1 0 gamma];
    %commandIndex = commandIndex + 1;    
else
    dx = vr_goal.translation(1) - chair.translation(1);
    dz = vr_goal.translation(3) - chair.translation(3);
    beta = asin( dx / ( sqrt( dx^2 + dz^2 ) ) );
    if(dz<0)
        if(dx>0)
            beta = pi - beta;
        else
            beta = - pi - beta;
        end
    end
    alpha = chair.rotation(2) * chair.rotation(4);
    gamma = beta - alpha;
    if(gamma < -pi)
        gamma = gamma + 2*pi;
    elseif(gamma > pi)
        gamma = gamma - 2*pi;
    end
    if ( abs(gamma) > (pi/16 + (vr_viewPoint.fieldOfView/2) ) )
        % fuera del campo de visión
        vr_signallingArrow.translation = [0 0 0];
    else
        % dentro
        vr_signallingArrow.translation = [0 1 0];
    end
    vr_signallingArrow.rotation = [0 1 0 gamma];

end

