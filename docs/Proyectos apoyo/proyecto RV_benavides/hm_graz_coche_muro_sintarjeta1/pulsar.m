%--------------------------------------------------------------------------
%   Programa Pulsar
%--------------------------------------------------------------------------
%   Francisco Benavides Martín, Mayo de 2007.
%   Copyright (c) 2006-07 by Dpto. de Tecnología Electrónica - Universidad
%   de Málaga.
%--------------------------------------------------------------------------

function pulsar (src,evnt)
global tecla movido dio inst_tecla pulso pruebactual pulsacion;

tecla(1)=evnt.Key(1);
movido=0;

if (tecla=='r')&(pulso==0)
    putvalue(dio.Line(3),1);
    inst_tecla=toc;
    pulso=1;
    pulsacion(pruebactual)=0;
end
if (tecla=='l')&(pulso==0)
    putvalue(dio.Line(4),1);
    inst_tecla=toc;
    pulso=1;
    pulsacion(pruebactual)=1;
end
