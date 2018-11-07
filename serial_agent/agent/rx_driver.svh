`ifndef INC_RX_DRIVER_SV
`define INC_RX_DRIVER_SV

class rx_driver #(
  int ports     =2 , 
  int TYPE_WIDTH=2 ,
  int DATA_WIDTH=32,
  int DEST_WIDTH=5 , // mean: there are 2^DEST_WIDTH = 2^5 = 32 destination
  int PRIO_WIDTH=4 ,
  int FLIT_SPEC =DATA_WIDTH - 2*DEST_WIDTH - PRIO_WIDTH  // remaining header, = 32 - 5 - 4 = 23
);

  virtual serial_inf#(.ports(ports)).TB  vif;   //
  string               name;
  string               hier_info;  // display  hierarchical name

  int                  target;     //target port

  bit [DEST_WIDTH-1:0] destX,destY;
  bit [PRIO_WIDTH-1:0] prio;
  bit [FLIT_SPEC-1:0]  flit_spec; // flit specific info

  logic [DATA_WIDTH-1:0] payload[$]; 

  Packet                pkt2send; // stimulus Packet object

  function new(string name="DriverBase", string hier_info, virtual serial_inf#(.ports(ports)).TB  vif);
    if (TRACE_LOW) $display("[TRACE]%t %s %s:%m", $realtime, hier_info,name);
    this.name = name;
    this.hier_info = hier_info;
    this.vif = vif;
  endfunction
  
  // send one Packet 
  virtual task send();

    if (TRACE_HIGH) $display("[TRACE]%t %s %s:send() sa = %0h, dX = %0h, dY = %0h", 
                              $realtime, hier_info, name, target,this.destX,this.destY);

    // Header Flit
    send_flit(HEADER, {this.destX, this.destY, this.prio, this.flit_spec});  
    // Payload Flit
    foreach(payload[index]) begin
      send_flit(PAYLOAD, payload[index]); 
    end
    send_flit(LAST, $random);  

  endtask

  // send one flit to interface
  virtual task send_flit(input bit[TYPE_WIDTH-1:0] ftype, input [DATA_WIDTH-1:0] content );

    if (TRACE_HIGH) $display("[TRACE]%t @%s %s:send_flit, ftype = %0b, content = 0x%0h",
                             $realtime,hier_info, name, ftype, content);

    @(vif.cb); 
    if(vif.cb.in_ready_i[target]) begin
      vif.cb.in_sflit_o[target] <= 1'b0;    @(vif.cb); //start bit
      if(TRACE_LOW) $display("[TRACE]%t %s %s::%m  Send Start bit" , $realtime,hier_info, name );

      for(int i=0; i <(DATA_WIDTH+TYPE_WIDTH); i++ ) begin
         if(i < DATA_WIDTH ) begin
            vif.cb.in_sflit_o[target] <= content[i];
            if(TRACE_LOW) $display("[TRACE]%t %s::%m Send %0dth bit %0b", $realtime, hier_info, name, i, content[i] );
         end else begin
            vif.cb.in_sflit_o[target] <= ftype[i-DATA_WIDTH];
            if(TRACE_LOW) $display("[TRACE]%t %s::%m Send %0dth bit %0b", $realtime, hier_info, name, i, ftype[i-DATA_WIDTH] );
         end
         @(vif.cb);
      end
       
      vif.cb.in_sflit_o[target] <= 1'b1; @(vif.cb); //stop bit
      if(TRACE_LOW) $display("[TRACE]%t %s %s::%m  Send Stop bit ", $realtime, hier_info, name );
    end else begin
      $display("[Error]%t %s:%s in_ready_i port not ready!", $realtime, hier_info, name); 
    end
  endtask


endclass
`endif
