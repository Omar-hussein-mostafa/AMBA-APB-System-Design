///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE   : RAM MEMORY Slave 
//SLAVE_NUM: ZERO
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module MEM_slave#(parameter DATA_WIDTH=32 , parameter RAM_DEPTH=64,parameter MAIN_ADDR_WIDTH=32)(
  PCLK,PRESET_n,PADDR,PSEL,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA
  );

localparam DATA_BYTE_NUM      = DATA_WIDTH/8                        ;   //Default=4 Bytes
localparam BYTE_ENCODING_BITS = $clog2(DATA_BYTE_NUM)               ;   //Default=2 bits
localparam RAM_ADDR_WIDTH     = BYTE_ENCODING_BITS+$clog2(RAM_DEPTH);   //Default=2 bits + 6 bits = 8 bits

//INPUTS TO THE SLAVE
input [MAIN_ADDR_WIDTH-1:0] PADDR    ;               //32 bit Address coming from the master encoded in byte address style 
input [DATA_WIDTH     -1:0] PWDATA   ;               //32 Data to be written in the MEMORY
input [DATA_BYTE_NUM  -1:0] PSTRB    ;               //Strobe signal to select the valid input bytes to be written
input                       PCLK     ;               //System Clock
input                       PRESET_n ;               //System Reset
input                       PSEL     ;               //Select signal to activate the Slave
input                       PENABLE  ;               //Enable signal to allow the Access of the Slave
input                       PWRITE   ;               //Write/Read signal to control the operation whether read or write
integer i;

//OUTPUTS FROM THE SLAVE
output reg [DATA_WIDTH-1:0] PRDATA;
output reg                  PREADY;

//======================Decoding the PADDR as it's Byte addressed not word addressed=====================// 
//=======================PADDR[PSelection,word_addr,bytes location to be accessed]=======================//
wire [RAM_ADDR_WIDTH-BYTE_ENCODING_BITS-1:0] word_addr;               //Default [8-2-1:0] -> [5:0] -> 6  bits
assign word_addr= PADDR[RAM_ADDR_WIDTH -1:BYTE_ENCODING_BITS];        //Default [7    :2] ----------> 6  bits
reg  [DATA_WIDTH                       -1:0] temp_data;               //Default [31   :0] ----------> 32 bits
reg flag;                                                             //Flag asserted when Data is written

reg [DATA_WIDTH-1:0]MEM[RAM_DEPTH-1:0];                               //MEMORY RAM With 64 word each of 32 bits

always @(posedge PCLK) begin
    if(!PRESET_n) begin
      {PREADY,PRDATA,flag,temp_data} <= 'b0;
    end
    else begin
      PREADY<=0;
      if(PSEL) begin
        temp_data<=MEM[word_addr];
        if(PENABLE) begin
          if(PWRITE) begin
            PREADY<=0;
            if(!flag) begin
            for(i=0;i<=DATA_BYTE_NUM-1;i=i+1) begin
              if(PSTRB[i]) begin
               temp_data[i*8 +:8] <= PWDATA[i*8 +:8];
              end
            end
            PREADY<=1;
            flag<=1;
            end
            else begin
              MEM[word_addr]<=temp_data;
              flag<=0;
              PREADY<=0;
            end
          end
          else  begin
            PREADY<=1;
            PRDATA<=MEM[word_addr];
          end
        end
      end
    end
end
endmodule