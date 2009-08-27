function timeControl
global closingTime idleState;
global world;
global barThreshold;
global chair vr_bar vr_barMaterial vr_feedback vr_barWheel vr_barWheelMaterial vr_point vr_graphicalInterface;
global vr_wheel vr_goalArrow
global vr_trnukSignallingMaterial vr_tipSignallingMaterial
global inerciaActiva;
global barra_min;
global metodo vel seleccion2 umbral_selec2 t_reset tiempo_en_bloq t_pause giro explore interfaz numVueltas sound commandsNo reubicax numColisiones;
global handlerFw handlerIdle nextCommand newTurn ordenCom;

nextCommand = 0;
numColisiones = 0;
newTurn = 1;
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
global arrowAngle initialArrowAngle;
% posición inicial
if(commandsNo == 3)
    initialArrowAngle = 60;
else
    initialArrowAngle = 45;
end
arrowAngle = initialArrowAngle;

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


%Sonidos
%load('sonidos/sounds.mat');
load('sounds.mat');
% 3 seg de beep para indicar selección
handlerBeep = audioplayer(beep2,1500);
handlerLeft = audioplayer(left,44000);
handlerRight = audioplayer(right,44000);
handlerFw = audioplayer(forward,44000);
handlerBack = audioplayer(back,44000);
handlerIdle = audioplayer(idle,44000);
sound = 0; %se pone a 0 para que no suene
if (interfaz == 2) % Solo sonido
    sound = 1;
    vr_graphicalInterface.translation = [0 0 -1];
elseif (interfaz == 3) % Gráfica y sonido
    sound = 1;
end

% Estadísticos
global  num_vueltas t_total t_bloque num_eleccx t_invocaxRed t_invocaxGreen path;

% Vbles temporales para guardar una vez se elija un comando
num_vueltasTemp = 0;
global t_totalTemp t_bloqueTemp t_invocaxTemp;
t_totalTemp = 0;
t_bloqueTemp = 0;
t_invocaxTemp = 0;
t_invocaxGreen = [];
t_invocaxRed = [];

% en path se guarda la posición inicial; a partir de entonces se guardan
% las coordenadas cada vez que se pare el avance
path =  chair.translation;

margen = 0.3; % margen de espacio previo a la colisión (para el pasillo)

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
% dcha, 3 izqd, 4 atrás

global commands commandIndex randomCommandsNo selectedOption commandTime commandTimeTot

% Se obtienen todos los nodos para luego buscar los sensores de proximidad
myNodes = get(world, 'Nodes');
% Número de nodos
nodesNo = size(myNodes);
% vector en el que se guardan los índices de los nodos que son sensores de
% proximimdad
proxSensIndices = [];
proxSensInteriorIndices = [];
rectasInteriorsIndices = [];
if (explore  ~= 3) % lo clásico, se buscan los sensores de proximidad de los objetos
    for i=1:nodesNo
        if(strcmp( get( myNodes(i), 'Type') , 'ProximitySensor') )
            proxSensIndices = [proxSensIndices, i];
        end
    end
    sensorsNo = length(proxSensIndices);
else % en el pasillo, se buscan las rectas que forman el camino
    for i=1:nodesNo
        aux = findstr( get( myNodes(i), 'Name') , 'rectaInterior');
        if( ~isempty(aux) )
            rectasInteriorsIndices = [rectasInteriorsIndices, i];
        end
    end
    rectasNo = length(rectasInteriorsIndices);
end

randomCommandsNo = 0;
commands = [];
selectedOption = [];
lastTile = 0; % para el modo en que hay que reubicar la silla, esta vble indica cuál es la última recta en la que
% la siila estaba en una posición válida

