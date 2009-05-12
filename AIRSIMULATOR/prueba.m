function prueba()

global textura;
global avion;
global camara;
vrclear;
world = vrworld('./wrl_src/mundoAvion.WRL');
open(world);
reload(world);

fig_sujeto=vrfigure(world,[4 75 1300 750]);
vrdrawnow;
%nodes(world);
textura = vrnode(world,'TT');
avion=vrnode(world,'A6M2Fuse');
camara = vrnode(world,'Viewpoint_user02');
textura.translation(2)+0.0002;
vrdrawnow;
pause(2);

textura.center = textura.center + [0 0];

vrdrawnow;
pause(2);
 movePlain('d',5000);
 %movePlain('i',1);
 %movePlain('d',1);
 %movePlain('d',30);
 %movePlain('i',10);
vrdrawnow;
pause(2);
vrclear;
%vrclose;







