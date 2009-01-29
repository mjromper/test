%
% Funcion DIBUJO(fig)
%
%   Dibujo es el encargado de dibujar la rueda adecuada en cada momento.
%   Comprueba una serie de variables, para saber que figura tiene que hacer.
%   Tiene que diferenciar entre la rueda principal y la auxiliar, y si es
%   la segunda, el bloque que hemos seleccionado.
%
%
% Diagrama de Bloques de la Herramienta de Medida:
%
% Panel --> Ensayo --> Medir --> Prueba --> tiempo2frec --> Desp_barra --> Desplaza --> Selec_bloque --> Selec_letra --> Escribe
%             |                                      |                                           |
%             ---> filtrar_eeg ---> filtrado         ---> filter                                 ---> dibujo(rued_aux)
%
%
% Vea tambien: pulsar
%
%
% Tomas Perez Lisbona - Dpto. de Tecnología Electrónica - Universidad de Málaga - 2007
%--------------------------------------------------------------------------------------------------------------

function dibujo(fig)

global color_texto color_gris texto principal tecla bloque 


a=0;        % 'a' es una variable local para moverme dentro de una cadena de caracteres
j=450;      % 'j' es una variable local que uso para dibujar las lineas de separación de la circunferencia
            % equivaldria a los grados de esta

if principal==1,            % compruebo si tengo q dibujar la rueda principal para asignar sus valores
    letras=('ABCDEFGHIJKLMNÑOPQRSTUVWXYZ-+'); % letras es la cadena de caracteres que voy a dibujar
    empieza=445;            % angulo donde empieza la primera letra -33.7445º =360º + 85º 
    termina_raya1=120;      % angulo donde va la ultima linea
    termina_raya2=120;      % angulo para finalizar la escritura de caracteres
    separa1=-33.7;          % grados de separación entre lineas
    separa2=-11.3;          % grados de separación entre letras
    pos_opcion=112;         % angulo donde dibujo la opción, el ultimo bloque("borrar")
    opcion=('Borrar');      % la cadena que dibujo en la opcion
    
else        %/ si no es la rueda "principal"  asigno los valores igual que antes, pero en la rueda auxiliar
    empieza=405;
    termina_raya1=160;
    termina_raya2=140;
    separa1=-90;
    separa2=-90;
    pos_opcion=135;
    
    if (tecla==5) | (tecla==6) | (tecla==8) | (tecla==9), % si las teclas tienen 4 caracteres los valores son diferentes
        empieza=414;
        separa1=-72;
        separa2=-72;
        pos_opcion=126;
    end,
    opcion=('atras');
    
    if tecla==1,            % si elegimos la tecla 1, dibujamos los caracteres 'A B C'
        letras=('ABC');
    elseif tecla==2,
        letras=('DEF');
    elseif tecla==3,
        letras=('GHI');
    elseif tecla==4,
        letras=('JKL');
    elseif tecla==5,
        letras=('MNÑO');
    elseif tecla==6,
        letras=('PQRS');
    elseif tecla==7,   
        letras=('TUV'); 
    elseif tecla==8,
        letras=('WXYZ');
    else
        letras=('_+-#');
    end,
end,    %/ "principal"

rueda=fig;          % figura que le hemos pasado
figure(rueda);
hold on;

%---------------------------------------------------------------------dibujo las lineas de separación de la rueda

for bloque=1:10             % como maximo dibujo 10 lineas de separacion de bloques
    if j>=termina_raya1,    % si llego a 'termina_raya' no dibujo mas lineas
        x=cosd(j);          
        y=sind(j);
        plot([1+(x*0.7) 1+x],[1+(y*0.7) 1+y],'color',[0 0 0],'LineWidth',2); % dibujo raya
        
        if (bloque<5) | (bloque==7)     % si son bloques de 3 caracteres 
            j=j+separa1;
        elseif (bloque==5) | (bloque==6) | (bloque==8)  % si son bloques de 4 caracteres, la separación aumenta
            j=j+separa1-11.3;
        end,

    end,    % end "if j" 
end,     % end "for bloque"

if principal==1             % si estoy en la rueda principal tengo q dibujar 'borrar'
    x=cosd(120);            % dibujo las lineas de separación de borrar, que lleva una posición concreta
    y=sind(120);
    plot([1+(x*0.7) 1+x],[1+(y*0.7) 1+y],'color',[0 0 0],'LineWidth',2);
end,


%---------------------------------------------------------------------dibujo cada una de las letras de la rueda
x=(0)* cosd(445);
y=(0)* sind(445);
for i= empieza: separa2 : termina_raya2     % bucle para dibujar los caracteres      
    a=a+1;                                  % con esta variable me muevo por la cadena de caracteres
    texto=uicontrol( ...                    % configuración de las letras
        'HorizontalAlignment','center',...
        'Style','text', ...
        'Units','cent', ...
        'Position',[7+x 7+y 0.4 0.4], ...
        'FontWeight', 'bold', ...
        'FontSize', 11, ...
        'FontName', 'Helvetica', ...
        'BackgroundColor',color_gris, ...   % Color del fondo
        'ForegroundColor',color_texto, ...
        'String',letras(a));                % cadena de caracteres 'letras' en la posición 'a'
    
    for bar=0: 0.4 :5         % voy desplazando desde el centro cada letra %/ esto ahora mismo no lo uso
        x=(bar)* cosd(i);
        y=(bar)* sind(i);
    
        set(texto,'HorizontalAlignment','center',...
            'Style','text', ...
            'Units','cent', ...
            'Position',[7+x 7+y 0.4 0.4], ...
            'FontWeight', 'bold', ...
            'FontSize', 11, ...
            'FontName', 'Helvetica', ...
            'BackgroundColor',color_gris, ... %Color del fondo de cada letra
            'ForegroundColor',color_texto, ...
            'String',letras(a));
        %pause(0.03)
    end,
end,

x=(bar+0.2)* cosd(pos_opcion);             % escribo el bloque de opción, "borrar" ó "atras"
y=(bar+0.2)* sind(pos_opcion);

texto=uicontrol( ...
    'HorizontalAlignment','center',...
    'Style','text', ...
    'Units','cent', ...
    'Position',[7+x 7+y 1.3 0.4], ...
    'FontWeight', 'bold', ...
    'FontSize', 11, ...
    'FontName', 'Helvetica', ...
    'BackgroundColor',color_gris, ... %Color del fondo de la letra
    'ForegroundColor',color_texto, ...
    'String',opcion);