if(explore == 1) % Modo Evaluación
    % Se impone el modo de avance y de giro discreto
    % También se impone numVueltas = 0;
    giro = 2;
    metodo = 2;
    numVueltas = 0;

    %sensorsNo = 0;
    % se eligen , aleatoriamente, 'randomCommandsNo' comandos de cada tipo
    randomCommandsNo = 2;
    commands = zeros(1,commandsNo*randomCommandsNo);
    selectedOption = zeros(1,commandsNo*randomCommandsNo);
    commandTime = zeros(1,commandsNo*randomCommandsNo);
    commandTimeTot = zeros(1,commandsNo*randomCommandsNo);

    sequence = rand(1,randomCommandsNo*commandsNo);
    selectedCommands = [0 0 0 0];
    for i=1:(randomCommandsNo*commandsNo)
        if (commandsNo == 3)

            if( sequence(i) <= 1/3 )
                if( selectedCommands(1) < randomCommandsNo )
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                elseif ( selectedCommands(2) < randomCommandsNo )
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                else
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                end
            elseif ( sequence(i) <= 2/3 )
                if( selectedCommands(2) < randomCommandsNo )
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                elseif ( selectedCommands(3) < randomCommandsNo )
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                else
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                end
            else
                if( selectedCommands(3) < randomCommandsNo )
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                elseif ( selectedCommands(1) < randomCommandsNo )
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                else
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                end
            end
        else % commandsNo == 4
            if( sequence(i) <= 1/4 )
                if( selectedCommands(1) < randomCommandsNo )
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                elseif ( selectedCommands(2) < randomCommandsNo )
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                elseif ( selectedCommands(3) < randomCommandsNo )
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                else
                    commands(i) = 4;
                    selectedCommands(4) = selectedCommands(4) + 1;
                end
            elseif ( sequence(i) <= 2/4 )
                if( selectedCommands(2) < randomCommandsNo )
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                elseif ( selectedCommands(3) < randomCommandsNo )
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                elseif ( selectedCommands(4) < randomCommandsNo )
                    commands(i) = 4;
                    selectedCommands(4) = selectedCommands(4) + 1;
                else
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                end
            elseif ( sequence(i) <= 3/4 )
                if( selectedCommands(3) < randomCommandsNo )
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                elseif ( selectedCommands(4) < randomCommandsNo )
                    commands(i) = 4;
                    selectedCommands(4) = selectedCommands(4) + 1;
                elseif ( selectedCommands(1) < randomCommandsNo )
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                else
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                end
            else
                if( selectedCommands(4) < randomCommandsNo )
                    commands(i) = 4;
                    selectedCommands(4) = selectedCommands(4) + 1;
                elseif ( selectedCommands(1) < randomCommandsNo )
                    commands(i) = 1;
                    selectedCommands(1) = selectedCommands(1) + 1;
                elseif ( selectedCommands(2) < randomCommandsNo )
                    commands(i) = 2;
                    selectedCommands(2) = selectedCommands(2) + 1;
                else
                    commands(i) = 3;
                    selectedCommands(3) = selectedCommands(3) + 1;
                end
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
            if(sound)
                play(handlerIdle);
            end
        elseif (t_pause > 0 && pauseTime == 0 && inerciaActiva == 1)
            stop(pauseTimer);
            start(pauseTimer);
            pauseTime = 1;
            idleTimerActive = 0;
        end;

        if(explore == 1)%Modo evaluación
            if(randomTime == 1 && pauseTime == 0  && inerciaActiva == 0)
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
            % Modo objetivo o pasillo
            randomTime = 0;
        end

        if(barSize < barThreshold && inerciaActiva == 0)
            if (idleTimerActive)
                % acaba de pasar el umbral
                idleTimerActive = 0;
                t_reseting = 0;
                t_iniReset = toc;
                stop(handlerBeep);
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
                if(sound)
                    play(handlerBeep);
                end
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
                stop(handlerBeep);
                t_invocaxTemp = toc - t_invocaxTemp;
                t_invocaxTemp2 = t_invocaxTemp;
                % el tiempo de invocación no se guarda hasta que no se haya
                % elegido el comando correspondiente, por si se vuelve al
                % estado NC sin haber elegido ninguno
                vr_feedback.translation = vr_feedback.translation + [0 1 0];
                vr_wheel.translation = vr_wheel.translation - [0 1 0];
                idleState = 0;
                feedbackColor = [0 0 1];
                t_active = 0;
                inerciaActiva = 1;
                option = 1;
                firstCommand = 1; % lo usaremos para guardar los tiempos de invocax a 0 en el resto de comandos que se elijan desde el IC antes de volver al NC
                newTurn = 1;
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
            if (newTurn == 1 && sound)
                        if (option == 1) % forward
                                play(handlerFw);                         
                        elseif(option == 2) % right
                                play(handlerRight);                      
                        end
                        newTurn = 0;
            end
            if(barSize2 < threshold2)
                stop(handlerBeep);
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

                if(commandsNo == 3)
                    
                    if ( ( (arrowAngle <= 60) && option == 3)  )
                        % se resetea                      
                        reset = 1;
                        option = 1;
                        t_bloqueTemp = toc;
                        num_vueltasTemp = num_vueltasTemp + 1;
                        if( num_vueltasTemp == numVueltas)
                            idleState = 1;
                            reinicio();
                            num_vueltasTemp = 0;
                        else
                            if(sound)
                                play(handlerFw);
                            end
                        end
                    elseif ( (arrowAngle <= 300 && arrowAngle >= 180) && option == 1 )
                        if(sound)
                            play(handlerRight);
                        end
                        % se resetea
                        reset = 1;
                        t_bloqueTemp = toc;
                        option = 2;
                    elseif ( (arrowAngle <= 180)  &&  option == 2 )
                        if(sound)
                            play(handlerLeft);
                        end
                        % se resetea
                        reset = 1;
                        t_bloqueTemp = toc;
                        option = 3;
                    end
                else % commandsNo == 4
                   if ( (arrowAngle <= 45) && option == 3)
                        % se resetea
                        reset = 1;
                        option = 1;
                        t_bloqueTemp = toc;
                        num_vueltasTemp = num_vueltasTemp + 1;
                        if( num_vueltasTemp == numVueltas)
                            idleState = 1;
                            reinicio();
                            num_vueltasTemp = 0;
                        else
                            if(sound)
                                play(handlerFw);                                
                            end
                        end
                    elseif ( (arrowAngle <= 315 && arrowAngle >= 225) && option == 1 )
                        if(sound)
                            play(handlerRight);
                        end
                        % se resetea
                        reset = 1;
                        t_bloqueTemp = toc;
                        option = 2;
                    elseif ( (arrowAngle <= 225 && arrowAngle >= 135) && option == 2 )
                        if(sound)
                            play(handlerBack);
                        end
                        % se resetea
                        reset = 1;
                        t_bloqueTemp = toc;
                        option = 4;
                    elseif ( (arrowAngle <= 135)  &&  option == 4 )
                        if(sound)
                            play(handlerLeft);
                        end
                        % se resetea
                        reset = 1;
                        t_bloqueTemp = toc;
                        option = 3;
                    end
                    %end
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
                if(sound)
                    play(handlerBeep);
                end
                % si ya estaba activo, no se hace nada
            end

            t_active = t_active + (toc - t_iniActive);
            t_iniActive = toc;

            vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
            vr_barWheel.scale = [1 barSize2 1];
            if(t_active >= tiempo_en_bloq)
                % Se ha elegido un comando, debemos guardar los
                % estadísticos
                stop(handlerBeep);
                t_bloqueTemp = toc - t_bloqueTemp;
                t_totalTemp = toc - t_totalTemp;
                % en estos cálculos no se tiene en cuenta si se ha
                % acertado o no, eso sí se puede considerar analizando los
                % arrays "selectedOption, commandTime y CommandTimeTot"
                t_total(option) = t_total(option) + t_totalTemp;
                t_bloque(option) = t_bloque(option) + t_bloqueTemp;
                num_eleccx(option) = num_eleccx(option) + 1;
                num_vueltas(option) = num_vueltas(option) + num_vueltasTemp;
                if(firstCommand == 1)
                    % para el primer comando tras el cambio a IC ya se han
                    % guardado los tiempos de invocación
                    firstCommand = 0;

                    if(randomTime == 1)
                        t_invocaxRed = [t_invocaxRed t_invocaxTemp2];
                        t_invocaxGreen = [t_invocaxGreen 0];
                    else
                        t_invocaxGreen = [t_invocaxGreen t_invocaxTemp2];
                        t_invocaxRed = [t_invocaxRed 0];
                    end

                else
                    %  para los demás comandos se pone este tiempo a 0
                    t_invocaxRed = [t_invocaxRed 0];
                    t_invocaxGreen = [t_invocaxGreen 0];
                end
                num_vueltasTemp = 0;
                moving = 1;
                busyTimerActive = 0;
                contMovWaiting = 0;
                % Se guarda la posición actual
                if(explore == 1) %evaluación
                    selectedOption(commandIndex) = option;
                    commandTime(commandIndex) = t_bloqueTemp;
                    commandTimeTot(commandIndex) = t_totalTemp;
                    if(option == commands(commandIndex))
                        succesNo = succesNo + 1;
                    end
                else
                    commands = [commands 0]; % para que encaje en "resultMatrix"
                    selectedOption = [selectedOption option];
                    commandTime = [commandTime t_bloqueTemp];
                    commandTimeTot = [commandTimeTot t_totalTemp];
                end
            end
        elseif (moving) % en movimiento

            if ( (option == 1) || (option == 4) )

                % se avanza, si se colisiona se vuelve a la posición
                % anterior y al estado de no movimiento
                rot = chair.rotation(4);
                x = stepSize*sin(rot);
                z = stepSize*cos(rot);
                if(metodo == 1 && moving) %avance continuo
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
                            if (numVueltas > 0)
                                nextCommand = 2;
                                reinicio2();
                            else
                                % se para el movimiento y se vuelve a idle
                                idleState = 1;
                                reinicio();
                            end;
                        end
                    else
                        % se sigue avanzando
                        vr_barWheel.scale = [1 barSize2 1];
                        if(contMovWaiting == 1)
                            contMovWaiting = 0;
                        end
                        previousPosition = chair.translation;
                        if(option == 1) % avanza
                            chair.translation = previousPosition + [x 0 z];
                        else % retrocede
                            chair.translation = previousPosition - [x 0 z];
                        end
                        vrdrawnow;

                        % Se testean los sensores de proximimdad hasta que alguno detecte colisión
                        i = 1;
                        if (explore  ~= 3) %lo clásico, se testean los sensores de colisión, si alguno está activo, se detiene el movimiento
                            while( moving && i<=sensorsNo)
                                if(myNodes(proxSensIndices(i)).isActive == 1)
                                    if(strcmp( get( myNodes(proxSensIndices(i)), 'Name') , 'goalProximitySensor') )
                                        closingTime = 1;
                                        disp('FIN');
                                    else
                                        chair.translation = previousPosition;
                                        nextCommand = 2;
                                        reinicio2();
                                        numColisiones = numColisiones + 1;
                                    end
                                end
                                i = i+1;
                            end
                        else % en este caso el sujeto se mueve dentro de la zona de "rectasInteriores", con lo que el movimiento se detendrá si no está dentro de ninguna
                            tempMoving = 0;
                            while(   tempMoving == 0 && i<=rectasNo)
                                recta = vrnode(world, get( myNodes(rectasInteriorsIndices(i)), 'Name'));
                                pos = chair.translation - recta.translation;
                                [theta, r] = cart2pol( pos(1), -pos(3) );
                                [posX posY] = pol2cart( (theta - (recta.rotation(2)*recta.rotation(4) ) ) , r );
                                pos2 = [posX -posY];
                                w = recta.scale(3);
                                l = recta.scale(1);
                                % Mejor no le pones el margen en la dimensión de avance...
                                if( ( (-w/2+margen) <= pos2(2)  && pos2(2) <= (w/2-margen) &&  (-l/2) <= pos2(1)  && pos2(1) <= (l/2)) )
                                    tempMoving = 1; % está dentro de alguna
                                    lastTile = recta;
                                end
                                i = i+1;
                            end
                            if (tempMoving == 0)
                                numColisiones = numColisiones + 1;
                                if(reubicax == 1) % se deja donde está
                                    chair.translation = previousPosition;
                                else % se lleva al centro del pasillo
                                    pause(0.5);
                                    pos = chair.translation - lastTile.translation;
                                    [theta, r] = cart2pol( pos(1), -pos(3) );
                                    [posX posY] = pol2cart( (theta - (lastTile.rotation(2)*lastTile.rotation(4) ) ) , r );
                                    [pos2X pos2Y]= pol2cart( (lastTile.rotation(2)*lastTile.rotation(4) ), posX );
                                    chair.translation = lastTile.translation + [pos2X 0 -pos2Y];
                                    rot4 = lastTile.rotation(2)*lastTile.rotation(4) - pi/2; % pq la silla está girada 90º desde el principio
                                    if(rot4 < -pi)
                                        rot4 = rot4 +  2*pi;
                                    elseif(rot4 > pi)
                                        rot4 = rot4 -  2*pi;
                                    end
                                    chair.rotation = [0 1 0 rot4];
                                end
                                nextCommand = 2;
                                reinicio2();
                            end
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
                        if(option == 1) % avanza
                            chair.translation = previousPosition + [x 0 z];
                        else % retrocede
                            chair.translation = previousPosition - [x 0 z];
                        end
                        vrdrawnow;
                        if (explore  ~= 3) %lo clásico, se testean los sensores de colisión, si alguno está activo, se detiene el movimiento
                            i = 1;
                            while( moving && i<=sensorsNo)
                                if(myNodes(proxSensIndices(i)).isActive == 1)
                                    if(strcmp( get( myNodes(proxSensIndices(i)), 'Name') , 'goalProximitySensor') )
                                        closingTime = 1;
                                        disp('FIN');
                                    else
                                        chair.translation = previousPosition;
                                        moving = 0;
                                        numColisiones = numColisiones + 1;
                                    end
                                end
                                i = i+1;
                            end
                        else % en este caso el sujeto se mueve dentro de la zona de "rectasInteriores", con lo que el movimiento se detendrá si no está dentro de ninguna
                            i = 1;
                            tempMoving = 0;
                            while(   tempMoving == 0 && i<=rectasNo)
                                recta = vrnode(world, get( myNodes(rectasInteriorsIndices(i)), 'Name'));
                                pos = chair.translation - recta.translation;
                                [theta, r] = cart2pol( pos(1), -pos(3) );
                                [posX posY] = pol2cart( (theta - (recta.rotation(2)*recta.rotation(4) ) ) , r );
                                pos2 = [posX -posY];
                                w = recta.scale(3);
                                l = recta.scale(1);
                                % Mejor no le pones el margen en la dimensión de avance...
                                if( ( (-w/2+margen) <= pos2(2)  && pos2(2) <= (w/2-margen) &&  (-l/2) <= pos2(1)  && pos2(1) <= (l/2)) )
                                    tempMoving = 1; % está dentro de alguna
                                    lastTile =recta;
                                end
                                i = i+1;
                            end
                            if (tempMoving == 0)
                                numColisiones = numColisiones + 1;
                                if(reubicax == 1) % se deja donde está
                                    chair.translation = previousPosition;
                                else % se lleva al centro del pasillo
                                    pause(0.5);
                                    pos = chair.translation - lastTile.translation;
                                    [theta, r] = cart2pol( pos(1), -pos(3) );
                                    [posX posY] = pol2cart( (theta - (lastTile.rotation(2)*lastTile.rotation(4) ) ) , r );
                                    [pos2X pos2Y]= pol2cart( (lastTile.rotation(2)*lastTile.rotation(4) ), posX );
                                    chair.translation = lastTile.translation + [pos2X 0 -pos2Y];
                                    rot4 = lastTile.rotation(2)*lastTile.rotation(4) - pi/2; % pq la silla está girada 90º desde el principio
                                    if(rot4 < -pi)
                                        rot4 = rot4 +  2*pi;
                                    elseif(rot4 > pi)
                                        rot4 = rot4 -  2*pi;
                                    end
                                    chair.rotation = [0 1 0 rot4];
                                end
                                moving = 0;
                            end
                        end
                        j = j+1;
                        % Se llama a la función que presenta la flecha indicando la dirección a seguir
                        signalling();
                        pause(0.1);
                    end
                    if (numVueltas > 0)
                        nextCommand = 2;
                        reinicio2();
                    else
                        % se para el movimiento y se vuelve a idle
                        idleState = 1;
                        reinicio();
                    end;
                    if(explore == 1)
                        commandIndex = commandIndex + 1;
                        if (commandIndex > commandsNo*randomCommandsNo)
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
                            pause(0.05);
                        end
                    else %( option == 3)
                        % j <= 20 pequeños pasos
                        j = 1;
                        while j <= 20
                            chair.rotation = chair.rotation + [0 0 0 pi/(2*20)];
                            j = j+1;
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

                    if (numVueltas > 0)
                        reinicio2();
                    else
                        % se para el movimiento y se vuelve a idle
                        idleState = 1;
                        reinicio();
                    end;
                    if(explore == 1)
                        commandIndex = commandIndex + 1;
                        if (commandIndex > commandsNo*randomCommandsNo)
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
                            if (numVueltas > 0)
                                reinicio2();
                            else
                                % se para el movimiento y se vuelve a idle
                                idleState = 1;
                                reinicio();
                            end;
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
                    end
                end
            end
        end
    end
