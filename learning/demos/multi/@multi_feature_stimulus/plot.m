function plot(this,input)

clf reset;


subplot(3,1,1);
t=0:1e-3:input.info(1).Tstim;
r=input.info(1).a+input.info(1).b*sin(2*pi*t*input.info(1).fback+input.info(1).phi);       % time varying rate r(t)
r=max(min(r,1),0);                                % restrict to interval [0,1]
plot(t,r);
xlabel('time [s]');
ylabel('r(t)');
title('r(t)');

subplot(3,1,2);
for j=1:this.d
  st=this.pattern(1).st{j};
  line([st; st],j+[0.3; -0.3]*ones(1,length(st)),'Color','k','Linewidth',1.5);
end
set(gca,'XLim',[0 this.Tpattern],'Ylim',[0.5 this.d+0.5],'YTick',1:this.d,'Ydir','reverse');
xlabel('time [s]');
ylabel('spike train #');
title('pattern(1)');

subplot(3,1,3);
t1=input.info(1).t_pat;
t2=input.info(1).t_pat+this.Tpattern;
for j=1:this.d
  st=input.channel(j).data;
  line([st; st],j+[0.3; -0.3]*ones(1,length(st)),'Color','k','Linewidth',1.5);
  st = st(st>=t1 & st<=t2);
  line([st; st],j+[0.3; -0.3]*ones(1,length(st)),'Color','g','Linewidth',1.5);
end
set(gca,'XLim',[0 input.info(1).Tstim],'Ylim',[0.5 this.d+0.5],'YTick',1:this.d,'Ydir','reverse');
xlabel('time [s]');
ylabel('spike train #');
%title('input spike trains','FontWeight','bold');

drawnow;
