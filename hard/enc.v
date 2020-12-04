`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ISCAS-TCA
// Engineer: WJ
// 
// Create Date: 2020/11/04 15:12:45
// Design Name: SM4
// Module Name: enc
// Project Name: SM4
// Target Devices: Kintex-7
// Tool Versions: 20.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SM4_ENC(din, kin, dout, Drdy, Krdy, Dvld, Kvld, BSY, clk, rstn);


    input [127:0] din;
    input [127:0] kin;
    output [127:0] dout;
    
    
    input Drdy;
    input Krdy;
    
    output reg Dvld;
    output reg Kvld;
    
    output reg BSY;
    
    input clk, rstn;
    
    parameter fk = 128'ha3b1bac656aa3350677d9197b27022dc;
    
    (* mark_debug = "true" *)reg [127:0] dkey, dx;
    (* mark_debug = "true" *)wire [31:0] dat_next, rkey;
    (* mark_debug = "true" *)reg [4:0] round;
    reg done;
    (* mark_debug = "true" *)reg ready;
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn)ready <= 0;
        else if (Drdy)ready <= 1;
        else if (&round) ready <= 0;
    end
    
    
    // send data after send key
    always @(posedge clk or negedge rstn)begin
        if (!rstn) round <= 5'b0;
        else if (ready || round != 0)round = round + 1;
    end
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn) begin dkey <= 128'd0; end
        else if (Krdy) begin dkey <= kin^fk;end
        else if (round != 0 || ready)dkey <= {dkey[95:64], dkey[63:32], dkey[31:0], rkey};
    end
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn) begin dx <= 128'd0;  end
        else if (Drdy)begin dx <= din;  end
        else if (round != 0  || ready)dx <= {dx[95:64], dx[63:32], dx[31:0], dat_next};
    end 
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn) BSY <= 0;
        else BSY <= Drdy | |round;
    end
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn)done <= 0;
        else if (&round) done <= 1;
    end
    
    //assign done = &round;
    assign dout = done ? {dx[31:0], dx[63:32], dx[95:64], dx[127:96]} : 128'd0;
    
    SM4_Core round_enc(dx, rkey, dat_next);
    Key_Expand round_key(dkey, round, rkey);
    
    
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn) Dvld <= 0;
        else if (&round)Dvld <= 1;
    end
    
    always @(posedge clk or negedge rstn)begin
        if (!rstn) Kvld <= 0;
        else Kvld <= Krdy;
    end
    
    
    
    
endmodule
