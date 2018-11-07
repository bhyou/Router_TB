
class tx_monitor #(
int  ports     =2 ,
int  TYPE_WIDTH=2 ,
int  DATA_WIDTH=32,
int  DEST_WIDTH=9 ,
int  PRIO_WIDTH=4 ,
int  FLIT_SPEC = DATA_WIDTH -2*DEST_WIDTH - PRIO_WIDTH
);
  virtual serial_inf#(.ports(ports)).TB     vif;
  string                 name;
  string                 hier_info;
  
  static int pkt_cnt = 0;
  int                    target = 0;

  logic [DATA_WIDTH-1:0] Header;
  logic [DATA_WIDTH-1:0] pkt2cmp_payload[$];  // actual payload array

  Packet    pkt2cmp;                         // actual Packet object
  event     pkt_end;                         //receive one Packet

  function new(string name="ReceiverBase",string hier_info="", virtual serial_inf#(.ports(ports)).TB  vif);
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info, name);
    this.hier_info = hier_info;
    this.name =  name;
    this.vif = vif;
    this.pkt2cmp = new("RecvPkt");
  endfunction
  
  virtual task recv_pkt();
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info, name);

    this.txMonitor();
//    this.pkt2cmp.dest = Header[DATA_WIDTH-1:DATA_WIDTH-DEST_WIDTH];  // dest
    this.pkt2cmp.destX = Header[DATA_WIDTH-1:DATA_WIDTH-DEST_WIDTH];  // destX
    this.pkt2cmp.destY = Header[DATA_WIDTH-DEST_WIDTH-1:DATA_WIDTH-2*DEST_WIDTH];  // destY
    this.pkt2cmp.prio  = Header[DATA_WIDTH-2*DEST_WIDTH-1:FLIT_SPEC];   // prio
    this.pkt2cmp.flit_spec = Header[FLIT_SPEC-1:0];                  // flit specific
    this.pkt2cmp.payload = pkt2cmp_payload;
    if(INFO_MEDIUM) pkt2cmp.display("recvPkt");
    this.pkt2cmp.name = $psprintf("recvPkt[%0d]", pkt_cnt++); 
  endtask  

  virtual task txMonitor();
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info, name);
    pkt2cmp_payload.delete();
    vif.cb.out_ready_o[target] <= 1;

//    fork 
//      begin: wd_timer_fork
//        fork: flit_wd_timer
//          @(vif.cb) if(vif.cb.out_sflit_i[target]==0); //wait for valid data ack
//          begin
//            repeat(1000) @(vif.cb);
//            $display("\n%m\n[ERROR]%t Flit Ready signal timed out!\n", $realtime);
//            $finish;
//          end
//        join_any:flit_wd_timer
//        disable fork;
//      end: wd_timer_fork
//    join

    forever begin
      bit [DATA_WIDTH+TYPE_WIDTH-1:0] datum;

      @(vif.cb);
      if(vif.cb.out_sflit_i[target] == 0) begin
        if (TRACE_LOW) $display("[TRACE]%t %s %s:%m, reciever start bit", $realtime, hier_info, name);
        for(int i=0; i<DATA_WIDTH+TYPE_WIDTH; i++) begin
           @(vif.cb);
           datum[i] = vif.cb.out_sflit_i[target];
          if (TRACE_LOW) 
            $display("[TRACE]%t %s %s:%m, reciever %0dth %0b", $realtime, hier_info, name, i, vif.cb.out_sflit_i[target]);
        end

        @(vif.cb);
        if(vif.cb.out_sflit_i[target] == 0) begin
           $display("[ERROR] @%t:%m Framing error detecting\n",$time );
        end else begin
           if (TRACE_LOW) $display("[TRACE]%t %s %s:%m, reciever stop bit", $realtime, hier_info, name);

           if(datum[DATA_WIDTH+TYPE_WIDTH-1:DATA_WIDTH]== HEADER)  begin   // header flit
             Header =  datum[DATA_WIDTH-1:0];
             if(INFO_LOW) $display("[mon_if] @%t %s %s:%m Receive Header Flit: 0x%0h! ", $realtime, hier_info, name, datum[DATA_WIDTH-1:0]);
           end else if( datum[DATA_WIDTH+TYPE_WIDTH-1:DATA_WIDTH] == LAST) begin
             if(INFO_LOW) $display("[mon_if] @%t %s %s:%m Receive LAST Flit: 0x%0h! ", $realtime, hier_info, name, datum[DATA_WIDTH-1:0]);
             pkt2cmp_payload.push_back(datum[DATA_WIDTH-1:0]); 
             return;
           end else begin
             if(INFO_LOW) $display("[mon_if] @%t %s %s:%m Receive Flit: 0x%0h! ", $realtime, hier_info, name, datum[DATA_WIDTH-1:0]);
             pkt2cmp_payload.push_back(datum[DATA_WIDTH-1:0]); 
           end
        end
      end
    end 
  endtask

endclass

