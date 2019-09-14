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

%% 用户选择参数
maptoread = 2;                      % 读入的地图 1: small 2-big
Experiments = 2;                    % 实验次数

%% 读取数字地图，并转换成初始的 RawRewardTable(地图还需要人工转换)
if maptoread == 1
    load('data\Distance.mat');
    load('data\NodeSide.mat');
elseif maptoread == 2
    load('data\Distance_bigmap.mat');
    load('data\NodeSide_bigmap.mat'); 
else
    error('parameter "maptoread" should be either 1 or 2.');
end

%% 设置超参数、规划起点、终点和障碍路段(用户可以修改，体现“动态”)
% 小地图: 4*5条路 12个街区 33个节点 44条边(单位路径)
% 大地图: 40*50条路 39*49个街区 3950个节点 5860条边(单位路径)
if maptoread == 1
    node_num = 33;                      % 节点数量
    side_num = 44;                      % 单位路径数量
    episode = 50;                         % 迭代次数(根据经验值: 小地图情况下 50 足以应付大多数情况)
elseif maptoread == 2
    node_num = 3950;                    % 节点数量
    side_num = 5860;                    % 单位路径数量
    episode = 200;                       % 迭代次数
end
% Q-Learning 算法超参数
alpha = 0.9;                            % 更新步长/学习效率
gamma=0.8;                              % 折扣因子
step_max = side_num;                  % 尝试的最大步骤数(根据经验值，取尝试的最大步骤数为边长数目的2倍)

data = repmat(struct('number',[],'start_state',[],'final_state',[],'obstacle',[],'route',[],'routelen',[],'time1',[],...
    'error_type',0,'obstacle_add',[],'obstacle_add_at_route',[],'new_route',[],'wait_thresh',[],'time2',[]),...
    Experiments,1);
for TIMES = 1:Experiments
    tic;
    all_routes = unique(NodeSide);
    all_routes(all_routes<0)=[];
    % ------------------------------- 正式代码 -----------------------------
    start_state = randperm(node_num,1);                     % 在所有状态中任选一个作为起点
    final_state = randperm(node_num,1);                     % 在所有状态中任选一个作为终点
    if maptoread == 1
        obstacle_num = randi([4,8],1,1);                    % 障碍的数量在 4-8 个之间
    elseif maptoread == 2
        obstacle_num = randi([40,80],1,1);                  % 障碍的数量在 40-80 个之间
    end
    obstacle = all_routes( randperm(length(all_routes),obstacle_num) ); % 在所有路径中任选 obstacle_num 个障碍路段
    % ------------------------------- 测试代码 -----------------------------
%     start_state = 16;               % 在所有状态中任选一个作为起点
%     final_state = 1;               % 在所有状态中任选一个作为终点
%     obstacle = [12, 40, 3, 35, 43, 29];       % 在所有路径中任选 obstacle_num 个障碍路段
    % --------------------------------- over -------------------------------


    % bug 1：存在孤岛，训练时随机初始的状态正好落在“孤岛内”，无法完成训练
    % 解决方案：训练时设定每个episode内机器人的step数上限为100，
    % 超过仍没有到达final_state则判定此次训练失败，转入下一个episode
%     start_state = 1;         
%     final_state = 10;               
%     obstacle = [30 8 26 33 39 27 28 34 43 24 11 40];        

    % bug 2: 起始点和终止点分别为“孤岛”，训练完毕后无法找到路径
    % 解决方案：寻找路径时设定机器人的step上限为100，超过100仍没到达final_state则判定此次任务失败
%     start_state = 16;               
%     final_state = 2;              
%     obstacle = [44 35 14 32 15 1 9 18 41 7 8 25];    

    % bug 3: 计算得到的 route 竟然是 [23 1 21 6 7 26 12 11 29],其中23->1这一步显然是不可能的
    % 解决方案：在函数 myQLearningRoute 中: 
    %       如果 Q_table(currentstate,:) 全部等于0，而且 currentstate 也不是 final_state
    %       （正常情况下是：Q_table(final_state,:)全部等于0）
    %       那么只能说明 currentstate 是死路，走不通，则判定此次任务失败
