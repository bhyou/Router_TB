`timescale 1ns/100ps

package serial_pkg;
//  static int TRACE_LOW = 1;
//
//  static int INFO_LOW = 1;
//  static int INFO_MEDIUM = 1;
//
//  static int REPORT_LOW = 1;
//  static int run_for_n_packets = 10;
  int TRACE_LOW = 0;
  int TRACE_HIGH = 1;

  int INFO_LOW = 0;
  int INFO_MEDIUM = 1;

  int REPORT_LOW = 1;
  int run_for_n_packets = 10;
  `include  "Packet.sv"
  typedef mailbox #(Packet) pkt_mbox;
  `include  "serial_define.svh"
  `include  "serial_sequnce.svh"
  `include  "Driver.svh"
  `include  "Receiver.svh"
  `include  "Scoreboard.svh"
  `include  "serial_agent.svh"

endpackage
