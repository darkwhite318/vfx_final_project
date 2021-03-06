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
%flow control flag
handles.load_img_flag = 0;
handles.out_flag = 0;
handles.patch_click_flag = 0;

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = img_clone_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in load_img.
function load_img_Callback(hObject, eventdata, handles)
%load tImg
[fileName pathName] = uigetfile({'*.jpg';'*.png'},'choose image file');
handles.tImg = imread([pathName,fileName]);
set(handles.fileName,'String',fileName);%set img name
%show tImg on the axes
axes(handles.screen2);
imshow(uint8(handles.tImg));
%set flag
handles.load_img_flag = 1;
 handles.patch_click_flag= 0;

guidata(hObject,handles);

% --- Executes on button press in save_img.
function save_img_Callback(hObject, eventdata, handles)
[fileName pathName] = uiputfile({'*.jpg';'*.png'},' key in file');
imwrite(handles.tImg,[pathName fileName]);
guidata(hObject,handles);

% --- Executes on button press in paste.
function paste_Callback(hObject, eventdata, handles)
if(handles.load_img_flag ==1)
%load data from sub GUI
[I mask save saveb maskin] = click;
handles.sImg = I;%source img
handles.sMask = mask;
handles.save = save;
handles.saveb = saveb;
handles.sMaskin = maskin;

%cut bound
[mask_small b center] = cutBound(mask);%b:[up down left right]
 handles.pMask = mask_small;%patch mask(small)
 handles.pCenter = center;%patch center
 handles.recB = b;%rectangular patch bound
 
%paste to the center of tImg
 imc = [round(size(handles.tImg,2)/2),round(size(handles.tImg,1)/2)];%img_center [x y]
Op = move(handles.tImg,I,handles.pMask,handles.pCenter,b,imc(1),imc(2));
handles.clonePoint = imc;%recent patch center
%update img 
axes(handles.screen2);
 imshow(uint8(Op));
 
 handles.patch_click_flag = 1;
guidata(hObject,handles);
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
if(handles.load_img_flag ==1)% image is loaded
    % cursor position tracking
    point = get(handles.screen2, 'CurrentPoint');
    [R C S]= size(handles.tImg);
    %out of axes checking
    handles.out_flag = 0;
    %cursor is out of boundary
    if(point(1,1)<0 || point(1,1)> C || point(1,2)<0 || point(1,2)>R)
        set(handles.position,'String','');
        handles.out_flag = 1;
    else% cursor is in the boundary
        set(handles.position,'String',['x = ',int2str(round(point(1,1))),' y = ',int2str(round(point(1,2)))]);
    end

    guidata(hObject,handles);
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
guidata(hObject,handles);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
if(handles.out_flag ==0 && handles.patch_click_flag==1)
point = get(handles.screen2, 'CurrentPoint');
handles.clonePoint = round(point);
O = move(handles.tImg,handles.sImg,handles.pMask,handles.pCenter,handles.recB,round(point(1,1)),round(point(1,2)));
axes(handles.screen2);
%hold on
imshow(uint8(O));
%plot(round(point(1,1)),round(point(1,2)),'b+');
%hold off
end
guidata(hObject,handles);


% --- Executes on button press in clone.
function clone_Callback(hObject, eventdata, handles)
%%  show patch pixel num
%num = sum(sum(handles.sMask));
% disp('num of total pixel points=');
% disp(num);
% %calc f-g for all boundary pixels
 numb = size(handles.saveb,1);
% disp('num of total boundary points=');
% disp(numb);
 numin = sum(sum(handles.sMaskin));
% disp('num of total inner pixel points=');
% disp(numin);
%% get differnce form source to target
% T = dif + S
dify = round(handles.clonePoint(1,2))-handles.pCenter(1);
difx = round(handles.clonePoint(1,1))-handles.pCenter(2);
u = handles.recB(1);
d = handles.recB(2);
l = handles.recB(3);
r = handles.recB(4);

