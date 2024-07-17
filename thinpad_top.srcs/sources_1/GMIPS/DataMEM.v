/*
 * File:         e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS\DataMEM
 * Project:      e:\NSCSCC\GMIPS\thinpad_top.srcs\sources_1\GMIPS
 * Created Date: 2024-07-17 16:03:13
 * Author:       Tommy Gong
 * description:  
 * ----------------------------------------------------
 * Last Modified: 2024-07-17 16:03:23
 */

module DataMEM(
    input clk,
    input [31:0] Addr,
    input [31:0] WriteData,
    input [1:0] WriteEn,        //00不使能，01为SB，10为SW
    input [1:0] ReadEn,         //00不使能，01为LB，10为LW
    output wire [31:0] DataOut,
    output wire [7:0] tiaoshi
    );

    reg [7:0] mem[16383:0];
    


    assign tiaoshi = mem[Addr+3];
    integer cnt;
    initial begin
        for(cnt=0;cnt<16384;cnt=cnt+1)
            mem[cnt] = 0;
    end

    assign DataOut = (ReadEn == 2'b00) ? 32'b0 :
                     (ReadEn == 2'b01) ? {{24{mem[Addr][7]}}, mem[Addr]} :
                     (ReadEn == 2'b10) ? {mem[Addr], mem[Addr+1], mem[Addr+2], mem[Addr+3]} :
                     32'o7777;      //调试

    always@(posedge clk) begin
        if(WriteEn == 2'b01) begin
            mem[Addr][7:0] <= WriteData[7:0];
        end
        else if(WriteEn == 2'b10) begin
            mem[Addr] <= WriteData[31:24];
            mem[Addr+1] <= WriteData[23:16];
            mem[Addr+2] <= WriteData[15:8];
            mem[Addr+3] <= WriteData[7:0];
        end
    end

endmodule