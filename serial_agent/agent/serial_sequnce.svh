class serial_sequence #(
   int PORT = 3
);
  string name;        //unique identifer
  string  hier_info;        //unique identifer
  Packet pkt2send;    // stimulus Packet object
  pkt_mbox out_box[]; // mailbox to Drivers

  function new(string name="Generator", string hier_info="");
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info, name);
    this.name = name;
    this.hier_info = hier_info;
    this.pkt2send = new("Packet2Send");
    this.out_box = new[PORT];
    foreach(this.out_box[i])
      this.out_box[i] = new();
  endfunction

  virtual task gener();
    static int pkts_generated = 0;
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info, name);

    pkt2send.name = $psprintf("Packet[%0d]",pkts_generated++);

    if (!pkt2send.randomize()) begin
      $display("\nn%m\n[ERROR]%t Randomization Failed!\n", $realtime);
      $finish;
    end
  endtask

  virtual task start();
    Packet pkt;
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, this.hier_info, this.name);
    fork
      repeat(run_for_n_packets) begin
        this.gener();
        begin
          pkt = new this.pkt2send;
          if(INFO_MEDIUM) $display("[TRACE]%t %s %s:start() generate Pkt!", $realtime, this.hier_info, this.name);
          if(INFO_MEDIUM) pkt2send.display("SerilPkt");
          this.out_box[pkt.self].put(pkt);
        end 
      end 
    join_none
 endtask
endclass
