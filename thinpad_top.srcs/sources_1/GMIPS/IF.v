/*
 * @Author: TommyGong 
 * @Date: 2024-07-05 11:07:55 
 * @Last Modified by: TommyGong
 * @Last Modified time: 2024-07-05 11:17:08
 */
include "defines.v";


module IF (
    input  wire        clk,
    input  wire        reset,
    output reg  [31:0] pc,
    output reg         ce,
    input  wire        branch_flag_i,
    input  wire        branch_address_i,

    input wire stall  //暂停信号
);

  always @(posedge clk) begin
    if (reset == `RstEnable) begin
      ce <= `ChipDisable;
    end else begin
      ce <= `ChipEnable;
    end
  end

  always @(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= `PC_START_ADDR;
    end else if(stall == 1'b0) begin
        if(branch_flag_i) begin
            pc <= branch_address_i;
        end else begin
            pc <= pc + 4'h4;
        end
    end
  end

endmodule
