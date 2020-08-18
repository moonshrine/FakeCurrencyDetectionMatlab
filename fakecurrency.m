function varargout = fakecurrency(varargin)
% FAKECURRENCY MATLAB code for fakecurrency.fig
%      FAKECURRENCY, by itself, creates a new FAKECURRENCY or raises the existing
%      singleton*.
%
%      H = FAKECURRENCY returns the handle to a new FAKECURRENCY or the handle to
%      the existing singleton*.
%
%      FAKECURRENCY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FAKECURRENCY.M with the given input arguments.
%
%      FAKECURRENCY('Property','Value',...) creates a new FAKECURRENCY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fakecurrency_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fakecurrency_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fakecurrency

% Last Modified by GUIDE v2.5 13-Jun-2020 17:41:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fakecurrency_OpeningFcn, ...
                   'gui_OutputFcn',  @fakecurrency_OutputFcn, ...
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


% --- Executes just before fakecurrency is made visible.
function fakecurrency_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fakecurrency (see VARARGIN)

% Choose default command line output for fakecurrency
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
%set(handles.axes1,'visible', 'off');


%set(handles.axes2,'Units','normalized');
% UIWAIT makes fakecurrency wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fakecurrency_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectbutton.
function selectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to selectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
[file,path] = uigetfile('*.jpg');
if isequal(file,0)
    disp('User selected Cancel');
else
    handles.String = 'file';
    disp(['User selected ', fullfile(path,file)]);
    img = imread(fullfile(path,file));
    img = imresize(img,0.5);
    axes(handles.axes10);
    imshow(img);
    
end

% --- Executes on button press in Startbutton.
function Startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
global s
global feature_lst
feature_lst = {};
im2 = rgb2gray(img);
axes(handles.axes2);
imshow(im2);

%%%%Lazy snapping
%position for foreground 
h1 = impoly(gca,[1000,500;1100,700],'Closed',false);

foresub = getPosition(h1);
foregroundInd = sub2ind(size(img),foresub(:,2),foresub(:,1));

%position for background
h2 = impoly(gca,[20,20;25,30],'Closed',false);

backsub = getPosition(h2);
backgroundInd = sub2ind(size(img),backsub(:,2),backsub(:,1));

L = superpixels(img,200);

BW = lazysnapping(img,L,foregroundInd,backgroundInd);
maskedImage = img;
maskedImage(repmat(~BW,[1 1 3])) = 0;

axes(handles.axes2);
imshow (maskedImage)

%%%

%%%canny edge detection after lazzy snapping
lsGray = rgb2gray(maskedImage);

sobelIm = edge(lsGray,'sobel');
%figure
%imshow(sobelIm)
%title('Sobel Edge detection after LS')
%%%




%edge crop
hullIm = bwconvhull(sobelIm);

%croping image using obeject labeling
label = bwlabel(hullIm);
B = (label==1);
%figure
%imshow(B)
%title('Labeled Image')
[row, col] = find(B);
len = max(row) -min(row)+2;
breadth = max(col) -min(col)+2;
target =uint8([len breadth]);

sy = min(col) -1;
sx = min(row) -1;

for i=1:size(row,1)
    x = row(i,1)-sx;
    y = col(i,1)-sy;
    
    target(x,y) = img(row(i,1),col(i,1));
    %target = ismember(B, i)>0;    
    
end

s = histeq(target);
axes(handles.axes3);
imshow (s)
%-----------end----

%-----feature detection and extraction---------

%\NoUVSnippets\threadfront.png,  
gandhi = imread('gandhi.png');
notevalue = imread('notevalue.png');
number = imread('numberright2.png');
idmark = imread('idmark.png');
thread = imread('threadfront2.png');
gandhi_intensity = 0;
value_intensity = 0;
idmark_intensity = 0;
number_intensity = 0;
thread_intensity = 0;
mulfactor = 1.4;

