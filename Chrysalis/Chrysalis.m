function varargout = Chrysalis(varargin)
% CHRYSALIS MATLAB code for Chrysalis.fig
%      CHRYSALIS, by itself, creates a new CHRYSALIS or raises the existing
%      singleton*.
%
%      H = CHRYSALIS returns the handle to a new CHRYSALIS or the handle to
%      the existing singleton*.
%
%      CHRYSALIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHRYSALIS.M with the given input arguments.
%
%      CHRYSALIS('Property','Value',...) creates a new CHRYSALIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Chrysalis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Chrysalis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Chrysalis

% Last Modified by GUIDE v2.5 14-Aug-2017 14:26:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Chrysalis_OpeningFcn, ...
                   'gui_OutputFcn',  @Chrysalis_OutputFcn, ...
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


% --- Executes just before Chrysalis is made visible.
function Chrysalis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Chrysalis (see VARARGIN)

% Choose default command line output for Chrysalis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Chrysalis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Chrysalis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in MovieBox.
function MovieBox_Callback(hObject, eventdata, handles)
% hObject    handle to MovieBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MovieBox
handles=guidata(hObject);
set(handles.StaticBox,'Value',0);
saveAVI = get(handles.MovieBox,'Value');
if saveAVI
    set(handles.saveAVI,'Visible','on');
    set(handles.writeBigData,'Visible','on');
    set(handles.MergeImages,'Visible','off');    
else
    set(handles.saveAVI,'Visible','off');
    set(handles.writeBigData,'Visible','off');
end
guidata(hObject,handles);

% --- Executes on button press in StaticBox.
function StaticBox_Callback(hObject, eventdata, handles)
% hObject    handle to StaticBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StaticBox
handles=guidata(hObject);
set(handles.MovieBox,'Value',0);
saveStatic = get(handles.StaticBox,'Value');
if saveStatic
    set(handles.MergeImages,'Visible','on');
    set(handles.saveAVI,'Visible','off');
    set(handles.writeBigData,'Visible','off');
else
    set(handles.MergeImages,'Visible','off');
end
guidata(hObject,handles);

% --- Executes on button press in indir.
function indir_Callback(hObject, eventdata, handles)
% hObject    handle to indir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
indir=uigetdir;
handles.indir=indir;
set(handles.indirtext,'String',handles.indir);
guidata(hObject,handles);


% --- Executes on button press in outdir.
function outdir_Callback(hObject, eventdata, handles)
% hObject    handle to outdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
outdir=uigetdir;
handles.outdir=outdir;
set(handles.outdirtext,'String',handles.outdir);
guidata(hObject,handles);

function indirtext_Callback(hObject, eventdata, handles)
% hObject    handle to indirtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of indirtext as text
%        str2double(get(hObject,'String')) returns contents of indirtext as a double


% --- Executes during object creation, after setting all properties.
function indirtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to indirtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function outdirtext_Callback(hObject, eventdata, handles)
% hObject    handle to outdirtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outdirtext as text
%        str2double(get(hObject,'String')) returns contents of outdirtext as a double


% --- Executes during object creation, after setting all properties.
function outdirtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outdirtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in spectralunmix.
function spectralunmix_Callback(hObject, eventdata, handles)
% hObject    handle to spectralunmix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectralunmix

