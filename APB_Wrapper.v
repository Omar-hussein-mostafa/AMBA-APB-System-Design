/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
//                                                       <------------------------                                   //
//                                                       |         ----------> SLAVE0                                //
//              HIGHER_LOGIC <---------> MASTER <--------> DECODER -                                                 //
//                                                       |         ----------> SLAVE1                                //
//                                                       <------------------------                                   //
//                                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module APB_Wrapper#(parameter DATA_WIDTH=32 , parameter RAM_DEPTH=64,parameter SLAVE_NUM=2,parameter MAIN_ADDR_WIDTH=32)
                        (PCLK,ADDR,WDATA,RDATA,PRESET_n,transfer,WRITE,READY,STRB);

localparam DATA_BYTE_NUM      = DATA_WIDTH/8;
localparam BYTE_ENCODING_BITS = $clog2(DATA_BYTE_NUM);       //Default=2 bits

//Inputs from the Higher Logic to MASTER
input                          PCLK    ;
input                          PRESET_n;
input                          transfer;
input                          WRITE   ;
input [DATA_WIDTH        -1:0] WDATA   ;
input [DATA_BYTE_NUM     -1:0] STRB    ;
input [MAIN_ADDR_WIDTH   -1:0] ADDR    ;

//Outputs to the Higher logic FROM MASTER
output[DATA_WIDTH        -1:0] RDATA   ;
output                         READY   ;

//MASTER WIRES WITH DECODER
wire  [SLAVE_NUM         -1:0] PSEL    ;
wire  [DATA_WIDTH        -1:0] PRDATA  ;
wire                           PREADY  ;

//SLAVE0 with the DECODER
wire                           PSEL0   ;
wire                           PREADY0 ;
wire  [DATA_WIDTH        -1:0] PRDATA0 ;

//SLAVE1 with the DECODER
wire                            PSEL1  ; 
wire                           PREADY1 ;
wire  [DATA_WIDTH        -1:0] PRDATA1 ;

//MASTER with both slaves
wire  [MAIN_ADDR_WIDTH    -1:0] PADDR   ;
wire  [DATA_WIDTH         -1:0] PWDATA  ;
wire  [DATA_BYTE_NUM      -1:0] PSTRB   ;
wire                            PENABLE ;
wire                            PWRITE  ;

APB_master #(DATA_WIDTH,SLAVE_NUM,MAIN_ADDR_WIDTH)MASTER(
        .transfer(transfer)
        ,.PCLK(PCLK)
        ,.PRESET_n(PRESET_n)
        ,.PADDR(PADDR)
        ,.PSEL(PSEL)
        ,.PENABLE(PENABLE)
        ,.PWRITE(PWRITE)
        ,.PWDATA(PWDATA)
        ,.PSTRB(PSTRB)
        ,.PREADY(PREADY)
        ,.PRDATA(PRDATA)
        ,.APB_RDATA(RDATA)
        ,.APB_ADDR(ADDR)
        ,.APB_WDATA(WDATA)
        ,.APB_STRB(STRB)
        ,.APB_WRITE(WRITE)
        ,.APB_PREADY(READY));

MEM_slave  #(DATA_WIDTH,RAM_DEPTH,MAIN_ADDR_WIDTH) MEM_SLAVE (
         .PCLK(PCLK)
        ,.PRESET_n(PRESET_n)
        ,.PADDR(PADDR)
        ,.PSEL(PSEL0)
        ,.PENABLE(PENABLE)
        ,.PWRITE(PWRITE)
        ,.PWDATA(PWDATA)
        ,.PSTRB(PSTRB)
        ,.PREADY(PREADY0)
        ,.PRDATA(PRDATA0));
Timer_slave #(DATA_WIDTH,MAIN_ADDR_WIDTH) TIMER (
         .PCLK(PCLK)
        ,.PRESET_n(PRESET_n)
        ,.PADDR(PADDR)
        ,.PSEL(PSEL1)
        ,.PENABLE(PENABLE)
        ,.PWRITE(PWRITE)
        ,.PWDATA(PWDATA)
        ,.PSTRB(PSTRB)
        ,.PREADY(PREADY1)
        ,.PRDATA(PRDATA1));
decoder #(DATA_WIDTH,SLAVE_NUM) DECODER(
    .PSEL(PSEL),
    .PSEL0(PSEL0),
    .PSEL1(PSEL1),
    .PRDATA(PRDATA),
    .PRDATA0(PRDATA0),
    .PRDATA1(PRDATA1),
    .PREADY0(PREADY0),
    .PREADY1(PREADY1),
    .PREADY(PREADY)
);
endmodule
