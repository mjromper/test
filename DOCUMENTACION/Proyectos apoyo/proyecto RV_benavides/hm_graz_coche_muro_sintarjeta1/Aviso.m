%--------------------------------------------------------------------------
%funci�n Aviso(mensaje,figura,ancho)
%--------------------------------------------------------------------------
%Universidad de M�laga - Depto. Tecnolog�a Electr�nica
%Francisco Benavides Mart�n
%--------------------------------------------------------------------------

function Aviso(mensaje,figura,ancho)

if nargin==1
   figure(2); 
else
   figure(figura); 
end

if nargin<3
   [nf,nc]=size(mensaje); 
   ntce_min=0;
   for i=1:nf,
      n_ls=length(find(mensaje(i,:)=='l')); 
      n_is=length(find(mensaje(i,:)=='i')); 
      n_its=length(find(mensaje(i,:)=='�')); 
      n_js=length(find(mensaje(i,:)=='j')); 
      n_1s=length(find(mensaje(i,:)=='1')); 
      n_adm1s=length(find(mensaje(i,:)=='�')); 
      n_adm2s=length(find(mensaje(i,:)=='!')); 
      n_pnts=length(find(mensaje(i,:)=='.')); 
      n_cms=length(find(mensaje(i,:)==',')); 
      ntce= n_ls + n_is + n_its + n_js + n_1s + n_adm1s + n_adm2s + n_pnts + n_cms; 
      ntce_min= min(ntce,ntce_min); 
      ancho= floor((nc-ntce_min)*6.5) + ntce_min*3;
   end
else
   
end

unidades=get(0,'Units');	set(0,'Units','pixels');
Screensize=get(0,'Screensize'); 

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

IconData=1:64;IconData=(IconData'*IconData)/64; 

Img=image('CData',IconData,'Parent',IconAxes);  
set(IconAxes, ...
   'XLim',get(Img,'XData')+[-0.5 0.5], ...
   'YLim',get(Img,'YData')+[-0.5 0.5], ...
   'Visible','off', ...
   'YDir','reverse'                  , ...      
   'HandleVisibility','callback' );

Font.FontUnits='pixels';
Font.FontSize=get(0,'FactoryUIControlFontSize');
Font.FontName=get(0,'FactoryUIControlFontName');

Mensaje_Hndl= uicontrol(gcf,...
   Font, ...
   'Style','text', ...
   'Units','pixels', ...
   'Position',[16 100-18*(nf-1) ancho 18*nf ] , ... 
   'String',[mensaje], ...
   'Tag','MessageBox' , ...
   'HorizontalAlignment','left' , ...    
   'BackgroundColor'    ,[0 0 0] , ... 
   'ForegroundColor'    ,[0.8 0.9 1]);
                                  
Accion_OK = ['delete(gcf)'];
Boton_OK=uicontrol(gcf,...
   'Style','pushbutton',...
   'Units','pixels',...
   'Position',[224-40 20 80 40],...
   'CallBack',Accion_OK,...
   'String','�VALE!',...
   'HorizontalAlignment','center',... 
   'TooltipString','Lea la advertencia y pulse para continuar',...
   'HorizontalAlignment','center',...
   'Tag','OKButton');

              
set(0,'PointerLocation',[round(Screensize(3)/2) round(Screensize(4)/2)]);

uiwait(gcf);  
            
set(0,'Units',unidades);
               