function NumberChannel_Callback(hObject, eventdata, handles)
% hObject    handle to NumberChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberChannel as text
%        str2double(get(hObject,'String')) returns contents of NumberChannel as a double
handles=guidata(hObject);
NumberChannel = str2double(get(handles.NumberChannel,'String'));
Channels = 1:NumberChannel;
set(handles.IncludeBox,'Max',NumberChannel,'Min',0);
set(handles.ExcludeBox,'Max',NumberChannel,'Min',0);
set(handles.basechannelmenu,'String',Channels);
set(handles.IncludeBox,'String',Channels);
set(handles.ExcludeBox,'String',Channels);
ChannelNumberArray = handles.ChannelNumberArray;
SelectedNewChannel = get(handles.SelectedNewChannel,'Value');
ChannelNumberArray{SelectedNewChannel,1} = NumberChannel;
handles.ChannelNumberArray = ChannelNumberArray;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NumberChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IncludeBox.
function IncludeBox_Callback(hObject, eventdata, handles)
% hObject    handle to IncludeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IncludeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IncludeBox
handles=guidata(hObject);
IncludeArray = handles.IncludeArray;
IncludeChannels = get(handles.IncludeBox,'Value');
SelectedNewChannel = get(handles.SelectedNewChannel,'Value');
IncludeArray{SelectedNewChannel,1} = IncludeChannels;
handles.IncludeArray = IncludeArray;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function IncludeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IncludeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ExcludeBox.
function ExcludeBox_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ExcludeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ExcludeBox
handles=guidata(hObject);
ExcludeArray = handles.ExcludeArray;
ExcludeChannels = get(handles.ExcludeBox,'Value');
SelectedNewChannel = get(handles.SelectedNewChannel,'Value');
ExcludeArray{SelectedNewChannel,1} = ExcludeChannels;
handles.ExcludeArray = ExcludeArray;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ExcludeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ExcludeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in basechannelmenu.
function basechannelmenu_Callback(hObject, eventdata, handles)
% hObject    handle to basechannelmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns basechannelmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from basechannelmenu
handles=guidata(hObject);
BaseChannelArray = handles.BaseChannelArray;
basechannel = get(handles.basechannelmenu,'Value');
SelectedNewChannel = get(handles.SelectedNewChannel,'Value');
BaseChannelArray{SelectedNewChannel,1} = basechannel;
handles.BaseChannelArray = BaseChannelArray;
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function basechannelmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to basechannelmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in saveAVI.
function saveAVI_Callback(hObject, eventdata, handles)
% hObject    handle to saveAVI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveAVI
handles=guidata(hObject);
saveAVI = get(handles.saveAVI,'Value');
if saveAVI
    set(handles.AVIcolors,'Visible','on');
    set(handles.AVIchannels,'Visible','on');
    set(handles.colornumbers,'Visible','on');
else
    set(handles.AVIcolors,'Visible','off');
    set(handles.AVIchannels,'Visible','off');
    set(handles.colornumbers,'Visible','off');
    set(handles.color1,'Visible','off');
    set(handles.color1text,'Visible','off');
    set(handles.color2,'Visible','off');
    set(handles.color2text,'Visible','off');
    set(handles.color3,'Visible','off');
    set(handles.color3text,'Visible','off');
    set(handles.color4,'Visible','off');
    set(handles.color4text,'Visible','off');
end
guidata(hObject,handles);


% --- Executes on button press in writeBigData.
function writeBigData_Callback(hObject, eventdata, handles)
% hObject    handle to writeBigData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of writeBigData


% --- Executes on button press in MergeImages.
function MergeImages_Callback(hObject, eventdata, handles)
% hObject    handle to MergeImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MergeImages

% --- Executes on button press in doMath.

% --- Executes on selection change in colornumbers.

function colornumbers_Callback(hObject, eventdata, handles)
% hObject    handle to colornumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colornumbers contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colornumbers
handles=guidata(hObject);
allcolornumbers = get(handles.colornumbers,'String');
colornumber = str2double(allcolornumbers(get(handles.colornumbers,'Value'),:));
if colornumber == 4
    set(handles.color1,'Visible','on');
    set(handles.color2,'Visible','on');
    set(handles.color3,'Visible','on');
    set(handles.color4,'Visible','on');
    set(handles.color1text,'Visible','on');
    set(handles.color2text,'Visible','on');
    set(handles.color3text,'Visible','on');
    set(handles.color4text,'Visible','on');
end
if colornumber == 3
    set(handles.color1,'Visible','on');
    set(handles.color2,'Visible','on');
    set(handles.color3,'Visible','on');
    set(handles.color4,'Visible','off');
    set(handles.color1text,'Visible','on');
    set(handles.color2text,'Visible','on');
    set(handles.color3text,'Visible','on');
    set(handles.color4text,'Visible','off');
end
if colornumber == 2
    set(handles.color1,'Visible','on');
    set(handles.color2,'Visible','on');
    set(handles.color3,'Visible','off');
    set(handles.color4,'Visible','off');
    set(handles.color1text,'Visible','on');
    set(handles.color2text,'Visible','on');
    set(handles.color3text,'Visible','off');
    set(handles.color4text,'Visible','off');
