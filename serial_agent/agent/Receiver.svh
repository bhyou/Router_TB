`include "tx_monitor.svh"

class Receiver#(int ports=2) extends tx_monitor #(.ports(ports));

  pkt_mbox out_box;   //Scoreboard mailbox
  

  function new(string name="Receiver",string hier_info="", int port_id,  pkt_mbox out_box,
               virtual serial_inf#(.ports(ports)).TB  vif);
    super.new(name,hier_info,vif);
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info,name);
    this.target = port_id;
    this.out_box = out_box;
  endfunction

  task start();
    fork 
      forever begin
        this.recv_pkt();
        begin 
          Packet pkt = new pkt2cmp;
          out_box.put(pkt);
        end
      end
    join_none

  endtask
endclass

