// router parallel port driver class
//`include "router_define.svh"

class router_drv ;
   string  name ;
   string  hier_info;
   int     vchanel = 1;
   int     delay = 0;
   virtual router_inf.tb router_if;

   
   // Two Transaction Instances that are used to bring and clone the stimulus
   Packet         trans, _trans;

   // trans_mobx  mailbox#(Packet)
   trans_mbox        send_stim;  // send stimuls to scoreboard
   trans_mbox        rece_stim;  // recevice stimuls from sequence

   function new(string name="router_driver", string hier_info="",
                virtual router_inf.tb router_if,
                trans_mbox rece_stim , trans_mbox send_stim);
      if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
      this.name = name; 
      this.hier_info = hier_info; 
      this.router_if = router_if;    // initialize the virtual interface
      this.rece_stim = rece_stim;      //  mailbox connect
      this.send_stim = send_stim;
   endfunction
   
   virtual task start();
      if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, this.hier_info,this.name);
      if(this.router_if == null)    
         $error("the router_drv virtual interface is null!");

      fork
         forever begin
            rece_stim.get(trans);    // get stimulus 
            _trans = new trans;      // copy to _trans and then is being applied to driver
            send( );
            send_stim.put(_trans);
         end
      join_none
   endtask
   
   virtual task send( );
      flit_s         flit;    
      if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime,this.hier_info, this. name);

//      if (INFO_LOW) $info("[INFO]%t the size of pkt is %0d", $realtime, $size(_trans.payload));

      flit.ftype = HEADER;
      flit.content = {_trans.destX, _trans.destY, _trans.prio, _trans.flit_spec};
      if(TRACE_MEDIUM) $display("[Driver]%t %s %s transmit flit, type:%0d, content:0x%x", 
                                 $realtime, this.hier_info, this.name, flit.ftype, flit.content );
      router_if.sendFlit({this.hier_info,":","this.name"}, {flit.ftype, flit.content});
      //router_inf.send_flit(vchanel, flit);
 
      for (int i=0;i<$size(_trans.payload)-1;i=i+1) begin
         flit.ftype = PAYLOAD;
         flit.content = _trans.payload[i];
         if(TRACE_MEDIUM) $display("[Driver]%t %s %s transmit flit, type:%0d, content:0x%x", 
                                     $realtime,this.hier_info, this.name, flit.ftype, flit.content );
         router_if.sendFlit({this.hier_info,":","this.name"}, {flit.ftype, flit.content});
         //router_inf.send_flit(vchanel, flit);
      end
      
      flit.ftype = LAST;
      flit.content = _trans.payload[$size(_trans.payload)-1];
      if(TRACE_MEDIUM) $display("[Driver]%t %s %s transmit flit, type:%0d, content:0x%x", 
                                   $realtime, this.hier_info, this.name, flit.ftype, flit.content );
      router_if.sendFlit({this.hier_info,":","this.name"}, {flit.ftype, flit.content});
      //router_inf.send_flit(vchanel, flit);
   endtask
   
endclass
