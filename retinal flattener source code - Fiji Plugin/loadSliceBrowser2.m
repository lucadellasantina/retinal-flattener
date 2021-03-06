function varargout = loadSliceBrowser2(varargin)
% LOADSLICEBROWSER2 MATLAB code for loadSliceBrowser2.fig
%      LOADSLICEBROWSER2, by itself, creates a new LOADSLICEBROWSER2 or raises the existing
%      singleton*.
%
%      H = LOADSLICEBROWSER2 returns the handle to a new LOADSLICEBROWSER2 or the handle to
%      the existing singleton*.
%
%      LOADSLICEBROWSER2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADSLICEBROWSER2.M with the given input arguments.
%
%      LOADSLICEBROWSER2('Property','Value',...) creates a new LOADSLICEBROWSER2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loadSliceBrowser2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loadSliceBrowser2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loadSliceBrowser2

% Last Modified by GUIDE v2.5 18-Dec-2017 09:40:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loadSliceBrowser2_OpeningFcn, ...
                   'gui_OutputFcn',  @loadSliceBrowser2_OutputFcn, ...
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


% --- Executes just before loadSliceBrowser2 is made visible.
function loadSliceBrowser2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loadSliceBrowser2 (see VARARGIN)

% Choose default command line output for loadSliceBrowser2
% handles.output = hObject;
global twostacks usepoints threestacks singlesurface
twostacks=0;
threestacks=0;
usepoints=1;
set(handles.usepoints,'Value',usepoints);
singlesurface=0;

movegui('northwest');
set(handles.loadedfile,'String','');
set(handles.xup,'String',1);
set(handles.yup,'String',1);
set(handles.zup,'String',1);
set(handles.smoothing,'String',20);
set(handles.maxthick,'String',10);
set(handles.movech1menu,'String',{'Channel 1','Channel 2','Channel 3'});
set(handles.imethod,'String',{'nearest';'linear';'cubic'});
set(handles.imethod,'Value',3);
set(handles.volumetoview,'String',{' '});
set(handles.mincellpixels,'String',100);
set(handles.maxcellpixels,'String',800);
set(handles.cellthresh,'String',200);
set(handles.celltrim,'String',3);
set(handles.cellsmooth,'String',9);

global addpoint chatpointx chatpointy chatpointz chatpointradius chatpointsurf
addpoint=0;
chatpointx=[];
chatpointy=[];
chatpointz=[];
chatpointradius=[];
chatpointsurf=[];

volume=varargin{1};
if ndims(volume==4)
volume=permute(volume,[2 1 4 3]);
else     
volume=permute(volume,[2 1 3]);
end
set(handles.loadedfile,'String',strcat('Image stack from Fiji is loaded: [',num2str(size(squeeze(volume(:,:,:,1)))),']'));
imstack=[];
im2stack=[];
im3stack=[];
        imstack=squeeze(volume(:,:,:,1));
        set(handles.channelorder,'String','1');
        twostacks=0;
        threestacks=0;
        numchan=size(volume,4);
        if numchan>1
            set(handles.channelorder,'String','1 2');
            twostacks=1;
            im2stack=squeeze(volume(:,:,:,2));
        end
        if numchan>2
            set(handles.channelorder,'String','1 2 3');
            threestacks=1;
            im3stack=squeeze(volume(:,:,:,3));
        end
handles.imstack=uint16(imstack);
handles.im2stack=uint16(im2stack);
handles.im3stack=uint16(im3stack);
imstack=[];
im2stack=[];
im3stack=[];

set(handles.volumetoview,'String',{'original'});
set(handles.volumetoview,'Value',1);
if get(handles.volumetoview,'Value')==1
end
% if get(handles.twochannels,'Value')
if twostacks
    set(handles.viewchannel2,'Enable','on');
else
    set(handles.viewchannel2,'Enable','off');
end
if threestacks
    set(handles.viewchannel3,'Enable','on');
else
    set(handles.viewchannel3,'Enable','off');
end
set(handles.viewslices,'Enable','on');
set(handles.upsample,'Enable','on');
set(handles.enableupsampling,'Enable','on');
% Update handles structure
h = waitbar(1,'Please Wait... Updating');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);

% UIWAIT makes loadSliceBrowser2 wait for user response (see UIRESUME)
uiwait(gcf);


% --- Outputs from this function are returned to the command line.
function varargout = loadSliceBrowser2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
global twostacks threestacks
if threestacks
    handles.output(:,:,3,:)=permute(handles.newim3stack,[2 1 4 3]);
end
if twostacks
    handles.output(:,:,2,:)=permute(handles.newim2stack,[2 1 4 3]);
end
handles.output(:,:,1,:)=permute(handles.newimstack,[2 1 4 3]);

% Get default command line output from handles structure
varargout{1} = handles.output;
close all


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks threestacks
[filename,pathname] = uigetfile({'*.lsm';'*.tif'});
if isequal(filename,0)
   disp('User selected Cancel')
else
h = waitbar(0,'Please Wait... Loading File');
im=tiffread(fullfile(pathname, filename));
imstack=[];
im2stack=[];
im3stack=[];
even=0;
for i=1:length(im)
    if iscell(im(i).data)
        imstack=cat(3,imstack,im(i).data{1});
