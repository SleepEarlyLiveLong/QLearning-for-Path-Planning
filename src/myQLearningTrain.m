function [STEP, Q_table] = myQLearningTrain(RewardTable, episode, alpha, gamma, final_state, step_max)
%MYQLEARNINGTRAIN - train Q_table through Q-learning algorithm.
%   
%   [STEP, Q_table] = myQLearningTrain(RewardTable, episode, alpha, gamma, final_state, step_max)
% 
%   Input - 
%   RewardTable: the specified reward table calculated from function 'mygetRewardTable';
%   episode:     hyperparameter, iteration times, number of times the agent is allowed to explore;
%   alpha:       hyperparameter, renewal step/learning efficiency, a scalar between 0 and 1;
%   gamma:       hyperparameter, discount factor;
%   final_state: ID of the final point of the route in the map;
%   step_max:    the maximum number of steps allowed for an agent in ONE exploration.
%   Output - 
%   STEP:       number of steps the agent takes in each episode;
%   Q_table:    Q_table trained through Q-learning algorithm.
% 
%   Copyright (c) 2019 CHEN Tianyang
%   more info contact: tychen@whu.edu.cn

%% 
state_num=size(RewardTable,1);  % ����״̬��Ŀ
Q_table=zeros(state_num);       % �����ʼ�� Q table

% -------- ����ʱʹ��: �����ж� Q table �����̶ȣ�����3�У� --------
% Q_table_past = Q_table;
% deltaQ = zeros(episode,1);     
% nonzeroQ = zeros(episode,1);   
% sumQ = zeros(episode,1); 
% --------------------����ʱʹ�� over ------------------------

STEP = zeros(episode,1);
for i=1:episode
    % ���ѡ���ʼ״̬
    current_state=randperm(state_num,1);
    % ʹ�� step ��Ϊ�˷�ֹ current_state �����������ԶҲ�ﲻ�� final_state����������ͻ������ѭ����
    step = 0;
    while current_state~=final_state
        % ���п��ܵĶ�����ȥ����һ��״̬��
        optional_action=find(RewardTable(current_state,:)>-1);
        % ��current_state״̬���п�ѡ����
        if ~isempty(optional_action)
            % ���ѡ����һ��״̬
            chosen_action=optional_action(randperm(length(optional_action),1));
            % ִ�иö������õ�reward����һ״̬
            r=RewardTable(current_state,chosen_action);
            next_state=chosen_action;
            % ����Q-Table
            next_possible_action= RewardTable(next_state,:)>-1;
            maxQ=max(Q_table(next_state,next_possible_action));
            % ���ĵ�����ʽ
            Q_table(current_state,chosen_action)=Q_table(current_state,chosen_action)+alpha*(r+gamma*maxQ-Q_table(current_state,chosen_action));
            % ����״̬
            current_state=next_state;
            % ���ԵĲ���step��1,���step��100��û�дﵽ�յ㣬����Ϊ���γ���ʧ��,ת����һ��episode����ѵ��
            step = step+1;
            if step>=step_max     
                break;
            end
        % ����current_state״̬����·���ߣ����˳�while�����������ʼ״̬
        else
            break;
        end
    end
    STEP(i) = step;
    % -------- ����ʱʹ��: ���� Q_table ���³̶ȣ��ж��Ƿ�ӽ����� --------
%     deltaQ(i) = sum(sum(abs(Q_table-Q_table_past)));
%     nonzeroQ(i) = length(find(Q_table~=0));
%     sumQ(i) = sum(sum(abs(Q_table)));
%     Q_table_past = Q_table;
    % --------------------����ʱʹ�� over ------------------------
end

% ---------------- ����ʱʹ��: �۲�Q����������� ---------------
% figure;
% subplot(1,2,1);
% plot(deltaQ,'color','r');hold on;
% plot(sumQ,'color','b');
% legend('deltaQ','sumQ');
% subplot(1,2,2);
% plot(nonzeroQ,'color','g');
% legend('nonzeroQ');
% length(find(Q_table~=0));
% --------------------����ʱʹ�� over ------------------------
end
