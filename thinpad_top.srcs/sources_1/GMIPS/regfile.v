`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/04 16:23:26
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
