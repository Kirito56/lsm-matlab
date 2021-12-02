function I=generate(gi,Tmax,varargin)

if gi.Tstim > -1, Tstim=gi.Tstim; else Tstim=Tmax; end

nInputs = gi.d;

%
% generate background spike trains
%
i=ceil(rand*size(gi.a,1));                 % choose interval
I.info(1).a=gi.a(i,1)+diff(gi.a(i,:))*rand;          % draw uniformly from interval

i=ceil(rand*size(gi.a,1));                 % choose interval
I.info(1).b=gi.b(i,1)+diff(gi.b(i,:))*rand;          % draw uniformly from interval

i=ceil(rand*size(gi.fback,1));             % choose interval
I.info(1).fback=gi.fback(i,1)+diff(gi.fback(i,:))*rand;  % draw uniformly from interval 

i=ceil(rand*size(gi.phi,1));               % choose interval
I.info(1).phi=gi.phi(i,1)+diff(gi.phi(i,:))*rand;  % draw uniformly from interval

t=0:1e-3:Tstim;
r=I.info(1).a+I.info(1).b*sin(2*pi*t*I.info(1).fback+I.info(1).phi);       % time varying rate r(t)
r=min(r,1);                                % restrict to interval [0,1]

%
% convert time varying rate to nInputs spike trains 
%
background=rate2spikes(r*gi.Fmax,1e-3,nInputs,Tstim);



if gi.rndorder
  rp = randperm(length(gi.events));
else
  rp = 1:length(gi.events);
end

prob=[];
for i=rp
  prob(i) = (rand < gi.events{i}{2});
end

%
% choose random event times (and make sure that they are at least Tpattern apart)
%
n=sum(prob);
dt_ev = 5e-3;
time = sort((Tstim-gi.Tpattern)*rand(1,n));
time = round(time/dt_ev)*dt_ev;
while any(diff(time)<1.1*gi.Tpattern)
  time = sort((Tstim-gi.Tpattern)*rand(1,n));
  time = round(time/dt_ev)*dt_ev;
end

e=0;
for i=rp
  if rand < gi.events{i}{2}
    e=e+1;
    ename=gi.events{i}{1};
    eval(sprintf('I.info(1).t_%s=time(e);',ename));
    if ~isempty(strfind(ename,'pat'))
      p=gi.events{i}{3};
      for j=1:nInputs;
	event(e).st{j} = time(e) + gi.pattern(p).st{j};
      end
    elseif ~isempty(strfind(ename,'bp')) | ~isempty(strfind(ename,'burst'))
      bp=gi.events{i}{3};
      for j=1:nInputs
	event(e).st{j} = unique([ background{j} time(e) + bp(j)*gi.Tpattern+[0:gi.nSpB-1]/gi.Fburst]);
      end
    elseif ~isempty(strfind(ename,'rs')) | ~isempty(strfind(ename,'ratesw'))
      rs=gi.events{i}{3};
      for j=1:nInputs
	if any(rs==j)
	  st = time(e)+[cumsum(gi.absrefract+exponentialrnd(1/(gi.Fbase+gi.Fdiff)-gi.absrefract,1,200))];
	else
	  st = time(e)+[cumsum(gi.absrefract+exponentialrnd(1/max((gi.Fbase-gi.Fdiff),10)-gi.absrefract,1,200))];
	end
	event(e).st{j} = st(st>=time(e) & st<=(time(e)+gi.Tpattern));
      end
    end
  end
end

%
% insert events into background
%
for e=1:length(event)
  for j=1:nInputs
    st = background{j};
    st = st(~(st>time(e) & st<time(e)+gi.Tpattern));
    st = [st event(e).st{j}];
    background{j} = unique(st(st>0 & st<Tstim));
  end
end

for j=1:nInputs
  I.channel(j).spiking = 1;
  I.channel(j).dt      = -1;
  I.channel(j).data    = background{j};
end

I.info(1).Tstim = Tstim;

