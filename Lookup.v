//just a prototype

module Lookup();

//index is row
//check hit / miss for all the columns for the given index
reg [7:0] Tag [0:25][0:25];

initial begin
Tag [0][0] = 8'b00000001;
Tag [1][1] = 8'b00001111;
Tag [0][1] = 8'b01010101;
Tag [3][2] = 8'b00011110;

    for (integer i=0;i<=4;i++) begin
        for (integer j=0;j<5;j++) begin
            if(Tag[i][j][0:0] !== 1'b0 && Tag[i][j][0:0] !== 1'b1) begin
            Tag[i][j]=8'b00000000;
            end
            //$display("r = %d and c=%d and tag=%b",i,j,Tag[i][j]);
        end
    end
end

integer column;
integer index=0;

reg [7:0] value;

initial begin
    value[7:0] = 8'b00000001;
end

always @(*) begin
    for (integer j=0;j<5;j++) begin
        if(Tag[index][j] == value) begin
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