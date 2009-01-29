function filtrado2(algoritmo,orden,rizado,tipof,Wn)      %%// he quitado entrada_t porq filtro en tiempo2frec
%%//function filtrado(entrada_t,algoritmo,orden,rizado,tipof,Wn)

%FILTRADO  filtra una señal usando uno de los distintos 
%			  métodos que oferta MATLAB
%
%salida_t: secuencia de muestras de salida ya filtrada;
%entrada_t: secuencia de muestras de entrada sin filtrar;
%algoritmo: el que se elija para filtrar(Ninguno=>pasotodo,
%				Butterworth o Chebyshev;
%orden: el del algoritmo de filtrado;
%rizado: medido en dB, es el que tiene la banda de paso para
%			Chebyshev o el Elíptico;
%tipof: si es pasobajo, pasoalto, rechazobanda o pasobanda;
%Wn: frecuencias normalizadas, en el caso de un pasobanda deberá
%	  ser un vector con las dos frecuencias de la banda;
%
%Vea también: Butter, Cheby1, Cheby2, Ellip, Filter

%   J. de la Torre Peláez, 25-11-01.
%   Copyright (c) 2001-02 by DTE-Universidad de Málaga
%%//-----------------------------------------------------------------------
%%// 
%%//   me da los valores B y A para el filtrado
%%//
%%//-----------------------------------------------------------------------


global B A

if (nargin<5 | nargin>5), 
   Error('Faltan o sobran argumentos para filtrado.m, use HELP');
else,
   %Construimos la orden de texto que se le pasa al algorimo matlab para indicarle
   %el tipof de filtrado:
   if tipof==1, %pasobajo
      tipe='0';%No se indica nada en el tipo
      Wn=Wn(1,1);%Sólo se usa la primera frecuencia(f1) del vector Wn
   elseif tipof==2, %pasoalto
      tipe='high';
      Wn=Wn(1,1);%Sólo se usa la primera frecuencia(f1) del vector Wn
   elseif tipof==3, %pasobanda
      tipe='0';%No se indica nada en el tipo
      if length(Wn)~=2,
         %disp('Wn debe ser un vector con dos frecuencias, vea el help');
         Error('Wn debe ser un vector con dos frecuencias, vea el help');
      end;
   elseif tipof==4, %rechazobanda
      tipe='stop';
      if length(Wn)~=2,
         Error('Wn debe ser un vector con dos frecuencias, vea el help');
      end;
   end;

   switch algoritmo, %Hallamos los coeficientes del filtro elegido:
   case 1, %Ninguno
%%//      salida_t= entrada_t; %No hacemos nada
      return;               %%// break; me da error el break pongo reurn
	case 2, %Butterworth
      if tipe=='0',
         [B,A]= butter(orden,Wn);
      else
         [B,A]= butter(orden,Wn,tipe);
      end;
   case 3, %Chebyshev
      if tipe=='0',
         [B,A]= cheby1(orden,rizado,Wn);
      else
         [B,A]= cheby1(orden,rizado,Wn,tipe);
      end;
   case 4, %Elíptico
      if tipe=='0',
         [B,A]= ellip(orden,rizado,Wn);
      else
         [B,A]= ellip(orden,rizado,Wn,tipe);
      end;   
   case 5, %Un filtro propio que creemos nosotros
      %B=...
      %A=...
      aviso('No hay ninguno disponible actualmente');%No hacemos nada con la señal y cortamos:
%%//      salida_t= entrada_t; return;               %%// break; me da error el break pongo reurn
   otherwise,
      Error('Se ha solicitado un algoritmo desconocido en filtrado.m, use: "help filtrado"');
   end; %Del switch
   B; %%NV
   A;%%NV
   
   
%%//   salida_t= filter(B,A,entrada_t); %  <<--------------Hacemos el filtrado
   
end; %Del if (nargin<...

      
      
   