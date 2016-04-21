function DataChromatix(varargin)
%
% DataChromatix(data, timeunit, yunit, displaywin, shift, memorywin, ...
% colorwin, nbins, ncolors, lambda, fs, videoname, minsec, cmap)
%
% Given any time series, creates a video of its chromatized version
% based on the probability distribution of the previous values
% on a certain window (memory). The memory can start from the beginning
% of the recording or be specified by the user.
%
% inputs:
% data --> 1-column matrix containing time series to colorize, in any units
% timeunit --> string containing the label for the time axis
%              if you choose 1 for minsec, it overrides this one
% yunit --> string containing the label for the y axis (physical units of
%           data)
% displaywin --> window to display, in same units as data
% shift --> shift from one window to the next, in same units as data
% memorywin --> memory used to colorize time series, in same units as data.
%               If left empty,infinite memory is employed
%               default=memory starting from beginning of recording
% colorwin --> length of window that is colorized at each iteration,
%              in same units as data. Must be >shift
%              if left empty, coincides with shift
% nbins --> number of bins of the histogram
%           if left empty, it is estimated via the Freedman-Diaconis rule
% ncolors --> number of colors used in the colorization (default=64)
% lambda --> smoothing parameter for histogram (default=10)
% fs --> sampling frequency of the data (default=1)
% videoname --> string containing name of the video to be saved
%               (default='Myvideo')
%               input 0 if you don't want the video, only the final figure
% minsec --> flag, if =1 shows time in mm:ss (default=0), assuming that
%            the original time series is in seconds
% cmap --> colormap you want to use (default='jet')
%
% Examples: please note that the wfdb library must be installed
% and in your Matlab path for the examples to work
%
% % Example 1: Fixed-length memory window
% wfdb2mat('ctu-uhb-ctgdb/1170')
% load 1170m
% data=val(1,:)';
% data=data/100;
% data(data<30 | data>240)=[];
% lambda=10;
% fs=4;
% T=600.0;      % sec time interval to display (10min)
% nbins=100;
% ncolors=64;
% colorwin=100;
% Tshift=60.0; % sec time shift
% DataChromatix(data, 'Time (mm:ss)', 'FHR (bpm)',T, Tshift, 1000, colorwin, nbins, ncolors, 10, fs, 'video1', 1)
%
% % Example 2: Memory window starting from the beginning of recording
% wfdb2mat('ctu-uhb-ctgdb/1170')
% load 1170m
% data=val(1,:)';
% data=data/100;
% data(data<30 | data>240)=[];
% lambda=10;
% fs=4;
% T=600.0;      % sec time interval to display (10min)
% Tshift=60.0; % sec time shift
% DataChromatix(data, 'Time (s)', 'FHR (bpm)',T, Tshift, [], [], [], [], 10, fs, 0, 0)
%
% Authors: Anton Burykin and Sara Mariani, 2015
% Last Modified: January 7th, 2015
%
% please report bugs/questions at sara.mariani7@gmail.com
%
% when using this script, please reference: 
% A. Burykin*, S. Mariani*, T. Henriques, T. Silva, 
% W. Schnettler, M. D. Costa** and A. L. Goldberger**, 
% "Remembrance of time series past: simple chromatic 
% method for visualizing trends in biomedical signals,"  
% Physiol.  Meas., vol. 36, pp. N95, 2015.

inputs={'data','timeunit','yunit','displaywin','shift','memorywin', ...
    'colorwin','nbins','ncolors','lambda', 'fs', 'videoname','minsec','cmap'};

if nargin>14
    error('Too many input arguments')
end

if nargin<5
    error('Not enough input arguments')
end

for n=1:nargin
    eval([inputs{n} '=varargin{n};'])
end
for n=nargin+1:14
    eval([inputs{n} '=[];'])
end

if isempty(lambda), lambda=10; end
if isempty(videoname), videoname='MyVideo'; end
if isempty(minsec), minsec=0; end
if isempty(cmap), cmap='jet'; end
if isempty(fs), fs=1; end
if isempty(ncolors), ncolors=64; end
if isempty(colorwin), colorwin=shift; end
if colorwin<shift
    error('The colorization window must be longer than the shift')
end

scrsz = get(0,'ScreenSize');

if videoname~=0
    vidObj = VideoWriter(videoname,'MPEG-4');
    vidObj.FrameRate = 1;
    open(vidObj);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
window=displaywin*fs;     % time interval in data points
shift=shift*fs;
memorywin=memorywin*fs;
colorwin=colorwin*fs;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t=(1:length(data))'/fs;
% set max and min range for screen based on data range
lowl=min(data)-std(data)/2;
hil=max(data)+std(data)/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lhr=length(data);
Jmax=fix((Lhr-window)/shift);

