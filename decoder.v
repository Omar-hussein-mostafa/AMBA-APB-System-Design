////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MODULE: DECODER
//NOTE  : THIS DECODER IS MADE TO DECODE TO ONLY TWO SLAVES , IF MORE , THE DECODER WILL  NEED MODIFICATIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module decoder #(parameter DATA_WIDTH=32,parameter SLAVE_NUM=2)(PSEL,PSEL0,PSEL1,PRDATA,PRDATA0,PRDATA1,PREADY0,PREADY1,PREADY);


//Master to DECODER
input      [SLAVE_NUM -1:0] PSEL   ;
//DECODER TO SLAVES
output reg                  PSEL0  ;
output reg                  PSEL1  ; 
//SLAVES TO DECODER
input      [DATA_WIDTH-1:0] PRDATA0;
input      [DATA_WIDTH-1:0] PRDATA1;
input                       PREADY0;
input                       PREADY1;
//DECODER TO MASTER
output reg                  PREADY ;
output reg [DATA_WIDTH-1:0] PRDATA ;


always @(*) begin
    case (PSEL)
        2'h1 :  begin
            PSEL0=1;
            PSEL1=0;
            PRDATA=PRDATA0;
            PREADY=PREADY0;
        end
        2'h2 : begin
            PSEL0=0;
            PSEL1=1;
            PRDATA=PRDATA1;
            PREADY=PREADY1;
        end
        default: begin
            PSEL0=0;
            PSEL1=0;
            PRDATA=0;
            PREADY=0;
        end
    endcase
end
endmodule