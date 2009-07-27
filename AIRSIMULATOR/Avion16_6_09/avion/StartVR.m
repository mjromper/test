function StartVR

% Pues no, vamos a intentar interactuar con el feedback
global chair vr_threshold vr_bar vr_barMaterial vr_feedback vr_barWheel 
global vr_barWheelMaterial vr_wheel barra_min   vr_viewPoint
global   vr_graphicalInterface
global closingFigure explore commandsNo mundoVR



% declaramos el estado inicial como reposo (idle)
global idleState;
idleState = 1;

global barThreshold;
      
% el mundo virtual
global world;
mundoVR = ['mundos/' mundoVR];


%%- MANOLO ---------------------------------------

%-----------------------------------------------%

world = vrworld(mundoVR);
open(world);
set(world, 'Description', 'Virtual World');
fig = view(world);
set(fig,'NavPanel', 'none',...
        'Toolbar', 'off',...
        'StatusBar','off');
    %     'FullScreen', 'on');

chair = vrnode(world, 'chair');
%chair.rotation = [0 1 0 -1.57];

%%- MANOLO ---------------------------------------
%%VARIABLE GLOBALES PARA EL SIMULADOR DE VUELO
global textura;
global avion;
global plano;
textura = vrnode(world,'TT');
avion=vrnode(world,'A6M2Fuse');
plano = vrnode(world,'Plane01');

%-----------------------------------------------%

vr_feedback = vrnode(world, 'feedback');
vr_threshold = vrnode(world, 'Umbral');
vr_bar = vrnode(world, 'Cilindro');
vr_barMaterial = vrnode(world, 'barMaterial');
vr_threshold.translation = [0 barThreshold 0];
vr_barWheel = vrnode(world, 'barraRueda');
vr_barWheelMaterial = vrnode(world, 'materialBarraRueda');
vr_wheel = vrnode(world, 'Rueda');
vr_threshold = vrnode(world, 'umbralRueda');
vr_threshold.scale = [barThreshold 1 barThreshold];
vr_barWheel.rotation = [0 0 1 (60*pi/180)];
vr_barWheel.scale = [1 barra_min 1];
vr_viewPoint = vrnode(world, 'Viewpoint_user');
% debe tener, en lugar de '1', stepSize
vr_graphicalInterface = vrnode(world, 'InterfazGrafica');

vr_separador1 = vrnode(world, 'separax1');
vr_separador2 = vrnode(world, 'separax2');
vr_separador3 = vrnode(world, 'separax3');
vr_separador4 = vrnode(world, 'separax4');

vr_flecha1 = vrnode(world, 'flechaAvance');
vr_flecha2 = vrnode(world, 'flechaDcha');
vr_flecha3 = vrnode(world, 'flechaIzqd');
vr_flecha4 = vrnode(world, 'flechaAtras');

commandsNo = commandsNo +2 ;
if(commandsNo == 3) % 3 comandos
    vr_separador1.translation = [0 0 -3];
    vr_separador2.translation = [0 0 -3];
    vr_separador3.translation = [0 0 -3];
     vr_flecha1.translation = [0 0.3 -3];
    vr_flecha2.translation = [0.3 -0.2 -3];
    vr_flecha3.translation = [-0.3 -0.2 -3];
    
    vr_separador1.rotation = [0 0 1 pi/3];
    vr_separador2.rotation = [0 0 1 pi];
    vr_separador3.rotation = [0 0 1 -pi/3];
else % 4 comandos
    vr_separador1.translation = [0 0 -3];
    vr_separador2.translation = [0 0 -3];
    vr_separador3.translation = [0 0 -3];
    vr_separador4.translation = [0 0 -3];
    
    vr_flecha1.translation = [0 0.3 -3];
    vr_flecha2.translation = [0.3 0 -3];
    vr_flecha3.translation = [-0.3 0 -3];
    vr_flecha4.translation = [0 -0.3 -3];
    
    vr_separador1.rotation = [0 0 1 pi/4];
    vr_separador2.rotation = [0 0 1 3*pi/4];
    vr_separador3.rotation = [0 0 1 -pi/4];
    vr_separador4.rotation = [0 0 1 -3*pi/4];
end

% presenta el mundo virtual
vrdrawnow;
figure(closingFigure);
    
    
