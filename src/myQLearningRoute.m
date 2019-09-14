function route = myQLearningRoute(Q_table, start_state, final_state, step_max)
%MYQLEARNINGROUTE - get route calculated from the trainned Q_table through Q-learning algorithm.
%   
%   route = myQLearningRoute(Q_table, start_state, final_state)
% 
%   Input - 
%   Q_table:        the trainned Q_table through Q-learning algorithm;
%   start_state:    ID of the start point of the route in the map;
%   final_state:    ID of the final point of the route in the map;
%   step_max:   the maximum number of steps allowed for an agent in ONE exploration.
%   Output - 
%   route:  route calculated from the trainned Q_table.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
% start_state == final_state 的情况应该在进入本函数前就已经被否定掉
route = [];
currentstate = start_state;
route(end+1) = currentstate;
step = 0;
% fprintf('Initialized state %d\n',currentstate);

% 根据 Q(s,a)=max{Q(s,a')} 选择 action
while currentstate~=final_state
    % 如果 Q_table(currentstate,:) 全部等于0，而且 currentstate 也不是 final_state
    % （正常情况下是：Q_table(final_state,:)全部等于0）
    % 那么只能说明 currentstate 是死路，走不通，则判定此次任务失败
    if all(Q_table(currentstate,:)==0)
        route = [];
        break;
    else
        [~,index]=max(Q_table(currentstate,:));
         nextstate=index;
%          fprintf('the robot goes to %d\n',nextstate);
         currentstate = nextstate;
         route(end+1) = currentstate;
         step = step+1;
         if step >= step_max
             route = [];        % step超过 step_max 仍没到达final_state则判定此次任务失败,返回空route
             break;
         end
    end
end
end