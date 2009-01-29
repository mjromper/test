%función Aviso(mensaje,figura,ancho)
%Muestra por pantalla una advertencia o aviso al usuario. Dicha 
%advertencia se pasa en la variable 'mensaje'. Sino se le indica
%un número de figura concreto, por defecto dibuja en la figure(2),
%pues se hizo pensando en los programas del proyecto BCI.
%Como hace un dibujo en la figura, al representar el texto usando
%uicontrols, hay que borrar parte de él, y convendrá que se borre
%lo justo para que quede presentable. Esta función incluye un 
%pequeño procedimiento para calcular el ancho de dibujo que hace
%falta borrar, pero no siempre queda bien, en tal caso podemos
%pasarle nosotros el ancho(en pixels) que estimemos adecuado.
%
%Universidad de Málaga - Depto. Tecnología Electrónica - Proyecto Albatros - Interfaz BCI
%Francisco Benavides Martín.

function Aviso(mensaje,figura,ancho)

%Creación de la figura en la que irá el aviso:
if nargin==1,
   figure(2); %Figura por defecto
else,
   figure(figura); %Figura solicitada
end;

%Cálculo del ancho de texto necesario(se usará en el uicontrol mensaje_Hndl):
if nargin<3, %Hay que calcularlo porque no se nos ha dado:
   [nf,nc]=size(mensaje); %nf= nº filas del msj; nc = nº col. del msj
   %Intento hallar aproximadamente el ancho en pixels, que ocupará el texto que me han dado:
   %Para ello cuento el número de caracteres estrechos(i,j,l,1,¡,!) que hay en cada fila.
   ntce_min=0;
   for i=1:nf,
      n_ls=length(find(mensaje(i,:)=='l')); %Número de veces que aparece la letra 'l' en la linea i.
      n_is=length(find(mensaje(i,:)=='i')); %Número de veces que aparece la letra 'i' en la linea i.
      n_its=length(find(mensaje(i,:)=='í')); %Número de veces que aparece la letra 'i' tildada en la linea i.
      n_js=length(find(mensaje(i,:)=='j')); %Número de veces que aparece la letra 'j' en la linea i
      n_1s=length(find(mensaje(i,:)=='1')); %Número de veces que aparece el nº '1' en la linea i
      n_adm1s=length(find(mensaje(i,:)=='¡')); %Número de veces que aparece el carácter '¡' en la linea i.
      n_adm2s=length(find(mensaje(i,:)=='!')); %Número de veces que aparece el carácter '!' en la linea i.
      n_pnts=length(find(mensaje(i,:)=='.')); %Número de veces que aparece el carácter '.' en la linea i.
      n_cms=length(find(mensaje(i,:)==',')); %Número de veces que aparece el carácter ',' en la linea i.
      ntce= n_ls + n_is + n_its + n_js + n_1s + n_adm1s + n_adm2s + n_pnts + n_cms; %Número total de caracteres estrechos
      ntce_min= min(ntce,ntce_min); %Nos quedamos el mínimo
      ancho= floor((nc-ntce_min)*6.5) + ntce_min*3;%depende tb del tipo de letra
   end;
else, %(nargin>=3)
   %Nada, ya se habrá indicado en la variable ancho
end;

unidades=get(0,'Units');	set(0,'Units','pixels');
Screensize=get(0,'Screensize'); %Tomo el tamaño de la pantalla; Deberia poder usarlo con
%											'position' en las figuras, pero hace cosas raras.
AnchoS=Screensize(3);
AltoS=Screensize(4);
set(gcf, 'Units','pixels', ...
   'position',[AnchoS/2-224 AltoS/2-64 448 128],...
   'Name','Advertencia',...
   'Menubar','none',...
   'Colormap',bone(64),...
   'NumberTitle','off',...
   'Resize','Off');
        
IconAxes=axes( 'Units','pixels', ...
   'Position',[0 0 7*64 2*64], ...
   'HandleVisibility','on', ...
   'Tag','IconAxes');     

IconData=1:64;IconData=(IconData'*IconData)/64; %Cada número de estos indica un color del
                                                %mapa de colores(Colormap) que hayamos elegido(bone)

Img=image('CData',IconData,'Parent',IconAxes);  
set(IconAxes, ...
   'XLim',get(Img,'XData')+[-0.5 0.5], ...%XData me da la longitud en dir X de la Img
   'YLim',get(Img,'YData')+[-0.5 0.5], ...%...dir Y...
   'Visible','off', ...%Que no se vean los ejes
   'YDir','reverse'                  , ...      
   'HandleVisibility','callback' );
%XLim e YLim marcan el rango de los ejes.

%Definimos la siguiente estructura, que posteriormente usaremos en los uicontrols:
Font.FontUnits='pixels';
Font.FontSize=get(0,'FactoryUIControlFontSize');
Font.FontName=get(0,'FactoryUIControlFontName');

Mensaje_Hndl= uicontrol(gcf,...
   Font, ...%Curioso, verdad?
   'Style','text', ...
   'Units','pixels', ...
   'Position',[16 100-18*(nf-1) ancho 18*nf ] , ... %7 pixels es el promedio de puntos por letra
   'String',[mensaje], ...
   'Tag','MessageBox' , ...
   'HorizontalAlignment','left' , ...    
   'BackgroundColor'    ,[0 0 0] , ... %Lo suyo seria que hubiera un color trasparente
   'ForegroundColor'    ,[0.8 0.9 1]);%Color del texto
                                  
Accion_OK = ['delete(gcf)'];
Boton_OK=uicontrol(gcf,...
   'Style','pushbutton',...
   'Units','pixels',...
   'Position',[224-40 20 80 40],...
   'CallBack',Accion_OK,...
   'String','¡VALE!',...
   'HorizontalAlignment','center',... 
   'TooltipString','Lea la advertencia y pulse para continuar',...
   'HorizontalAlignment','center',...
   'Tag','OKButton');

              
set(0,'PointerLocation',[round(Screensize(3)/2) round(Screensize(4)/2)]);

uiwait(gcf);  %Espera a que se pulse un boton dentro de la ventana, pero no trae cuenta porque
            %sin él, puede pulsarse tambien cualquier tecla. Lo q me gustaria es que se bloqueara
            %esa ventana y no se pudiera hacer otra cosa hasta que no se pulse el boton.
set(0,'Units',unidades);%Reponemos el valor que tuviera antes de llamarse a este programa
               
