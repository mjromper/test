function [mat_sal] = GuardaPolin(mat_ent,fila,polinomio);

%GuardaPolin(Guarda Polinomio);
%Esta funci�n surge de la necesidad de guardar un conjunto
%de polinomios en una matriz parcialmente redimensionable,
%es decir redimensionable s�lo en una dimensi�n(la horizon-
%tal=>variar n� de columnas).
%
%Partimos de una matriz con un n�mero fijo de filas(1 fila
%por polinomio) pero un n�mero variable de columnas, ya que
%los polinomios a�adidos pueden tener un orden muy alto,
%mayor que el de los que ya estan guardados.
%Cuando quiera introducir un polinomio nuevo en una fila
%concreta, deber� ver primero si cabe, y si no cabe, agrandar
%previamente la matriz. Asimismo, si el polinomio cabe a la
%primera deber� ver si puedo eliminar columnas de la matriz.
%
%Par�metros de entrada:
%- mat_ent: matriz de entrada.
%- fila: fila en la que quiero guardar el nuevo polinomio.
%- polinomio: coeficientes del polinomio que quiero guardar.
%
%Par�metros de salida:
%- mat_sal: matriz de salida con el nuevo polinomio.

[nf , nc] = size(mat_ent); %N� de filas(=n� de polinomios) y n� de columnas(=orden+1) de
%									 la matriz de polinomios de entrada.
long_pol_ent= length(polinomio); %Longitud del polinomio de entrada

if nc >= long_pol_ent,%El polinomio cabe en la matriz:
   %El polinomio [0 ... 0 a b ... z] es igual al [a b ... z];
   mat_sal = mat_ent;
   mat_sal(fila,:)= zeros(1,nc);%Para borrar el polinomio que hab�a guardado
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

