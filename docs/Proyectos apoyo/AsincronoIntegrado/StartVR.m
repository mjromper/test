function StartVR

% Pues no, vamos a intentar interactuar con el feedback
global chair vr_threshold vr_bar vr_barMaterial vr_feedback vr_barWheel vr_signallingArrow
global vr_barWheelMaterial vr_wheel barra_min vr_goalArrow vr_goal vr_viewPoint vr_point;
global vr_trnukSignallingMaterial vr_tipSignallingMaterial
global closingFigure explore

% declaramos el estado inicial como reposo (idle)
global idleState;
idleState = 1;

global barThreshold;
      
% el mundo virtual
global world;
world = vrworld('mundo1.WRL');
open(world);
set(world, 'Description', 'Virtual World');
fig = view(world);
set(fig,'NavPanel', 'none',...
        'Toolbar', 'off',...
        'StatusBar','off');
%     ,...   
%         'FullScreen', 'on');


chair = vrnode(world, 'chair');
chair.rotation = [0 1 0 -1.57];

vr_feedback = vrnode(world, 'feedback');
vr_threshold = vrnode(world, 'Umbral');
vr_bar = vrnode(world, 'Cilindro');
vr_barMaterial = vrnode(world, 'barMaterial');
vr_threshold.translation = [0 barThreshold 0];
vr_barWheel = vrnode(world, 'barraRueda');
vr_barWheelMaterial = vrnode(world, 'materialBarraRueda');
vr_wheel = vrnode(world, 'Rueda');
vr_threshold = vrnode(world, 'umbralRueda');
vr_goalArrow = vrnode(world, 'goalArrow');
vr_goal = vrnode(world, 'Objetivo');
vr_threshold.scale = [barThreshold 1 barThreshold];
vr_barWheel.rotation = [0 0 1 (60*pi/180)];
vr_barWheel.scale = [1 barra_min 1];
vr_viewPoint = vrnode(world, 'Viewpoint_user');
vr_signallingArrow = vrnode(world, 'signallingArrow');
vr_signallingArrow = vrnode(world, 'signallingArrow');
vr_point = vrnode(world, 'marca');
vr_point.translation = [0 0.05 1];
% debe tener, en lugar de '1', stepSize
vr_tipSignallingMaterial = vrnode(world, 'puntaFlechaMaterial');
vr_trnukSignallingMaterial = vrnode(world, 'cuerpoFlechaMaterial');

% presenta el mundo virtual
vrdrawnow;
figure(closingFigure);
if(explore == 1)
    vr_goal.translation = [0 -10 0];
end
    
    
