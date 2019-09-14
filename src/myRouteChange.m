function Results = myRouteChange(NodeSide,Distance,old_route,obstacle,obstacle_add,obstacle_add_at_route,QLP)
%MYROUTECHANGE - to re-plan the route when the previosuly planned route does not work.
%   
%   Results = myRouteChange(NodeSide,Distance,old_route,obstacle,obstacle_add,obstacle_add_at_route,QLP)
% 
%   Input - 
%   NodeSide:   a matrix representing the undirected graph abstracted from the map;
%   Distance:   a matrix representing the distance between the Direct Connectable Points 
%               in an undirected graph abstracted from the map;
%   old_route:  a vector representing the previously planned route;
%   obstacle:   a vector whose elements are ID of obstacles;
%   obstacle_add:           a vector whose elements are ID of newly added obstacles;
%   obstacle_add_at_route:  a vector whose elements are ID of part of newly added 
%                           obstacles who are on the previously planned route;
%   QLP:        hyperparameter parameters of the Q-Learning algorithm.
%       QLP.episode:    iteration times, number of times the agent is allowed to explore;
%   	QLP.alpha:      renewal step/learning efficiency, a scalar between 0 and 1;
%       QLP.gamma:      discount factor;
%       QLP.step_max:   the maximum number of steps allowed for an agent in ONE exploration.
%   Output - 
%   Results:    result of the replanned route.
%       Results.new_route: the newly planned route;
%       Results.wait_thresh: a threshold to decide whether or not to use 'new_route'.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 确定新规划路径的起点
% 根据 obstacle_add_at_route 确定新规划路径的起点. 注意：obstacle_add_at_route 可能不止1个,也可能是0个
% 如果 obstacle_add_at_route 为空，直接退出程序
if isempty(obstacle_add_at_route)
    Results.new_route = [];
    Results.wait_thresh = [];
    return;
end

% 障碍路段两个端点的编号
len = length(obstacle_add_at_route);
node1 = zeros(len,1);
node2 = zeros(len,1);
for i = 1:len
    [a,b] = find(NodeSide==obstacle_add_at_route(i));
    node1(i) = a(1);
    node2(i) = b(1);
end
node_set = union(node1,node2);          % 所有障碍路段的端点集合(重复的仅保留1个)

% 寻找 node_set 中在 old_route 中的、且排列最靠前(start_serisl_new最小)的点
start_point_new = [];
start_serial_new = [];
for i = 1:length(node_set)
    if find(old_route==node_set(i))
        start_point_new(end+1) = node_set(i);                % 新的起始点
        start_serial_new(end+1) = find(old_route==node_set(i));    % 新的起始点所在的位置
    end
end
if isempty(start_point_new) || isempty(start_serial_new)
    error('Error.\n');
end
[start_serial_new,pos] = min(start_serial_new);
start_point_new = start_point_new(pos);

%% 得到新的障碍路段
% 新障碍序列等于原有障碍序列与新增障碍(所有障碍 obstacle_add,而不只是 obstacle_add_at_route)的并集
obstacle = union(obstacle,obstacle_add);

%% 重新 QLearning 规划路径
episode = QLP.episode;                      % 迭代次数(本例中有33个可选初始状态，迭代100次足够)
alpha = QLP.alpha;                          % 更新步长/学习效率
gamma = QLP.gamma;                          % 折扣因子
step_max = QLP.step_max;
start_state = start_point_new;
final_state = old_route(end);

RTable = mygetRewardTable(NodeSide,final_state,obstacle);
[~, Q_table] = myQLearningTrain(RTable, episode, alpha, gamma, final_state, step_max);
new_route = myQLearningRoute(Q_table, start_state, final_state, step_max);
routelen_new = mygetRoutelen(Distance,new_route);
routelen_old = mygetRoutelen(Distance,old_route(start_serial_new:end));

%% 输出参数
if isempty(routelen_new)
    Results.new_route = new_route;
    Results.wait_thresh = [];
else
    UV_speed = 1;
    wait_thresh = (routelen_new - routelen_old)/UV_speed;      % 等待时间小于wait_thresh就不换
    Results.new_route = new_route;
    Results.wait_thresh = wait_thresh;
end

end