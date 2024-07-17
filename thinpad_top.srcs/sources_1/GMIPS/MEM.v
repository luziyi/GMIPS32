/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\MEM.v
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-10 10:18:31
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:12:26
 */

module MEM (
    input        clk,
    input        rst_n,
    input [31:0] EX_PC,
    input [31:0] EX_Instr,
    input [31:0] DataMemOut,

    input [31:0] EX_ALUOut,
    input [31:0] EX_MemWriteData,
    input [ 4:0] EX_RegWriteID,
    input        EX_RegWriteEn,
    input [ 1:0] EX_MemReadEn,
    input        EX_MemtoReg,
    input [ 3:0] EX_base_ram_be_n,
    input        is_using_uart,

    output reg [31:0] MEM_PC,
    output reg [31:0] MEM_Instr,
    output reg [31:0] MEM_MemtoRegData,
    output reg [31:0] MEM_MemWriteAddr,
    output reg [31:0] MEM_MemWriteData,
    output reg [ 4:0] MEM_RegWriteID,
    output reg        MEM_RegWriteEn,
    output reg        MEM_MemtoReg
);

  always @(posedge clk) begin
    if (rst_n) begin
      MEM_PC           <= 0;
      MEM_Instr        <= 0;
      MEM_MemtoRegData <= 0;
      MEM_MemWriteAddr <= 0;
      MEM_MemWriteData <= 0;
      MEM_RegWriteEn   <= 0;
      MEM_RegWriteID   <= 0;
    end else begin
      MEM_PC <= EX_PC;
      MEM_Instr <= EX_Instr;
      MEM_MemtoRegData <= (EX_MemReadEn == 2'b10) ? DataMemOut :
                                (EX_MemReadEn == 2'b01) && is_using_uart ? DataMemOut :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1110) ? {{24{DataMemOut[7]}}, DataMemOut[7:0]} : 
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1101) ? {{24{DataMemOut[15]}}, DataMemOut[15:8]} :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b1011) ? {{24{DataMemOut[23]}}, DataMemOut[23:16]} :
                                (EX_MemReadEn == 2'b01 && EX_base_ram_be_n == 4'b0111) ? {{24{DataMemOut[31]}}, DataMemOut[31:24]} :
                                32'h7777;
      MEM_MemWriteAddr <= EX_ALUOut;
      MEM_MemWriteData <= EX_MemWriteData;
      MEM_RegWriteID <= EX_RegWriteID;
      MEM_RegWriteEn <= EX_RegWriteEn;
      MEM_MemtoReg <= EX_MemtoReg;
    end
  end

endmodule