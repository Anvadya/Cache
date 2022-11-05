module MainMemory(
    input wire [31:0] Address,
    input wire [7:0] Data,
    input wire [0:0] isWrite,

    output wire [7:0] outputdata
);

reg [7:0] Address_last8bits;

always @(*) begin
    if(isWrite) begin
        $display("Write executed");
        Address_last8bits <= 8'd0; // Default
    end
    else begin
        $display("Read executed");
        Address_last8bits <= Address[7:0] ;
    end
end

assign outputdata = Address_last8bits;

endmodule