%         if get(handles.twochannels,'Value')
set(handles.channelorder,'String','1 2 3');
        twostacks=0;
        threestacks=0;
        numchan=size(im(1).data,1);
        if numchan>1
            set(handles.channelorder,'String','1 2');
            twostacks=1;
            im2stack=cat(3,im2stack,im(i).data{2});
        end
        if numchan>2
            set(handles.channelorder,'String','1 2 3');
            threestacks=1;
            im3stack=cat(3,im3stack,im(i).data{3});
        end
    else
%         if get(handles.twochannels,'Value')
            set(handles.channelorder,'String','1 2');
            twostacks=1;
            if even
                im2stack=cat(3,im2stack,im(i).data);
                even=0;
            else
                imstack=cat(3,imstack,im(i).data);
                even=1;
            end
%         else
%             twostacks=0;
%             imstack=cat(3,imstack,im(i).data);
%         end
    end
    waitbar(i/length(im),h);
end
% movech1=get(handles.movech1menu,'Value');
% if movech1==1
%     handles.imstack=uint16(imstack);
%     handles.im2stack=uint16(im2stack);
%     handles.im3stack=uint16(im3stack);
% else
%     if movech1==2
%         if twostacks
%             handles.imstack=uint16(im2stack);
%             handles.im2stack=uint16(imstack);
%             handles.im3stack=uint16(im3stack);
%         else
%             handles.imstack=uint16(imstack);
%             handles.im2stack=uint16(im2stack);
%             handles.im3stack=uint16(im3stack);
%         end
%     else
%         if threestacks
%             handles.imstack=uint16(im3stack);
%             handles.im2stack=uint16(im2stack);
%             handles.im3stack=uint16(imstack);
%         else
%             handles.imstack=uint16(imstack);
%             handles.im2stack=uint16(im2stack);
%             handles.im3stack=uint16(im3stack);
%         end
%     end
% end
% if get(handles.channelswitch,'Value')
%     handles.imstack=uint16(im2stack);
%     handles.im2stack=uint16(imstack);
% else
%     handles.imstack=uint16(imstack);
%     handles.im2stack=uint16(im2stack);
% end
% handles.im3stack=uint16(im3stack);
% handles.imst10_resized=0.*handles.imstack;
%delete imstack im2stack
%clear imstack im2stack
handles.imstack=uint16(imstack);
handles.im2stack=uint16(im2stack);
handles.im3stack=uint16(im3stack);
imstack=[];
im2stack=[];
im3stack=[];
set(handles.loadedfile,'String',filename);
set(handles.volumetoview,'String',{'original'});
set(handles.volumetoview,'Value',1);
if get(handles.volumetoview,'Value')==1
end
% if get(handles.twochannels,'Value')
if twostacks
    set(handles.viewchannel2,'Enable','on');
else
    set(handles.viewchannel2,'Enable','off');
end
if threestacks
    set(handles.viewchannel3,'Enable','on');
else
    set(handles.viewchannel3,'Enable','off');
end
set(handles.viewslices,'Enable','on');
set(handles.upsample,'Enable','on');
set(handles.enableupsampling,'Enable','on');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);
end



function loadedfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadedfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadedfile as text
%        str2double(get(hObject,'String')) returns contents of loadedfile as a double