end

close(world);
delete(world);
end



%---------------------------------------------------
function reinicio
global  arrowAngle initialArrowAngle vr_barWheel  vr_barWheelMaterial vr_wheel vr_feedback t_active barra_min vr_bar vr_trnukSignallingMaterial vr_tipSignallingMaterial path chair
global  inerciaActiva moving randomTime
moving = 0;
% se reinicia la posición de la flecha en la rueda
arrowAngle = initialArrowAngle;
vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
inerciaActiva = 1;
barColor = [0 0 1];
vr_barWheel.scale = [1 barra_min 1];
vr_barWheelMaterial.diffuseColor = barColor;
% Se vuelve al estado NC
vr_feedback.translation = vr_feedback.translation - [0 1 0];
vr_wheel.translation = vr_wheel.translation + [0 1 0];
t_active = 0;
vr_bar.scale = [1 barra_min 1];
vr_trnukSignallingMaterial.emissiveColor = [0.3 0 0];
vr_tipSignallingMaterial.emissiveColor = [0.5 0 0];
vr_trnukSignallingMaterial.diffuseColor = [.85 0 0];
vr_tipSignallingMaterial.diffuseColor = [.85 0 0];
randomTime = 1;
% Se guarda la posición actual
path = [path ; chair.translation];
end

