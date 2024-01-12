function varargout = main_gui(varargin)
% MAIN_GUI MATLAB code for main_gui.fig
%      MAIN_GUI, by itself, creates a new MAIN_GUI or raises the existing
%      singleton*.
%
%      H = MAIN_GUI returns the handle to a new MAIN_GUI or the handle to
%      the existing singleton*.
%
%      MAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN_GUI.M with the given input arguments.
%
%      MAIN_GUI('Property','Value',...) creates a new MAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main_gui

% Last Modified by GUIDE v2.5 31-Mar-2015 15:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @main_gui_OutputFcn, ...
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


% --- Executes just before main_gui is made visible.
function main_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main_gui (see VARARGIN)

% Choose default command line output for main_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = hObject;
a = imread('icon\1.png');
b=imresize(a,.21);
set(handles.input1, 'CData', b);

handles.output = hObject;
a1 = imread('icon\1.png');
b1=imresize(a1,.21);
set(handles.input2, 'CData', b1);
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in input1.
function input1_Callback(hObject, eventdata, handles)
% hObject    handle to input1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I1 p1 f1
[f1 p1] = uigetfile('*.*');
I1 = imread([p1 f1]);
I1 = imresize(I1,[256,256]);
axes(handles.axes1);
imshow(I1);axis off;
title('Input Image 1');


% --- Executes on button press in input2.
function input2_Callback(hObject, eventdata, handles)
% hObject    handle to input2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I2
[f2 p2] = uigetfile('*.*');
I2 = imread([p2 f2]);
I2 = imresize(I2,[256,256]);
axes(handles.axes2);
imshow(I2); axis off;
title('Input Image 2');


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pre.
function pre_Callback(hObject, eventdata, handles)
% hObject    handle to pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I1 I2 Mf1 Mf2
im = fspecial('gaussian',[3 3]);
Mf1 = imfilter(I1,im);
axes(handles.axes1)
imshow(Mf1); axis off;
title('Filtered Image 1');
axes(handles.axes2)
Mf2 = imfilter(I2,im);
imshow(Mf2); axis off;
title('Filtered Image2')


% --- Executes on button press in encrypt.
function encrypt_Callback(hObject, eventdata, handles)
% hObject    handle to encrypt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dfusion II Stand RMSE message
img = II;  
delete('Encrypt\*.jpg');
[n m k] = size(img);
key = keyGen(n*m);
skey1 = str2double(get(handles.edit1,'string'));
EncrImage = imageProcess(img,key,skey1);
% ------------------------------------------------------------------------
message1 = Stand;
message2 = RMSE;
message = ['STD DEV IS',Stand];
BIT=2;
if isempty(message)
    msgbox('Enter the data');
%     set(handles.text1,'string','Please Enter the Data','Foregroundcolor',[1 0 0]);
else
    II=img;
 if size(II,3)==3
    c=II(:,:,1);
    g=II(:,:,2);
    d=II(:,:,3);
else
    c=II;
 end
%     message = strtrim(message);
    AsciiCode = uint8(message); 
    binaryString = dec2bin(AsciiCode,8)';
    b = binaryString(:);
    N = length(b);
   for i=1:size(binaryString,2)
       CH{i}=char(AsciiCode(i));
       BiCH{i}=binaryString(:,i);
   end
    k=1;
    k1=BIT;
    te=1;
    sb=BIT-1;
    c(size(c,1),size(c,2))=N;
  for i=1:size(c,1)
     for j=1:(size(c,2))
         if k<N+1
         B=dec2bin(c(i,j),8);
         SIV(te)=c(i,j);
         SBV{te}=B;
         if k1>N
             temp=k1-N;
             B(end-temp:end)=b(k:(k1-temp));
             SCHB{te}=b(k:(k1-temp));
         else
         B(end-sb:end)=b(k:k1);
         SCHB{te}=b(k:k1);
         end
         INV{te}=B;
         s(i,j)=bin2dec(B);
         MIV(te)=s(i,j);
         k=k+BIT;
         k1=k1+BIT;
         te=te+1;
         else
             s(i,j)=c(i,j);
         end
     end
  end 
if size(II,3)==3
HI=cat(3,s,g,d);
else
 HI=s;
end
[filen pth] = uiputfile({'*.png';'*.jpg';'*.bmp'},'Save Processed image');
    if isequal(filen,0) || isequal(pth,0)
        set(handles.text1,'string','Image is not save','Foregroundcolor',[1 0 0]);
    else
imwrite(HI,[pth '(2-bit) ',filen])
    end
set(handles.text1,'string','Retrive the Data','Foregroundcolor',[0 0 0]);
end

% ------------------------------------------------------------------------


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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


% --- Executes on button press in mosaic.
function mosaic_Callback(hObject, eventdata, handles)
% hObject    handle to mosaic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Mf1 Mf2 II I1 I2 I3 I4
global I11 I21 I31 I41
global Stand RMSE
re_t = imresize(Mf2,[30 30]);
% D = eig(re_t,'matrix')
% [E e] = eig(double(re_t));
R1 = Mf1(:,:,1);
G1 = Mf1(:,:,2);
B1 = Mf1(:,:,3);
Mean_R1 = mean(R1);
Mean_G1 = mean(G1);
Mean_B1 = mean(B1);
Std_R1 = std(Mean_R1)
Std_G1 = std(Mean_G1)
Std_B1 = std(Mean_B1)
STD_1 = Std_R1+Std_G1+Std_B1

