%--------------------------------------------------------------------------
%   Programa pauseTimerOut
%--------------------------------------------------------------------------
%   Francisco Velasco Álvarez, Octubre 2008.
%--------------------------------------------------------------------------
% Detecta el fin del timer para la pausa

function pauseTimerOut (src,evnt)
global pauseTime inerciaActiva t_totalTemp t_bloqueTemp t_invocaxTemp t_iniRandom min_t_random max_t_random t_random;

% aquí es donde empieza a girar, ponemos a 0 el contador de
% tiempo, o lo que es lo mismo, guardamos el valor actual de toc para luego
% restarlo al hacer la elección del comando
t_totalTemp = toc;
t_bloqueTemp = toc;
pauseTime = 0;
inerciaActiva = 0;
t_invocaxTemp = toc;
t_random = random('unif', min_t_random, max_t_random);
t_iniRandom = toc;