end
if colornumber == 1
    set(handles.color1,'Visible','on');
    set(handles.color2,'Visible','off');
    set(handles.color3,'Visible','off');
    set(handles.color4,'Visible','off');
    set(handles.color1text,'Visible','on');
    set(handles.color2text,'Visible','off');
    set(handles.color3text,'Visible','off');
    set(handles.color4text,'Visible','off');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function colornumbers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colornumbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color1.
function color1_Callback(hObject, eventdata, handles)
% hObject    handle to color1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color1


% --- Executes during object creation, after setting all properties.
function color1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color2.
function color2_Callback(hObject, eventdata, handles)
% hObject    handle to color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color2


% --- Executes during object creation, after setting all properties.
function color2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color3.
function color3_Callback(hObject, eventdata, handles)
% hObject    handle to color3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color3


% --- Executes during object creation, after setting all properties.
function color3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in color4.
function color4_Callback(hObject, eventdata, handles)
% hObject    handle to color4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns color4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from color4


% --- Executes during object creation, after setting all properties.
function color4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CompMatrix.
function CompMatrix_Callback(hObject, eventdata, handles)
% hObject    handle to CompMatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
[filename, pathname] = uigetfile('*.sdm', 'Select a MATLAB code file');
if isequal(filename,0)
   disp('Please select the compensation matrix ')
else
   CompMatrix=fullfile(pathname, filename);
end
handles.CompMatrix=CompMatrix;
set(handles.CompMatrixText,'String',handles.CompMatrix);
guidata(hObject,handles);


function CompMatrixText_Callback(hObject, eventdata, handles)
% hObject    handle to CompMatrixText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CompMatrixText as text
%        str2double(get(hObject,'String')) returns contents of CompMatrixText as a double


% --- Executes during object creation, after setting all properties.
function CompMatrixText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CompMatrixText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NumberofNewChannels_Callback(hObject, eventdata, handles)
% hObject    handle to NumberofNewChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumberofNewChannels as text
%        str2double(get(hObject,'String')) returns contents of NumberofNewChannels as a double
handles=guidata(hObject);
NumberNewChannels = str2double(get(handles.NumberofNewChannels,'String'));
Channels = 1:NumberNewChannels;
set(handles.SelectedNewChannel,'String',Channels);
handles.ChannelNumberArray = cell(NumberNewChannels,1);
handles.BaseChannelArray = cell(NumberNewChannels,1);
handles.IncludeArray = cell(NumberNewChannels,1);
handles.ExcludeArray = cell(NumberNewChannels,1);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function NumberofNewChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumberofNewChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SelectedNewChannel.
function SelectedNewChannel_Callback(hObject, eventdata, handles)
% hObject    handle to SelectedNewChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SelectedNewChannel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SelectedNewChannel
handles=guidata(hObject);
BaseChannelArray = handles.BaseChannelArray;
SelectedNewChannel = get(handles.SelectedNewChannel,'Value');
NumberChannel = str2double(get(handles.NumberChannel,'String'));
Channels = 1:NumberChannel;
set(handles.IncludeBox,'Max',NumberChannel,'Min',0);
set(handles.ExcludeBox,'Max',NumberChannel,'Min',0);

if ~isempty(BaseChannelArray{SelectedNewChannel,1})
    set(handles.basechannelmenu,'String',Channels);
    set(handles.IncludeBox,'String',Channels);
    set(handles.ExcludeBox,'String',Channels);
    set(handles.IncludeBox,'Value',[]);
    set(handles.ExcludeBox,'Value',[]);
    set(handles.basechannelmenu,'Value',[]);
    set(handles.NumberChannel,'Value',[]);
    set(handles.NumberChannel,'Value',handles.ChannelNumberArray{SelectedNewChannel,1});
    set(handles.basechannelmenu,'Value',handles.BaseChannelArray{SelectedNewChannel,1});
    set(handles.IncludeBox,'Value',handles.IncludeArray{SelectedNewChannel});
    set(handles.ExcludeBox,'Value',handles.ExcludeArray{SelectedNewChannel});
