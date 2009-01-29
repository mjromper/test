function [matNums_sal,matDens_sal]=NumDenfiltro1(eje_salida,filtroi,algoritmo,orden,rizado,tipof,Wn,matNums_ent,matDens_ent)
%NUMDENFILTRO1  filtra una se�al usando uno de los distintos 
%			  m�todos que oferta MATLAB
%
%Par�metros de Salida:
%matNums_sal: matriz actualizada de coeficientes de los numeradores de  
%		las funciones de trasferencia del filtro.
%matDens_sal: matriz  actualizada de coeficientes de los denominadores  
%		de las funciones de trasferencia del filtro.
%
%Par�metros de Entrada:
%eje_salida: es el identificador del axe donde queremos que 
%            se dibuje la resp en frecuencia del filtro.
%filtroi:   Filtro con el que se esta trabajando actualmente
%algoritmo: El que se elija para filtrar(Ninguno=>pasotodo,
%				Butterworth o Chebyshev;
%orden:     El del algoritmo de filtrado;
%rizado:    Medido en dB, es el que tiene la banda de paso para
%           Chebyshev o el El�ptico;
%tipof:     Si es pasobajo, pasoalto, rechazobanda o pasobanda;
%Wn: frecuencias normalizadas, en el caso de un pasobanda deber�
%	  ser un vector con las dos frecuencias de la banda;
%matNums_ent: Matriz de coeficientes de los numeradores de las funciones
%		 de trasferencia del filtro.
%matDens_ent: Matriz de coeficientes de los denominadores de las funciones
%		 de trasferencia del filtro.
%
%Vea tambi�n: Butter, Cheby1, Cheby2, Ellip, Filter

%   J. de la Torre Pel�ez, 25-11-01.
%   Copyright (c) 2001-02 by DTE-Universidad de M�laga

%>>>>>>>>>>>>>>>>>Ver NOTAS al final de este script.

%1� ----------------->>------------------ Inicializacion de variables:
global nmfltros Fs;
global Num Den; %fdatool exporta las variables al Workspace, y saber si esas variables han
%                aparecido o no en el Workspace es la unica forma que tenemos de saber cuando
%                se ha terminado con fdatool. Por tanto, es necesario que usemos unas variables
%                'Num' y 'Den' globales.(Para comprender mejor esto, ver un poco mas adelante 
%                lo que se hace cuando se llama a fdatool).
%                ADEMAS: estas variables son tambien usadas aqui independientemente del tipo de
%                algoritmo elegido(Ninguno,Butterworth, Chebyshev,...,Cargar de un fichero,
%                Dise�ar). Asi que al finalizar la ejecucion de esta funcion, en 'Num' y 'Den'
%                siempre estara el filtro recien dise�ado. Para guardar el banco de filtros(for-
%                mado por todos los filtros dise�ados) se usan las variables 'matNums_sal' y 
%                'matDens_sal'(que son locales), como ya se ha dicho en la cabecera esta funcion.

%En 'Num' y 'Den' guardaremos los coeficientes del filtro que creemos aqu�, y despu�s los
%guardaremos en la fila 'filtroi' de las matrices de coeficientes de filtros 'matNums_sal' y
%'matDens_sal' que son las que se devuelven al programa que llam� esta funci�n.

%A nosotros s�lo nos interesa, de los vectores que nos pasan, los elementos que est�n en
%la posici�n 'filtroi', as� que por comodidad y teniendo en cuenta que son variables 
%locales, sacaremos ya:
algoritmo=	algoritmo(filtroi);
orden=	orden(filtroi);
rizado=	rizado(filtroi);
tipof=	tipof(filtroi);
Wn=		Wn(filtroi,:);

%2� ------------->>-------------- Calculo del Numerador y Denominador de la H(f) del filtro:
if (nargin<9 | nargin>9), 
   error('Faltan o sobran argumentos para filtrado.m, use HELP');
else,
   %Construimos la orden de texto que se le pasa al algorimo matlab para indicarle
   %el tipof de filtrado:
   if tipof==1, %pasobajo
      tipe='0';%No se indica nada en el tipo
      Wn=Wn(1,1);%S�lo se usa la primera frecuencia(f1) del vector Wn
   elseif tipof==2, %pasoalto
      tipe='high';
      Wn=Wn(1,1);%S�lo se usa la primera frecuencia(f1) del vector Wn
   elseif tipof==3, %pasobanda
      tipe='0';%No se indica nada en el tipo
      if length(Wn)~=2,
         Error('Wn debe ser un vector con dos frecuencias, vea el help');
      end;
   elseif tipof==4, %rechazobanda
      tipe='stop';
      if length(Wn)~=2,
         error('Wn debe ser un vector con dos frecuencias, vea el help');
      end;
   end;

   switch algoritmo, %Hallamos los coeficientes del filtro elegido:
   case 1, %Ninguno
      Num=1;
      Den=1;
	case 2, %Butterworth
      if tipe=='0',
         [Num,Den]= butter(orden,Wn);
      else
         [Num,Den]= butter(orden,Wn,tipe);
      end;
   case 3, %Bessel
      if tipe=='0',
         [Num,Den]= besself(orden,Wn);
      else
         [Num,Den]= besself(orden,Wn,tipe);
      end;
   case 4, %Chebyshev tipo I(rizado uniforme en la banda de paso)
      if tipe=='0',
         [Num,Den]= cheby1(orden,rizado,Wn);
      else
         [Num,Den]= cheby1(orden,rizado,Wn,tipe);
      end;
   case 5, %Chebyshev tipo II(rizado uniforme en la banda de rechazo)
      if tipe=='0',
         [Num,Den]= cheby2(orden,rizado,Wn);
      else
         [Num,Den]= cheby2(orden,rizado,Wn,tipe);
      end;
   case 6, %El�ptico
      %[B,A] = ELLIP(N,Rp,Rs,Wn)
      %Rp: Rizado en la banda de paso
      %Rs: Rizado en la banda de rechazo-->Este no lo pido, hago Rs=Rp*10;
      %Seg�n el Help, puede estar bien empezar por Rp=0.5dB y Rs=20dB;
      if tipe=='0',
         [Num,Den]= ellip(orden,rizado,rizado*10,Wn);
      else
         [Num,Den]= ellip(orden,rizado,rizado*10,Wn,tipe);
      end;   
   case 7, %Cargar filtro
      [Num,Den]= CargarFiltro;
   case 8, %fdatool(filter design tool)
      Num=[];%Las vaciamos(sirve para el control de fdatool).
      Den=[];%Las vaciamos(sirve para el control de fdatool).
      fdatool;%--->Devuelve Num y Den, tenemos que ir al men� File->Export to...->Workspace
      %Num=matNums_ent(filtroi,:); Den=matDens_ent(filtroi,:);
      %No devuelvo el control de ejecucion, hasta que no se devuelvan 'Num' o 'Den':
      tiempo=0;
      while isempty(Num),%exist('Num')==0;
         tiempo=tiempo+1; pause(1); disp(tiempo);
      end;
   otherwise,
      error('Se ha solicitado un algoritmo desconocido en filtrado.m, use: "help NumDenFiltro1".');
   end; %Del switch
   
   %3� ------------>>---------Actualizaci�n de las matrices de coeficientes de los filtos:
   matNums_sal = GuardaPolin(matNums_ent,filtroi,Num);
   matDens_sal = GuardaPolin(matDens_ent,filtroi,Den);
   
   %4� ------------>>--------------------------------------Plot del filtro:
   %Para resetear los ejes y hacer el plot, necesitamos establecerlo como los ejes
   %por defecto:
   axes(eje_salida);
   Accion_eje_salida=get(gca,'ButtonDownFcn');%Lo guardamos porque lo necesitaremos luego
   cla;  %Limpiamos eje_salida(donde se representa el modulo de la respuesta en
   %      frecuencia del filtro).
   %4.1� ----------- Filtro 'i' seleccionado actualmente:
   hold off;
   [H,f]=freqz(Num,Den,128,Fs);   plot(f,(abs(H)).^2); %Dibujamos el modulo de la respuesta en frecuencia.
   XLim_sup= max((abs(H)).^2); %Se usar� para fijar el l�mite superior del eje;
   %4.2� ----------- Calculo del Filtro total(formado por el producto de todos los existentes):
   Numtotal=1;
   Dentotal=1;
   for nf=1:nmfltros,
      Numtotal=conv(Numtotal,matNums_sal(nf,:));
      Dentotal=conv(Dentotal,matDens_sal(nf,:));
   end;
   hold on;
   [H,f]=freqz(Numtotal,Dentotal,128,Fs);   plot(f,(abs(H)).^2,':m'); %Dibujamos el modulo de la respuesta en frecuencia.
   XLim_sup= max(XLim_sup,max((abs(H)).^2));
   %NOTA: Cuidado porque 2 filtros pasobanda en serie, con bandas que no se cruzan, es lo mismo
   %		 que no dejar pasar nada de nada. Osea, que para hacer un filtro con 2 bandas de paso 
   %		 separadas usando filtros en paralelo, realmente ser�a mejor usar un paso banda y un 
   %		 rechazo banda. 
   %4.3� ----------- Actualizacion de los ejes:
   set(gca,'Xlim',[0,Fs/2],'Ylim',[0,1.1*XLim_sup],...%Reponemos las propiedades borradas con cla
      'XTick',[0 Fs/2],'XTickLabel',[0 Fs/2],'ButtonDownFcn',Accion_eje_salida);
   %---------------------------<<----------------------------------------Plot del filtro
end; %Del if (nargin<...

%IMPORTANTE:
%  Fijate que los filtros no necesitan conocer la frecuencia de muestreo:
%- Los metodos de calculo del Numerador y Denominador(butter, cheby1,...), los 
%  calculan para una frecuencia normalizada.
%- FILTER tampoco la necesita, Fs sera necesaria cuando se representen las se�ales
%  en el dominio de la frecuencia.

%NOTAS Aclaratorias en general:
%- Los m�todos Butter, Cheby1, ... dan los coeficientes para wn=1(osea no necesitan Fs)
%- filter NO NECESITA la frecuencia de muestreo de la se�al que filtra.
%- Soy yo el que introduce la frecuencia de muestreo al REPRESENTAR los datos.

%NOTAS sobre los m�todos[Discrete-Time Signal Processing, Alan V. Oppenheim, p.418]:
%- Butterworth es monot�nico en la banda de paso y de rechazo;
%- Chebyshev tipo I, tiene rizado uniforme en la banda de paso y un rizado que var�a 
%	monot�nicamente en la banda de rechazo.
%- Chebyshev tipo II es monot�nico en la banda de baso y de rizado uniforme en la de
%	rechazo.
%- Los filtros el�pticos tienen un rizado uniforme en ambas bandas, la de paso y la de
%	rechazo.

%NOTAS sobre los par�metros de los filtros:
%- Los filtros pueden calcularse de dos formas:
%� (orden,rizado,frecuencia/s de corte). �ste m�todo es el implementado por las 
%	funciones: Butter, Besself, Cheby1, Cheby2, Ellip.
%	El rizado s�lo sirve para Cheby1 y Cheby2, Ellip requiere dos par�metros de
%	rizado(el de la banda de paso y el de la de corte);
%	La frecuencia de corte ser� un s�lo n�mero cuando se trate de un filtro pasobajo
%	o pasoalto, y ser� dos n�meros cuando el filtro sea pasobanda o rechazobanda.
%	La frecuencia de corte indica para los filtros Butterworth y Bessel, la frecuencia
%	de 3dB de atenuaci�n respecto a la banda de paso. Para los filtros con rizado, 
%	dicha frec. de corte es aquella a la que se presenta una atenuaci�n de 'rizado' dB
%	respecto del m�ximo de la banda de paso.
%
%� (Wp:frec de paso, Ws:frec de corte, Rp:Rizado en la banda de paso, Rs:Rizado en la banda rechazo)
%	En este caso, lo que se hace es pedir con una funci�n(Butterord, Bessel NO TIENE, 
%	Cheb1ord, Cheb2ord, Ellipord) los par�metros (orden,rizado,frecuencia/s de corte) que
%	correspondan, y despu�s se llama a los m�todos que requer�an estos par�metros.
%	La frecuencia de paso podr� ser 1 o dos frecuencias dependiendo de si el filtro es
%	pasoalto/pasobajo o pasobanda/rechazobanda. En dicha banda de paso, se mantendr�
%	el rizado por debajo de lo indicado en Rp

      
   