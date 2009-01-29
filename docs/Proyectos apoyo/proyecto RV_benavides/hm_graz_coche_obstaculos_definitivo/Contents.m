%-----------------------------------------------------------------------------------
%  |||       Proyecto Albatros - Interfaz BCI - Herramienta de Medida          |||
%-----------------------------------------------------------------------------------
%Diagrama de Bloques de la Herramienta de Medida:
% HMPanel --> Ensayo --> Present --> Medir --> Prueba --> tiempo2frec --> Descursor
%     |                    |
%     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
%
%   J. de la Torre Peláez, 25-11-01.
%   Copyright (c) 2001-02 by Dpto. de Tecnología Electrónica - Universidad de Málaga
%------------------------------------------------------------------------------------
%
%   HMPanel
%
%ES EL PROGRAMA QUE HAY QUE LLAMAR PARA UTILIZAR LA HERRAMIENTA DE MEDIDA. Gestiona 
%la recogida de datos o parámetros del ensayo desde un panel de control, vigilando 
%que se introducen correctamente, y avisando por pantalla en caso de error. 
%
%
%   Ensayo
%
%Se responsabiliza de la organización general del ensayo, llamando al programa Present
%tantas veces como pruebas haya, grabando la estadística de aciertos/fallos, y grabando
%la configuración tras el ensayo y antes de salir.(Para mas información mirar dentro
%de este mismo programa).
%
%
%  Present
%
%Es el encargado de realizar los últimos ajustes en las distintas figuras que hay 
%abiertas antes de llamar al programa Medir. Además una vez terminado éste, si la 
%prueba era de tipo jugar y hubo acierto hace el parpadeo correspondiente usando 
%el programa Parpadeo.
%
%
%  Medir (function Medir)
%
%Inicializa la tarjeta, llama a Prueba.m, y se queda esperando a que pase el tiempo
%que dura una prueba(esto puede modificarse-ver instrucciones dentro del programa).
%Para esperar utiliza por defecto(si no se hace la modificacion) un pause(d_prueba).
%Cuando pasa el tiempo que dura la prueba, borra el objeto de entrada analogica, es
%decir el identificador de la tarjeta, y devuelve el control al programa que lo
%llamó(Present).
%
%
%  Prueba (function Prueba)
%
%Junto a Medir y tiempo2frec forma el corazón de la Herramienta. Es el encargado de 
%hacer aparecer el cursor y el objetivo en el momento adecuado, recoge las muestras 
%de la tarjeta y las manda analizar(tiempo2frec) e interpretar (Descursor). Como 
%Descursor desplaza el cursor en función de lo que interprete en el análisis en 
%frecuencia, al programa Prueba le resulta muy fácil averiguar si el cursor ha 
%alcanzado al objetivo. En tal caso PARA la adquisición de muestras, y completa con 
%ceros el resto de los vectores de muestras hasta completar la longitud que debieran
%tener en función de la duración con que se definió la prueba. Además graba todas las
%muestras, utilizando un fichero 'rti.mat' por prueba, donde la 'i' representa el 
%número de orden de la prueba en curso, y también graba los filtros que se han 
%diseñado para el ensayo en ficheros 'filtro_chk.mat' donde la 'k' representa el 
%número de orden del canal al que corresponde el filtro. (Mas info dentro del mismo
%programa).
%
%
%  Programa: TIEMPO2FREC (function tiempo2frec)
%
%Es el encargado de filtrar la señal y realizar su análisis en frecuencia(pero no
%interpretarlo, eso se deja a Descursor), asimismo representa gráficamente el 
%resultado de dicho análisis(si así se seleccionó en el panel) y graba el resultado
%de ese análisis en frecuencia en ficheros de la forma rfj.mat, donde la letra 'j' 
%identifica el orden de la prueba en curso.(Mas info sobre la funcion en si y como
%funciona dentro del programa).
%
%
%  Programa: Descursor (function Descursor)
%
%Esta función es la que evalúa los resultados de la estimación espectral 
%obtenidos en el programa llamante(tiempo2frec), Y en función de ellos realiza
%los movimientos oportunos del cursor.


     |                    -->Parpadeo
%     -->ModelarFiltros --> (NumdenFiltro1/2 --> GuardaPolin), PlotFiltro, Pulsador
SalirDeMatlab
SalirSesion
alargar
Aviso
