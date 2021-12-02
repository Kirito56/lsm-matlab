function this =  event_detect(varargin)

this.name            = 'event_detect';
this.description     = 'output 1 (during [t_event+t1,t_event+t2]) if a certain event occurs in the input';
this.abbrev          = 'event detect';
this.event           = 'pat';
this.event_comment   = 'name of the event to detect (see also general_input)';
this.tail            = 0;
this.tail_comment    = 'the value of the target function after the pulse';
this.t1              = 150e-3;
this.t1_comment      = 'the onset time of the pulse relative to the start of the event';
this.t2              = 200e-3;
this.t2_comment      = 'the offset time of the pulse relative to the start of the event';

this.target_type = 'classification';

if nargin == 0
  this = class(this,this.name);
elseif isa(varargin{1},this.name)
  this = varargin{1};
else
  this = class(this,this.name);
  this = set(this,varargin{:});
end
