% main.m: 
%   This is the main function of this project. Click the 'run' button, it will work.
% 
%   Users can set the value of two parameters to choose which map (the smaller 
%   4*5 map or the larger 40*50 one) to use and how many times the route
%   planning program goes.
%   Attention: it may take hundreds of seconds to run the larger map.
% 
%   Copyright (c) 2019 CHEN Tianyang 
%   more info contact: tychen@whu.edu.cn

%%
close all;clear;

%% �û�ѡ�����
maptoread = 2;                      % ����ĵ�ͼ 1: small 2-big
Experiments = 2;                    % ʵ�����

%% ��ȡ���ֵ�ͼ����ת���ɳ�ʼ�� RawRewardTable(��ͼ����Ҫ�˹�ת��)
if maptoread == 1
    load('data\Distance.mat');
    load('data\NodeSide.mat');
elseif maptoread == 2
    load('data\Distance_bigmap.mat');
    load('data\NodeSide_bigmap.mat'); 
else
    error('parameter "maptoread" should be either 1 or 2.');
end

%% ���ó��������滮��㡢�յ���ϰ�·��(�û������޸ģ����֡���̬��)
% С��ͼ: 4*5��· 12������ 33���ڵ� 44����(��λ·��)
% ���ͼ: 40*50��· 39*49������ 3950���ڵ� 5860����(��λ·��)
if maptoread == 1
    node_num = 33;                      % �ڵ�����
    side_num = 44;                      % ��λ·������
    episode = 50;                         % ��������(���ݾ���ֵ: С��ͼ����� 50 ����Ӧ����������)
elseif maptoread == 2
    node_num = 3950;                    % �ڵ�����
    side_num = 5860;                    % ��λ·������
    episode = 200;                       % ��������
end
% Q-Learning �㷨������
alpha = 0.9;                            % ���²���/ѧϰЧ��
gamma=0.8;                              % �ۿ�����
step_max = side_num;                  % ���Ե��������(���ݾ���ֵ��ȡ���Ե��������Ϊ�߳���Ŀ��2��)

data = repmat(struct('number',[],'start_state',[],'final_state',[],'obstacle',[],'route',[],'routelen',[],'time1',[],...
    'error_type',0,'obstacle_add',[],'obstacle_add_at_route',[],'new_route',[],'wait_thresh',[],'time2',[]),...
    Experiments,1);
for TIMES = 1:Experiments
    tic;
    all_routes = unique(NodeSide);
    all_routes(all_routes<0)=[];
    % ------------------------------- ��ʽ���� -----------------------------
    start_state = randperm(node_num,1);                     % ������״̬����ѡһ����Ϊ���
    final_state = randperm(node_num,1);                     % ������״̬����ѡһ����Ϊ�յ�
    if maptoread == 1
        obstacle_num = randi([4,8],1,1);                    % �ϰ��������� 4-8 ��֮��
    elseif maptoread == 2
        obstacle_num = randi([40,80],1,1);                  % �ϰ��������� 40-80 ��֮��
    end
    obstacle = all_routes( randperm(length(all_routes),obstacle_num) ); % ������·������ѡ obstacle_num ���ϰ�·��
    % ------------------------------- ���Դ��� -----------------------------
%     start_state = 16;               % ������״̬����ѡһ����Ϊ���
%     final_state = 1;               % ������״̬����ѡһ����Ϊ�յ�
%     obstacle = [12, 40, 3, 35, 43, 29];       % ������·������ѡ obstacle_num ���ϰ�·��
    % --------------------------------- over -------------------------------


    % bug 1�����ڹµ���ѵ��ʱ�����ʼ��״̬�������ڡ��µ��ڡ����޷����ѵ��
    % ���������ѵ��ʱ�趨ÿ��episode�ڻ����˵�step������Ϊ100��
    % ������û�е���final_state���ж��˴�ѵ��ʧ�ܣ�ת����һ��episode
%     start_state = 1;         
%     final_state = 10;               
%     obstacle = [30 8 26 33 39 27 28 34 43 24 11 40];        

    % bug 2: ��ʼ�����ֹ��ֱ�Ϊ���µ�����ѵ����Ϻ��޷��ҵ�·��
    % ���������Ѱ��·��ʱ�趨�����˵�step����Ϊ100������100��û����final_state���ж��˴�����ʧ��
%     start_state = 16;               
%     final_state = 2;              
%     obstacle = [44 35 14 32 15 1 9 18 41 7 8 25];    

    % bug 3: ����õ��� route ��Ȼ�� [23 1 21 6 7 26 12 11 29],����23->1��һ����Ȼ�ǲ����ܵ�
    % ����������ں��� myQLearningRoute ��: 
    %       ��� Q_table(currentstate,:) ȫ������0������ currentstate Ҳ���� final_state
    %       ������������ǣ�Q_table(final_state,:)ȫ������0��
    %       ��ôֻ��˵�� currentstate ����·���߲�ͨ�����ж��˴�����ʧ��
