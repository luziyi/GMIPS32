/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\stage4.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-12 10:02:50
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:03:38
 */

module stage4 (
    input wire clk,
    input wire rst,

    input wire stall,

    input wire [ 4:0] mem_waddr,
    input wire        mem_we,
    input wire [31:0] mem_wdata,

    output reg [ 4:0] wb_waddr,
    output reg        wb_we,
    output reg [31:0] wb_wdata
);

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      wb_waddr <= 5'b00000;
      wb_we    <= 1'b0;
      wb_wdata <= 32'h00000000;
    end else begin
      wb_waddr <= mem_waddr;
      wb_we    <= mem_we;
      wb_wdata <= mem_wdata;
    end
  end

endmodule
