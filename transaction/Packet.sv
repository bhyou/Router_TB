class Packet #(
int  DATA_WIDTH=32,
int  DEST_WIDTH=9,
int  PRIO_WIDTH=4,
int  FLIT_SPEC = DATA_WIDTH -2*DEST_WIDTH - PRIO_WIDTH,
int  vchannels =1
);
   string name;

   rand integer virtualc;
   rand bit [DEST_WIDTH-1:0] self;   // packet source
   rand bit [DEST_WIDTH-1:0] destX;   // Packet destion 
   rand bit [DEST_WIDTH-1:0] destY;   // Packet destion 
        bit [FLIT_SPEC -1:0] flit_spec;   // remaining bit to specific flit info 
   rand bit [DATA_WIDTH-1:0] payload[];
   rand bit [PRIO_WIDTH-1:0] prio;

   constraint Limit { 
      self inside {[0:2]} ;
      destX inside {[0:301]};
      destY inside {[0:301]};
      prio dist { 4'b0000:=1, 4'b1000:= 1, 4'b1100:= 1, 4'b1110:=1, 4'b1111:= 1 }; 
      payload.size() inside {[2:4]}; 
   } 
   constraint valid_vc  { virtualc >= 0; virtualc < vchannels; }


   function new(string name);
     if(TRACE_LOW) $display("[TRACE]%t :%m", $realtime);
     this.name = name;
     this.flit_spec = 0;
   endfunction
   
   function bit compare(Packet pkt2cmp, ref string message);
     if (payload.size() != pkt2cmp.payload.size()) begin
       message = "Payload Size Mismatch:\n";
       message = { message, $psprintf("payload.size() = %0d, pkt2cmp.payload.size() = %0d\n", payload.size(), pkt2cmp.payload.size()) };
       return(0);
     end
     
     if (payload == pkt2cmp.payload) ;
     else begin
       message = "Payload Content Mismatch:\n";
       message = { message, $psprintf("Packet Sent:  %p\nPkt Received: %p", payload, pkt2cmp.payload) };
       return(0);
     end

     message = "Successfully Compared";
     return(1);
   endfunction
   
   function void display(string prefix = "NOTE");
     $display("[%s]%t %s sa = %0h, dX = %0d, dY = %0d, prio = %0h", prefix, $realtime, name, self, destX, destY, prio);
     foreach(payload[i])
       $display("[%s]%t %s payload[%0d] = 0x%0h", prefix, $realtime, name, i, payload[i]);
   endfunction

endclass // packet

