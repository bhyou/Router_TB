class router_sequence;
   string name ;
   string hier_info;
   Packet trans;
//   mailbox #(router_transaction) to_driv;   // stimulus to 
  trans_mbox to_driv;
 
   function new(string name="router_sequence", string hier_info="");
      this.name = name;
      this.hier_info = hier_info;
      if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, this.hier_info, this.name);
      trans = new("Packet");
      to_driv = new(); 
   endfunction
   
   virtual task body();
      static int router_pkts = 0;
      if(TRACE_LOW) $display("[TRACE]%t %s %s:%m ", $realtime, this.hier_info, this.name);
//      #inject_delay;
      // void'(trans.randomize() with {self == 1;});
      trans.name = $psprintf("Para_Pakcet[%0d]",router_pkts++);

      if(!(trans.randomize() with { destX == 301; destY==0; })) begin
         $display("\nn%m\n[ERROR]%t Randomization Failed!\n", $realtime);
      end
   endtask

   virtual task start();
      Packet _trans;
      fork
        repeat(router_run_pkts) begin
           this.body();
           _trans =  new this.trans ;

           if(INFO_MEDIUM) $display("[info]%t %s %s:start() genrate Pkt!", 
                      $realtime, this.hier_info, this.name);

           if(INFO_MEDIUM) trans.display("ParaPkt");
           to_driv.put(_trans);
        end
      join_none
   endtask

endclass