else
    set(handles.basechannelmenu,'String',Channels);
    set(handles.IncludeBox,'String',Channels);
    set(handles.ExcludeBox,'String',Channels);
    set(handles.IncludeBox,'Value',[]);
    set(handles.ExcludeBox,'Value',[]);
    set(handles.NumberChannel,'Value',[]);
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function SelectedNewChannel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SelectedNewChannel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in doRescale.
function doRescale_Callback(hObject, eventdata, handles)
% hObject    handle to doRescale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doRescale

function doMath_Callback(hObject, eventdata, handles)
% hObject    handle to doMath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doMath
handles=guidata(hObject);
doMath = get(handles.doMath,'Value');
if doMath == 1
    set(handles.NumberChannel,'Visible','on');
    set(handles.IncludeBox,'Visible','on');
    set(handles.ExcludeBox,'Visible','on');
    set(handles.basechannelmenu,'Visible','on');
    set(handles.NumberChannel,'Visible','on');
    set(handles.includechannels,'Visible','on');
    set(handles.excludechannels,'Visible','on');
    set(handles.basechannel,'Visible','on');
    set(handles.doMathTitle,'Visible','on');
    set(handles.NumberofNewChannelsText,'Visible','on');
    set(handles.NumberofNewChannels,'Visible','on');
    set(handles.SelectedNewChannel,'Visible','on');
    set(handles.SelectedNewChanneltext,'Visible','on');
    set(handles.NumberofChannelstext,'Visible','on');
else
    set(handles.NumberChannel,'Visible','off');
    set(handles.IncludeBox,'Visible','off');
    set(handles.ExcludeBox,'Visible','off');
    set(handles.basechannelmenu,'Visible','off');
    set(handles.NumberChannel,'Visible','off');    
    set(handles.includechannels,'Visible','off');
    set(handles.excludechannels,'Visible','off');
    set(handles.basechannel,'Visible','off');
    set(handles.doMathTitle,'Visible','off');
    set(handles.NumberofNewChannelsText,'Visible','off');
    set(handles.NumberofNewChannels,'Visible','off');
    set(handles.SelectedNewChannel,'Visible','off');
    set(handles.SelectedNewChanneltext,'Visible','off');
    set(handles.NumberofChannelstext,'Visible','off');
end
guidata(hObject,handles);

% --- Executes on button press in Run.
function Run_Callback(hObject, eventdata, handles)
% hObject    handle to Run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
%bfmatlablocation = uigetdir('select bfmatlab folder');
%DIPimagelocation = uigetdir('select DIPimage folder');
%addpath(bfmatlablocation);
%addpath(DIPimagelocation); dipstart
if ~isdeployed
    addpath ('C:\Program Files\bfmatlab');
end

%addpath('C:\Program Files\DIPimage 2.8'); dipstart

%extension = '.lif';
extension = get(handles.eExtension,'String');
extension_length = length(extension);

MovieBox = get(handles.MovieBox,'Value');
StaticBox = get(handles.StaticBox,'Value');
MergeImages = get(handles.MergeImages,'Value');
writeBigData = get(handles.writeBigData,'Value');

doRescale = get(handles.doRescale,'Value');

%define colors1-4 as a dropmenu
% the string for colors = blue red yellow cyan green magenta
%define colornumbers as a dropmenu

indir=get(handles.indirtext,'String');
outdir=get(handles.outdirtext,'String');
if isempty(indir)
    uiwait(msgbox('Please select an input directory', 'No input directory specified','error'));
    return;
end
if isempty(outdir)
    uiwait(msgbox('Please select an output directory', 'No output directory specified','error'));
    return;
end

files = dir(fullfile(indir,[ '*' extension ]));

if isempty(files)
    uiwait(msgbox(['No files found in "' indir '" with extension "' extension '"'], 'No input files','error'));
    return;
end

if ~exist(outdir,'dir')
    mkdir(outdir);
end

