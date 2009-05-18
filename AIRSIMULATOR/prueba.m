function prueba()

global textura;
global avion;
global plano;
vrclear;
world = vrworld('./wrl_src/etsitPlain.WRL');
open(world);
reload(world);

fig_sujeto=vrfigure(world,[4 75 1300 750]);
vrdrawnow;
%nodes(world);
textura = vrnode(world,'TT');
avion=vrnode(world,'A6M2Fuse');
%camara = vrnode(world,'Viewpoint_user02');
plano = vrnode(world,'Plane01');
textura.translation(2)+0.0002;
vrdrawnow;
pause(2);
fields(plano)
textura.center = textura.center + [0.15 -0.5];
plano.translation
vrdrawnow;
pause(2);

movePlain('s',40);
movePlain('s',40);
movePlain('i',40);
movePlain('d',40);
movePlain('b',40);
movePlain('b',40);

vrdrawnow;
pause(2);
vrclear;
%vrclose;







