function [mat_sal] = GuardaPolin(mat_ent,fila,polinomio);

%GuardaPolin(Guarda Polinomio);
%Esta función surge de la necesidad de guardar un conjunto
%de polinomios en una matriz parcialmente redimensionable,
%es decir redimensionable sólo en una dimensión(la horizon-
%tal=>variar nº de columnas).
%
%Partimos de una matriz con un número fijo de filas(1 fila
%por polinomio) pero un número variable de columnas, ya que
%los polinomios añadidos pueden tener un orden muy alto,
%mayor que el de los que ya estan guardados.
%Cuando quiera introducir un polinomio nuevo en una fila
%concreta, deberé ver primero si cabe, y si no cabe, agrandar
%previamente la matriz. Asimismo, si el polinomio cabe a la
%primera deberé ver si puedo eliminar columnas de la matriz.
%
%Parámetros de entrada:
%- mat_ent: matriz de entrada.
%- fila: fila en la que quiero guardar el nuevo polinomio.
%- polinomio: coeficientes del polinomio que quiero guardar.
%
%Parámetros de salida:
%- mat_sal: matriz de salida con el nuevo polinomio.

[nf , nc] = size(mat_ent); %Nº de filas(=nº de polinomios) y nº de columnas(=orden+1) de
%									 la matriz de polinomios de entrada.
long_pol_ent= length(polinomio); %Longitud del polinomio de entrada

if nc >= long_pol_ent,%El polinomio cabe en la matriz:
   %El polinomio [0 ... 0 a b ... z] es igual al [a b ... z];
   mat_sal = mat_ent;
   mat_sal(fila,:)= zeros(1,nc);%Para borrar el polinomio que había guardado
   mat_sal(fila,end-(long_pol_ent-1):end)= polinomio;
   %Aunque no es necesario, por elegancia vamos a borrar posibles columnas
   %columnas nulas que queden a la izquierda:
   while mat_sal(:,1)==zeros(nf,1),
      mat_sal=mat_sal(:,2:end);
   end;
else, %nc< long_pol_ent--> El polinomio no cabe, y hay que agrandar la matriz:
   %La matriz se agranda introduciendo ceros por la izquierda, ya que
   %el polinomio [0 ... 0 a b ... z] es igual al [a b ... z];
   mat_sal = [zeros(nf,long_pol_ent-nc) , mat_ent];
   mat_sal(fila,:)= polinomio;
end;

