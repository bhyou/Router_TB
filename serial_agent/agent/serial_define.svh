
typedef enum bit[1:0] { 
   HEADER =2'b01, 
   SINGLE =2'b11, 
   PAYLOAD=2'b00, 
   LAST   =2'b10  
} ftype_s;
                  
typedef enum bit[4:0] {
   SELECT_NONE =0,
   SELECT_NORTH=1,
   SELECT_EAST =2,
   SELECT_SOUTH=4,
   SELECT_WEST =8,
   SELECT_LOCAL=16
} dir_select_s;
                  
typedef struct {
//   ftype_s  ftype;
   bit [1:0]  ftype;
   bit [31:0] content;
} flit_s;

typedef struct {
//   ftype_s  ftype;
   bit [1:0]  ftype;
   bit [31:0] content;
   time       timestamp;
} timeflit_s;

