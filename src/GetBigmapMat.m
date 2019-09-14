% GetBigmapMat.m: 
%   This file is to get the matrix representation of a undirected graph for
%   the 40-row * 50-column map, with its nodes' and edges' ID marked.
%   The map has 3950 points and 5860 edges.
% 
%   Copyright (c) 2019 CHEN Tianyang 
%   more info contact: tychen@whu.edu.cn

%% 
close; clear;

%% get list of the big map
% �� 40*50 �ĵ�ͼ�У�һ����3950���㣬5860����
points = 3950;
list = repmat(struct('number',[],'start_state',[],'final_state',[],'line',[],'length',[]),points,1);
for i=1:points
    list(i).number = i;
end
% ��Ҫ·�ߣ�40 �У�50��
for i=1:40
    if i==1                 % �ڵ�1��
        for j=1:50
            list(50*(i-1)+j).number = 50*(i-1)+j;
            list(50*(i-1)+j).start_state = 50*(i-1)+j;
            if j==1                                 % �ڵ�1��
                list(50*(i-1)+j).final_state = [j+1,j+2000];        % �ұߡ��±�
                list(50*(i-1)+j).line = [j,j+2000];
                list(50*(i-1)+j).length = [50,16.5];
            elseif j==50                            % �ڵ�50��
                list(50*(i-1)+j).final_state = [j-1,j+2000];        % ��ߡ��±�
                list(50*(i-1)+j).line = [j-1,(2*j-1)+2000];
                list(50*(i-1)+j).length = [50,16.5];
            else                                    % �ڵ�2-49��
                list(50*(i-1)+j).final_state = [j-1,j+1,j+2000];    % ��ߡ��ұߡ��±�
                list(50*(i-1)+j).line = [j-1,j,(2*j-1)+2000];
                list(50*(i-1)+j).length = [50,50,16.5];
            end
        end
    elseif i==40            % �ڵ�40��
        for j=1:50
            list(50*(i-1)+j).number = 50*(i-1)+j;
            list(50*(i-1)+j).start_state = 50*(i-1)+j;
            if j==1                                                 % �ڵ�1��
                list(50*(i-1)+j).final_state = [50*(i-1)+j+1,50*(i-1)+j-50+2000];   % �ұߡ��ϱ�
                list(50*(i-1)+j).line = [50*(i-1)+j,2000+(i-2)*100+2*j];            
                list(50*(i-1)+j).length = [50,16.5];
            elseif j==50                                            % �ڵ�50��
                list(50*(i-1)+j).final_state = [50*(i-1)+j-1,50*(i-1)+j-50+2000];   % ��ߡ��ϱ�
                list(50*(i-1)+j).line = [50*(i-1)+j-1,2000+(i-2)*100+2*j];
                list(50*(i-1)+j).length = [50,16.5];
            else                                                    % �ڵ�2-49��
                list(50*(i-1)+j).final_state = [50*(i-1)+j-1,50*(i-1)+j+1,50*(i-1)+j-50+2000];  % ��ߡ��ұߡ��ϱ�
                list(50*(i-1)+j).line = [50*(i-1)+j-1,50*(i-1)+j,2000+(i-2)*100+2*j];
                list(50*(i-1)+j).length = [50,50,16.5];
            end
        end
    else                    % �ڵ�2-39��
        for j=1:50
            list(50*(i-1)+j).number = 50*(i-1)+j;
            list(50*(i-1)+j).start_state = 50*(i-1)+j;
            if j==1                                                 % �ڵ�1��
                list(50*(i-1)+j).final_state = [50*(i-1)+j+1,50*(i-2)+j+2000,50*(i-1)+j+2000];   % �ұߡ��ϱߡ��±�
                list(50*(i-1)+j).line = [50*(i-1)+j,2000+100*(i-2)+2*j,2000+100*(i-1)+2*j-1];            
                list(50*(i-1)+j).length = [50,16.5,16.5];
            elseif j==50                                            % �ڵ�50��
                list(50*(i-1)+j).final_state = [50*(i-1)+j-1,50*(i-2)+j+2000,50*(i-1)+j+2000];   % ��ߡ��ϱߡ��±�
                list(50*(i-1)+j).line = [50*(i-1)+j-1,2000+100*(i-2)+2*j,2000+100*(i-1)+2*j-1];
                list(50*(i-1)+j).length = [50,16.5,16.5];
            else                                                    % �ڵ�2-49��
                list(50*(i-1)+j).final_state = [50*(i-1)+j-1,50*(i-1)+j+1,50*(i-2)+j+2000,50*(i-1)+j+2000];  % ��ߡ��ұߡ��ϱߡ��±�
                list(50*(i-1)+j).line = [50*(i-1)+j-1,50*(i-1)+j,2000+(i-2)*100+2*j,2000+(i-1)*100+2*j-1];
                list(50*(i-1)+j).length = [50,50,16.5,16.5];
            end
        end
    end
end

% block�ĳ���ڣ�39 �У�50��
for i=1:39
    for j=1:50
        number = 2000+50*(i-1)+j;
        list(number).number = number;
        list(number).start_state = number;
        list(number).final_state = [(i-1)*50+j,i*50+j];
        list(number).line = [2000+(i-1)*100+2*j-1,2000+(i-1)*100+2*j];
        list(number).length = [16.5,16.5];
    end
end

%% transfer list to Adjacent Matrix 
NodeSide = -1*ones(points);             % NodeSide
Distance = -1*ones(points);       % Distance
for i=1:points
    final_state_num = length(list(i).final_state);
    for j=1:final_state_num
        NodeSide(i,list(i).final_state(j)) = list(i).line(j);
        Distance(i,list(i).final_state(j)) = list(i).length(j);
    end
end

%% ��������
save('data\NodeSide_bigmap.mat','NodeSide');
save('data\Distance_bigmap.mat','Distance');

%% д��excel�ļ�(��ѡ��)
% xlswrite('DigitalMap_big.xlsx',NodeSide,'NodeSide')
% xlswrite('DigitalMap_big.xlsx',Distance,'Distance')

%% over