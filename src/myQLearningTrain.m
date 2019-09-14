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
state_num=size(RewardTable,1);  % 所有状态数目
Q_table=zeros(state_num);       % 随机初始化 Q table

% -------- 测试时使用: 用以判断 Q table 收敛程度（以下3行） --------
% Q_table_past = Q_table;
% deltaQ = zeros(episode,1);     
% nonzeroQ = zeros(episode,1);   
% sumQ = zeros(episode,1); 
% --------------------测试时使用 over ------------------------

STEP = zeros(episode,1);
for i=1:episode
    % 随机选择初始状态
    current_state=randperm(state_num,1);
    % 使用 step 是为了防止 current_state 陷入孤立域，永远也达不到 final_state（这样程序就会进入死循环）
    step = 0;
    while current_state~=final_state
        % 所有可能的动作（去往下一个状态）
        optional_action=find(RewardTable(current_state,:)>-1);
        % 在current_state状态下有可选动作
        if ~isempty(optional_action)
            % 随机选择下一个状态
            chosen_action=optional_action(randperm(length(optional_action),1));
            % 执行该动作，得到reward和下一状态
            r=RewardTable(current_state,chosen_action);
            next_state=chosen_action;
            % 更新Q-Table
            next_possible_action= RewardTable(next_state,:)>-1;
            maxQ=max(Q_table(next_state,next_possible_action));
            % 核心迭代公式
            Q_table(current_state,chosen_action)=Q_table(current_state,chosen_action)+alpha*(r+gamma*maxQ-Q_table(current_state,chosen_action));
            % 更新状态
            current_state=next_state;
            % 尝试的步骤step加1,如果step到100还没有达到终点，则认为本次尝试失败,转入下一个episode继续训练
            step = step+1;
            if step>=step_max     
                break;
            end
        % 若在current_state状态下无路可走，就退出while，放弃这个初始状态
        else
            break;
        end
    end
    STEP(i) = step;
    % -------- 测试时使用: 计算 Q_table 更新程度，判断是否接近收敛 --------
%     deltaQ(i) = sum(sum(abs(Q_table-Q_table_past)));
%     nonzeroQ(i) = length(find(Q_table~=0));
%     sumQ(i) = sum(sum(abs(Q_table)));
%     Q_table_past = Q_table;
    % --------------------测试时使用 over ------------------------
end

% ---------------- 测试时使用: 观察Q矩阵收敛情况 ---------------
% figure;
% subplot(1,2,1);
% plot(deltaQ,'color','r');hold on;
% plot(sumQ,'color','b');
% legend('deltaQ','sumQ');
% subplot(1,2,2);
% plot(nonzeroQ,'color','g');
% legend('nonzeroQ');
% length(find(Q_table~=0));
% --------------------测试时使用 over ------------------------
end
