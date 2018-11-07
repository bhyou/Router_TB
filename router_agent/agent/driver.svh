class driver;
  virtual router_inf router_if;
  string                name;

  function new(string name, virtual router_inf router_if);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.name = name;
    this.router_if = router_if;
  endfunction

//  task automatic send_flit(int vc, flit_t #(type_width,data_width) SendFlit);
  task automatic send_flit(int vc, flit_s SendFlit);
      @(router_if.cb iff router_if.cb.in_ready_i[vc]) begin
        router_if.cb.in_valid_o[vc] <= 1'b1;
        router_if.cb.in_flit_o <= {SendFlit.ftype, SendFlit.content};
//      router_if.cb.in_flit_o[data_width+type_width-1:type_width] = SendFlit.content;
//      router_if.cb.in_flit_o[type_width-1:0] = SendFlit.ftype;
        @(router_if.cb);
      end
      router_if.cb.in_valid_o[vc] <= 1'b0;
      $display("%t sent on vc %1d: %x%x",$time,vc,SendFlit.ftype,SendFlit.content);
   endtask:send_flit

endclass
