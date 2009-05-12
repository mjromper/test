function prueba()

global textura;
global avion;
global plano;
vrclear;
world = vrworld('./wrl_src/etsitPlain3.WRL');
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
 movePlain('b',10);
 movePlain('b',10);
 movePlain('s',10);
 movePlain('s',10);
 %
 %movePlain('d',30);
 %movePlain('i',10);
vrdrawnow;
pause(2);
vrclear;
%vrclose;







