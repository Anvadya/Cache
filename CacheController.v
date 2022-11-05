module CacheController(
    input wire [31:0] memoryAddress, // last 3 bits offset 
    input wire [7:0] writeValue,
    input wire isWrite,

    output wire [7:0] outputdata
);

integer Associativity = 4;
integer Blocks = 20;

reg [2:0] offset;
reg [1:0] index;
// <--------------------------------Variable Value to be changed-------------------------------------->
reg [26:0] tag; 

integer r; //rows
integer c; //columns
reg [9:0] TagArray [0:25][0:25];
// <--------------------------------Variable Value to be changed-------------------------------------->
initial begin
    r = Associativity;
    c = Blocks/Associativity;

    $display(r);
    $display(c);
end

 //25 is the max limit of rows and columns taken for the Tag array
reg [63:0] DataMemory [0:25][0:25]; //Data Memory Array
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

integer column;
reg [7:0] value;

initial begin
    value[7:0] = 8'b00000001;
end

always @(*) begin
    for (integer j=0;j<Associativity;j++) begin
        if((TagArray[index][j] == value) && (TagArray[index][j][7:7] == 1'b1)) begin
            $display("HIT");
            column = j;
            $display("Column : ",column);
        end
        else begin
            $display("MISS");
            column = 404;
            $display("Column : ",column);
        end
    end
end

endmodule