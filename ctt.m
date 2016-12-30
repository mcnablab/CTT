function varargout = ctt(varargin)
% MATLAB GUI of CLARITY Tractography Toolbox
%
%
%
% Qiyuan Tian, McNab Lab, Stanford University
% December 2016

% GUI Initialization
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ctt_OpeningFcn, ...
                   'gui_OutputFcn',  @ctt_OutputFcn, ...
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

function ctt_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
initialize_gui(hObject, handles, false);


function varargout = ctt_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


%%%% Object Initialization %%%%
function initialize_gui(fig_handle, handles, isreset)
if ~isreset
    return;
end
handles.params.outdir = '';
handles.params.roidir = '';
handles.params.dogsigmas = [];
handles.params.gausigmas = [];
handles.params.angthresholds = [];

set(handles.etout, 'String', '');
set(handles.etroi, 'String', '');
set(handles.etdog, 'String', '');
set(handles.etgau, 'String', '');
set(handles.etang, 'String', '');

guidata(handles.figure1, handles);



%%%% Callback %%%%
function etout_Callback(hObject, eventdata, handles)
dpOut = get(hObject, 'String');
if ~exist(dpOut, 'dir')
    errordlg('Input must be a number', 'Error');
end

function etroi_Callback(hObject, eventdata, handles)
dpRoi = get(hObject, 'String');
if ~exist(dpRoi, 'dir')
    errordlg('ROI directory does not exist! Input again!', 'Error');
end

function etdog_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('DoG Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.params.dogsigmas = sigs;

function etgau_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('Gau Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.params.gausigmas = sigs;

function etang_Callback(hObject, eventdata, handles)
angstr = get(hObject, 'String');
angs = str2num(angstr);
if isempty(angs)
   errordlg('Angle Threshold must be numbers! Input again!', 'Error'); 
   return
end
handles.params.angthresholds = angs;

function pbout_Callback(hObject, eventdata, handles)

function pbroi_Callback(hObject, eventdata, handles)
dpRoi = uigetdir;
set(handles.etroi, 'String', dpRoi);

function pbtrack_Callback(hObject, eventdata, handles)

function pbreset_Callback(hObject, eventdata, handles)
initialize_gui(gcbf, handles, true);


%%%%% Object %%%%%
function etout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function etroi_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function etdog_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function etgau_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function etang_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

