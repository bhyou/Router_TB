interface serial_inf #(parameter ports = 1)
(input  bit   clk, input bit reset );

// if parallel transfer is used to local port, the Ports valuse shoulde be minus one.


//   parameter VC    = 1;   // virtual chain numbers
   bit                          TRACE = 0;

   logic                        reset_      ;   // reset NoC, when reset = 1
   logic [ports-1:0]            in_sflit_o ;   // Input flit will be received by RXmodule  
   logic [ports-1:0]            in_ready_i ;   // RXmodule can receive new sflit, when in_ready high.
   logic [ports-1:0]            out_sflit_i;   // serial output flit 
   logic [ports-1:0]            out_ready_o;   // TXmodule can transmit sflit, when out_ready high.

   clocking cb @(posedge clk);
     default input #1 output #1;
     output  in_sflit_o ;
     output  out_ready_o;
     input   in_ready_i ;
     input   out_sflit_i;
   endclocking

  modport TB(clocking cb, input reset,import initialize);

  task initialize( string message="");
    if(TRACE) $display("[TRACE]%t,run in %m:%s ", $realtime, message);
    if(reset) begin
      cb.in_sflit_o <= '1;
      cb.out_ready_o <= '1;
    end
  endtask

endinterface

