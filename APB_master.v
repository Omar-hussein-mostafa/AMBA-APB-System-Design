/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//PREPARED BY : OMAR MOHAMED HUSSEIN MOSTAFA
//MODULE      : MASTER 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module APB_master#(parameter DATA_WIDTH=32,parameter SLAVE_NUM=2,parameter MAIN_ADDR_WIDTH=32)
        (transfer,PCLK,PRESET_n,PADDR,PSEL,PENABLE,PWRITE,PWDATA,PSTRB,PREADY,PRDATA,
                APB_RDATA,APB_ADDR,APB_WDATA,APB_STRB,APB_WRITE,APB_PREADY
        );

localparam DATA_BYTE_NUM=DATA_WIDTH/8 ;                  //Default=4 Bytes

//States Encoding
localparam IDLE  =2'b00;
localparam SETUP =2'b01;
localparam ACCESS=2'b10;
// Internal signals for the next and current states
reg [1:0]cs,ns;


//system inputs
input                            PCLK      ;             //system Clock
input                            PRESET_n  ;             //system Reset
//higher request to the master 
input                            transfer  ;             //Transfer signal to instantiate the APB
input                            APB_WRITE ;             //Operation Write or Read
input      [DATA_BYTE_NUM  -1:0] APB_STRB  ;             //Strobe select from the higher logic
input      [DATA_WIDTH     -1:0] APB_WDATA ;             //Data from the higher logic
input      [MAIN_ADDR_WIDTH-1:0] APB_ADDR  ;             //encoming address encodes both the slave select and the byte addressing.
//output from the master to the higher logic
output     [DATA_WIDTH     -1:0] APB_RDATA ;             //output Read data from the master to the higher logic
output                           APB_PREADY;             //output Ready signal to the higher logic
//output from master to the slave
output reg [MAIN_ADDR_WIDTH-1:0] PADDR     ;             //Address sent to the slave in byte addressed style
output reg [DATA_WIDTH     -1:0] PWDATA    ;             //Data transfered to the slave
output reg [DATA_BYTE_NUM  -1:0] PSTRB     ;             //Strobe signal to validate certain DATA input bytes
output reg [SLAVE_NUM      -1:0] PSEL      ;             //Select signal to be decoded to each slave
output reg                       PENABLE   ;             //Enable signal to access the slaves
output reg                       PWRITE    ;             //Operation signal to whether read or write
//input for the master from the slave
input                            PREADY    ;             //Ready signal from the slave to the master to end transfer
input      [DATA_WIDTH     -1:0] PRDATA    ;             //Data read to be sent to the master

assign APB_PREADY=PREADY;                                //Ready signal to be sent to the higher logic
assign APB_RDATA =PRDATA;                                //Data read sent to the higher logic

//output  logic
always @(*) begin
    case(cs)
      IDLE: begin
        {PADDR,PWDATA,PSTRB,PSEL,PENABLE,PWRITE}='b0;  
      end
      SETUP: begin
        //NOTE: THE APB ADDR COMMING FROM THE HIGHER LOGIC CONTAINS  BOTH ADDRESS TO BE  ACCESSED AND THE SELECTED SLAVE  //
        //APB_ADDR ENCODED AS FOLLOWS ------> APB_ADDR={PSELECTION[SLAVE_NUM-1:0],ADDRESS ACCESSED IN THE SLAVES REGISTER}//
        PADDR=APB_ADDR[MAIN_ADDR_WIDTH-1  :0        ];  //Register the 32 bit address
        PSEL =APB_ADDR[MAIN_ADDR_WIDTH-1 -:SLAVE_NUM];  //decode from the ADDR the PSEL based on the SLave num starting from the MSB

        PWDATA =APB_WDATA;                              //register the data to be written
        PENABLE=0;                                      //SETUP ----> PENABLE=0
        if(APB_WRITE) begin
          PSTRB =APB_STRB;                              //register the PSTROBE only in writing phase
        end
        else  begin
          PSTRB ='b0;                                   //STROBES must be zero while reading
        end
        PWRITE =APB_WRITE;                              //register the operation to be implemented
      end
      ACCESS: begin
        PADDR=APB_ADDR[MAIN_ADDR_WIDTH-1  :0        ];  //Register the 32 bit address
        PSEL =APB_ADDR[MAIN_ADDR_WIDTH-1 -:SLAVE_NUM];  //decode from the ADDR the PSEL based on the SLave num starting from the MSB

        PWDATA =APB_WDATA;                              //register the data to be written
        if(APB_WRITE) begin
          PSTRB =APB_STRB;                              //register the PSTROBE only in writing phase
        end
        else  begin
          PSTRB ='b0;                                   //STROBES must be zero while reading
        end
        PWRITE =APB_WRITE;                              //register the operation to be implemented
        PENABLE=1;                                      //ACCESS -----> PENABLE is high
      end
      default:{PADDR,PWDATA,PSTRB,PSEL,PENABLE,PWRITE}='b0;  
    endcase
end

//memory logic
always @(posedge PCLK) begin
    if(!PRESET_n) begin
      cs<=0;
    end
    else begin
      cs<=ns;
    end
end

//next state logic
always @(*) begin
    case(cs) 
        IDLE: begin
            if(!transfer) begin
                ns=IDLE;
            end
            else begin
                ns=SETUP;
            end
        end
        SETUP: ns=ACCESS;
        ACCESS: begin
          if(!PREADY) begin
            ns=ACCESS;
          end
          else if (PREADY && transfer) begin            //Another transfer request
            ns=SETUP;
          end
          else if (PREADY && !transfer) begin           //No other transfers 
            ns=IDLE;
          end
          else begin
            ns=IDLE;
          end
        end
        default : ns=IDLE;
    endcase
end
endmodule