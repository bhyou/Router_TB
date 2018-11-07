
class Scoreboard #(
 int DEST_WIDTH = 5
);
  string     name;   
  event      DONE;      // flag to indicate goal reached

  Packet     refPkt[$]; // reference Packet array
  Packet     pkt2send;  // Packet object from Drivers 
  Packet     pkt2cmp ;  // Packet object from Receivers

  pkt_mbox   driver_mbox;    // mailbox for Packet objects from Drivers
  pkt_mbox   receiver_mbox;  // mailbox for Packet objects from Receivers


  bit[DEST_WIDTH-1:0]  destX, destY;


  function new(string name="Scoreboard", pkt_mbox driver_mbox = null, pkt_mbox receiver_mbox = null);
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $time, name);
    this.name = name;

    if (driver_mbox == null) driver_mbox = new();
    this.driver_mbox = driver_mbox;

    if(receiver_mbox == null) receiver_mbox = new();
    this.receiver_mbox = receiver_mbox;

  endfunction


  task start();
    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $time, name);
    fork 
      while(1) begin
        this.receiver_mbox.get(this.pkt2cmp);
        while(this.driver_mbox.num()) begin
          Packet pkt;
          this.driver_mbox.get(pkt);
          this.refPkt.push_back(pkt);
        end
//        this.check();
        this.statistic();
      end
    join_none
  endtask

  virtual task check();
    int         index[$];
    string      message;
    static int  pkts_checked = 0;

    if (TRACE_LOW) $display("[TRACE]%t %s:%m", $time, name);

    if(INFO_LOW)  begin
      foreach(refPkt[i])
        this.refPkt[i].display($psprintf("refPkt[%0d]",i) );
    end

    index = this.refPkt.find_last_index() with (item.destX == this.pkt2cmp.destX && item.destY== this.destY);

    if (index.size() <= 0) begin
      $display("\n%m\n[ERROR]%0t %s not found in Reference Queue\n", $time, this.pkt2cmp.name);
      this.pkt2cmp.display("ERROR");
      $finish;
    end

    this.pkt2send = this.refPkt[index[0]];
    this.refPkt.delete(index[0]);

    if (!this.pkt2send.compare(this.pkt2cmp, message)) begin
      $display("\n%m\n[ERROR]%0t Packet #%0d %s\n", $time, pkts_checked, message);
      this.pkt2send.display("ERROR");
      this.pkt2cmp.display("ERROR");
      $finish;
    end

    $display("[NOTE]%t Packet #%0d %s", $realtime, pkts_checked++, message);

    if (pkts_checked >= run_for_n_packets) 
      -> this.DONE;
  endtask: check

  virtual task statistic();
    if(refPkt.size() >= run_for_n_packets)
      -> DONE;
  endtask

endclass
