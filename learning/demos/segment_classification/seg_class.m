
% Initial (Matlab related) stuff

startup;                   

VERBOSE_LEVEL  = 2;              % the higher the more is printed at stdout 
PLOTTING_LEVEL = 1;              % the higher the more plots will appear

%
% decide wether to use a fake liquid or a real one
%
FAKE = 0; 


%
% define the input distribution
%
Tmax = 1.0;
nInputChannels=1;
InputDist = jittered_templates('nChannels',nInputChannels,'nTemplates',[2 2 2 2],'Tstim',Tmax,'jitter',4e-3);

%
% define the neural circuit (liquid
%
if FAKE
  fprintf('***\n*** FAKE LIQUID\n***\n');
  nmc=delay_lines('nMulti',135,'delayRange',[0 20e-3],'nInputs',nInputChannels);
else
  make_liquid
end

%
% do some plotting if required
%
if PLOTTING_LEVEL > 0
  % run the liquid on one input
  S=generate(InputDist);
  reset(nmc);
  R=simulate(nmc,Tmax,S);

  % plot the input in figure 1
  figure(1); clf reset;
  plot(InputDist,S);

  % plot the response in figure 2
  figure(2); clf reset;
  plot_response(R);

  % and wait for any key
  anykey;
end

N=400;

%
% collext stimulus/response pairs for training
%
[train_response,train_stimuli] = collect_sr_data(nmc,InputDist,5*N);

%
% we train all the readouts on the same 
% set of states so we precalculate them
%
train_states  = response2states(train_response,[],Tmax); 

%
%  and now some test data
%
[test_response,test_stimuli] = collect_sr_data(nmc,InputDist,3*N);

test_states = response2states(test_response,[],Tmax);

%
% we train a readout for each segment
%
clear readout

for s=1:4
  readout{s} = external_readout('description',sprintf('segment %i',s),...
                                'targetFunction',segment_classification('posSeg',s),...
				'algorithm',linear_classification);
end

[trained_readouts, perf_train, perf_test] = train_readouts(readout,train_states,train_stimuli,test_states,test_stimuli);

%
% plot the performance over segment number
%
figure(3); clf reset;
p=1-[perf_test(:).mae]
cc=[perf_test(:).cc]
bar(cc);
set(gca,'Ylim',[0.5 1],'Xlim',[0.5 4.5]);
xlabel('segment');
ylabel('1-mae');

%
% now we plot the result AT OTHER SAMPLING TIME POINTS
%
figure(4); clf reset;
VERBOSE_LEVEL  = 0;
plot_readouts(trained_readouts,test_response,test_stimuli,{ 'response2states' '[0:0.05:Tmax]' });








