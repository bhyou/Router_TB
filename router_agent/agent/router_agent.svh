class router_agent;
  string                 name;
  string                 hier_info;
  virtual router_inf.tb  router_if;
  bit                    seq_en  ;   // whether seqence enable
  // router Driver
  router_drv              _drv;
  // router Sequencer
  router_sequence         _seq;
  // router Monitor
  router_mon              _mon;
  // router scoreboard
  router_scoreboard       scbd;
  // router Coverage block
//  router_coverage         _cov;

  function new (string name="router_agent", string hier_info="", virtual router_inf.tb pvif);
      this.name = name;
      this.hier_info = hier_info;
      if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, this.name, this.hier_info);
      this.router_if = pvif;
  endfunction:new

  function set(bit seq_en);
     this.seq_en = seq_en;
  endfunction

  extern function void build ();
  extern task reset();
  extern task start();
  extern task wait_for_end();
endclass:router_agent

function void router_agent::build();
  if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime,this.hier_info,  this.name);
 // scbd scoreboard collection output, and compare with reference/ golden model 
  this.scbd = new("router_scoreboard");           
 //  sequence : generate transaction and then tansmit data to driver
  this._seq = new("router_sequence" ,{this.hier_info," ",this.name} );              
 //  driver receive stimulus and fowwarding data to scoreboard 
  this._drv = new("router_driver",{this.hier_info," ",this.name}, this.router_if, this._seq.to_driv, this.scbd.from_drv);    
 //  monitor  : receive output data from dut, convert into transaction
  this._mon = new("router_monitor", this.router_if, this.scbd.from_mon);  
endfunction:build

task router_agent::reset();
  if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, this.hier_info, this.name);
  this.router_if.initialize();
endtask

task router_agent::start();
   if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime,this.hier_info, this.name);
   if(this.router_if == null) $error("the router agent virtual interface is null!"); 
   // generate stimulus
   if(seq_en) this._seq.start();
   
   this._drv.start();
   
   this._mon.start();
   
   this.scbd.start();

endtask:start



task router_agent::wait_for_end();
   if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime,this.hier_info, this.name);
   wait(this.scbd.DONE.triggered);
endtask
