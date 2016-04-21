% Example 2: Memory window starting from the beginning 
% of recording
% Please note that the wfdb library must be installed
% and in your Matlab path for the example to work
clc
close all
clear all
wfdb2mat('ctu-uhb-ctgdb/1170')
load 1170m
data=val(1,:)';
data=data/100;
data(data<30 | data>240)=[];
lambda=10;
fs=4;
T=600.0;      % sec time interval to display (10min)
Tshift=60.0; % sec time shift
DataChromatix(data, 'Time (s)', 'FHR (bpm)',T, Tshift, [], [], [], [], 10, fs, 0, 0)