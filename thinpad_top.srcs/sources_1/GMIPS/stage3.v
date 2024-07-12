/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\stage3.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-12 10:01:37
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-12 10:03:50
 */

module stage3 (
    input wire rst,
    input wire clk,

    input wire [31:0] ex_pc,
    input wire        ex_we,
    input wire [ 4:0] ex_waddr,
    input wire [31:0] ex_wdata,

    input wire [ 3:0] ex_mem_op,
    input wire [31:0] ex_mem_addr,
    input wire [31:0] ex_mem_data,

    output reg [31:0] mem_pc,
    output reg [ 3:0] mem_mem_op,
    output reg [31:0] mem_mem_addr,
    output reg [31:0] mem_mem_data,

    output reg        mem_we,
    output reg [ 4:0] mem_waddr,
    output reg [31:0] mem_wdata,

    output reg [31:0] last_store_data,
    output reg [31:0] last_store_addr
);

  always @(posedge clk) begin
    if (rst == 1'b1) begin
      mem_pc          <= 32'h00000000;
      mem_mem_op      <= 4'b0000;
      mem_mem_addr    <= 32'h00000000;
      mem_mem_data    <= 32'h00000000;

      mem_we          <= 1'b0;
      mem_waddr       <= 5'b00000;
      mem_wdata       <= 32'h00000000;

      last_store_addr <= 32'h00000000;
      last_store_data <= 32'h00000000;
    end else begin
      mem_pc       <= ex_pc;
      mem_mem_op   <= ex_mem_op;
      mem_mem_addr <= ex_mem_addr;
      mem_mem_data <= ex_mem_data;

      mem_we       <= ex_we;
      mem_waddr    <= ex_waddr;
      mem_wdata    <= ex_wdata;
      case (ex_mem_op)
        4'b0011: begin
          last_store_addr <= ex_mem_addr;
          case (ex_mem_addr[1:0])
            2'b00: begin
              last_store_data <= {24'h000000, ex_mem_data[7:0]};
            end
            2'b01: begin
              last_store_data <= {16'h0000, ex_mem_data[7:0], 8'h00};
            end
            2'b10: begin
              last_store_data <= {8'h00, ex_mem_data[7:0], 16'h0000};
            end
            2'b11: begin
              last_store_data <= {ex_mem_data[7:0], 12'h000000};
            end
            default: begin
              last_store_data <= last_store_data;
            end
          endcase
        end
        4'b0100: begin
          last_store_addr <= ex_mem_addr;
          last_store_data <= ex_mem_data;
        end
        default: begin
          last_store_addr <= last_store_addr;
          last_store_data <= last_store_data;
        end
      endcase
    end
  end

endmodule
