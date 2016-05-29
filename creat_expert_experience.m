function [ expert_appentice_vector,map_matrix ] = creat_expert_experience( N )
%%  creat_expert_experience
%    N*N map start point:1,1 end point:N+1,N+1
%    ex:N=4 1 1 1 1 1 1
%           1 s 0 0 0 1
%           1 0 0 0 0 1
%           1 0 0 0 0 1
%           1 0 0 0 e 1
%           1 1 1 1 1 1
%    N: map dimension
%    expert_appentice_vector: N*N+1,1   experience vector
%    map_matrix:walk step in number sequence
   
   appentice_matrix=zeros(N,N); 
   learn_wall=0;
   gamma=0.9;
   count=0;
   position_x=2;
   position_y=2;
while ~((position_x==N+1 && position_y==N+1))
   
count=count+1;

direction=input('please give me the expert direction:');
% action = max_index;
map_matrix(position_x,position_y)=count;

pre_position_x=position_x;
pre_position_y=position_y;

switch direction
     
    case 8
        position_x = pre_position_x-1;   %up
    case 2
        position_x = pre_position_x+1;  %down
    case 4
        position_y = pre_position_y-1;  %left
    case 6
        position_y = pre_position_y+1;  %right
    
end

    if(position_x==1 || position_x==N+2 || position_y==1 || position_y==N+2)
        learn_wall = learn_wall + power(gamma,count);
        position_x = pre_position_x;
        position_y = pre_position_y;
       
   
    else
        appentice_matrix(position_x-1,position_y-1)=appentice_matrix(position_x-1,position_y-1)+power(gamma,count);
       
    end   
    
 
  disp(['position_x: ' num2str(position_x) ' position_y: ' num2str(position_y)]);
 %disp(['count: ' num2str(count)]);   

end
expert_appentice_vector=reshape(appentice_matrix,N*N,1);
expert_appentice_vector=[expert_appentice_vector;learn_wall];
disp('finish');
end

