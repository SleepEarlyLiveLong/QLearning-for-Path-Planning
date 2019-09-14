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

%% ȷ���¹滮·�������
% ���� obstacle_add_at_route ȷ���¹滮·�������. ע�⣺obstacle_add_at_route ���ܲ�ֹ1��,Ҳ������0��
% ��� obstacle_add_at_route Ϊ�գ�ֱ���˳�����
if isempty(obstacle_add_at_route)
    Results.new_route = [];
    Results.wait_thresh = [];
    return;
end

% �ϰ�·�������˵�ı��
len = length(obstacle_add_at_route);
node1 = zeros(len,1);
node2 = zeros(len,1);
for i = 1:len
    [a,b] = find(NodeSide==obstacle_add_at_route(i));
    node1(i) = a(1);
    node2(i) = b(1);
end
node_set = union(node1,node2);          % �����ϰ�·�εĶ˵㼯��(�ظ��Ľ�����1��)

% Ѱ�� node_set ���� old_route �еġ��������ǰ(start_serisl_new��С)�ĵ�
start_point_new = [];
start_serial_new = [];
for i = 1:length(node_set)
    if find(old_route==node_set(i))
        start_point_new(end+1) = node_set(i);                % �µ���ʼ��
        start_serial_new(end+1) = find(old_route==node_set(i));    % �µ���ʼ�����ڵ�λ��
    end
end
if isempty(start_point_new) || isempty(start_serial_new)
    error('Error.\n');
end
[start_serial_new,pos] = min(start_serial_new);
start_point_new = start_point_new(pos);

%% �õ��µ��ϰ�·��
% ���ϰ����е���ԭ���ϰ������������ϰ�(�����ϰ� obstacle_add,����ֻ�� obstacle_add_at_route)�Ĳ���
obstacle = union(obstacle,obstacle_add);

%% ���� QLearning �滮·��
episode = QLP.episode;                      % ��������(��������33����ѡ��ʼ״̬������100���㹻)
alpha = QLP.alpha;                          % ���²���/ѧϰЧ��
gamma = QLP.gamma;                          % �ۿ�����
step_max = QLP.step_max;
start_state = start_point_new;
final_state = old_route(end);

RTable = mygetRewardTable(NodeSide,final_state,obstacle);
[~, Q_table] = myQLearningTrain(RTable, episode, alpha, gamma, final_state, step_max);
new_route = myQLearningRoute(Q_table, start_state, final_state, step_max);
routelen_new = mygetRoutelen(Distance,new_route);
routelen_old = mygetRoutelen(Distance,old_route(start_serial_new:end));

%% �������
if isempty(routelen_new)
    Results.new_route = new_route;
    Results.wait_thresh = [];
else
    UV_speed = 1;
    wait_thresh = (routelen_new - routelen_old)/UV_speed;      % �ȴ�ʱ��С��wait_thresh�Ͳ���
    Results.new_route = new_route;
    Results.wait_thresh = wait_thresh;
end

end