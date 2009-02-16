function prueba()

global textura;
global avion;

world = vrworld('plain3.WRL');
open(world);
reload(world);

% fig_sujeto=vrfigure(world,[4 75 1300 750]);
vrdrawnow;
nodes(world);
textura = vrnode(world,'TT');
avion=vrnode(world,'A6M2Fuse');
fields(avion)
textura.translation(2)+0.0002
vrdrawnow;
pause(0.02);


movePlain(3);
movePlain(3);
movePlain(0);
movePlain(1);








