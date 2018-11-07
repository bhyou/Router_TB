`timescale 1ns/1ps
module tb_noc_router;
   parameter Cycle = 10 ;
   parameter PORTS = 2  ;  // serial ports number

//   `define parall_only

   reg  SystemCLK;
   reg  Reset;


   serial_inf                 uart_if[0:PORTS-1](SystemCLKi, Reset);
   router_inf                 local_if(SystemCLK, Reset);

   test#(.ports(PORTS)) tb(uart_if, local_if);

`ifdef uart_only
   lisnoc_router_2dgrid_serial uut0(
      .out_sflit_o         (uart_if.out_sflit_i),
      .out_sready_i        (uart_if.out_ready_o),
      // flit input dirction
      .in_sready_o         (uart_if.in_ready_i),
      .in_sflit_i          (uart_if.in_sflit_o),
      // system sig 
      .clk                 (SystemCLK),
      .rst                 (Reset)
   );   
`elsif parall_only

   router_2dgrid #(
      .ports(PORTS),
      .xaddr(XADDR),
      .yaddr(YADDR)
   )  uut0(
      .out_sflit_o         (     ),
      .out_sready_i        (     ),
      // flit input dirction     
      .in_sready_o         (     ),
      .in_sflit_i          (     ),

      .local_out_flit_o    (local_if.lout_flit_i ), 
      .local_out_valid_o   (local_if.lout_valid_i), 
      .local_out_ready_i   (local_if.lout_ready_o),
      .local_in_flit_i     (local_if.lin_flit_o  ),
      .local_in_valid_i    (local_if.lin_valid_o ), 
      .local_in_ready_o    (local_if.lin_ready_i ), 
      // system sig 
      .clk                 (SystemCLK ),
      .rst                 (Reset)
   );   

`else 

   router_2dgrid uut0(
      .out_sflit_o         (uart_if.out_sflit_i),
      .out_sready_i        (uart_if.out_ready_o),
      // flit input dirction
      .in_sready_o         (uart_if.in_ready_i),
      .in_sflit_i          (uart_if.in_sflit_o),

      .local_out_flit_o    (local_if.lout_flit_i ), 
      .local_out_valid_o   (local_if.lout_valid_i), 
      .local_out_ready_i   (local_if.lout_ready_o),
      .local_in_flit_i     (local_if.lin_flit_o  ),
      .local_in_valid_i    (local_if.lin_valid_o ), 
      .local_in_ready_o    (local_if.lin_ready_i ), 
      // system sig 
      .clk                 (uart_if.clk  ),
      .rst                 (uart_if.reset)
   );   

`endif

   initial begin
     $timeformat(-9, 1, "ns", 10);
     SystemCLK = 0;
     forever begin
       #(Cycle/2) 
       SystemCLK = ~SystemCLK;
     end
   end

   initial begin
      Reset = 1'b1;
      #103 Reset = 0;
      repeat(15) @(posedge SystemCLK);
      Reset = 1'b1;
      repeat(15) @(posedge SystemCLK);
      Reset = 1'b0;
   end

   task sendflit();      
     local_if.sendFlit( {2'b01,$random} );   //virtual channel,  header, content
     repeat(10)
       local_if.sendFlit( {2'b00,$random} );   // payload
     local_if.sendFlit( {2'b10,$random} );   // last
   endtask


endmodule

