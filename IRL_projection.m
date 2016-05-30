%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------------------------------------------------------------------
% Project <A simple way to implement IRL in projection version>
% Date    : 2016/5/30
% Author  : Kun da Lin
% Comments: Language: Matlab. 
% Source: matlab 
% ---------------------------------------------------------------------------------
%Q(state,x1)=  oldQ + alpha * (R(state,x1)+ (gamma * MaxQ(x1)) - oldQ);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
%% set paramater
round_max=20000;
N=20;
stop_count=100;

for experiment_times=1:100       %experiment times
    
%%  zero initial    
qtable = zeros(N+2,N+2,4);
round = 0;
count=0;


% You can use next line create your own experience and save it for using in the future
%[ expert_vector ,expert_map_matrix]= creat_expert_experience(N);

% You can use next line to save the expert's experience which you created
%save('expert_experience_30.mat','expert_vector','expert_map_matrix');
load('expert_experience_20.mat');
%expert_vector(225)=0;
[ old_appentice_vector ] = creat_learner_experience(N,stop_count);
%% IRL initialization , create firt set of reward matrix
w=expert_vector-old_appentice_vector;
learn_appentice_vector=old_appentice_vector;
reward_matrix=reshape(w(1:N*N),N,N);
wall_reward=w(end);



while round<round_max
    round=round+1;
% If N is 4
% map_matrix = [-2,-1,-1,-1,-1,-2;
%               -1, 0, 0, 0, 0,-1;
%               -1, 0, 0, 0, 0,-1;
%               -1, 0, 0, 0, 0,-1;
%               -1, 0, 0, 0, 0,-1;
%               -2,-1,-1,-1,-1,-2];
map_matrix=zeros(N+2,N+2);
map_matrix(1,:)=map_matrix(1,:)-1;
map_matrix(N+2,:)=map_matrix(N+2,:)-1;
map_matrix(:,1)=map_matrix(:,1)-1;
map_matrix(:,N+2)=map_matrix(:,N+2)-1;
% expert's matrix example     
% expert_matrix = [ 1,1   ,1   ,1   ,1   ,1;
%                   1,0   ,0   ,0   ,0   ,1;
%                   1,0.9 ,0   ,0   ,0   ,1;
%                   1,0.81,0.73,0.66,0.59,1;
%                   1,0   ,0   ,0   ,0.53,1;
%                   1,1   ,1   ,1   ,1   ,1];

%% Caculate the square error
delta_mu=expert_vector-learn_appentice_vector;
square_error=sqrt(sum(power(delta_mu,2)));
save_error(round+1,1)=sum(square_error);
disp(['trial: ' num2str(round) ' square_error: ' num2str(square_error)]);

%% if success
if(square_error<0.000001)
     IRL_terminate=1;
     %save('reward_expert_15.mat','reward_matrix','wall_reward');
     disp(['Congratulation! You succeed at ' num2str(round) ' trial']);
     break;
else
    IRL_terminate=0;
     %qtable = zeros(N+2,N+2,4);   %don't reset qtable is faster than reset
end

 %%  IRL:caculate new reward function
 % If round ==0 or  IRL_terminate==1(mean you success) break if
if(~(round==1 || IRL_terminate==1))

up=((learn_appentice_vector-old_appentice_vector)'*(expert_vector-old_appentice_vector));
down=(learn_appentice_vector-old_appentice_vector)'*(learn_appentice_vector-old_appentice_vector);
new_ue_bar=old_appentice_vector+(up/down)*(learn_appentice_vector-old_appentice_vector);
w= expert_vector-new_ue_bar;
old_appentice_vector=new_ue_bar;

reward_matrix=reshape(w(1:N*N),N,N);
wall_reward=w(end);
 

end
%% RL : Once you got the reward function , throw into RL and train it.

%load('reward_expert_15.mat');
RL_Epsidoe=0;

while (RL_Epsidoe<200)
    RL_Epsidoe=RL_Epsidoe+1;
    RL_count=0;
    position_x=2;
    position_y=2;
while ~((position_x==N+1 && position_y==N+1) || RL_count>stop_count) %stop_count
    RL_beta=0.7;
	RL_gamma=0.9;


RL_count=RL_count+1;
rand_action = floor(mod(rand*10,4))+1;
rand_number=rand;
[max_q, max_index] = max([qtable(position_x,position_y,1) qtable(position_x,position_y,2) qtable(position_x,position_y,3) qtable(position_x,position_y,4)]);

if(qtable(position_x,position_y,rand_action)>=qtable(position_x,position_y,max_index))
    action = rand_action;
else
    action = max_index;
end

%% epsilon greedy
%epsilon=1-1/(1+exp(-round));
%epsilon=1-round/50;
if(rand_number<0.05)
    action = rand_action;
else
    action = max_index;
end
map_matrix(position_x,position_y)=RL_count;

pre_position_x=position_x;
pre_position_y=position_y;

switch action
     
    case 1
        position_y = pre_position_y-1;   %up
    case 2
        position_y = pre_position_y+1;  %down
    case 3
        position_x = pre_position_x-1;  %left
    case 4
        position_x = pre_position_x+1;  %right
end
    if(position_x==1 || position_x==N+2 || position_y==1 || position_y==N+2)
        position_x = pre_position_x;
        position_y = pre_position_y;
        reward=wall_reward;
        b=0;    
    elseif(position_x==N+1 && position_y==N+1)        
        reward=reward_matrix(position_x-1,position_y-1);
        b=0;
    else        
        reward=reward_matrix(position_x-1,position_y-1);
    end  
    
    
  [max_qtable, max_qtable_index] = max([qtable(position_x,position_y,1) qtable(position_x,position_y,2) qtable(position_x,position_y,3) qtable(position_x,position_y,4)]);
  %disp(['position_x: ' num2str(position_x) ' position_y: ' num2str(position_y)]);
  %disp(['count: ' num2str(count)]);
 
   %% Q learning
   old_q=qtable(pre_position_x,pre_position_y,action);
   new_q=old_q+RL_beta*(reward+RL_gamma*max_qtable-old_q);
   qtable(pre_position_x,pre_position_y,action)=new_q;   
   
   %disp(['RL_Epsidoe: ' num2str(RL_Epsidoe) ' RL_count: ' num2str(RL_count)]);
end   
end%episode
%% Once you have done the work of RL, use the Q table you obtain and throw it into next function to find mul
 [ learn_appentice_vector,learner_map_matrix] = transport_qtable_to_mul(N,stop_count,qtable);
  %disp(['trial: ' num2str(round) ' count: ' num2str(RL_count)]);
  save_data(round,:)=RL_count;  
end%round
  save_experiment_times(experiment_times,1)=round;
  disp(['experiment_times: ' num2str(experiment_times) ' round: ' num2str(round)]);
end%experiment times
 figure(1);
 plot(save_data);
 title('Learning');
 xlabel('episode'); % x-axis label
 ylabel('step'); % y-axis label
  
 figure(2)
 plot(save_error);
 title('Error');
 xlabel('episode'); % x-axis label
 ylabel('U_e-U_l'); % y-axis label
 
 figure(3);
 reward_matrix=normc(reward_matrix);
 mesh(reward_matrix);
 title('Reward function');
 xlabel('X'); % x-axis label
 ylabel('Y'); % y-axis label
 zlabel('reward');
 
 disp('expert:');
 disp(expert_map_matrix);
 disp('learner:');
 disp(learner_map_matrix);
 
 