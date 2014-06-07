function varargout = img_clone(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_clone_OpeningFcn, ...
                   'gui_OutputFcn',  @img_clone_OutputFcn, ...
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


% --- Executes just before img_clone is made visible.
function img_clone_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
handles.flag = 0;
handles.down = 0;
handles.out = 0;
handles.patch_click = 0;
% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = img_clone_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in load_img.
function load_img_Callback(hObject, eventdata, handles)
[fileName pathName] = uigetfile({'*.jpg';'*.png'},'choose image file');
handles.imsrc = imread([pathName,fileName]);
set(handles.fileName,'String',fileName);
axes(handles.screen2);
hold on;
imshow(uint8(handles.imsrc));
handles.flag = 1;
guidata(hObject,handles);


% --- Executes on button press in paste.
function paste_Callback(hObject, eventdata, handles)
[I mask save saveb] = click;
handles.sImg = I;%source img
handles.save = save;
handles.saveb = saveb;
[smask b center] = cutBound(mask);%b:[up down left right]
 handles.pMask = smask;%patch mask(small)
 handles.pCenter = center;%patch center
 handles.recB = b;%rectangular patch bound
imc = [round(size(handles.imsrc,2)/2),round(size(handles.imsrc,1)/2)];%img_center [x y]
Op = move(handles.imsrc,I,smask,center,b,imc(1),imc(2));
 axes(handles.screen2);
 imshow(uint8(Op));
 handles.patch_click = 1;
guidata(hObject,handles);


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
if(handles.flag ==1)% image is loaded
    point = get(handles.screen2, 'CurrentPoint');
    [R C S]= size(handles.imsrc);
    handles.out = 0;
    %cursor is out of boundary
    if(point(1,1)<0 || point(1,1)> C || point(1,2)<0 || point(1,2)>R)
        set(handles.position,'String','');
        handles.out = 1;
    else% cursor is in the boundary
        set(handles.position,'String',['x = ',int2str(round(point(1,1))),' y = ',int2str(round(point(1,2)))]);
    end
    %
%     if(handles.down == 1 && handles.out == 0 && handles.patch_click ==1)
%         O = move(handles.imsrc,handles.sImg,handles.pCenter,handles.recB,point(1,1),round(point(1,1)),round(point(1,2)));
%         axes(handles.screen2);
%         imshow(uint8(O));
%     end
    guidata(hObject,handles);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
disp('down!!');
handles.down = 1;
guidata(hObject,handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
handles.down = 0;
if(handles.out ==0 && handles.patch_click==1)
point = get(handles.screen2, 'CurrentPoint');
O = move(handles.imsrc,handles.sImg,handles.pMask,handles.pCenter,handles.recB,round(point(1,1)),round(point(1,2)));
axes(handles.screen2);
imshow(uint8(O));
end
guidata(hObject,handles);