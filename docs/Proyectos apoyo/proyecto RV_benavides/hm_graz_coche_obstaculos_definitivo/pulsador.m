%Pulsador.m
%Sirve de pulsador entre figuras. Aprovecha la misma figura, dibujando un bot�n sobre
%ella, que se borrar� posteriormente al ser pulsado.

set(gcf,'Units','points'); %Nos aseguramos de que la figura actual tiene sus unidades en 'puntos'
figure_size=get(gcf,'Position'); %Tomamos la posici�n y tama�o de la figura actual
                                   
%Construimos el registro Font, que se usar� en el bot�n para indicar ciertas propiedades:
Font.FontUnits='points';
Font.FontSize=25; %get(0,'FactoryUIControlFontSize');
Font.FontName=get(0,'FactoryUIControlFontName');
Font.FontWeight='bold'; %get(0,'FactoryUIControlFontWeight');
%Dibujamos el bot�n
BotonHandle=uicontrol(gcf, Font, ...
                  'Style','pushbutton', ...
                  'Units','points', ...
                  'Position',[figure_size(3)-30 0 30 22], ...
                  'CallBack','set(BotonHandle,''visible'',''off''); clear BotonHandle;', ...
                  'String','>>', ...
                  'Tooltipstring','Pulse para continuar',...
                  'HorizontalAlignment','center', ...
                  'Tag','OKButton');


waitfor(BotonHandle,'visible','off');  %Obliga a que se pulse el bot�n antes de continuar,
%													 resulta �til para detener la ejecuci�n y adaptarla
%													 al ritmo del usuario.
%Existe otra instrucci�n parecida a WAITFOR, que es UIWAIT, y que espera a que se cierre la
%ventana para continuar
               
