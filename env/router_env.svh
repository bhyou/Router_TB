class router_env #(int ports=2);
  string name; 
  int     TRACE = 1; 
  virtual serial_inf.TB    svif[];            //  uart interface
  virtual router_inf.tb    pvif;              // router parallel interface

  serial_agent#(.ports(ports))   uart_agent;

  router_agent                   router_agt;   

  function new(string name="router_env", virtual serial_inf.TB svif[],
               virtual router_inf.tb pvif);
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
    this.name = name;
    this.svif = svif;
    this.pvif = pvif;
  endfunction

 
  function void build(); 
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
      uart_agent = new("uart_agent",svif);
      uart_agent.build();
      router_agt = new("router_agent", pvif);
      router_agt.build(); 
  endfunction
  
  task reset();
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
    fork
       svif.initialize();
       pvif.initialize();
     join
//    uart_agent.reset();
  endtask
  
  task start();
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
    fork
       uart_agent.start();
       router_agt.start(); 
    join_none
  endtask
  
  task wait_for_end();
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
    uart_agent.build();
    router_agt.wait_for_end(); 
  endtask 
  
  task run();
    if (TRACE) $display("[TRACE]%t %s:%m", $realtime, name);
    this.build();
    this.reset();
    this.start();

    #100000;
    $finish;
  //  this.wait_for_end();
  endtask

endclass