% --- Executes during object creation, after setting all properties.
function loadedfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadedfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in upsample.
function upsample_Callback(hObject, eventdata, handles)
% hObject    handle to upsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks threestacks
try
xup=max(1,floor(str2double(get(handles.xup,'String'))));
yup=max(1,floor(str2double(get(handles.yup,'String'))));
zup=max(1,floor(str2double(get(handles.zup,'String'))));
imethods=get(handles.imethod,'String');
imethod=imethods(get(handles.imethod,'Value'));
% imstack=handles.imstack;
% im2stack=handles.im2stack;
% save('temp_imstacks.mat','imstack','im2stack');
%delete imstack im2stack handles.im2stack
%clear imstack im2stack handles.im2stack
% imstack=[];
% im2stack=[];
if xup>0&&yup>0&&zup>0
if xup~=1||yup~=1||zup~=1
    size(handles.imstack)
    %try
        %delete handles.supsampledimstack handles.supsampledim2stack
        %clear handles.supsampledimstack handles.supsampledim2stack
        handles.supsampledimstack=int16([]);
        handles.supsampledim2stack=int16([]);
        [null, k] = flexinterpn_method(1, 1, imethod{1});
        %[bgridx,bgridy,bgridz]=meshgrid(single(1:1/xup:size(handles.imstack,2)),single(1:1/yup:size(handles.imstack,1)),single(1:1/zup:size(handles.imstack,3)));
        h = waitbar(0,'Please Wait... Upsampling Channel 1');
        try
            %handles.upsampledimstack=flexinterpn(handles.imstack,[Inf,Inf,Inf;1,1,1;1/xup,1/yup,1/zup;size(handles.imstack,1),size(handles.imstack,2),size(handles.imstack,3)],k(:),1);
            %throw;
        catch
            %strcat('error upsampling channel 1: may need to compile flexinterpn on this computer; using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
            %handles.upsampledimstack=interp3(double(handles.imstack),min([xup,yup,zup]),imethod{1});
            w = warndlg(sprintf('Error upsampling channel 1: may need to compile flexinterpn on this computer.\nClick Ok to just using original volume instead.'));
            uiwait(w);
            handles.upsampledimstack=handles.imstack;
        end
        totalslice=size(handles.imstack,3)*zup;
        totalx=size(handles.imstack,1)*xup;
        totaly=size(handles.imstack,2)*yup;
        quarterslice=2*zup
        subd=floor(totalslice/quarterslice)
        ol=2;
        if 1
            waitbar(1/subd,h);
            [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,quarterslice/zup+ol,quarterslice+ol*zup));
            handles.upsampledimstack(:,:,1:quarterslice+ol*zup)=interp3(double(handles.imstack(:,:,1:quarterslice/zup+ol)),meshx,meshy,meshz,imethod{1});
            handles.supsampledimstack(:,:,1:quarterslice)=uint16(handles.upsampledimstack(:,:,1:quarterslice));
            handles.upsampledimstack(:,:,1:quarterslice)=[];
        end
        [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,quarterslice/zup+ol*2,quarterslice+ol*2*zup));
        for i=2:subd-1
            waitbar(1/subd*i,h);
            handles.upsampledimstack(:,:,1:quarterslice+ol*2*zup)=interp3(double(handles.imstack(:,:,quarterslice/zup*(i-1)+1-ol:i*quarterslice/zup+ol)),meshx,meshy,meshz,imethod{1});
            handles.supsampledimstack(:,:,quarterslice*(i-1)+1:i*quarterslice)=uint16(handles.upsampledimstack(:,:,1+ol*zup:quarterslice+ol*zup));
            handles.upsampledimstack(:,:,1:quarterslice)=[];
        end
        if 1
            waitbar(1-1/subd/2,h);
            [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,(totalslice-(subd-1)*quarterslice)/zup+ol,totalslice-(subd-1)*quarterslice+ol*zup));
            handles.upsampledimstack(:,:,1:totalslice-(subd-1)*quarterslice+ol*zup)=interp3(double(handles.imstack(:,:,(subd-1)*quarterslice/zup+1-ol:end)),meshx,meshy,meshz,imethod{1});
            handles.supsampledimstack(:,:,(subd-1)*quarterslice+1:totalslice)=uint16(handles.upsampledimstack(:,:,1+ol*zup:totalslice-(subd-1)*quarterslice+ol*zup));
        end
        %delete handles.upsampledimstack
        %clear handles.upsampledimstack
        handles.upsampledimstack=[];
        size(handles.supsampledimstack)
        waitbar(1,h);
        delete(h);
        if twostacks
            h = waitbar(0,'Please Wait... Upsampling Channel 2');
            try
                %handles.upsampledim2stack=flexinterpn(handles.im2stack,[Inf,Inf,Inf;1,1,1;1/xup,1/yup,1/zup;size(handles.im2stack,1),size(handles.im2stack,2),size(handles.im2stack,3)],k(:),1);
                %throw;
            catch
                %strcat('error upsampling channel 2: may need to compile flexinterpn on this computer; using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
                %handles.upsampledim2stack=interp3(double(handles.im2stack),min([xup,yup,zup]),imethod{1});
                w = warndlg(sprintf('Error upsampling channel 2: may need to compile flexinterpn on this computer.\nClick Ok to just using original volume instead.'));
                uiwait(w);
                handles.upsampledim2stack=handles.im2stack;
            end
            if 1
                waitbar(1/subd,h);
                [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,quarterslice/zup+ol,quarterslice+ol*zup));
                handles.upsampledim2stack(:,:,1:quarterslice+ol*zup)=interp3(double(handles.im2stack(:,:,1:quarterslice/zup+ol)),meshx,meshy,meshz,imethod{1});
                handles.supsampledim2stack(:,:,1:quarterslice)=uint16(handles.upsampledim2stack(:,:,1:quarterslice));
                handles.upsampledim2stack(:,:,1:quarterslice)=[];
            end
            [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,quarterslice/zup+ol*2,quarterslice+ol*2*zup));
            for i=2:subd-1
                waitbar(1/subd*i,h);
                handles.upsampledim2stack(:,:,1:quarterslice+ol*2*zup)=interp3(double(handles.im2stack(:,:,quarterslice/zup*(i-1)+1-ol:i*quarterslice/zup+ol)),meshx,meshy,meshz,imethod{1});
                handles.supsampledim2stack(:,:,quarterslice*(i-1)+1:i*quarterslice)=uint16(handles.upsampledim2stack(:,:,1+ol*zup:quarterslice+ol*zup));
                handles.upsampledim2stack(:,:,1:quarterslice)=[];
            end
            if 1
                waitbar(1-1/subd/2,h);
                [meshx,meshy,meshz]=meshgrid(linspace(0,size(handles.imstack,1),size(handles.imstack,1)*xup),linspace(0,size(handles.imstack,2),size(handles.imstack,2)*yup),linspace(0,(totalslice-(subd-1)*quarterslice)/zup+ol,totalslice-(subd-1)*quarterslice+ol*zup));
                handles.upsampledim2stack(:,:,1:totalslice-(subd-1)*quarterslice+ol*zup)=interp3(double(handles.im2stack(:,:,(subd-1)*quarterslice/zup+1-ol:end)),meshx,meshy,meshz,imethod{1});
                handles.supsampledim2stack(:,:,(subd-1)*quarterslice+1:totalslice)=uint16(handles.upsampledim2stack(:,:,1+ol*zup:totalslice-(subd-1)*quarterslice+ol*zup));
            end
            %delete handles.upsampledim2stack
            %clear handles.upsampledim2stack
            handles.upsampledim2stack=[];
            size(handles.supsampledim2stack)
            waitbar(1,h);
            delete(h);
        end
