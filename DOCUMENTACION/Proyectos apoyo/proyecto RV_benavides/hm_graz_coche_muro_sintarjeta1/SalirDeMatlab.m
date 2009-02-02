
Screensize=get(0,'Screensize'); 
                               
AnchoS=Screensize(3);
AltoS=Screensize(4);
figs(2) = figure( 'Units','pixels', ...
            'position',[AnchoS/2-224 AltoS/2-64 448 128],...
            'Menubar','none',...
            'Colormap',bone(64),...
            'NumberTitle','off',...
            'Resize','Off');
        
IconAxes=axes( 'Units','pixels', ...
               'Position',[0 0 7*64 2*64], ...
               'HandleVisibility','on', ...
               'Tag','IconAxes');     

IconData=1:64;IconData=(IconData'*IconData)/64; 
                                                

Img=image('CData',IconData,'Parent',IconAxes);  
set(IconAxes, ...
      'XLim'            ,get(Img,'XData')+[-0.5 0.5], ...
      'YLim'            ,get(Img,'YData')+[-0.5 0.5], ...
      'Visible'         ,'off'                      , ...
      'YDir'            ,'reverse'                  , ...      
      'HandleVisibility','callback' );
        
 
Font.FontUnits='pixels';
Font.FontSize=get(0,'FactoryUIControlFontSize');
Font.FontName=get(0,'FactoryUIControlFontName');
        


MsgHandle=uicontrol(figs(2), Font, ...
                   'Style','text', ...
                   'Units','pixels', ...
                   'Position',[16 100 415 18 ] , ...
                   'String',['Si sale ahora de Matlab perdera todo lo que no grabo, �esta seguro?'], ...
                   'Tag','MessageBox' , ...
                   'HorizontalAlignment','left' , ...    
                   'BackgroundColor'    ,[0 0 0] , ... 
                   'ForegroundColor'    ,[0.8 0.9 1]    ... 
                   );

    AccionSi = ['close all; clear all;',...
                'quit'];
SiHandle=uicontrol(figs(2), Font, ...
                  'Style','pushbutton' , ...
                  'Units','pixels', ...
                  'Position',[50 25 80 40]  , ...
                  'CallBack',AccionSi, ...
                  'String','Si'  , ...
                  'TooltipString', 'Saldra de Matlab y se cerraran todas las ventanas', ...
                  'HorizontalAlignment','center'   , ...
                  'Tag','SiButton');
             
NoHandle=uicontrol(figs(2), Font, ...
                  'Style','pushbutton' , ...
                  'Units','pixels', ...
                  'Position',[448-50-80 25 80 40]  , ...
                  'CallBack','delete(get(0,''CurrentFigure''))', ...
                  'String','No'  , ...
                  'TooltipString', 'volver al entorno en que estaba', ...
                  'HorizontalAlignment','center'   , ...
                  'Tag','NoButton');
               
set(0,'PointerLocation',[round(Screensize(3)/2) round(Screensize(4)/2)]);

uiwait(figs(2)); 
               
               