function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 19-Jun-2014 20:30:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

global origim;
global matting;
global SegImg;
global FinalAlpha NumofComp;
NumofComp=7;
SegImg=[];
FinalAlpha=[];
origim=[];
matting=0;
set(handles.edit1,'string',num2str(NumofComp));
set(handles.uipanel12,'SelectedObject',[]);  %na mn einai epilegmeno forgr h backgr button
%set(handles.foregroundscrbl,'Enable','off');
% set(handles.backgroundscrbl,'Enable','off');
%set(handles.rectangleb,'Enable','off');
imshow([],'Parent',handles.origimg);        
imshow([],'Parent',handles.rectimg);
imshow([],'Parent',handles.fbimg);
imshow([],'Parent',handles.resultimg);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_Callback(hObject, eventdata, handles)   

% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function openimg_Callback(hObject, eventdata, handles)

cla(handles.origimg,'reset');
cla(handles.rectimg,'reset');
cla(handles.fbimg,'reset');
cla(handles.resultimg,'reset');
imshow([],'Parent',handles.origimg);        
imshow([],'Parent',handles.rectimg);
imshow([],'Parent',handles.fbimg);
imshow([],'Parent',handles.resultimg);
[filename, pathname]=uigetfile('*.jpg;*.png;*.tif;*.gif;*.bmp', 'Choose An image');
fullname=fullfile(pathname, filename);
global origim;
origim=imread(fullname);
imshow(origim,'Parent',handles.origimg);
%set(handles.rectangleb,'Enable','on')