spectra = [];
if get(handles.spectralunmix,'Value') == 1
    spectraFilename = get(handles.CompMatrixText,'String');
        
    a=xml2struct(spectraFilename);

    for i = 1:length(a.Children)
        dye = a.Children(i);
        nch = length(dye.Children);
        dyeSpectrum = zeros(nch,1);
        for j = 1:nch
            dyeSpectrum(j) = str2double(dye.Children(j).Children(1).Data);
        end
        spectra = [spectra dyeSpectrum];
    end
end
    
if MovieBox==1
    hProgress = waitbar(0,'Analysis progress...');
    
    for ifile = 1:length(files)
        %rawDataFilename = fullfile(indir,'508 Lm-P2A.lif');
        rawDataFilename = files(ifile).name;
        rawDataPath = fullfile(indir,rawDataFilename);
        %% Read in raw data
        fprintf('Opening %s\n',rawDataPath);
        reader = bfGetReader(rawDataPath);
        %reader.setId();
        
        nSeries = reader.getSeriesCount();
        
        %a = bfopen(rawDataPath);
        
        total=[];
        for i_series = 1:nSeries
            total_progress = (ifile-1)/length(files) + (i_series)/nSeries/length(files);
            waitbar(total_progress,hProgress,sprintf('%s (%i/%d)...',rawDataFilename,i_series,nSeries))
            
            fprintf('Analyzing series %d\n',i_series);
            
            reader.setSeries(i_series-1);
            omeMeta = reader.getMetadataStore();
            stackSizeX = omeMeta.getPixelsSizeX(i_series-1).getValue(); % image width, pixels
            stackSizeY = omeMeta.getPixelsSizeY(i_series-1).getValue(); % image height, pixels
            stackSizeZ = omeMeta.getPixelsSizeZ(i_series-1).getValue(); % number of Z slices
            stackSizeT = omeMeta.getPixelsSizeT(i_series-1).getValue(); % number of timepoints
            stackSizeC = omeMeta.getPixelsSizeC(i_series-1).getValue(); % number of channels
            
            if ~strcmp(char(omeMeta.getPixelsType(0)),'uint8')
                error('Only works with 8bit')
            end
            
            vols={};
            try
                parfor it = 0:stackSizeT-1
                    preader = bfGetReader(rawDataPath);
                    preader.setSeries(i_series-1);
                    
                    vols{it+1} = zeros(stackSizeX,stackSizeY,stackSizeZ,stackSizeC,'uint8');
                    for ic = 0:stackSizeC-1
                        for iz = 0:stackSizeZ-1
                            iPlane = preader.getIndex(iz, ic, it) + 1;
                            plane = typecast(preader.openBytes(iPlane-1),'uint8');
                            %vol(:,:,iz+1,ic+1,it+1) = reshape(plane,stackSizeX,stackSizeY);
                            vols{it+1}(:,:,iz+1,ic+1) = reshape(plane,stackSizeX,stackSizeY);
                        end
                    end
                end
                clear preader
            catch err
                disp(err)
                fprintf('Skipping series %d\n',i_series);
                continue
            end
            
            vol = cat(5,vols{:});
            vol = permute(vol,[1 2 3 5 4]);
        
            if get(handles.spectralunmix,'Value') == 1
                vol_unmixed_iso = unmixing(vol,spectra);
            else
                vol_unmixed_iso = vol;
            end
           
            if get(handles.doMath,'Value') == 1
                final = vol_unmixed_iso;
                NumberofNewChannels = str2double(get(handles.NumberofNewChannels,'String'));
                for ndoMath = 1:NumberofNewChannels
                    include = handles.IncludeArray{ndoMath};
                    exclude = handles.ExcludeArray{ndoMath};
                    basechannel = handles.BaseChannelArray{ndoMath};
                    final = doMath_noDipImage(include,exclude,basechannel,final);
                end
            else
                final = vol_unmixed_iso;
            end
            
            if writeBigData
                fprintf('Saving as XML/HDF5...');
                total_name = sprintf('%s-series%d',rawDataFilename(1:end-extension_length),i_series);
                if exist(fullfile(outdir,[total_name '.h5']),'file')
                    warning(['Found existing file and deleting ' fullfile(outdir,[total_name '.h5']) ]);
                    delete(fullfile(outdir,[total_name '.h5']));
                end
                
                if doRescale && (isa(final,'float') || isa(final,'double') )
                    warning('Rescaling floating point data to fill the uint16 range')
                    scaleFactor=zeros(size(final,5),1);
                    for ich = 1:size(final,5)
                        final_c = final(:,:,:,:,ich);
                        scaleFactor(ich) = 256*256/max(final_c(:));
                        final(:,:,:,:,ich) = scaleFactor(ich) * final_c;
                    end
                    writetable(table(scaleFactor),[rawDataFilename(1:end-extension_length) '.scaleFactors.txt']);
                end

                writeBigDataXML(fullfile(outdir,total_name),uint16(final),'XYZTC','DeflateLevel',3);
                fprintf('done!\n');
            end
            
            if get(handles.saveAVI,'Value') == 1
            fprintf('Saving movie...');
            total_name = fullfile(outdir,sprintf('%s-series%d.avi',rawDataFilename(1:endextension_length),i_series));
            % 4-ch to RGB
            if get(handles.doMath,'Value') == 1
                full_movie = final(:,:,:,:,1:end-NumberofNewChannels);
            else
                full_movie = final;
            end
            s0 = size(full_movie);
            s1 = size(full_movie); 
         
            if numel(s0)>4
                nch=s0(5);
                s1(end)=3;
            else
                nch=1;
                s1 = [s1 3];
            end
            
            blue = [0 0 .75];
            red = [.75 0 0];
            yellow = [1/2 1/2 0];
            cyan = [0 1/2 .25];
            green = [0 .75 0];
            magenta = [1/2 0 1/2];
            
            allcolors = get(handles.color1,'string');
            color1 = allcolors(get(handles.color1,'Value'),:);
            color2 = allcolors(get(handles.color2,'Value'),:);
            color3 = allcolors(get(handles.color3,'Value'),:);
            color4 = allcolors(get(handles.color4,'Value'),:);
            
            color1 = eval(color1);
            color2 = eval(color2);
            color3 = eval(color3);
            color4 = eval(color4);
            
            allcolornumberz = get(handles.colornumbers,'String');
            colornumberz = str2double(allcolornumberz(get(handles.colornumbers,'Value'),:));
            
            colors = [color1;color2;color3;color4];
            colors = colors(1:colornumberz,:);
            
            full_movie = reshape(reshape(single(full_movie),[prod(s0(1:4)) nch])*[colors],s1);
            %full_movie = permute(vol_unmixed,[1 2 5 3 4]); 
            %full_movie = reshape(full_movie,stackSizeX,stackSizeY*stackSizeC,stackSizeZ,stackSizeT);
            full_movie = squeeze(sum(full_movie ,3)); %full_movie = full_movie(:,:,:,[3 2 1]);
            %full_movie = squeeze(sum(max(final,[],3),5));
            %full_movie = squeeze(max(max(final,[],3),[],5));
            h = fspecial('gaussian',7,1);
            for ic = 1:size(full_movie,4)
                %bkg = squeeze(mean(full_movie(:,:,:,ic),3)); % average through time
                %mins = squeeze(min(min(full_movie(:,:,:,ic),[],2),[],1));
                %maxs = squeeze(max(max(full_movie(:,:,:,ic),[],2),[],1));
                for it=1:size(full_movie,3)
                    fr = imfilter(squeeze(full_movie(:,:,it,ic)),h);
                    fr = (fr-min(fr(:)))/(max(fr(:))-min(fr(:)))*255;
                    full_movie(:,:,it,ic)=fr;
                end
            end
            full_movie = uint8(full_movie/max(full_movie(:))*255);
            writer = VideoWriter(total_name);
            set(writer,'FrameRate',10);
            open(writer);
            for iframe = 1:size(full_movie,3)
                writeVideo(writer,squeeze(full_movie(:,:,iframe,:)));
            end
            close(writer);
            end

            fprintf('done!\n');               
        end
    end
    
    close(hProgress);
