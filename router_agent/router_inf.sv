`include "router_define.svh"

interface router_inf#(type_width=2,data_width=32,vchannels=1)
         (input bit clock, input bit  reset);
  
  // testbench to dut, regard as a monitor of dut
  logic [data_width+type_width-1:0]  lout_flit_i;
  logic                              lout_valid_i;
  logic                              lout_ready_o;

  // driver dut
  logic [data_width+type_width-1:0]  lin_flit_o;
  logic                              lin_valid_o;
  logic                              lin_ready_i;
   
  int             act_edge;     // 2: negative edge 1: posi tive edge
  bit             TRACE_LOW = 0;
  bit             INFO = 1;

  clocking cb @(posedge clock);
     default input #1 output #1;
     // for monitor
     input      lout_flit_i ;
     input      lout_valid_i;
     output     lout_ready_o;
     // for driver
     output     lin_flit_o  ;
     output     lin_valid_o ;
     input      lin_ready_i ;
  endclocking

  modport tb(clocking cb, import initialize, sendFlit, receiveFlit  );
  
  task automatic sendFlit( string message="", logic [type_width+data_width-1:0] flit);
      if(TRACE_LOW) $display("@%t,run in %m ", $realtime);
      lin_valid_o = 1'b1;
      lin_flit_o = flit;
      #1;
      lin_valid_o = 1'b1;
      @(posedge clock iff lin_ready_i);
       if(INFO) $display("[drv_if]%t sent %x-%x",$realtime,flit[type_width+data_width-1:data_width] ,flit[data_width-1:0]);
      else $display("waiting %s's lin_ready_i ready!", message);
      lin_valid_o = 1'b0;
   endtask:sendFlit

   task automatic receiveFlit( ref logic [type_width+data_width-1:0] RecvFlit);
      if(TRACE_LOW)  $display("[TRACE]%t,run in %m ", $realtime); 
//      repeat(delay) @(posedge clock);
     lout_ready_o = 1'b1;

//     @(posedge clock iff lout_valid_i);
     @(posedge clock);
     if(lout_valid_i) begin
        RecvFlit = lout_flit_i;
        if(INFO) $display("[mon_if]%t received %x-%x",$time,RecvFlit[type_width+data_width-1:data_width],RecvFlit[data_width-1:0]);
     end
     else             RecvFlit = 0;

   endtask:receiveFlit

   task initialize( string message="");
     if(TRACE_LOW) $display("[TRACE]%t run in %m: %s", $realtime, message);
     if(reset) begin
       lin_flit_o   = 0;
       lin_valid_o  = 0;
       lout_ready_o = 1;
     end
   endtask
/*
   task automatic receive_flit(ref int vc, flit_t #(type_width, data_width) RecvFlit);
//   task automatic receive_flit(int vc, flit_s RecvFlit);
//      repeat(delay) @(posedge clock);
      lout_ready_o = {vchannels{1'b1}};

      @(posedge clock iff | lout_valid_i);
      {RecvFlit.ftype,RecvFlit.content} = lout_flit_i;

      for (int i=0;i<vchannels;i=i+1) begin
         if (lout_valid_i[i]) begin
            vc = i;
            $display("%t received on vc %1d: %x%x",$time,vc,RecvFlit.ftype,RecvFlit.content);
            break;
         end
      end
      lout_ready_o = {vchannels{1'b0}};
   endtask:receive_flit

  task automatic send_flit(int vc, flit_t #(type_width,data_width) SendFlit);
//  task automatic send_flit(int vc, flit_s SendFlit);
//      repeat(delay) @(posedge clock);
      lin_valid_o[vc] = 1'b1;
      lin_flit_o[data_width+type_width-1:type_width] = SendFlit.content;
      lin_flit_o[type_width-1:0] = SendFlit.ftype;
      #1;
      lin_valid_o[vc] = 1'b1;
      @(posedge clock iff lin_ready_i[vc]);
      $display("%t sent on vc %1d: %x%x",$time,vc,SendFlit.ftype,SendFlit.content);
      lin_valid_o[vc] = 1'b0;
   endtask:send_flit
*/
endinterface
