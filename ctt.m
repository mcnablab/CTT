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
handles = initialize_gui(hObject, handles);
guidata(hObject, handles);

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
handles = updata_log(hObject, handles, ['Output directory selected: ' dpOut]);

guidata(handles.figure1, handles);


function etin_Callback(hObject, eventdata, handles)
dpIn = get(hObject, 'String');
if ~exist(dpIn, 'dir')
    errordlg('Input directory does not exist! Enter again!', 'Error');
    return
end
handles.param.indir = dpIn;
handles = updata_log(hObject, handles, ['Input directory selected: ' dpIn]);

guidata(handles.figure1, handles);


function etdog_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('DoG Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.param.dogsigmas = sigs(:)';
handles = updata_log(hObject, handles, ['DoG Sigma selected: ' mat2str(handles.param.dogsigmas)]);

guidata(handles.figure1, handles);


function etgau_Callback(hObject, eventdata, handles)
sigstr = get(hObject, 'String');
sigs = str2num(sigstr);
if isempty(sigs)
   errordlg('Gau Sigma must be numbers! Input again!', 'Error'); 
   return
end
handles.param.gausigmas = sigs(:)';
handles = updata_log(hObject, handles, ['Gau Sigma selected: ' mat2str(handles.param.gausigmas)]);

guidata(handles.figure1, handles);


function etang_Callback(hObject, eventdata, handles)
angstr = get(hObject, 'String');
angs = str2num(angstr);
if isempty(angs)
   errordlg('Angle Threshold must be numbers! Input again!', 'Error'); 
   return
end
handles.param.angthresholds = angs(:)';
handles = updata_log(hObject, handles, ['Angle Threshold selected: ' mat2str(handles.param.angthresholds)]);

guidata(handles.figure1, handles);


function pbout_Callback(hObject, eventdata, handles)
dpOut = uigetdir;
if dpOut == 0, return, end
set(handles.etout, 'String', dpOut);
handles.param.outdir = dpOut;
handles = updata_log(hObject, handles, ['Output directory selected: ' dpOut]);

guidata(handles.figure1, handles);


function pbin_Callback(hObject, eventdata, handles)
dpIn = uigetdir;
if dpIn == 0, return, end
set(handles.etin, 'String', dpIn);
handles.param.indir = dpIn;
handles = updata_log(hObject, handles, ['Input directory selected: ' dpIn]);

guidata(handles.figure1, handles);


function pbreset_Callback(hObject, eventdata, handles)
handles = initialize_gui(gcbf, handles);

guidata(handles.figure1, handles);

function pbconvert_Callback(hObject, eventdata, handles)
dpIn = handles.param.indir;
if isempty(dpIn), errordlg('Input directory does not exist! Enter please!', 'Error'), return, end

dpOut = handles.param.outdir;
if isempty(dpOut), errordlg('Output directory does not exist! Enter please!', 'Error'), return, end

handles = convert2nii(hObject, handles, 'data', 'datadir');
handles = convert2nii(hObject, handles, 'mask-brain', 'bmaskdir');
handles = convert2nii(hObject, handles, 'mask-seed', 'smask');

dirname = listdir(fullfile(dpIn, 'mask-roi*'));
if ~isempty(dirname)
    for ii = 1 : length(dirname)
        handles = convert2nii(hObject, handles, dirname{ii}, 'rmask');
    end
end
guidata(handles.figure1, handles);

function pbtrack_Callback(hObject, eventdata, handles)
dpIn = handles.param.indir;
if isempty(dpIn), errordlg('Input directory does not exist! Enter please!', 'Error'), return, end

dpOut = handles.param.outdir;
if isempty(dpOut), errordlg('Output directory does not exist! Enter please!', 'Error'), return, end

dogsigs = handles.param.dogsigmas;
if isempty(dogsigs), errordlg('DoG Sigma does not exist! Enter please!', 'Error'), return, end

gausigs = handles.param.gausigmas;
if isempty(gausigs), errordlg('Gau Sigma directory does not exist! Enter please!', 'Error'), return, end

angs = handles.param.angthresholds;
if isempty(angs), errordlg('Angle Threshold does not exist! Enter please!', 'Error'), return, end

fpData = fullfile(dpOut, [handles.param.datadir '.nii.gz']);
if ~exist(fpData, 'file'), handles = convert2nii(hObject, handles, 'data', 'datadir'); end

fpBmask = fullfile(dpOut, [handles.param.bmaskdir '.nii.gz']);
if ~exist(fpBmask, 'file')
    handles = convert2nii(hObject, handles, 'mask-brain', 'bmaskdir'); 
    fpBmask = fullfile(dpOut, [handles.param.bmaskdir '.nii.gz']);
end

fpSmask = fullfile(dpOut, [handles.param.smaskdir '.nii.gz']);
if ~exist(fpSmask, 'file')
    handles = convert2nii(hObject, handles, 'mask-seed', 'smaskdir'); 
    fpSmask = fullfile(dpOut, [handles.param.smaskdir '.nii.gz']);
end

handles = updata_log(hObject, handles, 'Tracking starts ...'); pause(1);

stack = single(loadstack(fullfile(dpIn, handles.param.datadir)));
track(stack, dogsigs, gausigs, angs, fpBmask, fpSmask, dpOut);

handles = updata_log(hObject, handles, 'Tracking completes.');

guidata(handles.figure1, handles);

%%%% utility %%%%
function handles = initialize_gui(fig_handle, handles)

handles.param.outdir = '';
handles.param.indir = '';
handles.param.datadir = '';
handles.param.bmaskdir = '';
handles.param.smaskdir = '';
handles.param.rmaskdir = '';

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

root = fileparts(mfilename('fullpath'));
addpath(genpath(root));

function handles = updata_log(fig_handle, handles, str)
handles.log = [str char(10) handles.log];
set(handles.stlog, 'String', handles.log);

function handles = convert2nii(fig_handle, handles, name, field)
dpIn = handles.param.indir;
dpOut = handles.param.outdir;

dirname = listdir(fullfile(dpIn, [name '*']));
if isempty(dirname), errordlg([name ' directory does not exist! Check please!'], 'Error'), return, end
if length(dirname) > 1, errordlg(['Multiple ' name ' directories exist! Check please!'], 'Error'), return, end
handles.param.(field) = dirname{1};
handles = updata_log(fig_handle, handles, [name ' directory selected: ' handles.param.(field)]);

handles = updata_log(fig_handle, handles, ['Converting ' name ' to nii ...']);
stack = loadstack(fullfile(dpIn, handles.param.(field)));
fpNii = fullfile(dpOut, [handles.param.(field) '.nii.gz']);
writenii(stack, fpNii);
handles = updata_log(fig_handle, handles, ['Converting ' name ' to nii is done.']);

