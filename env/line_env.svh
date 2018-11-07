
class line_env #(
  routers = 300,
  ports = 2
);
  string        name ;
  
  bit           TRACE_LOW = 0;  
  bit           rand_test = 0;
//  event         done_reset;
  event         finish;
  int           count_pkts = 999;

  serial_agent#(.ports(1))              line_agt  ;
  serial_agent#(.ports(ports-1))        uart_agt[];
  router_agent                          router_agt[];

  virtual serial_inf#(.ports(1)).TB       dvif;

  function new( string name="line_env", 
         virtual serial_inf#(.ports(1)).TB       dvif, 
         virtual serial_inf#(.ports(ports-1)).TB svif[], 
         virtual router_inf.tb                   pvif[] 
  );
    this.name = name;

    this.router_agt = new[pvif.size()];
    this.uart_agt   = new[svif.size()];

    this.dvif       = dvif  ;
    this.line_agt   = new("line_agt", dvif);
    this.line_agt.build();

    foreach (svif[i]) begin
      this.uart_agt[i] = new($psprintf("node[%0d]_uart_agt",i),svif[i]); 
      this.uart_agt[i].build();
    end

    foreach (pvif[i]) begin
      this.router_agt[i] = new($psprintf("node[%0d]_para_agt",i), this.name, pvif[i]); 
      this.router_agt[i].build();
    end

  endfunction:new

  virtual function sysconfig();
    for(int i=0; i<100; i++) begin
      this.router_agt[i].set(1);
    end
    this.line_agt.set(0);
  endfunction

  virtual function randconfig();
    int node_select;
    repeat(100) begin
      node_select = $urandom_range(299,0);
      $display("the select nodes is %0d!", node_select);
      this.router_agt[$urandom_range(299,0)].set(1);
    end
  endfunction

  task reset();
    if (TRACE_HIGH) $display("[TRACE]%t %s:%m is runing...." , $realtime, name);
    begin
    fork
      this.line_agt.reset();

      foreach(this.uart_agt[i])
        this.uart_agt[i].reset();

      foreach(this.router_agt[i])
        this.router_agt[i].reset();
    join
    end
  endtask

  task start();
    $display("[TRACE]%t line have been initialized, startapplying incentives .....", $realtime);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    fork 
      this.line_agt.start();

      foreach(this.uart_agt[i])
        this.uart_agt[i].start();

      foreach(this.router_agt[i])
        this.router_agt[i].start(); 
    join
  endtask

  task wait_for_end();
//    this.line_agt.wait_for_end();
    if(this.line_agt.scor.refPkt.size() >= count_pkts)
      -> finish;
  endtask

  task run();
    $display("[TRACE]%t line have been initialized, line simulation begin.....", $realtime);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);

    if(rand_test) randconfig();
    else          sysconfig();

    this.reset();
    wait(~dvif.reset);
    this.start();
    this.wait_for_end();
    wait(this.finish.triggered);
    $finish;
  endtask
endclass

