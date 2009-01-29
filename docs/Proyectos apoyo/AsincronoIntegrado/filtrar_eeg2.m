%%//function filtrar_eeg(yy)

global fc1 fc2 Fs

%Esta funcion junto con la de filtrado me van a preparar el filtro
%los parametros son los que se eligen a continuacion

%preparo las variables del filtrado

%%//muest=yy;

filtrado_algoritmo=2; %(1=>Ninguno,2=>Butterworth,3=>Chebyshev,4=>Elíptico)
filtrado_orden=5; %Orden del filtro(CUIDADO: Puede no ser estable!!!!!)
filtrado_rizado=1;%Decibelios en la banda de paso(solo util para metodos de Chebyshev/Eliptico.
filtrado_tipo=3; %(1=>Pasobajo, 2=>Pasoalto, 3=>PasoBanda, 4=>Rechazobanda)
%fc1=8; %Frecuencia inferior del filtro en [Hz] filtrado_f1             %%%// las introduzco en Panel
%fc2=12; %Frecuencia superior del filtro en [Hz]. filtrado_f2;Junto con la anterior determina la banda de paso
%Fs=128;%%%%%%%%%%%%%%%%%%%%%%%%%%

%llamo a la funcion de filtrar
%%//secmuestras_filt = filtrado(muest,filtrado_algoritmo,filtrado_orden,filtrado_rizado,filtrado_tipo,[fc1 fc2]/(Fs/2));
filtrado2(filtrado_algoritmo,filtrado_orden,filtrado_rizado,filtrado_tipo,[fc1 fc2]/(Fs/2));
