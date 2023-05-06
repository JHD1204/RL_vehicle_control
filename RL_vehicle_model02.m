clear
open_system('RL_vehicle_dynamic_model02');

%% ��������
% ����۲���
obsInfo = rlNumericSpec([6 1],'LowerLimit',[0 0 -inf -inf -inf -inf]','UpperLimit',[inf inf inf inf inf inf]');
obsInfo.Name = 'observations';
obsInfo.Description = 'vx, kr, ed, ded, ephi, dephi';
numObservations = obsInfo.Dimension(1);
% ����action
actInfo = rlNumericSpec([1 1],'LowerLimit',-pi/3,'UpperLimit',pi/3);
actInfo.Name = 'delta_f';
numActions = actInfo.Dimension(1);
% ���廷��
env = rlSimulinkEnv('RL_vehicle_dynamic_model02','RL_vehicle_dynamic_model02/RL Agent',obsInfo,actInfo);
% ����reset����
env.ResetFcn = @(in)localResetFcn02(in); 
% �������ʱ��Ͳ���
Ts = 0.1;
Tf = 300; 
% �������������
rng(0)

%% ����critic
% ���弸�������磬����������Ҫ������㡢ȫ���Ӳ㡢�ػ����
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
% �����������������γ�critic
criticNetwork = layerGraph(); 
criticNetwork = addLayers(criticNetwork,statePath); 
criticNetwork = addLayers(criticNetwork,actionPath); 
criticNetwork = addLayers(criticNetwork,commonPath); 
criticNetwork = connectLayers(criticNetwork,'CriticRelu1','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticRelu2','add/in2');
% ��������ṹ���ӻ�
% figure(1)
% plot(criticNetwork)
% ָ��������������
criticOpts = rlRepresentationOptions('LearnRate',1e-03,'GradientThreshold',1); 
% ʹ��ָ��������������������ô���critic
critic = rlRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},criticOpts);

%% ����actor
actorNetwork = [
    imageInputLayer([numObservations 1 1],'Normalization','none','Name','State')
    fullyConnectedLayer(64, 'Name','actorFC1')
    reluLayer('Name','actorRelu')   
    fullyConnectedLayer(numActions,'Name','Actorout')
    tanhLayer('Name','actorTanh')
    scalingLayer('Name','Action','Scale',actInfo.UpperLimit)
    ];
% ָ��������������:ѧϰ���ʡ��ݶ���ֵ��
actorOptions = rlRepresentationOptions('LearnRate',1e-04,'GradientThreshold',1);
% ʹ��ָ��������������������ô���actor, Action names must be an input or output name.
actor = rlRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);

%% ����һЩ���ò�����agent
%����ʱ��
%Ŀ����µ�ƽ������
%�ۿ�����
%�������С�����Ĵ�С
%���黺������С
agentOpts = rlDDPGAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-3,...
    'DiscountFactor',0.95, ...
    'MiniBatchSize',64, ...
    'ExperienceBufferLength',1e6); 
agentOpts.NoiseOptions.Variance = 0.3;
agentOpts.NoiseOptions.VarianceDecayRate = 1e-5;
agent = rlDDPGAgent(actor,critic,agentOpts);

%% ����ѵ������
maxepisodes = 2000;
maxsteps = ceil(Tf/Ts);
%���غ���
%ÿ�غ������
%ƽ�����ڳ���
%�Ƿ�����������ʾѵ�����ȣ�ʹ�� Episode Manager ��ʾѵ�����ȣ���ͼ�λ�������ʾ��������Ϣ
%ֹͣѵ������ֹ����
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
    % ��֤����Ч��
    simOpts = rlSimulationOptions('MaxSteps',maxsteps,'StopOnError','on');
    experiences = sim(env,saved_agent,simOpts);
end