%     start_state = 23;               
%     final_state = 29;              
%     obstacle = [2 27 3 40 44 17 38 10 19 24 30];  

    %% ���ݼ�¼ 1
    data(TIMES).number = TIMES;
    data(TIMES).start_state = start_state;
    data(TIMES).final_state = final_state;
    data(TIMES).obstacle = sort(obstacle);
    
    %% �����жϣ�����������ڷ�յĵ�λ·���ڣ����޷��滮·��
    start_state_path = NodeSide(:,start_state);     % ����ʼ��ֱ�����ӵ�����·�α��
    start_state_path(start_state_path==-1) = [];
    final_state_path = NodeSide(:,final_state);     % ����ֹ��ֱ�����ӵ�����·�α��
    final_state_path(final_state_path==-1) = [];
    if sum(ismember(start_state_path,obstacle)) == length(start_state_path)
        fprintf('Error_type = 1. Point %d cannot be the start point.\n',start_state);
        data(TIMES).error_type = 1;
        temp = toc;
        continue;
    elseif sum(ismember(final_state_path,obstacle)) == length(final_state_path)
        fprintf('Error_type = 2. Point %d cannot be the finnal point.\n',final_state);
        data(TIMES).error_type = 2;
        temp = toc;
        continue;
    elseif start_state == final_state
        fprintf('Error_type = 3. NO NEED TO DO: start_state is the same point as final_state.\n');
        data(TIMES).error_type = 3;
        temp = toc;
        continue;
    end

    %% ��ʼQLearning
    % Step1: ����֪�յ���ϰ��������ȷ�� RewardTable
    RTable = mygetRewardTable(NodeSide,final_state,obstacle);
    % Step2: ���� RewardTable ѵ�� Q-Table
    [STEP, Q_table] = myQLearningTrain(RTable, episode, alpha, gamma, final_state, step_max);     % !!! QLearning�㷨�ĺ��Ĳ��� !!!
    % Step3: ���� Q-Table �滮·��
    route = myQLearningRoute(Q_table, start_state, final_state, step_max);
    % Step4: ����·���ܳ���
    routelen = mygetRoutelen(Distance,route);
    
    %% ���ݼ�¼ 2
    data(TIMES).route = route;
    data(TIMES).routelen = routelen;
    if isempty(routelen)
        temp = toc;
        data(TIMES).time1 = [];
    else
        data(TIMES).time1 = toc;             % ��¼����ʵ��(���ι滮·��)�ĺ�ʱ
        toc
    end
    if isempty(data(TIMES).route)       % ��ʼ���޷�������ֹ�㣬˵�����߲���ͨ
        data(TIMES).error_type = 4;
    end
    
    %% ����������ϰ�����Ҫ���¹滮
    tic;
    % ��� error_type = 4������ִ������ĳ���(error_type=1,2,3�������֮ǰ�Ĵ��������п���)
    if data(TIMES).error_type == 4
        fprintf('Error_type = 4. No ROUTE: start_state and final_state are Disconnected Domains.\n');
        temp = toc;
        continue;
    end
    % ������������������ϰ�·��
    % ------------------------------- ��ʽ���� -----------------------------
    obstacle_add  = setxor(all_routes,obstacle);       % ��ԭ���ĳ�ͨ·���г�ȡ�µ��ϰ�·��
    obstacle_add_num = randi([3,5],1,1);       % �����ϰ���������3-6��֮��
    filter = randperm(length(obstacle_add),obstacle_add_num);
    obstacle_add = obstacle_add(filter);
    % �ҳ���ԭ·���ϵ������ϰ�·��: ����������ϰ�·�β���ԭ·���ϣ���û��Ҫ���¹滮
    obstacle_add_at_route = mygetRealObstacle(NodeSide,route,obstacle_add);
    % ------------------------------- ���Դ��� -----------------------------
%     obstacle_add = [14;32;1;28;30;23;37;5;18];
%     obstacle_add_at_route = [32;5;18];
    % --------------------------------- over -------------------------------
    
    % ���¹滮·��
    QLP.episode = episode;
    QLP.alpha = alpha;
    QLP.gamma = gamma;
    QLP.step_max = step_max;
    Results = myRouteChange(NodeSide,Distance,route,obstacle,obstacle_add,obstacle_add_at_route,QLP);
    
    %% ���ݼ�¼ 3
    data(TIMES).obstacle_add = sort(obstacle_add);
    data(TIMES).obstacle_add_at_route = sort(obstacle_add_at_route);
    data(TIMES).new_route = Results.new_route;
    data(TIMES).wait_thresh = Results.wait_thresh;
    if isempty(Results.new_route)
        temp = toc;
        data(TIMES).time2 = [];
    else
        data(TIMES).time2 = toc;             % ��¼����ʵ��(���¹滮·��)�ĺ�ʱ
        toc
    end
    
    fprintf('Experiments = %d finished.\n',TIMES);
    
end

%% ���۴洢
% ֱ�ӱ���Ϊmat
if maptoread == 1
    save('Planned\PlannedData2.mat','data');
elseif maptoread == 2
    save('Planned\PlannedData_bigmap2.mat','data');
end