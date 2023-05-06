function in = localResetFcn02(in)

% reset函数

% randomize initial state
X = 0;
% 初始位置随机化
% Y = (randn*2-1)*0.5;
% yaw = (randn*2-1)*10/180*pi;
Y = 0;
yaw = 0;
% Vx = 5;
% 速度随机化
vx = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15];
% vx = [2 4 6 8 10];
Vx = vx(randi(length(vx)));
Vy = 0;
yaw_rate = 0;

blk_X = 'RL_vehicle_dynamic_model02/2D dynamic model/X';
blk_Y = 'RL_vehicle_dynamic_model02/2D dynamic model/Y';
blk_yaw = 'RL_vehicle_dynamic_model02/2D dynamic model/yaw';
blk_Vx = 'RL_vehicle_dynamic_model02/2D dynamic model/Vx';
blk_Vy = 'RL_vehicle_dynamic_model02/2D dynamic model/Vy';
blk_yaw_rate = 'RL_vehicle_dynamic_model02/2D dynamic model/yaw_rate';
in = setBlockParameter(in,blk_X,'InitialCondition',num2str(X),...
                          blk_Y,'InitialCondition',num2str(Y),...
                          blk_yaw,'InitialCondition',num2str(yaw),...
                          blk_Vx,'Value',num2str(Vx),...
                          blk_Vy,'InitialCondition',num2str(Vy),...
                          blk_yaw_rate,'InitialCondition',num2str(yaw_rate));
                          
end