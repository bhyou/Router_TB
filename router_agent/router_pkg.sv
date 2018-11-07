`timescale 1ns/100ps

package router_pkg;
//  static int TRACE_LOW =1;
//  static int INFO_LOW = 1;
//  static int INFO_MEDIUM = 0;
//  static int REPORT_LOW = 1;
//  static int DEBUG_LOW = 1;
//  static int pkt_nums =10;

  int TRACE_LOW =0;
  int TRACE_MEDIUM = 1;
  int INFO_LOW = 1;
  int INFO_MEDIUM = 1;
  int REPORT_LOW = 1;
//  static int DEBUG_LOW = 1;
  int router_run_pkts =10;
  `include "Packet.sv"
  //`define trans_mbox   mailbox #(router_transaction) 
  typedef mailbox#(Packet)  trans_mbox;
  `include "router_define.svh" 
  `include "router_sequence.svh"
  `include "router_drv.svh"
  `include "router_mon.svh"
  `include "router_scbd.svh"
  `include "router_agent.svh"

endpackage