%--------set defaults------
myString = sprintf('Waiting');
set(handles.text24, 'String', myString);
myString = sprintf('0');
set(handles.text27, 'String', myString);
%-------clear axes------
axesHandlesToChildObjects = findobj(handles.axes6, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
  delete(axesHandlesToChildObjects);
end
axesHandlesToChildObjects = findobj(handles.axes7, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
  delete(axesHandlesToChildObjects);
end
axesHandlesToChildObjects = findobj(handles.axes8, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
  delete(axesHandlesToChildObjects);
end
axesHandlesToChildObjects = findobj(handles.axes9, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
  delete(axesHandlesToChildObjects);
end
%-------gandhi----
try
    croppedGandhi = FeatureDANDT(gandhi, handles);
    axes(handles.axes5);
    imshow(croppedGandhi);

    %check intensity of cropped feature
    gandhi_intensity = mean2(croppedGandhi);
    gandhi_intensity = gandhi_intensity*mulfactor;
    myString = sprintf('%f',gandhi_intensity);
    set(handles.text13, 'String', myString);
catch ME
    disp('error while cropping Gandhi Potrait');
    myString = sprintf('Error While Detecting');
    set(handles.text13, 'String', myString);
end
%----- end gandhi----

%-------notevalue----
try
    croppedValue = FeatureDANDT(notevalue, handles);
    axes(handles.axes6);
    imshow(croppedValue);
    %check intensity of cropped feature
    value_intensity = mean2(croppedValue);
    value_intensity = value_intensity*mulfactor;
    myString = sprintf('%f',value_intensity);
    set(handles.text15, 'String', myString);
catch ME
    disp('error while cropping Deno type');
    myString = sprintf('Error While Detecting');
    set(handles.text15, 'String', myString);
end
   
%----- end deno----

%-------Number----
try
    croppedNumber = FeatureDANDT(number, handles);
    axes(handles.axes7);
    imshow(croppedNumber);
    %check intensity of cropped feature
    number_intensity = mean2(croppedNumber);
    number_intensity = number_intensity*mulfactor;
    myString = sprintf('%f',number_intensity);
    set(handles.text19, 'String', myString);
catch ME
    disp('error while cropping Number');
    myString = sprintf('Error While Detecting');
    set(handles.text19, 'String', myString);
end
%----- end number----

%-------Id mark----
try
    croppedIdmark = FeatureDANDT(idmark, handles);
    axes(handles.axes9);
    imshow(croppedIdmark);
    %check intensity of cropped feature
    idmark_intensity = mean2(croppedIdmark);
    idmark_intensity = idmark_intensity*mulfactor;
    myString = sprintf('%f',idmark_intensity);
    set(handles.text21, 'String', myString);
catch ME
    disp('error while cropping identification mark');
    myString = sprintf('Error While Detecting');
    set(handles.text21, 'String', myString);
end
    
%----- end id mark----

%-------thread----
try
    croppedThread = FeatureDANDT(thread, handles);
    axes(handles.axes8);
    imshow(croppedThread);
    %check intensity of cropped feature
    thread_intensity = mean2(croppedThread);
    thread_intensity = thread_intensity*mulfactor;
    myString = sprintf('%f',thread_intensity);
    set(handles.text23, 'String', myString);
catch ME
    disp('error while cropping Thread');
    myString = sprintf('Error While Detecting');
    set(handles.text23, 'String', myString);
end
    
%----- end thread----

%-------draw all features-----
axes(handles.axes11);
imshow(s);
hold on;
%title('Detected Box');
%-----end----------
disp(feature_lst)
for k=1:length(feature_lst)
newBoxPolygon=feature_lst{k};
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
end

total_intensity = gandhi_intensity+value_intensity+number_intensity+idmark_intensity+thread_intensity;
avg_int = total_intensity/5;
percentage = (avg_int/256)*100;
disp(percentage)
myString = sprintf('%f',percentage);
set(handles.text27, 'String', myString);
if percentage < 60
    myString = sprintf('FAKE');
    set(handles.text24, 'String', myString);
else
    myString = sprintf('REAL');
    set(handles.text24, 'String', myString);
end




%------------function for feature detection and extraction------
function S = FeatureDANDT(featureimg, handles)
%-----feature detection and extraction---------
global s
global feature_lst
feature_bw = rgb2gray(featureimg);
boxImage = histeq(feature_bw);

sceneImage = s;
%detect features
boxPoints = detectSURFFeatures(boxImage);
scenePoints = detectSURFFeatures(sceneImage);

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

boxPairs = matchFeatures(boxFeatures, sceneFeatures);


matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
%figure;
%showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, ...
%    matchedScenePoints, 'montage');
%title('Putatively Matched Points (Including Outliers)');

[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

%figure;
%showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, ...
%    inlierScenePoints, 'montage');
%title('Matched Points (Inliers Only)');

boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
   
newBoxPolygon = transformPointsForward(tform, boxPolygon);

feature_lst = [feature_lst, newBoxPolygon];

%crop detected feature gandhi
xLeft = min(newBoxPolygon(:, 1));
xRight = max(newBoxPolygon(:, 1));
yTop = min(newBoxPolygon(:, 2));
yBottom = max(newBoxPolygon(:, 2));
height = abs(yBottom - yTop);
width = abs(xRight - xLeft);
S = imcrop(s, [xLeft, yTop, width, height]);