%     start_state = 23;               
%     final_state = 29;              
%     obstacle = [2 27 3 40 44 17 38 10 19 24 30];  

    %% 数据记录 1
    data(TIMES).number = TIMES;
    data(TIMES).start_state = start_state;
    data(TIMES).final_state = final_state;
    data(TIMES).obstacle = sort(obstacle);
    
    %% 首先判断，如果起讫点在封闭的单位路径内，则无法规划路径
    start_state_path = NodeSide(:,start_state);     % 与起始点直接连接的所有路段编号
    start_state_path(start_state_path==-1) = [];
    final_state_path = NodeSide(:,final_state);     % 与终止点直接连接的所有路段编号
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

    %% 开始QLearning
    % Step1: 在已知终点和障碍的情况下确定 RewardTable
    RTable = mygetRewardTable(NodeSide,final_state,obstacle);
    % Step2: 根据 RewardTable 训练 Q-Table
    [STEP, Q_table] = myQLearningTrain(RTable, episode, alpha, gamma, final_state, step_max);     % !!! QLearning算法的核心步骤 !!!
    % Step3: 根据 Q-Table 规划路径
    route = myQLearningRoute(Q_table, start_state, final_state, step_max);
    % Step4: 计算路径总长度
    routelen = mygetRoutelen(Distance,route);
    
    %% 数据记录 2
    data(TIMES).route = route;
    data(TIMES).routelen = routelen;
    if isempty(routelen)
        temp = toc;
        data(TIMES).time1 = [];
    else
        data(TIMES).time1 = toc;             % 记录本次实验(初次规划路线)的耗时
        toc
    end
    if isempty(data(TIMES).route)       % 起始点无法到达终止点，说明两者不连通
        data(TIMES).error_type = 4;
    end
    
    %% 出现意外的障碍，需要重新规划
    tic;
    % 如果 error_type = 4，无需执行下面的程序(error_type=1,2,3的情况在之前的代码中已有考虑)
    if data(TIMES).error_type == 4
        fprintf('Error_type = 4. No ROUTE: start_state and final_state are Disconnected Domains.\n');
        temp = toc;
        continue;
    end
    % 首先增加随机数量的障碍路段
    % ------------------------------- 正式代码 -----------------------------
    obstacle_add  = setxor(all_routes,obstacle);       % 在原来的畅通路段中抽取新的障碍路段
    obstacle_add_num = randi([3,5],1,1);       % 新增障碍的数量在3-6个之间
    filter = randperm(length(obstacle_add),obstacle_add_num);
    obstacle_add = obstacle_add(filter);
    % 找出在原路径上的新增障碍路段: 如果新增的障碍路段不在原路径上，则没必要重新规划
    obstacle_add_at_route = mygetRealObstacle(NodeSide,route,obstacle_add);
    % ------------------------------- 测试代码 -----------------------------
%     obstacle_add = [14;32;1;28;30;23;37;5;18];
%     obstacle_add_at_route = [32;5;18];
    % --------------------------------- over -------------------------------
    
    % 重新规划路径
    QLP.episode = episode;
    QLP.alpha = alpha;
    QLP.gamma = gamma;
    QLP.step_max = step_max;
    Results = myRouteChange(NodeSide,Distance,route,obstacle,obstacle_add,obstacle_add_at_route,QLP);
    
    %% 数据记录 3
    data(TIMES).obstacle_add = sort(obstacle_add);
    data(TIMES).obstacle_add_at_route = sort(obstacle_add_at_route);
    data(TIMES).new_route = Results.new_route;
    data(TIMES).wait_thresh = Results.wait_thresh;
    if isempty(Results.new_route)
        temp = toc;
        data(TIMES).time2 = [];
    else
        data(TIMES).time2 = toc;             % 记录本次实验(重新规划路线)的耗时
        toc
    end
    
    fprintf('Experiments = %d finished.\n',TIMES);
    
end

%% 结论存储
% 直接保存为mat
if maptoread == 1
    save('Planned\PlannedData2.mat','data');
elseif maptoread == 2
    save('Planned\PlannedData_bigmap2.mat','data');
end