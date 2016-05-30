function [ learner_appentice_vector ] = creat_learner_experience(N,stop_step)
%%  creat  learner_experience randomly
%    N*N map start point:1,1 end point:N+1,N+1
%    ex:N=4 1 1 1 1 1 1
%           1 s 0 0 0 1
%           1 0 0 0 0 1
%           1 0 0 0 0 1
%           1 0 0 0 e 1
%           1 1 1 1 1 1
%    N: map dimension
%    learner_appentice_vector: N*N+1,1   experience vector
%    stop_step: when counts>stop_step,restart an episode
% %% test data
%     N=5;
%     stop_step=30;
   appentice_matrix=zeros(N,N); 
   learn_wall=0;
   gamma=0.9;
   count=0;
   position_x=2;
   position_y=2;
while ~((position_x==N+1 && position_y==N+1) || count>stop_step)
   
count=count+1;
rand_action = floor(mod(rand*10,4))+1;

% action = max_index;
map_matrix(position_x,position_y)=count;

pre_position_x=position_x;
pre_position_y=position_y;

switch rand_action
     
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
        learn_wall = learn_wall + power(gamma,count);
        position_x = pre_position_x;
        position_y = pre_position_y;
       
   
    elseif(position_x==N+1 && position_y==N+1)
         appentice_matrix(position_x-1,position_y-1)=appentice_matrix(position_x-1,position_y-1)+power(gamma,count);
    else
         appentice_matrix(position_x-1,position_y-1)=appentice_matrix(position_x-1,position_y-1)+power(gamma,count);
    end   
    
 
  %disp(['position_x: ' num2str(position_x) ' position_y: ' num2str(position_y)]);
 %disp(['count: ' num2str(count)]);   

end
learner_appentice_vector=reshape(appentice_matrix,N*N,1);
learner_appentice_vector=[learner_appentice_vector;learn_wall];
end

