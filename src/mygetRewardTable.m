function RTable = mygetRewardTable(NodeSide,final_state,obstacle)
%MYGETREWARDYABLE - get the REWARD TABLR according to user's settings.
%   To get the reward table of one SPECIFIED situation.
%   
%   RTable = mygetRewardTable(NodeSide,final_state,obstacle)
% 
%   Input - 
%   NodeSide:       a matrix representing the undirected graph abstracted from the map;
%   final_state:    an integer, the ID of the final point;
%   obstacle:       a vector whose elements are ID of obstacles.
%   Output - 
%   RTable:         the specified reward table.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
RawRTable = NodeSide;
RawRTable(RawRTable(:,:)~=-1) = 0;

%% data assignment
% high reward for final_state
RawRTable(final_state,final_state) = 10000;
RawRTable(RawRTable(:,final_state) > -1,final_state) = 10000;

%% update reward_table according to obstacles
obsts = length(obstacle);
% obstacle ���ǿ�����
if obsts~=0
    for i = 1:obsts
        [row,col] = find(NodeSide==obstacle(i));    % Ѱ���ϰ�·�ε�λ�ã�Ҳ�����������ӵĵ��
        if length(row)~=2 || length(col)~=2         % ���ڶԳ��ԣ�����Ӧ����2
            error('Error!\n');
        else
            RawRTable(row(1),col(1)) = -1;          % �ϰ�·�Σ���ֹͨ��
            RawRTable(row(2),col(2)) = -1;          % �ϰ�·�Σ���ֹͨ��
        end
    end
end

%% data output
RTable = RawRTable;
end
