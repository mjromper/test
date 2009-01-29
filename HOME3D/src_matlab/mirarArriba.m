function  [pSalida ,oSalida] = mirarArriba(grados)
%AVANZAR Summary of this function goes here
%   Detailed explanation goes here

radianes = grados * pi / 180;
global cam;

      
      for i=1:7
        cam.orientation=[cam.orientation(1,1)+radianes/7 cam.orientation(1,2) cam.orientation(1,3)+radianes/7 cam.orientation(1,4)];
        vrdrawnow;
        pause(0.05);
      end

oSalida = cam.orientation;
pSalida = cam.position;
