`include "CacheController.v" 

module maintb();

    reg [31:0] memoryAddress_tb; 
    reg[7:0] writeValue_tb;
    reg isWrite_tb;
    reg clk;
    wire [7:0] outputdata_tb;
    
    integer hitno;
    integer totalno;
    
    CacheController c1 (.memoryAddress(memoryAddress_tb),.writeValue(writeValue_tb),.isWrite(isWrite_tb),.outputdata(outputdata_tb),.clk(clk));
    
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0,maintb);
        hitno=0;
        totalno=0;
        clk=0;
        writeValue_tb=9;
        isWrite_tb=0;

        memoryAddress_tb = 32'h02001f81;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        memoryAddress_tb = 32'h02001f71;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        memoryAddress_tb = 32'h02001f41;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        memoryAddress_tb = 32'h02001f51;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        memoryAddress_tb = 32'h02001f71;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        memoryAddress_tb = 32'h02001f41;
        #10;
        clk = ~clk;
        #10;
        clk = ~clk;
        $display("Hits: %d",hitno);
        $display("Total: %d",totalno);
    end
endmodule