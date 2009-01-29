function [Numerador, Denominador]=CargarFiltro()
%
%  [ Numerador , Denominador ] = CargarFiltro()
%
%Básicamente esta función carga un fichero, que debe tener almacenado
%un filtro en forma de dos arrays numéricos: 'Num' para el numerador,
%y 'Den' para el denominador. Si el fichero cargado no contiene estas
%variables, o las contiene pero no son numéricas, se muestra un mensaje
%de error por pantalla, y se devuelve el filtro paso-todo, es decir,
%se devuelve Numerador = 1 y Denominador = 1.
%
%  Numerador: Numerador del filtro.
%  Denominador: Denominador del filtro.

%   J. de la Torre Peláez, 7-11-01.
%   Copyright (c) 2001-02 by DTE-Universidad de Málaga


[fname,pname] = uigetfile('*.mat','Elija el fichero que contiene el filtro deseado:');
if (fname==0 & pname==0),
   %Se ha pulsado 'Cancelar', se deja el filtro que hubiera previamente, para lo que 
   %se recurre a las variables globales:
   global Num Den;
else, %Cargamos el fichero, se supone que éste siempre tiene guardados numerador 
   %   y denominador en arrays numéricos llamados 'Num' y 'Den' respectivamente.
   load([pname,fname]); 
   if exist('Num','var') & exist('Den','var'),
      if isnumeric(Num) & isnumeric(Den),%Este 'if' debe ir dentro del anterior, puesto
         %                                que si no existieran las variables 'Num' y 'Den'
         %                                en el fichero cargado, se produciria un error.
         %El filtro Parece válido: existen las variables y son arrays numéricos.
         %No se hace nada, solo la linea comun del final de este script.
      else,
         mensaje=                'Filtro no válido: contiene Num y Den, pero no son tipos';
         mensaje=strvcat(mensaje,'numéricos, se deja el filtro que hubiera antes.');
         Aviso(mensaje);  
         %Se deja el filtro que hubiera previamente => se recurre a las variables globales:
         global Num Den;   
      end;
   else,
      mensaje=                'Filtro no válido: no contiene las variables Num y Den,';
      mensaje=strvcat(mensaje,'se deja el filtro que hubiera antes.');
      Aviso(mensaje);
      %Se deja el filtro que hubiera previamente => se recurre a las variables globales:
      global Num Den;   
   end;
end;

Numerador = Num;     Denominador = Den;
