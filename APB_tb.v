module APB_tb();

reg  PCLK,PRESET_n,transfer,WRITE;
reg  [31:0] WDATA ;
reg  [3 :0] STRB  ;
reg  [31:0] ADDR  ;
wire [31:0] RDATA ;

APB_Wrapper #(32,64,2,32)DUT(PCLK,ADDR,WDATA,RDATA,PRESET_n,transfer,WRITE,READY,STRB);

initial begin
    PCLK=0;
    forever begin
        #10 PCLK=!PCLK;
    end
end

initial begin
    $readmemh("MEM.dat",DUT.MEM_SLAVE.MEM);
end

initial begin
//Reset assign
    PRESET_n=0;
    @(negedge PCLK);
    PRESET_n=1;
    {ADDR,WDATA,transfer,WRITE,STRB}='b0;
    repeat(2) @(negedge PCLK);
//Transfer and instantiating the MEM_slave
    transfer=1;
    ADDR=32'h4000000c;                          //select MEM , ADDRESS=c ---> word addr=3
    WRITE=1;                                    // Write operation
    WDATA=32'habcdef12;                         //Data to be written
    STRB=4'b1101;                               //validate only this bytes
    repeat(1) @(negedge PCLK);                  //now we are at SETUP
    transfer=0;                                 //to make state resets after transfer
    repeat(3) @(negedge PCLK);                  //ACCESS then the transfer ends
    transfer=1;                                 //again another transfer
    WRITE=0;                                    //Read operation , same address before so we predict abcd0012 to be out
    repeat(1) @(negedge PCLK);                  //now we are setup
    transfer=0;                                 //to make state resets after transfer
    repeat(3) @(negedge PCLK);                  //ACCESS then the transfer ends
    transfer=1;                                 //again another transfer
    ADDR=32'h40000008;                          //select MEM , ADDRESS=8 ---> word addr=2 
    WRITE=1;                                    //Write operation
    WDATA=32'hab777777;                         //write data
    STRB=4'b1011;                               //validate only this bytes
    repeat(1) @(negedge PCLK);                  //now we are at SETUP
    transfer=0;                                 //to make state resets after transfer
    repeat(3) @(negedge PCLK);                  //ACCESS then the transfer ends
    transfer=1;                                 //transfer 
    WRITE=0;                                    //Read operation
    repeat(1) @(negedge PCLK);                  //now setup
    transfer=0;                                 //to make state resets after transfer
    repeat(3) @(negedge PCLK);                  
    transfer=1;                                 //transfer 
    ADDR=32'h80000008;                          //now the timer slave activated , address points about reload value
    WDATA=32'h0000000a;                         //Reload value a to timer
    STRB=4'b1111;                               //validate all the data in
    WRITE=1;                                    //write opration
    repeat(1) @(negedge PCLK);                  //setup state
    transfer=0;                                 //to make state resets after transfer
    repeat(2) @(negedge PCLK);                  //ACCESS then end transfer
    PRESET_n=0;                                 //Resets to reload the timer
    @(negedge PCLK);                            //wait pos edge clk
    PRESET_n=1;                                 //remove resets
    transfer=1;                                 //transfer
    ADDR=32'h80000000;                          //Timer slave activated ,address points to enable timer 
    WDATA={28'b0,4'b1001};                      //write data to enables interrupt and and timer
    STRB=4'b1111;                               //validate data input
    WRITE=1;                                    //write operation
    repeat(1) @(negedge PCLK);                  //now setup state
    transfer=0;                                 //to make state resets after transfer
    repeat(2) @(negedge PCLK);                  //ACCESS then end transfer
    transfer=1;                                 //transfer
    ADDR=32'h80000004;                          //Timer slave activated ,address points to enable Timer value
    WDATA=32'h0000000a;                         //dumy bits
    STRB=4'b0000;                               //don't validate input                               
    WRITE=0;                                    //read the data
    repeat(3) @(negedge PCLK);                  //Setup access then end transfer
    transfer=1;                                 //transfer
    repeat(5) @(negedge PCLK);                  //read multiple times the timer value
    repeat(1) @(negedge PCLK);                  //Setup access then end transfer
    ADDR=32'h8000000c;                          //address points at interrupt state
    WDATA=32'h0000000a;                         //dumy bits
    STRB=4'b0000;                               //Don't validate inputs  
    WRITE=0;                                    //Read data                                 
    transfer=1;
    repeat(4) @(negedge PCLK);                  //access then end transfer
    transfer=1;
    // @(negedge PCLK);
    $stop;
end
endmodule