%     catch
%         strcat('error: may need to compile flexinterpn on this computer, using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
%         clear bgridx bgridy bgridz
%         memory
%         handles.newimstack=interp3(handles.imstack,min([xup,yup,zup]),imethod{1});
%     end
else
    handles.supsampledimstack=handles.imstack;
    handles.supsampledim2stack=handles.im2stack;
    handles.supsampledim3stack=handles.im3stack;
end
else
    error('x, y, and z factors must be >0')
end
class(handles.supsampledimstack)
class(handles.supsampledim2stack)
set(handles.volumetoview,'String',{'original','upsampled'});
set(handles.volumetoview,'Value',2);
set(handles.findcellbodies,'Enable','on');
catch errorObj
% If there is a problem, we display the error message
errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
handles.supsampledimstack=handles.imstack;
handles.supsampledim2stack=handles.im2stack;
handles.supsampledim3stack=handles.im3stack;
class(handles.supsampledimstack)
class(handles.supsampledim2stack)
set(handles.volumetoview,'String',{'original','upsampled'});
set(handles.volumetoview,'Value',2);
set(handles.findcellbodies,'Enable','on');
end
h = waitbar(1,'Please Wait... Updating');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);



function xup_Callback(hObject, eventdata, handles)
% hObject    handle to xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xup as text
%        str2double(get(hObject,'String')) returns contents of xup as a double


% --- Executes during object creation, after setting all properties.
function xup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yup_Callback(hObject, eventdata, handles)
% hObject    handle to yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yup as text
%        str2double(get(hObject,'String')) returns contents of yup as a double


% --- Executes during object creation, after setting all properties.
function yup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zup_Callback(hObject, eventdata, handles)
% hObject    handle to zup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zup as text
%        str2double(get(hObject,'String')) returns contents of zup as a double


% --- Executes during object creation, after setting all properties.
function zup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processchat.
function processchat_Callback(hObject, eventdata, handles)
% hObject    handle to processchat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks singlesurface threestacks
% try
maxthick=str2double(get(handles.maxthick,'String'));
[handles.VZminmesh,handles.VZmaxmesh,maxdiffs]=processchat_nosave2(handles.imst2,str2double(get(handles.smoothing,'String')),maxthick,singlesurface,get(handles.ignorecolumns,'Value'),handles.imst11);
% catch
%     errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');    
%     handles.VZminmesh=zeros(size(handles.supsampledimstack,1),size(handles.supsampledimstack,2));
%     handles.VZmaxmesh=zeros(size(handles.supsampledimstack,1),size(handles.supsampledimstack,2));
% end
[Nhist,edgeshist]=histcounts(maxdiffs);
[maxNhist,indNhist]=max(Nhist);
indNhist2 = find(Nhist >= 3/4*maxNhist, 1, 'last');
maxedgehist=1+edgeshist(indNhist2+1);
axes(handles.thicknesshist);
hg=histogram(maxdiffs);
hg.Orientation = 'horizontal';
hg.EdgeColor=hg.FaceColor;
xlim([0,maxNhist*6/5]);
set(gca,'XTickLabel',[])
title('Thickness Between CHaT Layers','FontSize',6);
ylabel('Pixels','FontSize',6);
hold on;
h2=line(xlim,[maxthick maxthick],'Color','k','LineWidth',2);
h1=line(xlim,[maxedgehist maxedgehist],'Color','r','LineWidth',1,'LineStyle','--');
lgd=legend([h1,h2],{sprintf(strcat('Estimated Max = ',num2str(maxedgehist))),sprintf(strcat('Applied Max = ',num2str(maxthick)))},'Position',[.52 .46 .05 .05],'color','none','box','off','Fontsize',8);
hold off;
'chat done'
set(handles.saveflattenallch,'Enable','on');
set(handles.flattench1,'Enable','on');
set(handles.scalethickness,'Enable','on');
if twostacks
    set(handles.flattench2,'Enable','on');
else
    set(handles.flattench2,'Enable','off');
end
if threestacks
    set(handles.flattench3,'Enable','on');
else
    set(handles.flattench3,'Enable','off');
end
h = waitbar(1,'Please Wait... Updating');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);



function smoothing_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothing as text
%        str2double(get(hObject,'String')) returns contents of smoothing as a double


% --- Executes during object creation, after setting all properties.
function smoothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewslices.
function viewslices_Callback(hObject, eventdata, handles)
% hObject    handle to viewslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Figures = findobj('Type','Figure','-not','Tag',get(handles.figure1,'Tag'));
close(Figures)
svalue=1;
if get(handles.viewchannel1,'Value')
if get(handles.volumetoview,'Value')==1
    SliceBrowser(handles.imstack);
else
    if get(handles.volumetoview,'Value')==2
        try
            SliceBrowser(handles.supsampledimstack,handles.imst10_resized,svalue.*handles.VZminmesh,svalue.*handles.VZmaxmesh);
        catch
            try
            SliceBrowser(handles.supsampledimstack,handles.imst10_resized);    
            catch
            SliceBrowser(handles.supsampledimstack);
            end
        end
    else
        try
            SliceBrowser(handles.newimstack,0.*handles.imst10_resized,svalue.*handles.newVZminmesh,svalue.*handles.newVZmaxmesh);
        catch
            try
            SliceBrowser(handles.newimstack,0.*handles.imst10_resized);
            catch
            SliceBrowser(handles.newimstack);
            end
        end
    end
end
else
if get(handles.viewchannel2,'Value')
if get(handles.volumetoview,'Value')==1
    SliceBrowser(handles.im2stack);
