`include "MainMemory.v"

module CacheController(
    input wire [31:0] memoryAddress, // last 3 bits offset 
    input wire [7:0] writeValue,
    input wire isWrite,
    input wire clk,
    output wire [7:0] outputdata
);
 
integer no_of_rows; 
integer no_of_columns; 

//Variable parameters
integer Associativity = 4; // <-----associativity------->
integer Blocks = 32;
parameter indexbit = 3; //log base 2 of rows

bool hitbit;
integer tag;
integer index;
integer offset; 
integer column;

reg [7:0] tempout;

reg [27:0] TagArray [0:7][0:3];
// reg [30-log(32/Associativity):0] TagArray [0:(32/Associativity)-1][0:Associativity-1];///////////////////////
reg [63:0] DataArray [0:7][0:3];
// reg [63:0] DataArray [0:(32/Associativity)-1][0:Associativity-1];////////////////////////////////////////////
integer frequency [0:7][0:3];
// integer frequency [0:(32/Associativity)-1][0:Associativity-1];///////////////////////////////////////////////

// Initialisation

initial begin
    no_of_rows = Blocks/Associativity;
    no_of_columns = Associativity;
    for(integer i=0;i<no_of_rows;i++) begin
        for(integer j=0;j<no_of_columns;j++) begin
            TagArray[i][j]=0;
            DataArray[i][j]=0;
            frequency[i][j]=j;
        end
    end
end

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
    index = memoryAddress [(indexbit+2):3];
    // index = memoryAddress [2+log(32/Associativity):3];/////////////////////////////////////////////////
    tag = memoryAddress [31:(indexbit+3)];
    // tag = memoryAddress [31:3+log(32/Associativity)];//////////////////////////////////////////////////
    hitbit = 0;
    column = 0;
    for (integer i=0;i<no_of_columns;i++) begin
        if (TagArray[index][i][(28-indexbit):0]==tag && TagArray[index][i][29-indexbit]==1) begin
            hitbit = 1;
            column = i;
        end
        // if (TagArray[index][i][28-log(32/Associativity):0]==tag && TagArray[index][i][29-log(32/Associativity)]==1) begin
        //     hitbit = 1;
        //     column = i;
        // end
    end
    if (isWrite==0 && hitbit==1) begin
        for (integer i=0;i<8;i++) begin
            tempout [i] = DataArray[index][column][8*offset+i];
        end
        for (integer i=0;i<no_of_columns;i++) begin
            if (frequency[index][i]==column) begin
                for (integer j=i;j>0;j--) frequency[index][j]=frequency[index][j-1];
                frequency[index][0]=column;
            end
        end
    end
    else if (hitbit==0) begin
        column = frequency[index][no_of_columns-1];
        if (TagArray[index][column][(30-indexbit)]) begin
            Address = memoryAddress;
            Address[31:(indexbit+3)] = TagArray[index][column][(28-indexbit):0];
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
        TagArray[index][column][(28-indexbit):0]=tag;
        // TagArray[index][column][28-log(32/Associativity):0]=tag;////////////////////////////////////////////////////////////
        TagArray[index][column][(29-indexbit)]=1;
        // TagArray[index][column][29-log(32/Associativity)]=1;///////////////////////////////////////////////////////////////
        for (integer j=no_of_columns-1;j>0;j--) frequency[index][j]=frequency[index][j-1];
        frequency[index][0]=column;
    end
    if (isWrite) begin
        for (integer i=0;i<8;i++) begin
            DataArray[index][column][8*offset+i] = writeValue[i];
        end 
    end 
    maintb.totalno++;
    if (hitbit) maintb.hitno++;
end

assign outputdata = tempout;

endmodule

