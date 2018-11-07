`include "rx_driver.svh"

class Driver #(int ports=2 ) extends rx_driver #(.ports(ports));
  mailbox #(Packet) in_box;	// Generator mailbox
  mailbox #(Packet) out_box;	// Scoreboard mailbox
  semaphore sem[];      	// output port arbitration

  function new(string name="Driver", string hier_info="", int port_id, semaphore sem[], 
               pkt_mbox in_box, pkt_mbox out_box, 
               virtual serial_inf#(.ports(ports)).TB  vif);
//  function new(string name="Driver", int port_id, pkt_mbox in_box, pkt_mbox out_box,  virtual serial_inf.TB vif);
    super.new(name,hier_info, vif);
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info,name);
    this.target = port_id;
    this.sem = sem;
    this.in_box = in_box;
    this.out_box = out_box;
  endfunction

  task start();
    fork
      forever begin
        in_box.get(pkt2send);
        this.destX = pkt2send.destX;
        this.destY = pkt2send.destY;
        this.prio = pkt2send.prio;
        this.flit_spec = pkt2send.flit_spec;
        this.payload = pkt2send.payload;
        send();
        sem[this.target].get(1);
        out_box.put(pkt2send);
        sem[this.target].put(1);
      end
    join_none
  endtask

endclass

/*
class Driver extends RX_Driver;
  mailbox #(Packet) in_box;	// Generator mailbox
  mailbox #(Packet) out_box;	// Scoreboard mailbox
  semaphore sem[];      	// output port arbitration

  function new(string name="Driver", int port_id, semaphore sem[], pkt_mbox in_box, out_box, virtual serial_inf.TB vif);
    super.new(name, vif);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $realtime, name);
    this.self = port_id;
    this.sem = sem;
    this.in_box = in_box;
    this.out_box = out_box;
  endfunction

  task start();
    fork 
      forever begin
        in_box.get(pkt2send);
        if(pkt2send.self != this.self) continue;
        this.dest = pkt2send.dest;
        this.dest = 2;
        this.prio = pkt2send.prio;
        this.flit_spec = pkt2send.flit_spec;
        this.payload = pkt2send.payload;
        sem[this.dest].get(1);
        send();
        out_box.put(pkt2send);
        sem[this.dest].put(1);
      end

    join_none
  endtask

endclass

*/