else
    if get(handles.volumetoview,'Value')==2
        try
            SliceBrowser(handles.supsampledim2stack,handles.imst10_resized,svalue.*handles.VZminmesh,svalue.*handles.VZmaxmesh,1);
        catch
            try
            SliceBrowser(handles.supsampledim2stack,handles.imst10_resized);
            catch
            SliceBrowser(handles.supsampledim2stack);
            end
        end
    else
        try
            SliceBrowser(handles.newim2stack,0.*handles.imst10_resized,svalue.*handles.newVZminmesh,svalue.*handles.newVZmaxmesh);
        catch
            try
            SliceBrowser(handles.newim2stack,0.*handles.imst10_resized);
            catch
            SliceBrowser(handles.newim2stack);
            end
        end
    end
end
else
if get(handles.volumetoview,'Value')==1
    SliceBrowser(handles.im3stack);
else
    if get(handles.volumetoview,'Value')==2
        try
            SliceBrowser(handles.supsampledim3stack,handles.imst10_resized,svalue.*handles.VZminmesh,svalue.*handles.VZmaxmesh,1);
        catch
            try
            SliceBrowser(handles.supsampledim3stack,handles.imst10_resized);
            catch
            SliceBrowser(handles.supsampledim3stack);
            end
        end
    else
        try
            SliceBrowser(handles.newim3stack,0.*handles.imst10_resized,svalue.*handles.newVZminmesh,svalue.*handles.newVZmaxmesh);
        catch
            try
            SliceBrowser(handles.newim3stack,0.*handles.imst10_resized);
            catch
            SliceBrowser(handles.newim3stack);
            end
        end
    end
end
end
end
guidata(hObject, handles);


% --- Executes on button press in flattench1.
function flattench1_Callback(hObject, eventdata, handles)
% hObject    handle to flattench1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global singlesurface
scale=get(handles.scalethickness,'Value');
xsize=size(handles.supsampledimstack,1);
ysize=size(handles.supsampledimstack,2);
zsize=size(handles.supsampledimstack,3);
xscale=xsize/(size(handles.VZmaxmesh,1)-1);
yscale=ysize/(size(handles.VZmaxmesh,2)-1);
if scale
    mthickness=abs(mean(mean(handles.VZmaxmesh-handles.VZminmesh)));
