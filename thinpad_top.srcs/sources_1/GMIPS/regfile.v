/*
 * File: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS\regfile.v
 * Project: e:\NSCSCC\2024175\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-04 16:23:24
 * Author: Tommy Gong
 * ----------------------------------------------------
 * Last Modified: 2024-07-05 16:05:33
 * Modified By: Tommy Gong
 * ----------------------------------------------------
 */



module regfile(
    input clk,
    input [4:0] raddr1,
    output [31:0] rdata1,
    input [4:0] raddr2,
    output [31:0] rdata2,
    input [4:0] waddr,
    input [31:0] wdata,
    input we
    );
    reg [31:0] reg_array[31:0];
    //WRITE
    always @(posedge clk) begin
        if(we) reg_array[waddr] <= wdata;
    end
    //READ OUT 1
    assign rdata1 = reg_array[raddr1];
    //READ OUT 2
    assign rdata2 = reg_array[raddr2];
endmodule
