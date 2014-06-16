
function varargout = click(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @click_OpeningFcn, ...
                   'gui_OutputFcn',  @click_OutputFcn, ...
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



% --- Executes just before click is made visible.
function click_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
handles.flag = 0;% set to 1 after image is loaded
handles.check_plot = 0;% set to 1 after point is ploted
handles.out = 0;%set to 1 after the mouse point is out of the image
handles.check_cut = 0;%set to check if the cut button is clicked
handles.saveb = [];% save entire boundary point in clicking order
handles.save = []; % save the clicked boundary point in clicking order
handles.mask = 0; % save choosen clicking region
handles.fill = 0; %check if fill button is clicked
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes click wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = click_OutputFcn(hObject, eventdata, handles) 
%varargout{1} = handles.output;
varargout{1} = handles.output_1;%imsrc
varargout{2} = handles.output_2;%maskfill
varargout{3} = handles.output_3;%save
varargout{4} = handles.output_4;%saveb
varargout{5} = handles.output_5;%maskfill-mask
delete(handles.figure1);


% --- Executes on button press in load_image.
function load_image_Callback(hObject, eventdata, handles)
[fileName pathName] = uigetfile({'*.jpg';'*.png'},'choose image file');
handles.fName = fileName;
handles.pName = pathName;
handles.imsrc = imread([pathName,fileName]);
handles.output_1 = handles.imsrc;
handles.mask = zeros(size(handles.imsrc,1),size(handles.imsrc,2));
%image show
hold off;
axes(handles.screen);
imshow(uint8(handles.imsrc));
set(handles.fileName,'String',fileName);

handles.flag = 1;
handles.fill = 0;
guidata(hObject,handles);


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)%show cursor position 
if(handles.flag ==1)% image is loaded
    point = get(handles.screen, 'CurrentPoint');
    [R C S]= size(handles.imsrc);
    handles.out = 0;
    %cursor is out of boundary
    if(point(1,1)<0 || point(1,1)> C || point(1,2)<0 || point(1,2)>R)
        set(handles.position,'String','');
        handles.out = 1;
    else% cursor is in the boundary
        set(handles.position,'String',['x = ',int2str(round(point(1,1))),' y = ',int2str(round(point(1,2)))]);
    end
    guidata(hObject,handles);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
global savea;
%click boundary reference point
if((handles.out==0) &&(handles.flag ==1) && (handles.fill == 0))
    if(handles.check_cut ==0)
        if(handles.check_plot ==0)
            savea = [];
        end
        point = get(handles.screen,'CurrentPoint');
        savea = [savea ;round(point(1,1)),round(point(1,2))];
        handles.save = savea;
        axes(handles.screen);
        hold on;
        %handles.ploting = plot(handles.save(:,1),handles.save(:,2),'y.');
        plot(round(point(1,1)),round(point(1,2)),'y.');
        
        handles.check_plot = 1;
        
    else % filling
%         point = get(handles.screen, 'CurrentPoint');
%         handles.mask(point(1,2),point(1,1)) = 1;
        handles.maskfill = imfill(handles.mask,'holes');
        handles.output_2 = handles.maskfill;
        handles.output_5 = handles.maskfill - handles.mask;
%         axes(handles.screen);
%         imshow(handles.mask);

        %coloring the patch
        patch_img = uint8(~(handles.maskfill));
        handles.src1 = handles.imsrc;
        handles.src1(:,:,1) = handles.imsrc(:,:,1).*patch_img;
        handles.src1(:,:,1) = handles.imsrc(:,:,1) + uint8(handles.maskfill)*200;
        axes(handles.screen);
        imshow(uint8(handles.src1));
        handles.fill = 1;
        uiresume(handles.figure1);
    end
    guidata(hObject,handles);
end

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
if(handles.check_plot == 1)
    handles.save = [];
    handles.saveb = [];
    handles.imsrc = imread([handles.pName,handles.fName]);
    handles.mask = zeros(size(handles.imsrc,1),size(handles.imsrc,2));
    handles.check_plot = 0;
    handles.check_cut = 0;
    handles.fill = 0;
    hold off;
    axes(handles.screen);
    imshow(uint8(handles.imsrc));
    guidata(hObject,handles);
end


% --- Executes on button press in cut.
function cut_Callback(hObject, eventdata, handles)
if(handles.check_plot ==1 && handles.check_cut == 0)
    saveb = [];
    num = size(handles.save,1);
    for in = 1:num-1
        %line([handles.save(in+1,1) handles.save(in,1)],[handles.save(in+1,2),handles.save(in,2)]);
        m = (handles.save(in+1,2)-handles.save(in,2))/(handles.save(in+1,1)-handles.save(in,1));
        if(handles.save(in+1,1)-handles.save(in,1) == 0)
            m =  (handles.save(in+1,2)-handles.save(in,2))/ 0.0001;
        end
        c = handles.save(in,2)-m*handles.save(in,1);
        if(abs(m)<1)
        step = sign(handles.save(in+1,1)-handles.save(in,1));
            for x = handles.save(in,1):step:handles.save(in+1,1)-1
                y = round(m*x+c);
                saveb = cat(1,saveb,[x,y]);
                %saveb = [saveb;x,y];
                handles.mask(y,x) = 1;
                plot(x,y,'y.');
            end
        else
            step = sign(handles.save(in+1,2)-handles.save(in,2));
            for y = handles.save(in,2):step:handles.save(in+1,2)-1
                x = round((y-c)/m);
                saveb = cat(1,saveb,[x,y]);
                %saveb = [saveb;x,y];
                handles.mask(y,x) = 1;
                plot(x,y,'y.');
            end
        end       
    end
    %line([handles.save(num,1) handles.save(1,1)],[handles.save(num,2),handles.save(1,2)]);
    m = (handles.save(1,2)-handles.save(num,2))/(handles.save(1,1)-handles.save(num,1));
    if((handles.save(1,1)-handles.save(num,1)) == 0)
        m = (handles.save(1,2)-handles.save(num,2))/0.0001;
    end
    c = handles.save(num,2)-m*handles.save(num,1);
    if(abs(m)<1)
        step = sign(handles.save(1,1)-handles.save(num,1));
        for x = handles.save(num,1):step:handles.save(1,1)-1
            y = round(m*x+c);
            saveb = cat(1,saveb,[x,y]);
            %saveb = [saveb;x,y];
            handles.mask(y,x) = 1;
            plot(x,y,'y.');
        end
    else
        step = sign(handles.save(1,2)-handles.save(num,2));
        for y = handles.save(num,2):step:handles.save(1,2)-1
            x = round((y-c)/m);
            saveb = cat(1,saveb,[x,y]);
            %saveb = [saveb;x,y];
            handles.mask(y,x) =1;
            plot(x,y,'y.');
         end
    end
    handles.saveb = saveb;
    %dlmwrite('out.txt',saveb);
    handles.output_3 = handles.save;
    handles.output_4 = handles.saveb;
    handles.check_cut = 1;
    guidata(hObject,handles);
end

