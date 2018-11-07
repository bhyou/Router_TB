`timescale 1ns/1ps
program automatic test#(parameter ports =2,parameter nodes=300)( 
   sing_svif, multi_svif, multi_pvif
);
//  serial_inf#(.ports(ports-1)).TB multi_svif[0:nodes-1],
//  serial_inf#(.ports(1)).TB       sing_svif            , 
//  serial_inf#(.ports(1))           sing_svif             ;
//  serial_inf#(.ports(ports-1))     multi_svif[0:nodes-1] ;

  serial_inf.TB           sing_svif             ;
  serial_inf.TB           multi_svif[0:nodes-1] ;

  router_inf.tb            multi_pvif[0:nodes-1] ;

  import serial_pkg::*;
  import router_pkg::*;
  `include "line_env.svh"

  parameter TYPE_WIDTH =  2; 
  parameter DATA_WIDTH = 32; 

//  int      TRACE_ON  =0;
//  int      TRACE_INFO=0;
//  int      TRACE_PKT =1;
   
  line_env #(.ports(ports), .routers(nodes))   env;
  
  
  initial begin
    $display(" the line test formal parameter Ports is %d", ports);
    env = new("line_env", sing_svif, multi_svif,multi_pvif);
//    env.reset();
    env.run();
  end

`ifdef VPD
  initial begin
      $vcdplusfile("router.vpd");
      $vcdpluson;
  end
`endif

endprogram
