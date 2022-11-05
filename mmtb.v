`include "MainMemory.v"
module mmtb();

reg [31:0] Address;
reg [7:0] Data;
reg [0:0] isWrite;

wire [7:0] outputdata;

MainMemory mm(.Address(Address),.Data(Data),.isWrite(isWrite),.outputdata(outputdata));

initial begin
    Address = 32'd6;
    Data = 8'd3;
    isWrite = 1'b0;
    #10;
    $display("Address = %b",Address);
    $display("Output = %b",outputdata);
end

endmodule