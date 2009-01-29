function varargout = inicio(varargin)
% INICIO M-file for inicio.fig
%      INICIO, by itself, creates a new INICIO or raises the existing
%      singleton*.
%
%      H = INICIO returns the handle to a new INICIO or the handle to
%      the existing singleton*.
%
%      INICIO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INICIO.M with the given input arguments.
%
%      INICIO('Property','Value',...) creates a new INICIO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before inicio_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to inicio_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help inicio

% Last Modified by GUIDE v2.5 17-Nov-2008 19:02:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @inicio_OpeningFcn, ...
                   'gui_OutputFcn',  @inicio_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before inicio is made visible.
function inicio_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to inicio (see VARARGIN)
global cam;
global yo;
global player;
global direccion;
global camino;
global sig;
sig=0;

world = vrworld('./mundos/casavr.WRL');

paso=wavread('./mundos/step3.wav');
player = audioplayer(paso, 44100);

open(world);

fig_sujeto=vrfigure(world,[4 75 1300 750]);

 
set(0,'Units','cent');
Screensize=get(0,'Screensize'); 
posicion=[Screensize(3)/2-7.5 Screensize(4)/2-5];


cam = vrnode(world, 'Camera01');
yo = vrnode(world,'yo');

cam.position = [49   12  -1]; % posicion inicial
            camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.orientation = [0 -1 0 1.57];
            direccion=1;
            vrdrawnow;
% Choose default command line output for inicio
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes inicio wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = inicio_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;
ruedaOpciones;




% --- Executes on key press over start with no controls selected.
function start_KeyPressFcn(hObject, eventdata, handles)
	
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    


% --------------------------------------------------------------------
function lugar_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to lugar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam;
global direccion;
global camino;
global sig;
sig=0;
        if hObject == handles.pasillo
          
            cam.position = [49   12  -1]; % posicion inicial
            camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.orientation = [0 -1 0 1.57];
            direccion=1;
            vrdrawnow;
        elseif hObject == handles.salon
            camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.position = [113   12 20]; % posicion inicial
            cam.orientation = [0 -1 0 8.6386];
            direccion=1.5;
            vrdrawnow;
        elseif hObject == handles.terraza
            camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.position = [182   12  104]; % posicion inicial
            cam.orientation = [0 -1 0 11.7802];
            direccion=-2.5;
            vrdrawnow;
       elseif hObject == handles.bano
          	camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.position = [181    12    -1]; % posicion inicial
            cam.orientation = [0 -1 0 -6.2840];
            direccion=-2.5;
            vrdrawnow;
        elseif hObject == handles.dormitorio
            camino = [2 1 1 3 2 7 2 1 2 2 3 2 2 5];
            cam.position = [133   12  -52]; % posicion inicial
            cam.orientation = [0 -1 0 16.4926];
            direccion=2.5;
            vrdrawnow;
        end    
    



