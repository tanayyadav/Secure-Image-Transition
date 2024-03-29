function varargout = Decrypt(varargin)
% DECRYPT MATLAB code for Decrypt.fig
%      DECRYPT, by itself, creates a new DECRYPT or raises the existing
%      singleton*.
%
%      H = DECRYPT returns the handle to a new DECRYPT or the handle to
%      the existing singleton*.
%
%      DECRYPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DECRYPT.M with the given input arguments.
%
%      DECRYPT('Property','Value',...) creates a new DECRYPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Decrypt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Decrypt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Decrypt

% Last Modified by GUIDE v2.5 23-Apr-2015 15:14:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Decrypt_OpeningFcn, ...
                   'gui_OutputFcn',  @Decrypt_OutputFcn, ...
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


% --- Executes just before Decrypt is made visible.
function Decrypt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Decrypt (see VARARGIN)

% Choose default command line output for Decrypt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Decrypt wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Decrypt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img message
[f p]=uigetfile({'*.png';'*jpg';'*.bmp'},'Select the embed image');
BIT=2;
sb=BIT-1;
if isequal(f,0) || isequal(p,0)
    set(handles.text1,'string','Retrive the Data')
else
    I=imread([p f]);    
if size(I,3)==3
    s=I(:,:,1);
    g=I(:,:,2);
    d=I(:,:,3);
else
    s=I;
end
N=s(size(s,1),size(s,2));
k=1;
k1=BIT;
  for i=1:size(s,1)
      for j=1:size(s,2)
          if k<N+1
          B=dec2bin(s(i,j),8);
          if k1>N
             temp=k1-N;
            b(1,k:(k+temp))=B(end-temp:end);
         else
          b(1,k:k1)=B(end-sb:end);
         end
          k=k+BIT;
          k1=k1+BIT;
          end
      end
  end
 i=1;
j=8;
k=1;
while j<=length(b)
B(i,:)=b(k:j);
i=i+1;
k=1+j;
j=j+8;
end
if size(I,3)==3
OI=cat(3,s,g,d);
else
    OI=s;
end
OS = bin2dec(num2str(B))
OO = OS(end);
O = char(OS)';
O1 = OS(end);
Retrieved_Message = ''
O
O1
% [PSNR]=psnr(img,OI);
axes(handles.axes1),imshow(OI,[]); title('Recieved image');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Stand I1 I2 I3 I4 I11 I31 I21 I41 II Mf1
I11 = imrotate(I11,180);
I21 = imrotate(I21,180);
I31 = imrotate(I31,180);
I41 = imrotate(I41,180);
axes(handles.axes2);
imshow(Mf1);title('Cover image')
I_R = (II-Stand)+[I11 I31 ; I21 I41];
% I_C = [I11 I31 ; I21 I41]- Mf1;
% figure,imshow(I_C);

% I33 = II - I;
% II1 = [I1-(I11+Stand) I3-(I31+Stand) ; I2-(I21+Stand) I4-(I41+Stand)];
axes(handles.axes3);
imshow(I_R);axis off;
title('Retrieved Image');
% set(handles.edit2,'string',Stand);
% set(handles.edit3,'string',RMSE);
% msgbox('Mosaic Image is Created');