hr_disp=[]';
t_disp=[]';
c_disp=[]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:Jmax
    ind1=fix(1+shift*(j-1));
    ind2=fix(shift*(j-1)+window);
    if isempty(memorywin) % infinite memory
        hr_mem=data(1:ind2); % this is my memory window
    else
        % if the memory is finite
        if (ind2<=memorywin)
            ind_s=1; % like infinite memory
        else
            ind_s=ind2-memorywin;
        end
        hr_mem=data(ind_s:ind2);   % window you use for histogram
    end
    % histogram bin number estimation via Freedman-Diaconis rule
    if isempty(nbins)
        binw=2*iqr(hr_mem)/length(hr_mem)^(1/3);
        nbins=(max(hr_mem)-min(hr_mem))/binw;
    end
    H1=hist(hr_mem,nbins);
    H1=smooth1D(H1',lambda);
    H1=H1/max(H1);
    
    Nmax=length(H1);
    z=zeros(size(H1));
    Zmin=min(hr_mem);
    Zmax=max(hr_mem);
    
    for n=1:Nmax
        z(n)=((n-1)/(Nmax-1))*(Zmax-Zmin)+Zmin;
    end
    
    color1=zeros(size(hr_mem));
    Kmax=length(hr_mem);
    
    for k=1:Kmax
        for n=1:Nmax-1
            if (hr_mem(k)>=z(n)) && (hr_mem(k)<z(n+1))
                color1(k)=H1(n);
            end
        end
    end
    
    if j==1
        hr_disp=[hr_disp' data(ind1:ind2)']';
        t_disp=[t_disp' t(ind1:ind2)']';
        c_disp=[c_disp' color1(ind1:ind2)']';
    else
        hr_disp=[hr_disp(1:end-(colorwin-shift+1))' data(ind2-colorwin:ind2)']';
        t_disp=[t_disp(1:end-(colorwin-shift+1))' t(ind2-colorwin:ind2)']';
        if isempty(memorywin)
            c_disp=[c_disp(1:end-(colorwin-shift+1))' color1(ind2-colorwin:ind2)']';
        else
            c_disp=[c_disp(1:end-(colorwin-shift+1))' color1(end-colorwin:end)']';
        end
    end
    
    if videoname~=0
        fig1=figure('Position',...
            [0.05*scrsz(3) 0.2*scrsz(4) 0.89*scrsz(3) 0.60*scrsz(4)],...
            'Color',[0.7 0.7 0.7]);
        scatter(t_disp(ind1:ind2),hr_disp(ind1:ind2),20,...
            c_disp(ind1:ind2),'filled')
        eval(['colormap(flipud(' cmap '(ncolors)));']);
        colorbar('location','EastOutside');
        caxis([0 1])
        xlim([t_disp(ind1) t_disp(ind2)]);
        ylim([lowl hil]);
        ylabel(yunit,'fontsize',24)
        if minsec
            tstart=ceil(t_disp(ind1)/60)*60;
            tend=floor(t_disp(ind2)/60)*60;
            set(gca,'Color',[0.7 0.7 0.7],'FontSize',24,'XTick', [tstart:60:tend],'xticklabel',seconds2time([tstart:60:tend]))
            xlabel('Time (mm:ss)','fontsize',24)
        else
            set(gca,'Color',[0.7 0.7 0.7],'FontSize',24);
            xlabel(timeunit,'fontsize',24)
        end
        grid on
        box on
        
        Fr1=getframe(fig1);
        writeVideo(vidObj,Fr1);
        
        clear Fr1 Im1 Im1_map im_file fr_file;
        close(fig1);
    end
end
if videoname~=0
    close(vidObj);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display whole signal
fig1=figure('Position',...
    [0.05*scrsz(3) 0.05*scrsz(4) 0.89*scrsz(3) 0.89*scrsz(4)],...
    'Color',[1 1 1]);
ah1=subplot(211);
plot(t_disp,hr_disp,'.k','linewidth',4)
ylabel(yunit,'fontsize',24)
xlim([t_disp(1) t_disp(end)])
ylim([lowl hil]);
set(gca,'fontsize',24)
grid on
box on

ah2=subplot(212);
scatter(t_disp,hr_disp,20,c_disp,'filled')
eval(['colormap(flipud(' cmap '(ncolors)));']);
xlim([t_disp(1) t_disp(end)])
ylim([lowl hil]);
set(gca,'fontsize',24)
grid on
box on
ylabel(yunit,'fontsize',24)

xlabel(timeunit);

h=colorbar('location','EastOutside','ytick',[0:0.25:1],'fontsize',24);

%# find current position [x,y,width,height]
pos2 = get(ah2,'Position');
pos1 = get(ah1,'Position');
%# set width of second axes equal to first
pos2(3) = pos1(3);
set(ah2,'Position',pos2)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [array]=seconds2time(seconds)
for i=1:length(seconds)
    mm=floor(seconds(i)/60);
    ss=seconds(i)-mm*60;
    string=[num2str(mm) ':' num2str(ss)];
    if numel(num2str(mm))==1
        string=['0' string];
    end
    if numel(num2str(ss))==1
        string=[string(1:3) '0' string(4)];
    end
    array{i}=string;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = smooth1D(Y,lambda)
[m,n] = size(Y);
E = eye(m);
D1 = diff(E,1);
D2 = diff(D1,1);
P = lambda.^2 .* D2'*D2 + 2.*lambda .* D1'*D1;
Z = (E + P) \ Y;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%