class monitor;

  virtual router_inf router_if;
  string                name;

  function new(string name, virtual router_inf router_if);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.name = name;
    this.router_if = router_if;
  endfunction

  
//   task automatic receive_flit(int vc, flit_t #(type_width, data_width) RecvFlit);
   task automatic receive_flit(int vc, flit_s RecvFlit);
//      repeat(delay) @(posedge clock);
      router_if.cb.out_ready_o <= {`vchannels{1'b1}};

      @(router_if.cb iff | router_if.cb.out_valid_i);
      {RecvFlit.ftype,RecvFlit.content} <= router_if.cb.out_flit_i;

      for (int i=0;i<`vchannels;i=i+1) begin
         if (router_if.cb.out_valid_i[i]) begin
            vc = i;
            $display("%t received on vc %1d: %x%x",$time,vc,RecvFlit.ftype,RecvFlit.content);
            break;
         end
      end
   endtask:receive_flit


endclass
