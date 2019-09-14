% time_test.m: 
%   A file to analyse the time consumed by path planning with the Q-Learning algorithm.
% 
%   Copyright (c) 2019 CHEN Tianyang 
%   more info contact: tychen@whu.edu.cn

%% 
close all;clear;
load('Planned\PlannedData.mat');            % smaller map
% load('Planned\PlannedData_bigmap.mat');     % larger map
len = size(data,1);
time = zeros(len,1);
for i=1:len
    if ~isempty(data(i).time1)
        time(i) = data(i).time1;
    end
end
time(time==0) = [];
figure;plot(time);xlabel('Number of experiments');ylabel('Time consuming(unit: second)');
title('Planning path time-consuming');
avg_time = mean(time);