%% calculate img difference and put them in the order of boundary list
[R C S] = size(handles.tImg);
diff_img = double(handles.tImg);
diff_img(u+dify:d+dify,l+difx:r+difx,:) = double(handles.tImg(u+dify:d+dify,l+difx:r+difx,:)) - double(handles.sImg(u:d,l:r,:));
diff_list = zeros(numb,3);
% diff_list5 = zeros(floor(numb/16),3);
for i = 1:numb
    diff_list(i,:) = diff_img(handles.saveb(i,2)+dify,handles.saveb(i,1)+difx,:);
end
% for j = 1:floor(numb/16)
%     diff_list5(j,:) = diff_list(j*16,:);
% end

handles.pMaskin = zeros(R,C);
handles.pMaskin(u+dify:d+dify,l+difx:r+difx) = handles.sMaskin(u:d,l:r);

new_img = handles.tImg;
%% calculate source and target mask list
tempx = difx*ones(numb,1);
tempy = dify*ones(numb,1);
temp = [tempx tempy];
bb = temp + handles.saveb;

pMaskin_list = zeros(numin,2);
count = 1;
for in1 = u+dify:d+dify
    for in2 = l+difx:r+difx
        if(handles.pMaskin(in1,in2))
           pMaskin_list(count,:) = [in2 in1];%[x y]
           count = count+1;
        end
    end
end
temp_mask_x = difx*ones(numin,1);
temp_mask_y = dify*ones(numin,1);
temp_mask = [temp_mask_x temp_mask_y];
sMaskin_list = pMaskin_list - temp_mask;

%% hierachical boundary sampling
% %construct hierachy
% hier_num = numb;
% level = 1;
% % ls_test = cell(14,1);
% % ls_test{1} = bb;
% hier_list = zeros(numb,2,14);
% hier_list(:,:,1) = bb;%use target boundary point list
% hier_num_list = zeros(14,1);
% hier_num_list(1,1) = numb;
% finalList = ones(numb,1);
% while(hier_num > 16)
%     hier_num_bound = hier_num-mod(hier_num,2);
%     for in = 2:2:hier_num_bound
%         hier_list(in/2,:,level+1) = hier_list(in,:,level);
%     end
% hier_num = hier_num_bound/2;
% hier_num_list(level+1,1) = hier_num;
% % ls_test{level+1} = hier_list(1:hier_num_list(level+1,1),:,level+1);
% level = level+1;
% end
% % axes(handles.screen2);
% % hold on;
% step = 2^(level-1); 
% for in1 = step : step : numb - mod(numb,step)
%     finalList(in1) = 0;
%     %plot(bb(in1,1),bb(in1,2),'r+');
% end
% tic
% O = hierachy(finalList,pMaskin_list(500,1),pMaskin_list(500,2),hier_list,hier_num_list,level-1);
% toc
% axes(handles.screen2);
% hold on;
% plot(pMaskin_list(500,1),pMaskin_list(500,2),'b+');
% for i = 1:size(O,1)
%     plot(O(i,1),O(i,2),'r+');
% end

% tic
% for iter = 1:numin
%     O = hierachy(finalList,pMaskin_list(iter,1),pMaskin_list(iter,2),hier_list,hier_num_list,level-1);
% end
% toc

%% run MVC on each point
%[R C S] = size(handles.pMaskin);

% iterations = [C R];
% parfor in = 1:prod(iterations)
%   [x,y] = ind2sub(iterations,in);
%   if(pMaskin(y,x) == 1)
%          new_img_p(in,:) = floor(double(handles.sImg(y,x,:)) + MVC(x,y,bb,diff_list));
%   end
% end

tic
for iter = 1:numin
    new_img(pMaskin_list(iter,2),pMaskin_list(iter,1),:) =  floor(double(handles.sImg(sMaskin_list(iter,2),sMaskin_list(iter,1),:)) + MVC(pMaskin_list(iter,1),pMaskin_list(iter,2),bb,diff_list));
end
toc
handles.tImg = new_img;

 %testing pixel unit
 %o = double(MVC(handles.clonePoint(1,1),handles.clonePoint(1,2),bb,diff_list));
 %v = double( handles.sImg(handles.clonePoint(1,2)-dify,handles.clonePoint(1,1)-difx,:));
 %oi = floor(o+v);
 %% %show
  %axes(handles.screen2);
  imshow(uint8(new_img));
guidata(hObject,handles);