end
handles.newimstack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 1');
%handles.newimstack=circshift(handles.supsampledimstack,floor(zsize/2-(handles.VZmaxmesh'+handles.VZminmesh')/2),3);
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newimstack(i,j,1:zsize)=circshift(handles.supsampledimstack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newimstack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newimstack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Surfaces');
xsize=size(handles.VZmaxmesh,1);
ysize=size(handles.VZmaxmesh,2);
for i=1:ysize
waitbar(i/ysize,h);
for j=1:xsize
handles.newVZminmesh(i,j)=round(handles.VZminmesh(i,j))+round((round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
handles.newVZmaxmesh(i,j)=round(handles.VZmaxmesh(i,j))+round((round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(i,j)-handles.VZminmesh(i,j))/mthickness;
    A=interp1([-1,1],single([handles.newVZminmesh(i,j),handles.newVZmaxmesh(i,j)]),linspace(-1/scalevalue, 1/scalevalue, 2),'linear','extrap');
    handles.newVZminmesh(i,j)=A(1);
    handles.newVZmaxmesh(i,j)=A(2);
end
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);
set(handles.savefilech1,'Enable','on');
set(handles.done,'Enable','on');
h = waitbar(1,'Please Wait... Updating');
delete(h);
guidata(hObject, handles);


% --- Executes on button press in savefilech1.
function savefilech1_Callback(hObject, eventdata, handles)
% hObject    handle to savefilech1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.tif'});
for K=1:length(handles.newimstack(1, 1, :))
    imwrite(uint16(handles.newimstack(:, :, K)), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
h = waitbar(1,'Please Wait... Updating');
delete(h);



% --- Executes on selection change in imethod.
function imethod_Callback(hObject, eventdata, handles)
% hObject    handle to imethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imethod


% --- Executes during object creation, after setting all properties.
function imethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in twochannels.
function twochannels_Callback(hObject, eventdata, handles)
% hObject    handle to twochannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of twochannels


% --- Executes on selection change in volumetoview.
function volumetoview_Callback(hObject, eventdata, handles)
% hObject    handle to volumetoview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns volumetoview contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volumetoview


% --- Executes during object creation, after setting all properties.
function volumetoview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumetoview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewchannel1.
function viewchannel1_Callback(hObject, eventdata, handles)
% hObject    handle to viewchannel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of viewchannel1
global twostacks threestacks
if get(hObject,'Value')
    if twostacks
        set(handles.viewchannel2,'Value',0)
    end
    if threestacks
        set(handles.viewchannel3,'Value',0)
    end
else
    set(handles.viewchannel1,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in viewchannel2.
function viewchannel2_Callback(hObject, eventdata, handles)
% hObject    handle to viewchannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of viewchannel2
global twostacks threestacks
if get(hObject,'Value')
    if twostacks
        set(handles.viewchannel1,'Value',0)
    end
    if threestacks
        set(handles.viewchannel3,'Value',0)
    end
else
    set(handles.viewchannel2,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in flattench2.
function flattench2_Callback(hObject, eventdata, handles)
% hObject    handle to flattench2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global singlesurface
scale=get(handles.scalethickness,'Value');
xsize=size(handles.supsampledim2stack,1);
ysize=size(handles.supsampledim2stack,2);
zsize=size(handles.supsampledim2stack,3);
xscale=xsize/(size(handles.VZmaxmesh,1)-1);
yscale=ysize/(size(handles.VZmaxmesh,2)-1);
if scale
    mthickness=abs(mean(mean(handles.VZmaxmesh-handles.VZminmesh)));
end
handles.newim2stack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 2');
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newim2stack(i,j,1:zsize)=circshift(handles.supsampledim2stack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newim2stack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newim2stack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Surfaces');
xsize=size(handles.VZmaxmesh,1);
ysize=size(handles.VZmaxmesh,2);
for i=1:ysize
waitbar(i/ysize,h);
for j=1:xsize
handles.newVZminmesh(i,j)=round(handles.VZminmesh(i,j))+(round(round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
handles.newVZmaxmesh(i,j)=round(handles.VZmaxmesh(i,j))+(round(round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(i,j)-handles.VZminmesh(i,j))/mthickness;
    A=interp1([-1,1],single([handles.newVZminmesh(i,j),handles.newVZmaxmesh(i,j)]),linspace(-1/scalevalue, 1/scalevalue, 2),'linear','extrap');
    handles.newVZminmesh(i,j)=A(1);
    handles.newVZmaxmesh(i,j)=A(2);
end
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);
set(handles.savefilech2,'Enable','on');
set(handles.done,'Enable','on');
h = waitbar(1,'Please Wait... Updating');
delete(h);
guidata(hObject, handles);


% --- Executes on button press in savefilech2.
function savefilech2_Callback(hObject, eventdata, handles)
% hObject    handle to savefilech2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.tif'});
for K=1:length(handles.newim2stack(1, 1, :))
    imwrite(uint16(handles.newim2stack(:, :, K)), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
h = waitbar(1,'Please Wait... Updating');
delete(h);



function errorbox_Callback(hObject, eventdata, handles)
% hObject    handle to errorbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of errorbox as text
%        str2double(get(hObject,'String')) returns contents of errorbox as a double


% --- Executes during object creation, after setting all properties.
function errorbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function viewslices_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to viewslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in usepoints.
function usepoints_Callback(hObject, eventdata, handles)
% hObject    handle to usepoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of usepoints
global usepoints
if get(hObject,'Value')
    usepoints=1;
else
    usepoints=0;
end


% --- Executes on button press in scalethickness.
function scalethickness_Callback(hObject, eventdata, handles)
% hObject    handle to scalethickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of scalethickness


% --- Executes on button press in channelswitch.
function channelswitch_Callback(hObject, eventdata, handles)
% hObject    handle to channelswitch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of channelswitch


% --- Executes on button press in findcellbodies.
function findcellbodies_Callback(hObject, eventdata, handles)
% hObject    handle to findcellbodies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.processchat,'Enable','on');
set(handles.usepoints,'Enable','on');
set(handles.singlesurface,'Enable','on');
set(handles.ignorecolumns,'Enable','on');
clear imst2 handles.imst2 imst3 imst4 imst5 imst6 imst7 imst8 imst9 imst10 handles.imst11 handles.imst10_resized
handles.imst10_resized=uint8([]);
guidata(hObject, handles);
% imst2=uint8(smooth3(imstack,'gaussian',1));
h = waitbar(0,'Please Wait... Finding Cell Bodies');
for i=1:size(handles.supsampledimstack,3)
imst2(:,:,i)=imresize(uint8(handles.supsampledimstack(:,:,i)),0.5);
imst3(:,:,i)=bwareaopen(imst2(:,:,i)>str2double(get(handles.cellthresh,'String')),str2double(get(handles.mincellpixels,'String')));
imst4(:,:,i)=bwareaopen(imst3(:,:,i),str2double(get(handles.maxcellpixels,'String')));
imst5(:,:,i)=imst3(:,:,i).*imcomplement(imst4(:,:,i));
imst6(:,:,i)=bwdist(imcomplement(imst5(:,:,i)));
waitbar(i/size(handles.supsampledimstack,3),h);
end
imst7=(single(smooth3(imst6>str2double(get(handles.celltrim,'String')),'gaussian',str2double(get(handles.cellsmooth,'String')))>0).*imst6);
imst8=permute(imst7,[3 2 1]);
imst9=imst8;
delete(h);
h = waitbar(0,'Please Wait... Smoothing in Z');
for j=1:10
for i=1:size(imst8,1)
imst9(:,:,i)=imgaussfilt(imst9(:,:,i),1);
end
waitbar(j/10,h);
end
imst10=permute(uint8(imcomplement(smooth3(imst9>0.25,'gaussian',5)>0)),[3 2 1]);
handles.imst11=imst10.*imst2;
handles.imst2=imst2;
for i=1:size(imst10,3)
handles.imst10_resized(:,:,i)=imresize(imcomplement(255.*imst10(:,:,i)),2);
end
delete(h);
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);


% --- Executes on button press in viewchannel3.
function viewchannel3_Callback(hObject, eventdata, handles)
% hObject    handle to viewchannel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of viewchannel3
global twostacks threestacks
if get(hObject,'Value')
    if twostacks
        set(handles.viewchannel2,'Value',0)
    end
    if threestacks
        set(handles.viewchannel1,'Value',0)
    end
else
    set(handles.viewchannel3,'Value',1)
end
guidata(hObject, handles);



function cellthresh_Callback(hObject, eventdata, handles)
% hObject    handle to cellthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellthresh as text
%        str2double(get(hObject,'String')) returns contents of cellthresh as a double


% --- Executes during object creation, after setting all properties.
function cellthresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellthresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cellsmooth_Callback(hObject, eventdata, handles)
% hObject    handle to cellsmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cellsmooth as text
%        str2double(get(hObject,'String')) returns contents of cellsmooth as a double


% --- Executes during object creation, after setting all properties.
function cellsmooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cellsmooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxcellpixels_Callback(hObject, eventdata, handles)
% hObject    handle to maxcellpixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxcellpixels as text
%        str2double(get(hObject,'String')) returns contents of maxcellpixels as a double


% --- Executes during object creation, after setting all properties.
function maxcellpixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxcellpixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function celltrim_Callback(hObject, eventdata, handles)
% hObject    handle to celltrim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of celltrim as text
%        str2double(get(hObject,'String')) returns contents of celltrim as a double


% --- Executes during object creation, after setting all properties.
function celltrim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to celltrim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mincellpixels_Callback(hObject, eventdata, handles)
% hObject    handle to mincellpixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mincellpixels as text
%        str2double(get(hObject,'String')) returns contents of mincellpixels as a double


% --- Executes during object creation, after setting all properties.
function mincellpixels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mincellpixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in singlesurface.
function singlesurface_Callback(hObject, eventdata, handles)
% hObject    handle to singlesurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of singlesurface
global singlesurface
if get(hObject,'Value')
    singlesurface=1;
else
    singlesurface=0;
end



function maxthick_Callback(hObject, eventdata, handles)
% hObject    handle to maxthick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxthick as text
%        str2double(get(hObject,'String')) returns contents of maxthick as a double


% --- Executes during object creation, after setting all properties.
function maxthick_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxthick (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in flattench3.
function flattench3_Callback(hObject, eventdata, handles)
% hObject    handle to flattench3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global singlesurface
scale=get(handles.scalethickness,'Value');
xsize=size(handles.supsampledim2stack,1);
ysize=size(handles.supsampledim2stack,2);
zsize=size(handles.supsampledim2stack,3);
xscale=xsize/(size(handles.VZmaxmesh,1)-1);
yscale=ysize/(size(handles.VZmaxmesh,2)-1);
if scale
    mthickness=abs(mean(mean(handles.VZmaxmesh-handles.VZminmesh)));
end
handles.newim2stack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 3');
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newim3stack(i,j,1:zsize)=circshift(handles.supsampledim3stack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newim3stack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newim3stack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Surfaces');
xsize=size(handles.VZmaxmesh,1);
ysize=size(handles.VZmaxmesh,2);
for i=1:ysize
waitbar(i/ysize,h);
for j=1:xsize
handles.newVZminmesh(i,j)=round(handles.VZminmesh(i,j))+(round(round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
handles.newVZmaxmesh(i,j)=round(handles.VZmaxmesh(i,j))+(round(round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(i,j)-handles.VZminmesh(i,j))/mthickness;
    A=interp1([-1,1],single([handles.newVZminmesh(i,j),handles.newVZmaxmesh(i,j)]),linspace(-1/scalevalue, 1/scalevalue, 2),'linear','extrap');
    handles.newVZminmesh(i,j)=A(1);
    handles.newVZmaxmesh(i,j)=A(2);
end
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);
set(handles.savefilech3,'Enable','on');
set(handles.done,'Enable','on');
h = waitbar(1,'Please Wait... Updating');
delete(h);
guidata(hObject, handles);


% --- Executes on button press in savefilech3.
function savefilech3_Callback(hObject, eventdata, handles)
% hObject    handle to savefilech3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.tif'});
for K=1:length(handles.newim3stack(1, 1, :))
    imwrite(uint16(handles.newim3stack(:, :, K)), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
h = waitbar(1,'Please Wait... Updating');
delete(h);


% --- Executes on button press in saveflattenallch.
function saveflattenallch_Callback(hObject, eventdata, handles)
% hObject    handle to saveflattenallch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global singlesurface twostacks threestacks
[filename,pathname] = uiputfile({'*.tif'});
scale=get(handles.scalethickness,'Value');
xsize=size(handles.supsampledimstack,1);
ysize=size(handles.supsampledimstack,2);
zsize=size(handles.supsampledimstack,3);
xscale=xsize/(size(handles.VZmaxmesh,1)-1);
yscale=ysize/(size(handles.VZmaxmesh,2)-1);
if scale
    mthickness=abs(mean(mean(handles.VZmaxmesh-handles.VZminmesh)));
end
handles.newimstack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 1');
%handles.newimstack=circshift(handles.supsampledimstack,floor(zsize/2-(handles.VZmaxmesh'+handles.VZminmesh')/2),3);
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newimstack(i,j,1:zsize)=circshift(handles.supsampledimstack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newimstack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newimstack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
if twostacks
h = waitbar(0,'Please Wait... Flattening Channel 2');
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newim2stack(i,j,1:zsize)=circshift(handles.supsampledim2stack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newim2stack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newim2stack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
end
if threestacks
h = waitbar(0,'Please Wait... Flattening Channel 3');
for i=1:xsize
waitbar(i/xsize,h);
for j=1:ysize
handles.newim3stack(i,j,1:zsize)=circshift(handles.supsampledim3stack(i,j,1:zsize),round(round(zsize/2)-(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)+handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/2),3);
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(round(j/yscale)+1,round(i/xscale)+1)-handles.VZminmesh(round(j/yscale)+1,round(i/xscale)+1))/mthickness;
    handles.newim3stack(i,j,1:zsize)=int16(interp1(linspace(-zsize/2,zsize/2,zsize),single(squeeze(handles.newim3stack(i,j,1:zsize))),linspace(-zsize/2*scalevalue, zsize/2*scalevalue, zsize),'nearest','extrap'));
end
end
end
delete(h);
end
h = waitbar(0,'Please Wait... Flattening Surfaces');
xsize=size(handles.VZmaxmesh,1);
ysize=size(handles.VZmaxmesh,2);
for i=1:ysize
waitbar(i/ysize,h);
for j=1:xsize
handles.newVZminmesh(i,j)=round(handles.VZminmesh(i,j))+round((round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
handles.newVZmaxmesh(i,j)=round(handles.VZmaxmesh(i,j))+round((round(zsize/2)-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
if scale&~singlesurface
    scalevalue=(handles.VZmaxmesh(i,j)-handles.VZminmesh(i,j))/mthickness;
    A=interp1([-1,1],single([handles.newVZminmesh(i,j),handles.newVZmaxmesh(i,j)]),linspace(-1/scalevalue, 1/scalevalue, 2),'linear','extrap');
    handles.newVZminmesh(i,j)=A(1);
    handles.newVZmaxmesh(i,j)=A(2);
end
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);

if filename==0&pathname==0
else
if ~twostacks&~threestacks
for K=1:length(handles.newimstack(1, 1, :))
    imwrite(uint16(handles.newimstack(:, :, K)), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
end
if twostacks
for K=1:length(handles.newimstack(1, 1, :))
    imwrite(uint16(cat(3,squeeze(handles.newimstack(:, :, K)),squeeze(handles.newim2stack(:, :, K)),squeeze(0.*handles.newimstack(:, :, K)))), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
end
if threestacks
for K=1:length(handles.newimstack(1, 1, :))
    imwrite(uint16(cat(3,squeeze(handles.newimstack(:, :, K)),squeeze(handles.newim2stack(:, :, K)),squeeze(handles.newim3stack(:, :, K)))), fullfile(pathname, strcat(filename, '.tmp')),'tif', 'WriteMode', 'append', 'Compression','none');
end
movefile(fullfile(pathname, strcat(filename, '.tmp')),fullfile(pathname, filename),'f');
end
end
set(handles.done,'Enable','on');
h = waitbar(1,'Please Wait... Updating');
delete(h);
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);


% --- Executes on button press in ignorecolumns.
function ignorecolumns_Callback(hObject, eventdata, handles)
% hObject    handle to ignorecolumns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ignorecolumns


% --- Executes on selection change in movech1menu.
function movech1menu_Callback(hObject, eventdata, handles)
% hObject    handle to movech1menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns movech1menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from movech1menu


% --- Executes during object creation, after setting all properties.
function movech1menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to movech1menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in enableupsampling.
function enableupsampling_Callback(hObject, eventdata, handles)
% hObject    handle to enableupsampling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.xup,'Enable','on');
set(handles.yup,'Enable','on');
set(handles.zup,'Enable','on');
set(handles.imethod,'Enable','on');
h = waitbar(1,'Please Wait... Updating');
delete(h);


% --- Executes on button press in switch1and2.
function switch1and2_Callback(hObject, eventdata, handles)
% hObject    handle to switch1and2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imstack=handles.imstack;
im2stack=handles.im2stack;
im3stack=handles.im3stack;
global twostacks
chorder=str2num(get(handles.channelorder,'String'));
        if twostacks
            if length(chorder)==2
            chorder=[chorder(2) chorder(1)];
            else
                if length(chorder)==3
                chorder=[chorder(2) chorder(1) chorder(3)];
                end
            end
            handles.imstack=uint16(im2stack);
            handles.im2stack=uint16(imstack);
            handles.im3stack=uint16(im3stack);
        else
            handles.imstack=uint16(imstack);
            handles.im2stack=uint16(im2stack);
            handles.im3stack=uint16(im3stack);
        end
imstack=[];
im2stack=[];
im3stack=[];
set(handles.channelorder,'String',num2str(chorder));
h = waitbar(1,'Please Wait... Updating');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);


% --- Executes on button press in switch1and3.
function switch1and3_Callback(hObject, eventdata, handles)
% hObject    handle to switch1and3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imstack=handles.imstack;
im2stack=handles.im2stack;
im3stack=handles.im3stack;
global threestacks
chorder=str2num(get(handles.channelorder,'String'));
        if threestacks
            if length(chorder)==3
            chorder=[chorder(3) chorder(2) chorder(1)];
            end
            handles.imstack=uint16(im3stack);
            handles.im2stack=uint16(im2stack);
            handles.im3stack=uint16(imstack);
        else
            handles.imstack=uint16(imstack);
            handles.im2stack=uint16(im2stack);
            handles.im3stack=uint16(im3stack);
        end
imstack=[];
im2stack=[];
im3stack=[];
set(handles.channelorder,'String',num2str(chorder));
h = waitbar(1,'Please Wait... Updating');
delete(h)
guidata(hObject, handles);
figc=gcf;
feval('viewslices_Callback',gcf,[], guidata(handles.viewslices));
figure(figc);



function channelorder_Callback(hObject, eventdata, handles)
% hObject    handle to channelorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelorder as text
%        str2double(get(hObject,'String')) returns contents of channelorder as a double


% --- Executes during object creation, after setting all properties.
function channelorder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelorder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(gcf);
