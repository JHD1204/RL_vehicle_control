clear
open_system('RL_vehicle_dynamic_model02');

%% 创建环境
% 定义观测量
obsInfo = rlNumericSpec([6 1],'LowerLimit',[0 0 -inf -inf -inf -inf]','UpperLimit',[inf inf inf inf inf inf]');
obsInfo.Name = 'observations';
obsInfo.Description = 'vx, kr, ed, ded, ephi, dephi';
numObservations = obsInfo.Dimension(1);
% 定义action
actInfo = rlNumericSpec([1 1],'LowerLimit',-pi/3,'UpperLimit',pi/3);
actInfo.Name = 'delta_f';
numActions = actInfo.Dimension(1);
% 定义环境
env = rlSimulinkEnv('RL_vehicle_dynamic_model02','RL_vehicle_dynamic_model02/RL Agent',obsInfo,actInfo);
% 定义reset函数
env.ResetFcn = @(in)localResetFcn02(in); 
% 定义仿真时间和步长
Ts = 0.1;
Tf = 300; 
% 定义随机数种子
rng(0)

%% 创建critic
% 定义几个神经网络，定义内容主要是输入层、全连接层、池化层等
statePath = [    imageInputLayer([numObservations 1 1],'Normalization','none','Name','State')    
    fullyConnectedLayer(64,'Name','CriticStateFC1')    
    reluLayer('Name','CriticRelu1')]; 
actionPath = [    imageInputLayer([numActions 1 1],'Normalization','none','Name','Action')    
    fullyConnectedLayer(64,'Name','CriticActionFC1')
    reluLayer('Name','CriticRelu2')];
commonPath = [    additionLayer(2,'Name','add')
    fullyConnectedLayer(64,'Name','CriticCommonFC1')
    reluLayer('Name','CriticCommonRelu')    
    fullyConnectedLayer(numActions,'Name','CriticOutput')];
% 将神经网络连接起来形成critic
criticNetwork = layerGraph(); 
criticNetwork = addLayers(criticNetwork,statePath); 
criticNetwork = addLayers(criticNetwork,actionPath); 
criticNetwork = addLayers(criticNetwork,commonPath); 
criticNetwork = connectLayers(criticNetwork,'CriticRelu1','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticRelu2','add/in2');
% 将神经网络结构可视化
% figure(1)
% plot(criticNetwork)
% 指定网络的相关设置
criticOpts = rlRepresentationOptions('LearnRate',1e-03,'GradientThreshold',1); 
% 使用指定的深度网络机器相关设置创建critic
critic = rlRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},criticOpts);

%% 创建actor
actorNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','State')
    fullyConnectedLayer(64, 'Name','actorFC1')
    reluLayer('Name','actorRelu')   
    fullyConnectedLayer(numActions,'Name','Actorout')
    tanhLayer('Name','actorTanh')
    scalingLayer('Name','Action','Scale',actInfo.UpperLimit)
    ];
% 指定网络的相关设置:学习速率、梯度阈值等
actorOptions = rlRepresentationOptions('LearnRate',1e-04,'GradientThreshold',1);
% 使用指定的深度网络机器相关设置创建actor, Action names must be an input or output name.
actor = rlRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);

%% 给定一些设置并创建agent
%采样时间
%目标更新的平滑因子
%折扣因子
%随机经验小批量的大小
%经验缓冲区大小
agentOpts = rlDDPGAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-3,...
    'DiscountFactor',0.95, ...
    'MiniBatchSize',64, ...
    'ExperienceBufferLength',1e6); 
agentOpts.NoiseOptions.Variance = 0.3;
agentOpts.NoiseOptions.VarianceDecayRate = 1e-5;
agent = rlDDPGAgent(actor,critic,agentOpts);

%% 设置训练参数
maxepisodes = 2000;
maxsteps = ceil(Tf/Ts);
%最大回合数
%每回合最大步数
%平均窗口长度
%是否在命令行显示训练进度，使用 Episode Manager 显示训练进度，以图形或数据显示奖励等信息
%停止训练的终止条件
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'ScoreAveragingWindowLength',20, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','EpisodeCount',...
    'StopTrainingValue',maxepisodes,...
    'SaveAgentCriteria','EpisodeCount',...
    'SaveAgentValue',maxepisodes,...
    'SaveAgentDirectory','VehicleDDPG04');
doTraining = false;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
else
    % Load pretrained agent for the example.
    load('VehicleDDPG04\Agent2000.mat','saved_agent')
    % 验证控制效果
    simOpts = rlSimulationOptions('MaxSteps',maxsteps,'StopOnError','on');
    experiences = sim(env,saved_agent,simOpts);
end




