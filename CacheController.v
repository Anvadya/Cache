`include "MainMemory.v"

module CacheController(
    input wire [31:0] memoryAddress, 
    input wire [7:0] writeValue, 
    input wire isWrite,
    input wire clk,
    output wire [7:0] outputdata 
);

parameter Associativity = 1;
parameter Blocks = 32;
parameter no_of_rows = Blocks/Associativity; 
parameter no_of_columns = Associativity;
parameter log = 5; // log(blocks/associativity) 

bool hitbit;
integer tag;
integer index;
integer offset; 
integer column;

reg [7:0] tempout; // temporary register for storing output data
reg [30-log:0] TagArray [0:no_of_rows-1][0:no_of_columns-1];
reg [63:0] DataArray [0:no_of_rows-1][0:no_of_columns-1]; 
integer frequency [0:no_of_rows-1][0:no_of_columns-1]; // last element is the LRU


// Initialisation

initial begin
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
    index = memoryAddress [2+log:3];
    tag = memoryAddress [31:3+log];
    hitbit = 0;
    column = 0;

    // Lookup

    for (integer i=0;i<no_of_columns;i++) begin
        // checking tag and valid bit
        if (TagArray[index][i][28-log:0]==tag && TagArray[index][i][29-log]==1) begin 
            hitbit = 1;
            column = i;
        end
    end

    // Hit/Miss check

    if (hitbit==1) begin // Hit
        for (integer i=0;i<no_of_columns;i++) begin
            if (frequency[index][i]==column) begin
                // Shifting the hit-column to the beginning of the frequency array
                for (integer j=i;j>0;j--) frequency[index][j]=frequency[index][j-1];
                frequency[index][0]=column;
            end
        end
    end
    else begin // Miss
        column = frequency[index][no_of_columns-1]; // column = LRU 
        if (TagArray[index][column][30-log]) begin // checking dirty bit
            // Writing LRU data into main memory
            Address = memoryAddress;
            Address[31:3+log] = TagArray[index][column][28-log:0];
            for (integer i=0;i<8;i++) begin
                for (integer j=0;j<8;j++) Data[j] = DataArray[index][column][8*i+j];
                Address[2:0]=i;
                ismemWrite=1;
                ismemWrite=0;
            end        
        end
        // Changing LRU data according to the input address
        Address = memoryAddress;
        for (integer i=0;i<8;i++) begin
            Address[2:0]=i;
            for (integer j=0;j<8;j++) DataArray[index][column][8*i+j]=outputmem[j];
        end
        TagArray[index][column][28-log:0]=tag; // changing LRU tag
        TagArray[index][column][29-log]=1; // changing LRU valid bit
        // Shifting LRU to the beginning of the frequency array
        for (integer j=no_of_columns-1;j>0;j--) frequency[index][j]=frequency[index][j-1];
        frequency[index][0]=column;
    end

    // Read/Write check

    if (isWrite) begin // Write
        // writing input value into data array
        for (integer i=0;i<8;i++) begin
            DataArray[index][column][8*offset+i] = writeValue[i];
        end 
        TagArray[index][column][30-log]=1; // changing dirty bit
    end 
    else begin // Read
        for (integer i=0;i<8;i++) tempout[i]=DataArray[index][column][8*offset+i];
    end

    // Hit-rate calculation

    maintb.totalno++; // always
    if (hitbit) maintb.hitno++; //hit
    
end

assign outputdata = tempout; // inserting final value of temporaryt register into the output wire

endmodule

