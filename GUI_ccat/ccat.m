function varargout = ccat(varargin)
% CCAT MATLAB code for ccat.fig
%      CCAT, by itself, creates a new CCAT or raises the existing
%      singleton*.
%
%      H = CCAT returns the handle to a new CCAT or the handle to
%      the existing singleton*.
%
%      CCAT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CCAT.M with the given input arguments.
%
%      CCAT('Property','Value',...) creates a new CCAT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ccat_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ccat_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ccat

% Last Modified by GUIDE v2.5 14-Feb-2022 01:01:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ccat_OpeningFcn, ...
                   'gui_OutputFcn',  @ccat_OutputFcn, ...
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


% --- Executes just before ccat is made visible.
function ccat_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ccat (see VARARGIN)

% Choose default command line output for ccat
handles.output = hObject;

handles.ROI = [];
handles.ROI_Path = [];
handles.TR = [];
handles.TimePoints = [];
handles.CurrDir = pwd;
handles.InputDir = [];
handles.OutputDir = [];

% handles.LSTN_Coor = [-11.89 -14.51 -6.40];
% handles.RSTN_Coor = [12.53 -13.97 -6.57];

% Update handles structure
guidata(hObject, handles);



% MAIN FUNCTION
% --- Executes on button press in mainfun2cal.
function mainfun2cal_Callback(hObject, eventdata, handles)
% hObject    handle to mainfun2cal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ccat_cal(handles.ROI_Path, handles.TR, handles.TimePoints, ...
    handles.InputDirPath, handles.OutputDirPath);

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = ccat_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on selection change in ROI_Set.
function ROI_Set_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.ROI = get(handles.ROI_Set,'value');
if handles.ROI == 3
    handles.ROI_Path = uigetdir(handles.CurrDir, 'Please select ROI directory');
else
    ROI_Path = which('ccat');
    handles.ROI_Path = ROI_Path(1:end-7);
end
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function ROI_Set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TR_Set_Callback(hObject, eventdata, handles)
% hObject    handle to TR_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TR = str2double(get(handles.TR_Set,'string'));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function TR_Set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TR_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimePoints_Set_Callback(hObject, eventdata, handles)
% hObject    handle to TimePoints_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TimePoints_Set as text
%        str2double(get(hObject,'String')) returns contents of TimePoints_Set as a double
handles.TimePoints = str2double(get(handles.TimePoints_Set,'string'));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function TimePoints_Set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimePoints_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in InputSet.
function InputSet_Callback(hObject, eventdata, handles)
% hObject    handle to InputSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.InputDir = uigetdir(handles.CurrDir, 'Please select SINGLE subject image directory');
if handles.InputDir
    set(handles.InputDirPath, 'String', handles.InputDir);
end
guidata(hObject, handles);


% --- Executes on button press in OutputSet.
function OutputSet_Callback(hObject, eventdata, handles)
% hObject    handle to OutputSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.OutputDir = uigetdir(handles.CurrDir, 'Please select output directory');
if handles.OutputDir
    set(handles.OutputDirPath, 'String', handles.OutputDir);
end
guidata(hObject, handles);


function InputDirPath_Callback(hObject, eventdata, handles)
% hObject    handle to InputDirPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function InputDirPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InputDirPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OutputDirPath_Callback(hObject, eventdata, handles)
% hObject    handle to OutputDirPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function OutputDirPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OutputDirPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



