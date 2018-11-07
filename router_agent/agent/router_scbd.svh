//`include "agent_define.svh"

class router_scoreboard;
   Packet  refTrans[$];
   Packet  trans_from_drv;
   Packet  trans_from_mon;
   Packet  trans_cmp;   // transaction object 
   
   string  name   ;
   event   DONE   ;

   trans_mbox  from_drv;
   trans_mbox  from_mon;    
   
   function new(string name="router_scoreboard",trans_mbox from_drv=null,trans_mbox from_mon=null);
      if (TRACE_LOW) $display("[TRACE]%t %s:%m", $time, name);
      this.name = name;
      if (from_drv == null) from_drv = new();
      this.from_drv = from_drv;

      if (from_mon == null) from_mon = new();
      this.from_mon = from_mon;
   endfunction
   
   virtual task start();
      fork 
         while(1) begin
            this.from_mon.get(this.trans_from_mon);

            while(this.from_mon.num()) begin
               this.from_drv.get(trans_from_drv);
               this.refTrans.push_back(trans_from_drv);
            end

      //      this.check();
         end
      join_none
   endtask
   
   task check();
    int         index[$];
    string      message;
    static int  router_pkts_checked = 0;

    if (TRACE_LOW) $display("[TRACE]%0t %s:%m", $time, name);

    if(INFO_MEDIUM)  begin
      foreach(refTrans[i])
        this.refTrans[i].display($psprintf("refTrans[%0d]",i) );
    end

    index = this.refTrans.find_last_index() with (item.destX == this.trans_from_mon.destX && item.destY==this.trans_from_mon.destY);

    if (index.size() <= 0) begin
      $display("\n%m\n[ERROR]%0t %s not found in Reference Queue\n", $time, this.trans_from_mon.name);
      this.trans_from_mon.display("ERROR");
      $finish;
    end

    this.trans_from_drv = this.refTrans[index[0]];
    this.refTrans.delete(index[0]);

    if (!this.trans_from_drv.compare(this.trans_from_mon, message)) begin
      $display("\n%m\n[ERROR]%0t Packet #%0d %s\n", $time, router_pkts_checked, message);
      this.trans_from_drv.display("ERROR");
      this.trans_from_mon.display("ERROR");
      $finish;
    end

    $display("[NOTE]%t Packet #%0d %s", $realtime, router_pkts_checked++, message);

    if (router_pkts_checked >= router_run_pkts) 
      -> this.DONE;
  endtask: check

endclass
