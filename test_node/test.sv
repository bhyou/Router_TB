`timescale 1ns/1ps
//program automatic test#(parameter ports=2)(serial_inf.TB svif, router_inf.tb pvif);
program automatic test#(parameter ports=2)(svif, pvif);

  serial_inf                      svif[0:ports-1]; 
  router_inf                      pvif;

  import serial_pkg::*;
  import router_pkg::*;
  `include "router_env.svh"

  parameter TYPE_WIDTH =  2; 
  parameter DATA_WIDTH = 32; 

  int             TRACE_ON  =0;
  int             TRACE_INFO=0;
  int             TRACE_PKT =1;
  
  router_env#(.ports(ports))    env;

  initial begin
    env = new("router_env", svif, pvif);
    env.run();
  end

`ifdef VPD
  initial begin
      $vcdplusfile("router.vpd");
      $vcdpluson;
  end
`endif

endprogram
