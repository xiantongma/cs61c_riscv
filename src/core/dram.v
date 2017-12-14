module dram(
    input           clk     ,
    input           rstb    ,
    input [31:0]    addr    ,
    input [31:0]    wdata   ,
    input           write   ,
    input           read    ,
    output [31:0]   rdata   
    );
    reg [31:0] mem[0:(1<<10) -1];
    //always @(posedge clk or negedge rstb)
    always @(posedge clk)
        if (write)        
            mem[addr[31:2]] <= wdata;

    assign rdata = mem[addr[31:2]];
endmodule