% --------------------------------------------------------------------
function saveimg_Callback(hObject, eventdata, handles)
global SegImg SegImg2;
global MatImg;
global matting scribblesimg origim;
global rect;
[FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Segmented Image As','C:\Users\vaggoss\Desktop');
Name = fullfile(PathName,FileName);  
imwrite(im2uint8(SegImg), Name, 'jpg');

if(matting)
    [FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Matted Image As','C:\Users\vaggoss\Desktop');
    Name = fullfile(PathName,FileName);  
    imwrite(im2uint8(MatImg), Name, 'jpg');
end
if(~isequal(scribblesimg,origim))
    [FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Scribbled Image As','C:\Users\vaggoss\Desktop');
    Name = fullfile(PathName,FileName);  
    imwrite(scribblesimg, Name, 'jpg');
    
    [FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Segmente Image 2 As','C:\Users\vaggoss\Desktop');
    Name = fullfile(PathName,FileName);  
    imwrite(SegImg2, Name, 'jpg');
    
    h=figure('Color',[1 1 1]);
    imshow(origim);
    rectangle('Position',rect,'EdgeColor','r','LineWidth',3);
    f=getframe(h);
    [X, map] = frame2im(f);
    [FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Rect Image As','C:\Users\vaggoss\Desktop');
    Name = fullfile(PathName,FileName);  
    imwrite(im2uint8(X), Name, 'jpg');
else
    h=figure('Color',[1 1 1]);
    imshow(origim);
    rectangle('Position',rect,'EdgeColor','r','LineWidth',3);
    f=getframe(h);
    [X, map] = frame2im(f);
    [FileName, PathName] = uiputfile({'*.jpg;*.png;*.tif;*.gif;*.bmp', 'All Image Files(*.jpg;*.png;*.tif;*.gif;*.bmp)';'*.*','All Files' },'Save Rect Image As','C:\Users\vaggoss\Desktop');
    Name = fullfile(PathName,FileName);  
    imwrite(im2uint8(X), Name, 'jpg');
end


% --- Executes on button press in rectangleb.
function rectangleb_Callback(hObject, eventdata, handles)
global origim;
global rect;
global  scribblesimg;
global alpha;
if(isempty(origim))
    imshow('','Parent',handles.rectimg);
else
    imshow(origim,'Parent',handles.rectimg);
    rect=round(getrect(handles.rectimg));
    rectangle('Position',rect,'EdgeColor','r','LineWidth',3);
    alpha=zeros(size(origim,1),size(origim,2));
    alpha(rect(2):rect(2)+rect(4),rect(1):rect(1)+rect(3))=1;
    scribblesimg=origim;
    
end





% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% Hint: get(hObject,'Value') returns toggle state of togglescribbles


% --- Executes when selected object is changed in uipanel12.
function uipanel12_SelectionChangeFcn(hObject, eventdata, handles)
global medianC;
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'foregroundscrbl'
        medianC(1)=0;
        medianC(2)=0;
        medianC(3)=1;
    case 'backgroundscrbl'
        medianC(1)=1;
        medianC(2)=0;
        medianC(3)=0;
    
        
end


% --- Executes on button press in scribblebutton.
function scribblebutton_Callback(hObject, eventdata, handles)

 global medianC;
 global scribblesimg;
scribblesimg =fbscribbles(scribblesimg,medianC,hObject, handles.rectimg);


% --- Executes during object deletion, before destroying properties.
function scribblebutton_DeleteFcn(hObject, eventdata, handles)
    global scribblesimg;
    scribblesimg=0;
    
    
    


% --- Executes on button press in algbutton.
function algbutton_Callback(hObject, eventdata, handles)
global origim;
global SegImg;
global SegImg2;
global MatImg;
global FinalAlpha;
global scribblesimg;
global alpha NumofComp matting;

imd=im2double(origim);
contents = get(handles.popupmenu2,'String'); 
popupmenu2value = contents{get(handles.popupmenu2,'Value')};

switch popupmenu2value
    case 'Run full algorithm'
        
        changed_f=[];
        changed_b=[];
   
        FinalAlpha=algorithm(alpha,imd,NumofComp,5,50,0,0,changed_f,changed_b);
        FinalAlpha=reshape(FinalAlpha,size(imd,1),size(imd,2));
        SegImg=imd.*repmat(FinalAlpha,[1 1 3]);
        imshow(SegImg,'Parent',handles.fbimg);
        if(matting)
            FinalAlpha=im2double(FinalAlpha);
            Contour=bwmorph(FinalAlpha,'remove');
            SE = strel('square', 13);
            U = imdilate(Contour,SE);
            FinalAlpha(U)=0.5;

            Trimap=FinalAlpha;
            NeighNum=41;
            VarC=0.01;
            MaxIter=10;
            minL=1e-6;
            [ MatImg ] = BayesianMatting( imd, Trimap, NeighNum ,VarC, MaxIter, minL);
            imshow(MatImg,'Parent',handles.resultimg);
        end
    case 'After further user editing...'
        if(isempty(SegImg))
            
        else
            changed_f=(origim(:,:,3)~=scribblesimg(:,:,3))&(scribblesimg(:,:,3)==255);
            changed_b=(origim(:,:,1)~=scribblesimg(:,:,1))&(scribblesimg(:,:,1)==255);

            if(any(changed_f(:)) && ~any(changed_b(:)))
                FinalAlpha=algorithm(alpha,imd,NumofComp,5,50,1,0,changed_f,changed_b);
            elseif(~any(changed_f(:)) && any(changed_b(:)))
                FinalAlpha=algorithm(alpha,imd,NumofComp,5,50,0,1,changed_f,changed_b);
            else
                FinalAlpha=algorithm(alpha,imd,NumofComp,5,50,1,1,changed_f,changed_b);
            end
            
            FinalAlpha=reshape(FinalAlpha,size(origim,1),size(origim,2));
            SegImg2=imd.*repmat(FinalAlpha,[1 1 3]);
            imshow(SegImg2,'Parent',handles.resultimg);
           
            if(matting)
                FinalAlpha=im2double(FinalAlpha);
                Contour=bwmorph(FinalAlpha,'remove');
                SE = strel('square', 13);
                U = imdilate(Contour,SE);
                FinalAlpha(U)=0.5;

                Trimap=FinalAlpha;
                NeighNum=41;
                VarC=0.01;
                MaxIter=10;
                minL=1e-6;
                [ MatImg ] = BayesianMatting( imd, Trimap, NeighNum ,VarC, MaxIter, minL);
                figure;
                imshow(MatImg);
            end
           
        end
       
end


% --- Executes on button press in plusbutton.
function plusbutton_Callback(hObject, eventdata, handles)
global NumofComp;
NumofComp=NumofComp+1;
set(handles.edit1,'string',num2str(NumofComp));



% --- Executes on button press in minusbutton.
function minusbutton_Callback(hObject, eventdata, handles)
global NumofComp;
NumofComp=NumofComp-1;
set(handles.edit1,'string',num2str(NumofComp));


function edit1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in on_off.
function on_off_Callback(hObject, eventdata, handles)
global matting;
if(get(hObject,'Value')==1)
   matting=1;   
else    
   matting=0;
end    


% --- Executes on button press in polygonbutton.
function polygonbutton_Callback(hObject, eventdata, handles)
global origim;
global alpha;
global scribblesimg;

if(isempty(origim))
    imshow('','Parent',handles.rectimg);
else
    imshow(origim,'Parent',handles.rectimg);
    h=impoly(handles.rectimg);
    setColor(h,[1 0 0]);
    pos = getPosition(h);
    c=round(pos(:,1));
    r=round(pos(:,2));
    alpha = roipoly(rgb2gray(origim), c, r) ;
    scribblesimg=origim;
    
end
