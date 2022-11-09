`include "MainMemory.v"

module CacheController(
    input wire [31:0] memoryAddress, // last 3 bits offset 
    input wire [7:0] writeValue,
    input wire isWrite,
    input wire clk,
    output wire [7:0] outputdata
);

reg [7:0] tempout;
integer Associativity = 4;
integer Blocks = 32;
// <--------------------------------Variable Value to be changed-------------------------------------->

integer offset; // 1 block consists of 8 words
integer index;
// <--------------------------------Variable Value to be changed-------------------------------------->
integer tag; 
// <--------------------------------Variable Value to be changed-------------------------------------->

integer r; //rows
integer c; //columns
reg [27:0] TagArray [0:7][0:3];
integer frequency [0:7][0:3];
reg [63:0] DataArray [0:7][0:3]; //Data Memory Array

// <--------------------------------Variable Value to be changed-------------------------------------->
initial begin
    r = Blocks/Associativity;
    c = Associativity;
    $display(r);
    $display(c);
    for(integer i=0;i<r;i++) begin
        for(integer j=0;j<c;j++) begin
            TagArray[i][j]=0;
            DataArray[i][j]=0;
            frequency[i][j]=j;
        end
    end
end

// <--------------------------------Variable Value to be changed-------------------------------------->

bool hitbit ;
integer column;

// Memory Variables
reg [31:0] Address;
reg [7:0] Data;
reg [0:0] ismemWrite;
wire [7:0] outputmem;

MainMemory m1 (.Address(Address),.Data(Data),.ismemWrite(ismemWrite),.outputmem(outputmem));

initial begin
    Address=0;
    Data=0;
    ismemWrite=0;
end
always @(posedge clk) begin
    offset = memoryAddress [2:0];
    index = memoryAddress [5:3]; // <--------value to be changed--------->
    tag = memoryAddress [31:6];
    $display(offset);
    $display(index);
    $display(tag);
    hitbit = 0;
    column = 0;
    for (integer i=0;i<c;i++) begin
        if (TagArray[index][i][25:0]==tag && TagArray[index][i][26]==1) begin
            hitbit = 1;
            column = i;
        end
    end
    $display(column);
    if (isWrite==0 && hitbit==1) begin
        for (integer i=0;i<8;i++) begin
            tempout [i] = DataArray[index][column][8*offset+i];
        end
        for (integer i=0;i<c;i++) begin
            if (frequency[index][i]==column) begin
                for (integer j=i;j>0;j--) frequency[index][j]=frequency[index][j-1];
                frequency[index][0]=column;
            end
        end
        $display("%b",frequency[index][0]);
        $display("%b",frequency[index][1]);
        $display("%b",frequency[index][2]);
        $display("%b",frequency[index][3]);
    end
    else if (hitbit==0) begin
        if (TagArray[index][frequency[index][c-1]][27]) begin
            Address = memoryAddress;
            Address[31:6] = TagArray[index][frequency[index][c-1]][25:0];
            for (integer i=0;i<8;i++) begin
                for (integer j=0;j<8;j++) Data[j] = DataArray[index][column][8*i+j];
                Address[2:0]=i;
                ismemWrite=1;
                ismemWrite=0;
            end        
        end
        Address = memoryAddress;
        for (integer i=0;i<8;i++) begin
            Address[2:0]=i;
            for (integer j=0;j<8;j++) DataArray[index][column][8*i+j]=outputmem[j];
        end
        if (isWrite==0) begin
            for (integer i=0;i<8;i++) tempout[i]=DataArray[index][column][8*offset+i];
        end
    end
    if (isWrite) begin
        for (integer i=0;i<8;i++) begin
            DataArray[index][column][8*offset+i] = writeValue[i];
        end
        TagArray[index][column][26]=1; // <----------value to be changed--------->
    end 
    maintb.totalno++;
    if (hitbit) maintb.hitno++;
end

assign outputdata = tempout;

endmodule

module maintb();
    integer hitno;
    integer totalno;
    reg [31:0] memoryAddress_tb; // last 3 bits offset 
    reg[7:0] writeValue_tb;
    reg isWrite_tb;
    reg clk;
    wire [7:0] outputdata_tb;
    CacheController c1 (.memoryAddress(memoryAddress_tb),.writeValue(writeValue_tb),.isWrite(isWrite_tb),.outputdata(outputdata_tb),.clk(clk));
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0,maintb);
        hitno=0;
        totalno=0;
        clk=0;
        writeValue_tb=9;
        isWrite_tb=1;
        memoryAddress_tb= 32'h02001f86;
        #10;
        clk=~clk;
        #10;
        clk=~clk;
        memoryAddress_tb= 32'h02001f86;
        #10;
        clk=~clk;
        #10;
        clk=~clk;
        $display("Hits: %d",hitno);
        $display("Total: %d",totalno);
    end
endmodule