function reinicio2
global  arrowAngle vr_barWheel  vr_barWheelMaterial   t_active barra_min vr_bar   path chair option
global  inerciaActiva moving initialArrowAngle nextCommand commandsNo newTurn ordenCom
moving = 0;
% se reinicia la posición de la flecha en la rueda

if (nextCommand == 2 && ordenCom == 1)
    if(commandsNo == 3)
        arrowAngle = 300;
    else
        arrowAngle = 315;
    end
    option = 2;
else
    arrowAngle = initialArrowAngle;
    option = 1;
end
newTurn = 1;
nextCommand = 0;
vr_barWheel.rotation = [0 0 1 (arrowAngle*pi/180)];
inerciaActiva = 1;
barColor = [0 0 1];
vr_barWheel.scale = [1 barra_min 1];
vr_barWheelMaterial.diffuseColor = barColor;
t_active = 0;
vr_bar.scale = [1 barra_min 1];
% Se queda en el estado IC
% Se guarda la posición actual
path = [path ; chair.translation];
end


% ----------------------------------------
function signalling
% Actualiza la dirección a la que apunta la flecha que indica el camino
% hacia el objetivo; hace que desaparezca si el objetivo está dentro del
% campo de visión del sujeto
global vr_goal chair vr_viewPoint vr_signallingArrow commandIndex explore  commands

% En modo objetivo, la flecha indica hacia el objetivo, en modo evaluación,
% la flecha indica uno de los 3 comandos a ejecutar
if(explore == 1)
    if(commands(commandIndex) == 1)
        gamma = 0;
    elseif(commands(commandIndex) == 2)
        gamma = -pi/2;
    elseif(commands(commandIndex) == 3)
        gamma = pi/2;
    else
        gamma = pi;
    end
    vr_signallingArrow.rotation = [0 1 0 gamma];
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
end

