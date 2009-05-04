function prueba()

global textura;
global avion;
global camara;
vrclear;
world = vrworld('plain.WRL');
open(world);
reload(world);

fig_sujeto=vrfigure(world,[4 75 1300 750]);
vrdrawnow;
%nodes(world);
textura = vrnode(world,'TT');
avion=vrnode(world,'A6M2Fuse');
camara = vrnode(world,'Camera02');
textura.translation(2)+0.0002;
vrdrawnow;
pause(2);

 movePlain('s',20);
 movePlain('d',10);
 movePlain('b',30);
 movePlain('i',10);
vrdrawnow;
pause(2);
vrclear;
vrclose;