end

if StaticBox==1
    hProgress = waitbar(0,'Analysis progress...');
    
    for ifile = 1:length(files)
        rawDataFilename = files(ifile).name;
        rawDataPath = fullfile(indir,rawDataFilename);
        
        %% Read in raw data
        fprintf('Opening %s\n',rawDataPath);
        reader = bfGetReader(rawDataPath);
        
        a = bfopen(rawDataPath);
        
        if MergeImages
            total=[];
        end
        
        for i_series = 1:size(a,1)            
            total_progress = (ifile-1)/length(files) + (i_series)/size(a,1)/length(files);
            status = sprintf('%s (%i/%d)...',rawDataFilename,i_series,size(a,1));

            if MergeImages
                waitbar(total_progress,hProgress,sprintf('Loading %s',status))
            else
                waitbar(total_progress,hProgress,sprintf('Analyzing %s',status))
            end
            
            fprintf('Analyzing series %d\n',i_series);
            
            reader.setSeries(i_series-1);
            omeMeta = reader.getMetadataStore();
            stackSizeC = omeMeta.getPixelsSizeC(i_series-1).getValue(); % number of channels
            
            vol = a{i_series,1};
            vol = cat(3,vol{:,1});
            vol = reshape(vol,[size(vol,1) size(vol,2) stackSizeC size(vol,3)/stackSizeC]);     % 3D -> XYCZ
            vol = permute(vol,[1 2 4 3]);                                                       % XYCZ -> XYZC
            
            if ~MergeImages
                doAnalysis(handles, vol, spectra, doRescale, fullfile(outdir,[rawDataFilename(1:end-extension_length) '-series' num2str(i_series)]));
            end
            
            if MergeImages
                total = cat(3,total,vol);
            end
        end
        
        if MergeImages
            waitbar(total_progress,hProgress,sprintf('Analyzing entire %s ...',rawDataFilename))
            doAnalysis(handles, total, spectra, doRescale, fullfile(outdir,rawDataFilename(1:end-extension_length)));
        end
        
    end
     
    close(hProgress);
