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
integer log = 2;
// <--------------------------------Variable Value to be changed-------------------------------------->

integer offset; // 1 block consists of 8 words
integer index;
// <--------------------------------Variable Value to be changed-------------------------------------->
integer tag; 
// <--------------------------------Variable Value to be changed-------------------------------------->

integer r; //rows
integer c; //columns
reg [28:0] TagArray [0:7][0:3];
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
            frequency[i][j]=0;
        end
    end
    DataArray[1][1]=1;
    frequency[1][0]=3;
    frequency[1][1]=1;
    frequency[1][2]=0;
    frequency[1][3]=2;    
    TagArray[1][1]=29'b01000000000000000000000000001;
end

// <--------------------------------Variable Value to be changed-------------------------------------->

//Tag Array Testing below:
// initial begin
// Tag [0][0] = 8'b00000001;
// Tag [1][1] = 8'b00001111;
// Tag [0][1] = 8'b01010101;
// Tag [3][2] = 8'b00011110;

//     for (integer i=0;i<=r;i++) begin
//         for (integer j=0;j<c;j++) begin
//             if(Tag[i][j][0:0] !== 1'b0 && Tag[i][j][0:0] !== 1'b1) begin
//             Tag[i][j]=8'b00000000;
//             end
//             $display("r = %d and c=%d and tag=%b",i,j,Tag[i][j]);
//         end
//     end
// end
reg [7:0] value;

// initial begin
//     value[7:0] = 8'b00000001;
// end

// always @(*) begin
//     for (integer j=0;j<Associativity;j++) begin
//         if((TagArray[index][j] == value) && (TagArray[index][j][7:7] == 1'b1)) begin
//             $display("HIT");
//             column = j;
//             $display("Column : ",column);
//         end
//         else begin
//             $display("MISS");
//             column = 404;
//             $display("Column : ",column);
//         end
//     end
// end

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
    index = memoryAddress [4:3]; // <--------value to be changed--------->
    tag = memoryAddress [31:5];
    $display(offset);
    $display(index);
    $display(tag);
    hitbit = 0;
    column = 0;
    for (integer i=0;i<c;i++) begin
        if (TagArray[index][i][26:0]==tag && TagArray[index][i][27]==1) begin
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
        // $display("%b",frequency[index][0]);
        // $display("%b",frequency[index][1]);
        // $display("%b",frequency[index][2]);
        // $display("%b",frequency[index][3]);
    end
    else if (hitbit==0) begin
        if (TagArray[index][frequency[index][c-1]][28]) begin
            Address = memoryAddress;
            Address[31:5] = TagArray[index][frequency[index][c-1]][26:0];
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
        TagArray[index][column][27]=1; // <----------value to be changed--------->
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
        memoryAddress_tb=40;
        writeValue_tb=4;
        isWrite_tb=0;
        clk=0;
        hitno=0;
        totalno=0;
        for(integer i=0;i<50;i++) begin
            #10;
            clk=~clk;
        end
        $display("Hits: %d",hitno);
        $display("Total: %d",totalno);
    end
endmodule