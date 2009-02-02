function figureOpciones(nombre)

% Create figure
figure1 = figure('Renderer','painters','PaperType','a4letter',...
    'PaperSize',[20.98 29.68],...
    'NumberTitle','off',...
    'Name',nombre,...
    'Color',[0.753 0.753 0.753],...
    'Position',[770 600 250 225],...
    'Menubar','none',...
    'Resize','off',...
    'Pointer','arrow',...
    'HandleVisibility','on',...
    'BackingStore','on');

% Create axes
axes('Visible','off','Parent',figure1);
box('on');
grid('on');
hold('all');



% Create rectangle
annotation(figure1,'rectangle',[0.1275 0.1073 0.7815 0.8217],...
    'EdgeColor',[1 1 1],...
    'LineWidth',2);

% Create ellipse
annotation(figure1,'ellipse',[0.207 0.1929 0.6211 0.6515],...
    'EdgeColor',[1 1 1],...
    'LineWidth',2);

% Create textbox
annotation(figure1,'textbox','String',{'CANCELAR'},...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',8,...
    'FitHeightToText','off',...
    'LineStyle','none',...
    'Position',[0.1937 0.8198 0.1391 0.07725]);

% Create textbox
annotation(figure1,'textbox','String',{'GIRAR'},...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',8,...
    'FitHeightToText','off',...
    'LineStyle','none',...
    'Position',[0.7079 0.8147 0.1391 0.07725]);

% Create textbox
annotation(figure1,'textbox','String',{'CAMINAR'},...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',8,...
    'FitHeightToText','off',...
    'LineStyle','none',...
    'Position',[0.717 0.1817 0.1391 0.07725]);

% Create textbox
annotation(figure1,'textbox','String',{'OTROS'},...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',8,...
    'FitHeightToText','off',...
    'LineStyle','none',...
    'Position',[0.1567 0.1814 0.1889 0.07725]);