end

if MovieBox==0 && StaticBox==0
    uiwait(msgbox('Please select either static or movie','Error','error'));
    return
end

uiwait(msgbox('Processing finished!','Done'));

guidata(hObject,handles);

function doAnalysis(handles, volume, spectra, doRescale, outFilename)
if get(handles.spectralunmix,'Value') == 1
    vol_unmixed_iso = unmixing(volume,spectra);
else
    vol_unmixed_iso = volume;
end

if get(handles.doMath,'Value') == 1
    final = vol_unmixed_iso;
    NumberofNewChannels = str2double(get(handles.NumberofNewChannels,'String'));
    for ndoMath = 1:NumberofNewChannels
        include = handles.IncludeArray{ndoMath};
        exclude = handles.ExcludeArray{ndoMath};
        basechannel = handles.BaseChannelArray{ndoMath};
        final = doMath_noDipImage(include,exclude,basechannel,final);
    end
else
    final = vol_unmixed_iso;
end

fprintf('Saving final giant volume ');
h5filename = [outFilename '.h5'];
if exist(h5filename,'file')
    warning(['Found existing file and deleting ' h5filename]);
    delete(h5filename);
end

if doRescale && (isa(final,'float') || isa(final,'double'))
    warning('Rescaling floating point data to fill the uint16 range')
    scaleFactor=zeros(size(final,4),1);
    for ich = 1:size(final,4)
        final_c = final(:,:,:,ich);
        scaleFactor(ich) = 256*256/max(final_c(:));
        final(:,:,:,ich) = scaleFactor(ich) * final_c;
    end
    writetable(table(scaleFactor),[outFilename '.scaleFactors.txt']);
end
writeBigDataXML(outFilename,uint16(final),'XYZC','DeflateLevel',3);
fprintf('done!\n');

function baseChannel = getBaseChannel(handles)
    allchannels_s = get(handles.basechannelmenu,'String');
    baseChannel = str2double(allchannels_s(get(handles.basechannelmenu,'Value'),:));



function eExtension_Callback(hObject, eventdata, handles)
% hObject    handle to eExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eExtension as text
%        str2double(get(hObject,'String')) returns contents of eExtension as a double


% --- Executes during object creation, after setting all properties.
function eExtension_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eExtension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
