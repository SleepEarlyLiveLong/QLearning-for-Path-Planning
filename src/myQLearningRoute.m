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
% start_state == final_state �����Ӧ���ڽ��뱾����ǰ���Ѿ����񶨵�
route = [];
currentstate = start_state;
route(end+1) = currentstate;
step = 0;
% fprintf('Initialized state %d\n',currentstate);

% ���� Q(s,a)=max{Q(s,a')} ѡ�� action
while currentstate~=final_state
    % ��� Q_table(currentstate,:) ȫ������0������ currentstate Ҳ���� final_state
    % ������������ǣ�Q_table(final_state,:)ȫ������0��
    % ��ôֻ��˵�� currentstate ����·���߲�ͨ�����ж��˴�����ʧ��
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
             route = [];        % step���� step_max ��û����final_state���ж��˴�����ʧ��,���ؿ�route
             break;
         end
    end
end
end