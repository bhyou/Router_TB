`timescale 1ns/1ps
module tb_noc_line;
   parameter FLIT_W = 34 ;
   parameter PORTS = 2   ;
   parameter NODES = 300 ;
   parameter Cycle = 10  ;

   reg    SystemCLK ;
   reg    Reset     ;
   event  done_reset;

   serial_inf#(.ports(1))          uart_if(
        .clk(SystemCLK), 
        .reset(Reset)
   );

   serial_inf#(.ports(PORTS-1))    multi_sif[0:NODES-1](
        .clk(SystemCLK), 
        .reset(Reset)
   );

   router_inf                     multi_pif[0:NODES-1](
        .clock(SystemCLK), 
        .reset(Reset)
   );

   test #(
      .ports(PORTS),
      .nodes(NODES)
   )  tb(
     .sing_svif     ( uart_if    ), 
     .multi_svif    ( multi_sif  ), 
     .multi_pvif    ( multi_pif  )
   );

   wire [FLIT_W-1:0]   lout_flit  [0:NODES-1];
   wire                lout_valid [0:NODES-1];
   wire                lout_ready [0:NODES-1];

   wire [FLIT_W-1:0]   lin_flit  [0:NODES-1];
   wire                lin_valid [0:NODES-1];
   wire                lin_ready [0:NODES-1];

   wire                out_sflit  [0:NODES-1];
   wire                out_sready [0:NODES-1];
   wire                in_sflit  [0:NODES-1];
   wire                in_sready [0:NODES-1];

   generate
     for(genvar i=0; i < NODES; i++ )  begin
       assign multi_pif[i].lout_flit_i  = lout_flit[i] ; 
       assign multi_pif[i].lout_valid_i = lout_valid[i];
       assign lout_ready[i] = multi_pif[i].lout_ready_o;
                  
       assign lin_flit[i]   = multi_pif[i].lin_flit_o  ; 
       assign lin_valid[i]  = multi_pif[i].lin_valid_o ; 
       assign multi_pif[i].lin_ready_i  =  lin_ready[i]; 
                  
       assign multi_sif[i].out_sflit_i  =  out_sflit[i];
       assign out_sready[i] = multi_sif[i].out_ready_o ;
       assign multi_sif[i].in_ready_i   =   in_sflit[i];
       assign in_sready[i]  = multi_sif[i].in_sflit_o  ;
     end
   endgenerate

   line #(.PORTS (PORTS)) dut (
      .out_sflit        (  out_sflit   ),
      .out_sready       (  out_sready  ),
      .in_sready        (  in_sflit    ),
      .in_sflit         (  in_sready   ),

      .pop_sflit        (uart_if.out_sflit_i   ),
      .pop_sready       (uart_if.out_ready_o   ),
      .push_sflit       (uart_if.in_ready_i    ),
      .push_sready      (uart_if.in_sflit_o    ),

      // flit parallel transmit
      .lout_flit        ( lout_flit  ), 
      .lout_valid       ( lout_valid ), 
      .lout_ready       ( lout_ready ),
      .lin_flit         ( lin_flit   ),
      .lin_valid        ( lin_valid  ), 
      .lin_ready        ( lin_ready  ), 
      // system sig 
      .clk                 (SystemCLK  ),
      .rst                 (Reset)
   );   

   initial begin
     $timeformat(-9, 1, "ns", 10);
     SystemCLK = 0;
     forever begin
       #(Cycle/2) 
       SystemCLK = ~SystemCLK;
     end
   end
   
   initial begin
//      Reset = 1'b1;
//      #103 Reset = 0;
//      repeat(15) @(posedge SystemCLK);
      Reset = 1'b1;
      repeat(15) @(negedge SystemCLK);
      Reset = 1'b0;
   end

//   initial begin
//     reset();
//   end
/*
   task reset();
     fork 
       uart_if.initialize("line in or out interface");

       foreach(multi_sif[i])
         multi_sif[i].initialize($psprintf("multi-para interface[%d]",i));

       foreach(multi_pif[i])
         multi_pif[i].initialize($psprintf("multi-para interface[%d]",i));

//       for(int i =0; i < NODES; i++) begin 
//         multi_pif[i].initialize($psprintf("multi-para interface[%d]",i));
//       end
     join_none
   endtask
*/
endmodule

