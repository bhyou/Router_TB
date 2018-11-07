//`include "router_define.svh"
class router_mon;
   string  name ;
   int     vchanels= 1;
   int     delay   = 0;
   virtual router_inf.tb router_if;
   
   trans_mbox           to_scbd;               //transmit received flit to scoreboard
   Packet               trans_recv;
   logic [`DATA_W-1:0]  refpkt_payload[$];

   logic [`DATA_W+`TYPE_W-1:0] recvflit;
   
   int router_port_recv_pkts = 0;


   function new(string name="router_monitor", virtual router_inf.tb router_if, trans_mbox to_scbd);
      if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
      this.name = name;
      this.router_if = router_if;
      this.to_scbd = to_scbd;
      trans_recv = new("ParaRecvPkt");
   endfunction
  
   // receive flit, then conver
   virtual task receive( );
      flit_s  recv_flit; 

      if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);

      if(this.router_if == null)    
         $error("the router_drv virtual interface is null!");

      //receive_flit(vc,  recv_flit);
      //router_if.receive_flit(vchanel, recv_flit);

      this.router_if.receiveFlit( recvflit );
      if(recvflit != 0)  begin
         {recv_flit.ftype, recv_flit.content} = recvflit;

         if(TRACE_MEDIUM) $display("[Monitor]%t Receive flit, type:%0d, content:%x", $realtime, recv_flit.ftype, recv_flit.content );

         if(recv_flit.ftype == HEADER)
            {trans_recv.destX, trans_recv.destY, trans_recv.prio,trans_recv.flit_spec} = recv_flit.content;
         else if(recv_flit.ftype == PAYLOAD)
            refpkt_payload.push_back(recv_flit.content);
         else if(recv_flit.ftype == LAST) begin
            refpkt_payload.push_back(recv_flit.content);
            trans_recv.payload = refpkt_payload;
            refpkt_payload.delete();

            trans_recv.name = $psprintf("PrecvPkt[%0d]", router_port_recv_pkts++);
            if(INFO_MEDIUM) trans_recv.display("PararecvPkt");
            to_scbd.put(trans_recv);
         end
       end
   endtask

/*
   virtual task receive_flit(ref int vc, flit_s RecvFlit);
//      repeat(delay) @(posedge clock);
      //router_if.cb.lout_ready_o = {vchanels{1'b1}};
      wait(router_if != null);
      router_if.cb.lout_ready_o <= 1'b1;

      @(router_if.cb iff | router_if.cb.lout_valid_i);
      {RecvFlit.ftype,RecvFlit.content} = router_if.cb.lout_flit_i;

      for (int i=0;i<vchanels;i=i+1) begin
         if (router_if.cb.lout_valid_i[i]) begin
            vc = i;
            $display("%t received on vc %1d: %x%x",$time,vc,RecvFlit.ftype,RecvFlit.content);
            break;
         end
      end
      router_if.cb.lout_ready_o <= {vchanels{1'b0}};
   endtask:receive_flit
*/   
   virtual task start();
      fork 
         forever receive( );
      join_none
   endtask

endclass
