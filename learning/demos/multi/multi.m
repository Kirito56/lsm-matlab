%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initial (Matlab related) stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

startup;

VERBOSE_LEVEL  = 2;              % the higher the more is printed at stdout 
PLOTTING_LEVEL = 1;              % the gigher the more plots will appear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FAKE = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tmax = 2;
nInputChannels=4;
Tpattern = 250e-3;
TrainDist = multi_feature_stimulus('Tpattern',Tpattern,'d',nInputChannels, ...
    'events',{ { 'rs2' 1.0 [ 1 3 ]} { 'bp1' 1.0 [0.000 0.369 0.833 0.249]} { 'rs1' 1.0 [1 2]} { 'pat' 1.0 1} },'rndorder',0);

%
% define the neural circuit (liquid)
%
if FAKE
  fprintf('***\n*** FAKE LIQUID\n***\n');
  nmc=delay_lines('nMulti',round(270/nInputChannels),'delayRange',[0 20e-3],'nInputs',nInputChannels);
else
  make_liquid
end

%
% do some plotting if required
%
if PLOTTING_LEVEL > 0
  % run the liquid on one input
  S=generate(TrainDist,Tmax);
  reset(nmc);
  R=simulate(nmc,Tmax,S);

  % plot the input in figure 1
  figure(1); clf reset;
  plot(TrainDist,S);

  % plot the response in figure 2
  figure(2); clf reset;
  plot_response(R);

  % and wait for any key
  anykey;
end

%
% collect stimulus/response pairs for training
%
[train_response,train_stimuli] = collect_sr_data(nmc,TrainDist,200,Tmax);


% we train all the readouts on the same set of states so we
% precalculate them
train_states  = response2states(train_response,[],[0:0.025:Tmax]); 


% and now some test data
TestDist = set(TrainDist,'a',[0.5 0.5],'b',[0.5 0.5],'fback',[4 4],'phi',[pi  pi],...
    'events',{ { 'bp1' 1.0 [0.000 0.369 0.833 0.249]} { 'rs1' 1.0 [1 2]} { 'pat' 1.0 1} { 'rs2' 1.0 [ 1 3 ]} },'rndorder',0);

[test_response,test_stimuli] = collect_sr_data(nmc,TestDist,100,Tmax);

test_states = response2states(test_response,[],0:0.025:Tmax);


% train several different readouts
clear  readout

readout{1} = external_readout('targetFunction',sum_of_rates('W', 30e-3,'delay',0),...
    'description','sum of rates [-30,0]');


readout{2} = external_readout('targetFunction',sum_of_rates('W',200e-3,'delay',0),...
    'description','sum of rates [-200,0]');


readout{3} = external_readout('targetFunction',...
    event_detect('event','pat','t1',100e-3,'t2',Tpattern+50e-3),...
    'description','spatio temporal spike pattern');
readout{3} = set(readout{3},'algorithm',linear_classification,'Kstratify',2);


readout{4} = external_readout('targetFunction',...
    event_detect('event','rs1','t1',100e-3,'t2',Tpattern+50e-3),...
    'description','rate switch');
readout{4} = set(readout{4},'algorithm',linear_classification,'Kstratify',2);


readout{5} = external_readout('targetFunction',...
    spike_corr('channels',[1 3],'delta',5e-3,'W',75e-3),...
    'description','spike correlation 1 3');


readout{6} = external_readout('targetFunction',...
    spike_corr('channels',[1 2],'delta',5e-3,'W',75e-3),'description','spike correlation 1 2');

[trained_readouts] = train_readouts(readout,train_states,train_stimuli,...
                                                        test_states,test_stimuli);


% plot the output of the trained readouts of the test data
VERBOSE_LEVEL  = 1;
best_example = plot_readouts(trained_readouts,test_states,test_stimuli);


