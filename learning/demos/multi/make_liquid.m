%
% initialize a liquid
%
nmc = neural_microcircuit;

%
% create two default pools of leaky I&F neurons
%
[nmc,p1] = add(nmc,'Pool','origin',[1 1 1]); % pool 1
[nmc,p2] = add(nmc,'Pool','origin',[5 1 1]); % pool 2

%
% create one pool of spiking input neurons
%
[nmc,pin] = add(nmc,'Pool','origin',[0 2 5],'size',[1 1 nInputChannels ],...
                'type','SpikingInputNeuron','frac_EXC',1);

%
% connect the input to the pools/pools
%
nmc = add(nmc,'Conn','dest',p1,'src',pin,'Cscale',0.9,'type','StaticSpikingSynapse',...
    'rescale',0,'Wscale',0.15,'lambda',Inf);
nmc = add(nmc,'Conn','dest',p2,'src',pin,'Cscale',0.9,'type','StaticSpikingSynapse',...
    'rescale',0,'Wscale',0.15,'lambda',Inf);
 
%
% add recurrent connections within the pools
%
nmc = add(nmc,'Conn','dest',p1,'src',p1,'lambda',2);
nmc = add(nmc,'Conn','dest',p2,'src',p2,'lambda',2);

%
% define the respones (i.e. what to record)
%
nmc = record(nmc,'Pool',p1,'Field','spikes');

