/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE   : TIMER Slave 
//SLAVE_NUM: ONE
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Timer_slave#(parameter DATA_WIDTH=32,parameter MAIN_ADDR_WIDTH=32)(
        PCLK,PRESET_n,PADDR,PSEL,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA   
        );

localparam DATA_BYTE_NUM      = DATA_WIDTH/8                ;       //Default=4 Bytes
localparam BYTE_ENCODING_BITS = $clog2(DATA_BYTE_NUM)       ;       //Default=2 bits
localparam TIMER_ADDR_WIDTH   = BYTE_ENCODING_BITS+$clog2(4);       //Default=2 bits + 2 bits = 4 bits

//INPUTS TO THE SLAVE
input [MAIN_ADDR_WIDTH-1:0]   PADDR      ;                          //32 bit Address coming from the master encoded in byte address style
input [DATA_WIDTH-1     :0]   PWDATA     ;                          //32 Data to be written
input [DATA_BYTE_NUM-1  :0]   PSTRB      ;                          //Strobe signal to select the valid input bytes to be written
input                         PCLK       ;                          //System Clock
input                         PRESET_n   ;                          //System Reset
input                         PSEL       ;                          //Select signal to activate the Slave
input                         PENABLE    ;                          //Enable signal to allow the Access of the Slave
input                         PWRITE     ;                          //Write/Read signal to control the operation whether read or write        
integer i;

//OUTPUTS FROM THE SLAVE
output reg [DATA_WIDTH-1:0]   PRDATA     ;                          //32 bit output going to the selector
output reg                    PREADY     ;                          //Ready  signal going to the selector

//internal Address states of the timer
localparam CNTRL =4'h0;
localparam VALUE =4'h4;
localparam RELOAD=4'h8;
localparam INT   =4'hc;

//Timer signals 
reg [DATA_WIDTH-1:0]          TIMER_VALUE ;                         //the timer countdown value
reg [DATA_WIDTH-1:0]          TIMER_RELOAD;                         //the timer reload values to start from
reg                           INT_EN      ;                         //the timer interrupt enable signal 
reg                           EXT_CLK     ;                         //external timer used when EXT_CLK is activated
reg                           EXT_EN      ;                         //external enable used when EXT_EN is activated
reg                           TIMER_EN    ;                         //timer enable signal driven by the master
reg                           INT_STATUS  ;                         //indicates the timer state
//INT_STATUS--->indicates when reading  whether counting down or the timer has finished, while when writing it resets the state// 

//Always block for the interferance with the master
always @(posedge PCLK) begin
    if(!PRESET_n) begin
      PREADY <=0  ;
      PRDATA <='b0;
      {INT_EN,EXT_CLK,EXT_EN,TIMER_EN}<='b0;
    end
    else  begin
        if(PSEL) begin
            PREADY<=1;  
            if(PENABLE) begin
                PREADY<=0;  
              if (PWRITE) begin
                case(PADDR[TIMER_ADDR_WIDTH-1:0])                   //only these bits we are looking for
                    CNTRL: begin
                        if(PSTRB[0]) begin
                            {INT_EN,EXT_CLK,EXT_EN,TIMER_EN}<=PWDATA[3:0];
                        end
                    end
                    VALUE: begin
                      for(i=0;i<=DATA_BYTE_NUM-1;i=i+1) begin
                          if(PSTRB[i]) begin
                           TIMER_VALUE[i*8 +:8] <= PWDATA[i*8 +:8];
                          end
                        end
                    end
                    RELOAD: begin
                      for(i=0;i<=DATA_BYTE_NUM-1;i=i+1) begin
                          if(PSTRB[i]) begin
                           TIMER_RELOAD[i*8 +:8] <= PWDATA[i*8 +:8];
                          end
                        end
                    end
                    INT: begin
                      if(PSTRB[0]) begin
                        if(PWDATA[0]) begin
                            INT_STATUS<=PWDATA[0];
                        end
                      end
                    end
                endcase
              end
              else begin
                case(PADDR[TIMER_ADDR_WIDTH-1:0])
                    CNTRL : PRDATA     <={28'b0,INT_EN,EXT_CLK,EXT_EN,TIMER_EN};
                    VALUE : PRDATA     <=TIMER_VALUE ;
                    RELOAD: PRDATA     <=TIMER_RELOAD;
                    INT   : PRDATA     <=INT_STATUS  ;
                endcase
              end
            end
        end
        else begin
        end
    end
end

// Timer always block //
always @(posedge PCLK) begin
    if(!PRESET_n) begin
        TIMER_VALUE<=TIMER_RELOAD;              //Reload the timer 
        INT_STATUS <=0;                         //Reload the state signal
    end
    else begin
        if(TIMER_EN) begin
            if(TIMER_VALUE !='d0) begin
                TIMER_VALUE<=TIMER_VALUE-1;    //Normal counting down
                INT_STATUS <=0;                //timer hasn't finished
            end
            else begin
                if(INT_EN) begin
                    INT_STATUS <=1;            //the timer has finished now
                end
            end
        end
    end     
end
endmodule