% ----------------------------------------------------------------
R2 = Mf2(:,:,1);
G2 = Mf2(:,:,2);
B2 = Mf2(:,:,3);
Mean_R2 = mean(R2);
Mean_G2 = mean(G2);
Mean_B2 = mean(B2);
Std_R2 = std(Mean_R2)
Std_G2 = std(Mean_G2)
Std_B2 = std(Mean_B2)
STD_2 = Std_R2+Std_G2+Std_B2
% -----------------------------------------------------------------

I1 = Mf1(1:size(Mf1,1)/2,1:size(Mf1,2)/2,:);
% -----------------------------------------------------------------
I2 = Mf1(size(Mf1,1)/2+1:size(Mf1,1),1:size(Mf1,2)/2,:);
% -----------------------------------------------------------------
I3 = Mf1(1:size(Mf1,1)/2,size(Mf1,2)/2+1:size(Mf1,2),:);
% -----------------------------------------------------------------
I4 = Mf1(size(Mf1,1)/2+1:size(Mf1,1),size(Mf1,2)/2+1:size(Mf1,2),:);
% =================================================================

I11 = Mf2(1:size(Mf2,1)/2,1:size(Mf2,2)/2,:);
% -----------------------------------------------------------------
I21 = Mf2(size(Mf2,1)/2+1:size(Mf2,1),1:size(Mf2,2)/2,:);
% -----------------------------------------------------------------
I31 = Mf2(1:size(Mf2,1)/2,size(Mf2,2)/2+1:size(Mf2,2),:);
% -----------------------------------------------------------------
I41 = Mf2(size(Mf2,1)/2+1:size(Mf2,1),size(Mf2,2)/2+1:size(Mf2,2),:);
% =================================================================
axes(handles.axes2)
imshow(I11);axis off;title('Patch 1')
pause(3)
imshow(I31);axis off;title('Patch 2')
pause(3)
imshow(I21);axis off;title('Patch 3')
pause(3)
imshow(I41);axis off;title('Patch 4');
pause(3)
% -----------------------------------------------------------------
M_P1 = mean(I11)
M_P1_1 = mean(M_P1(:,:,1));
M_P1_2 = mean(M_P1(:,:,2));
M_P1_3 = mean(M_P1(:,:,3));
% ---------------------------------------------------------
M_P2 = mean(I31)
M_P2_1 = mean(M_P2(:,:,1));
M_P2_2 = mean(M_P2(:,:,2));
M_P2_3 = mean(M_P2(:,:,3));
% ----------------------------------------------------------
M_P3 = mean(I21)
M_P3_1 = mean(M_P3(:,:,1));
M_P3_2 = mean(M_P3(:,:,2));
M_P3_3 = mean(M_P3(:,:,3));
% ----------------------------------------------------------
M_P4 = mean(I41)
M_P4_1 = mean(M_P4(:,:,1));
M_P4_2 = mean(M_P4(:,:,2));
M_P4_3 = mean(M_P4(:,:,3));
% ----------------------------------------------------------
S_P1 = std(M_P1)
S_P3 = std(M_P3)
S_P2 = std(M_P2)
S_P4 = std(M_P4)
% ----------------------------------------------------------
RMSE = rmse(Mf1(1,:),Mf2(1,:));
if RMSE == 0
    RMSE = 240;
end
RMSE = RMSE
Stand = (STD_1+STD_2)*2;
I11 = imrotate(I11,180);
I31 = imrotate(I31,180);
I21 = imrotate(I21,180);
I41 = imrotate(I41,180);

% figure,imshow(I11);
II = [I1+(I11-Stand) I3+(I31-Stand) ; I2+(I21-Stand) I4+(I41-Stand)];
imshow(II);axis off;
title('Mosaic image');
set(handles.edit2,'string',Stand);
set(handles.edit3,'string',RMSE);
msgbox('Mosaic Image is Created');
% MSE=mean(((Mf1(:)-I1(:)).^2)*(n))
%   PSNR=10*log10(255^2/MSE)*2
% MSE=mean(((Mf2(:)-I2(:)).^2)*(n))
%   PSNR=10*log10(255^2/MSE)*2
%   MSE=mean(((Mf1(:)-II(:)).^2)*(n))
%   PSNR=10*log10(255^2/MSE)*2
%   MSE=mean(((Mf1(:)-II(:)).^2)*(n))
%   PSNR=10*log10(255^2/MSE)*2


% --- Executes on button press in embed.
function embed_Callback(hObject, eventdata, handles)
% hObject    handle to embed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Mf1 Mf2 p1 f1 dfusion
para.nLv = 5;
para.debug_mode = 1;   % show message
para.wpropagation = 1; % weight propagation among subbands from parent to children
para.denoise = 1;  
J = imedgefuse( para, Mf1, Mf2 );
axes(handles.axes2);
imshow(J),axis off;
title('Embedded Image');
msgbox('Msg is Embedded')



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Decrypt