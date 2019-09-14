function obstacle_out = mygetRealObstacle(NodeSide,route,obstacle_in)
%OBSTACLE_OUT - pick out newly added obstacled sections on the previously planned
%   route which means two endpoints of the newly added obstacled sections should
%   be elements of the array representing the previously planned route.
%   
%   obstacle_out = mygetRealObstacle(NodeSide,route,obstacle_in)
% 
%   Input - 
%   NodeSide:       a matrix representing the undirected graph abstracted from the map;
%   route:          an array representing the previously planned route;
%   obstacle_in:    an array representing the newly added obstacled sections.
%   Output - 
%   obstacle_out:   an array representing part of the newly added obstacled sections who 
%                   are on the previously planned route.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%%
len = length(obstacle_in);
obstacle_out = obstacle_in;

for i=1:len
    [a,b] = find(NodeSide==obstacle_in(i));     % ĳһ���ϰ�·��
    node1 = a(1);       % �ϰ�·�ε�1���˵���
    node2 = b(1);       % �ϰ�·�ε���1���˵���
    % ֻҪ���ϰ�·�ε�2���˵�����1������ԭ·�����ö˵��ʾ���ϣ��Ϳ����ж��������ϰ�·�β���ԭ·����
    if isempty(find(route==node1, 1)) || isempty(find(route==node2, 1))   
        obstacle_out(i) = 0;
    end
end
obstacle_out = obstacle_out(obstacle_out~=0);
end