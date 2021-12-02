function Y = bnd_normrnd(mu,cv,lb,ub,m,n,msg)

if n*m == 0
  Y=[];
  return;
end

if cv > 0
  maxd = min(min(mu-lb,ub-mu),abs(5*cv*mu));
  clb = mu-maxd;
  cub = mu+maxd;
  if mu ~= 0
    acv=-1;
    s=1;
    cnt = 0;
    while abs(acv-cv) > 0.02*cv & cnt < 100
      Y      = gaussrnd(mu,s*abs(cv*mu),m,n);
      inv    = find( Y < lb | Y > ub);
      Y(inv) = clb+abs(cub-clb)*rand(1,length(inv));
      acv=abs(std(Y(:))/mean(Y(:)));
      if ~isnan(acv) & acv ~= 0
	s = s*cv/acv;
      else
	s = 1;
      end
      cnt = cnt + 1;
    end
    if ( n*m > 30 )
      amu=mean(Y(:)); 
      acv=abs(std(Y(:))/amu);
      % if abs(acv-cv) > 0.03*cv
%	fprintf('WARNING: acv (%g) not equal cv (%g)! (%s, %i)\n',acv,cv,msg,length(Y(:)));
%      end
%      if abs(amu-mu) > abs(0.1*mu)
%        fprintf('WARNING: amu (%g) not equal mu (%g)! (%s, %i)\n',amu,mu,msg,length(Y(:)));
%      end
    end
  else  
    clb = lb;
    cub = ub;
    Y = mu * ones(m,n);
  end
else
  clb = lb;
  cub = ub;
  Y = mu * ones(m,n);
end


%  figure(1); clf;
%  hist(Y,100);
%  yl=get(gca,'Ylim');
%  line([lb mu ub; lb mu ub],yl(:)*ones(1,3),'Color','r');
%  title(sprintf('%s: mean=%g (%g), cv=%g (%g), [%g,%g], [%g,%g]',msg,mean(Y(:)),mu,abs(std(Y(:))/mean(Y(:))),cv,lb,ub,clb,cub));


inv    = find( Y < lb | Y > ub);
if ~isempty(inv)
  error('values out of boundaries!');
end


