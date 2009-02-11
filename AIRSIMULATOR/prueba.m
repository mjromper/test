function prueba()


world = vrworld('plain2.WRL');
%reload(world);
open(world);
fig_sujeto=vrfigure(world,[4 75 1300 750]);

%nodes(world);
textura = vrnode(world,'TT');
textura.translation
vrdrawnow;
pause(0.02);
for i=0:0.001:2

   textura.translation = [0 i];
    vrdrawnow;
    pause(0.02);
end,    
 

 








