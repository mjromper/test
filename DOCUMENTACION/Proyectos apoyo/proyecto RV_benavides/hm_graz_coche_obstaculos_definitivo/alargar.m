%Este programa sirve para alargar una cadena de caracteres repitiendo 
%una secuencia que se le da:
%original: cadena de caracteres que se le da
%n_copias: numero de veces que queremos copiar esa cadena de caracteres.
%La entrada debe ser un string

function [y]=alargar(original,n_copias)
y=[];
for i=1:n_copias
    y=strcat(y,original);
end;
