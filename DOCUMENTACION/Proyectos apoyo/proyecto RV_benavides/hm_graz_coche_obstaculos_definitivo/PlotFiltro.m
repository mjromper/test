function PlotFiltro(filtroi,matNums_ent,matDens_ent,eje_filtro)
%PLOTFILTRO: 
%Simplemente dibuja el filtro actual y el global en los ejes que se le pasan y
%mantiene la ButtonDownFcn que tuvieran asociada los ejes del plot.
%
%filtroi:   Filtro con el que se esta trabajando actualmente.
%matNums_ent: matriz de coeficientes de los numeradores de las funciones de 
%		trasferencia del filtro.
%matDens_ent: matriz de coeficientes de los denominadores de las funciones de 
%		trasferencia del filtro.
%eje_filtro: es el identificador del axe donde se dibuja la resp
%				 en frecuencia del filtro.
%

%   J. de la Torre Peláez, 25-11-01.
%   Copyright (c) 2001-02 by DTE-Universidad de Málaga


%----------------->>------------------ Inicializacion de variables:
global Fs; %frecuencia de muestreo(definida en el programa principal)
global nmfltros; %numero de filtros(definida en el programa principal)

%------------>>--------------------------------------Plot del filtro:
%Para resetear los ejes y hacer el plot, necesitamos establecerlo como los ejes
%por defecto:
axes(eje_filtro);
Accion_eje_salida= get(gca,'ButtonDownFcn');%Lo guardamos porque lo necesitaremos luego
cla;  %Limpiamos eje_filtro(donde se representa el modulo de la respuesta en
%      frecuencia del filtro).

%----------- Filtro 'i' seleccionado actualmente:
hold off;
[H,f]=freqz(matNums_ent(filtroi,:),matDens_ent(filtroi,:),128,Fs);   plot(f,(abs(H)).^2); %Dibujamos el modulo de la respuesta en frecuencia.
XLim_sup= max((abs(H)).^2); %Se usará para fijar el límite superior del eje;

%----------- Calculo del Filtro total(formado por el producto de todos los existentes):
Numtotal=1;
Dentotal=1;
for nf=1:nmfltros,
   Numtotal=conv(Numtotal,matNums_ent(nf,:));
   Dentotal=conv(Dentotal,matDens_ent(nf,:));
end;
hold on;
[H,f]=freqz(Numtotal,Dentotal,128,Fs);   plot(f,(abs(H)).^2,':m'); %Dibujamos el modulo de la respuesta en frecuencia.
XLim_sup= max(XLim_sup,max((abs(H)).^2));

%----------- Actualizacion de los ejes:
set(gca,'Xlim',[0,Fs/2],'Ylim',[0,1.1*XLim_sup],...%Reponemos las propiedades borradas con cla
      'XTick',[0 Fs/2],'XTickLabel',[0 Fs/2],'ButtonDownFcn',Accion_eje_salida);
   
   
   