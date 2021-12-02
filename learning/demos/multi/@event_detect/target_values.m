function y=target_function(this,input,at_t)

eval(sprintf('t0=input.info(1).t_%s;',this.event));
t1=t0+this.t1;
t2=t0+this.t2;

if t1>0
  myt=[0       t1-5e-4  t1    t2      t2+1e-4 t2+max(at_t)];
  myy=[this.tail this.tail  1.0   1.0     this.tail this.tail  ];
else
  myt=[        t1-5e-4  t1    t2      t2+1e-4 t2+max(at_t)];
  myy=[        this.tail  1.0   1.0     this.tail this.tail  ];
end  

y=interp1(myt,myy,at_t);
