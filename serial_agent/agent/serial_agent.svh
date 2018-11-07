class serial_agent #(
  int ports = 2
);

  string  name;
  virtual serial_inf#(.ports(ports)).TB      svif;      // serial port of router   
  
  bit                        trans_en;
  Driver#(.ports(ports))     rxDriv[];    // driver object
  Receiver#(.ports(ports))   txRecv[];    //
  serial_sequence            trans;       // generator object
  Scoreboard                 scor;
  semaphore                  sem[];       // prevent output port collision

  function new(string name="serial_agent", virtual serial_inf#(.ports(ports)).TB  svif);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.name = name;
    this.svif = svif;
  endfunction


  virtual task run();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.build();
    this.reset();
    this.start();
    this.wait_for_end(); 
//    $finish();
  endtask 

  virtual function void configure();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.randomize();
  endfunction

  virtual function set( input bit trans_en);
    this.trans_en = trans_en;
  endfunction

  virtual function void build();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, this.name);
    
    this.sem    = new[ports];
    this.rxDriv = new[ports];
    this.txRecv = new[ports];
    this.trans = new("serilGen",this.name );
    this.scor = new("Scoreboard");
    
    foreach(sem[i])
      this.sem[i] = new(1);

    foreach(rxDriv[i])
      this.rxDriv[i] = new($psprintf("rxDriv[%0d]", i), this.name, i,this.sem, this.trans.out_box[i], this.scor.driver_mbox, this.svif);

    foreach(txRecv[i])
      this.txRecv[i] = new($psprintf("txRecv[%0d]",i), this.name, i, this.scor.receiver_mbox, this.svif);
  endfunction

//  virtual task sing_node_reset();
//    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, this.name);
//    this.svif.reset <= 1'b1;
//    this.svif.cb.in_sflit_o <= '1;
//    this.svif.cb.out_ready_o <= '1;
//    ##10 this.svif.cb.reset <= 1'b0;
//    repeat(15) @(this.svif.cb);
//  endtask

  virtual task reset();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, this.name);
    this.svif.initialize();
  endtask

  virtual task start();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, this.name);
    
    if(trans_en) this.trans.start();
    
    this.scor.start();

    foreach(this.rxDriv[i]) begin
      this.rxDriv[i].start();
    end

    foreach(this.txRecv[i]) begin
      this.txRecv[i].start();
    end

  endtask

  virtual task wait_for_end();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, this.name);
    wait(this.scor.DONE.triggered);
  endtask

endclass

