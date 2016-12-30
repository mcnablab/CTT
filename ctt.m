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
initialize_gui(hObject, handles);

function varargout = ctt_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%%%% Object %%%%%
function etout_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function etin_CreateFcn(hObject, eventdata, handles)
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


%%%% Callback %%%%
function etout_Callback(hObject, eventdata, handles)
dpOut = get(hObject, 'String');
if ~exist(dpOut, 'dir')
    response = questdlg([dpOut ' does not exist! Create this directory?'], 'Yes', 'No');
    if strcmpi(response, 'yes')
        mkdir(dpOut);
        warndlg([dpOut ' created!']);
    else
        errordlg('Directory does not exist! Enter again!', 'Error');
        return
    end
end
handles.param.outdir = dpOut;
updata_log(hObject, handles, ['Output directory selected: ' dpOut])


function etin_Callback(hObject, eventdata, handles)
dpIn = get(hObject, 'String');
if ~exist(dpIn, 'dir')
    errordlg('Input directory does not exist! Enter again!', 'Error');
    return
end
handles.param.indir = dpIn;
updata_log(hObject, handles, ['Input directory selected: ' dpIn])


function etdog_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('DoG Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.param.dogsigmas = sigs(:)';
updata_log(hObject, handles, ['DoG Sigma selected: ' mat2str(handles.param.dogsigmas)]);


function etgau_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('Gau Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.param.gausigmas = sigs(:)';
updata_log(hObject, handles, ['Gau Sigma selected: ' mat2str(handles.param.gausigmas)]);


function etang_Callback(hObject, eventdata, handles)
angstr = get(hObject, 'String');
angs = str2num(angstr);
if isempty(angs)
   errordlg('Angle Threshold must be numbers! Input again!', 'Error'); 
   return
end
handles.param.angthresholds = angs(:)';
updata_log(hObject, handles, ['Angle Threshold selected: ' mat2str(handles.param.angthresholds)]);


function pbout_Callback(hObject, eventdata, handles)
dpOut = uigetdir;
if dpOut == 0, return, end
set(handles.etout, 'String', dpOut);
updata_log(hObject, handles, ['Output directory selected: ' dpOut])


function pbin_Callback(hObject, eventdata, handles)
dpIn = uigetdir;
if dpIn == 0, return, end
set(handles.etin, 'String', dpIn);
updata_log(hObject, handles, ['Input directory selected: ' dpIn])


function pbtrack_Callback(hObject, eventdata, handles)


function pbreset_Callback(hObject, eventdata, handles)
initialize_gui(gcbf, handles);

%%%% utility %%%%
function initialize_gui(fig_handle, handles)

handles.param.outdir = '';
handles.param.indir = '';
handles.param.datadir = '';
handles.param.bmaskdir = '';
handles.param.smaskdir = '';

handles.param.dogsigmas = [];
handles.param.gausigmas = [];
handles.param.angthresholds = [];
handles.log = '';

set(handles.etout, 'String', '');
set(handles.etin, 'String', '');
set(handles.etdog, 'String', '');
set(handles.etgau, 'String', '');
set(handles.etang, 'String', '');
set(handles.stlog, 'String', handles.log);

guidata(handles.figure1, handles);

root = fileparts(mfilename('fullpath'));
addpath(genpath(root));

function updata_log(fig_handle, handles, str)
handles.log = [str char(10) handles.log];
set(handles.stlog, 'String', handles.log);
guidata(handles.figure1, handles);
