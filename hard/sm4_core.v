`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/04 15:25:49
// Design Name: 
// Module Name: sm4_core
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


module SM4_Core(dx, rkey, next);
    input [127:0] dx;
    input [31:0] rkey;
    output [31:0] next;
    
    wire [31:0] text0, text1, text2, text3;
    wire [31:0] in_T, out_T;
    wire [31:0] sb_out;
    
    assign text0 = dx[127:96];
    assign text1 = dx[95:64];
    assign text2 = dx[63:32];
    assign text3 = dx[31:0];
    
    assign in_T = text1^text2^text3^rkey;
    Sub_Bytes  sbox (in_T, sb_out);
    L l (sb_out, out_T);
    assign next = out_T ^ text0;   
    
    
endmodule

module Key_Expand(dkey, rnd, rkey);
    input [127:0] dkey;
    input [4:0] rnd;
    output [31:0] rkey;
    
    wire [31:0] key0, key1, key2, key3;
    wire [31:0] ck, sb_out, in_T, out_T;
    assign key0 = dkey[127:96];
    assign key1 = dkey[95:64];
    assign key2 = dkey[63:32];
    assign key3 = dkey[31:0];
    
    assign ck = c(rnd);
    assign in_T = key1^key2^key3^ck;
    Sub_Bytes sbox (in_T, sb_out);
    L_k lk (sb_out, out_T);
    assign rkey = key0 ^ out_T;
    
    function [31:0] c;
        input [4:0] rnd;
        case (rnd)
            'd0:  c = 32'h00070e15;  'd1: c = 32'h1c232a31;  'd2: c = 32'h383f464d;  'd3: c = 32'h545b6269;
            'd4:  c = 32'h70777e85; 'd5: c = 32'h8c939aa1; 'd6: c = 32'ha8afb6bd;  'd7: c = 32'hc4cbd2d9;
            'd8:  c = 32'he0e7eef5;  'd9: c = 32'hfc030a11;  'd10: c = 32'h181f262d;  'd11: c = 32'h343b4249;
            'd12: c = 32'h50575e65; 'd13: c= 32'h6c737a81; 'd14: c = 32'h888f969d; 'd15: c = 32'ha4abb2b9;
            'd16: c = 32'hc0c7ced5; 'd17: c = 32'hdce3eaf1; 'd18: c = 32'hf8ff060d;  'd19: c = 32'h141b2229;
            'd20: c = 32'h30373e45; 'd21: c = 32'h4c535a61; 'd22: c = 32'h686f767d; 'd23: c = 32'h848b9299;
            'd24: c = 32'ha0a7aeb5; 'd25: c = 32'hbcc3cad1; 'd26: c = 32'hd8dfe6ed; 'd27: c = 32'hf4fb0209;
            'd28: c = 32'h10171e25;   'd29: c = 32'h2c333a41; 'd30: c = 32'h484f565d; 'd31: c = 32'h646b7279;
        endcase
    endfunction
endmodule

module Sub_Bytes (x, y);
    input [31:0] x;
    output [31:0] y;
    
    assign y = {s(x[31:24]), s(x[23:16]), s(x[15:8]), s(x[7:0])};
    
    function [7:0] s;
        input [7:0] x;
        case (x)
            8'h00: s=8'hd6;  8'h01: s=8'h90;  8'h02: s=8'he9;  8'h03: s=8'hfe;
            8'h04: s=8'hcc;  8'h05: s=8'he1;  8'h06: s=8'h3d;  8'h07: s=8'hb7;
            8'h08: s=8'h16;  8'h09: s=8'hb6;  8'h0A: s=8'h14;  8'h0B: s=8'hc2;
            8'h0C: s=8'h28;  8'h0D: s=8'hfb;  8'h0E: s=8'h2c;  8'h0F: s=8'h05;
            
            8'h10: s=8'h2b;  8'h11: s=8'h67;  8'h12: s=8'h9a;  8'h13: s=8'h76;
            8'h14: s=8'h2a;  8'h15: s=8'hbe;  8'h16: s=8'h04;  8'h17: s=8'hc3;
            8'h18: s=8'haa;  8'h19: s=8'h44;  8'h1A: s=8'h13;  8'h1B: s=8'h26;
            8'h1C: s=8'h49;  8'h1D: s=8'h86;  8'h1E: s=8'h06;  8'h1F: s=8'h99;
            
            8'h20: s=8'h9c;  8'h21: s=8'h42;  8'h22: s=8'h50;  8'h23: s=8'hf4;
            8'h24: s=8'h91;  8'h25: s=8'hef;  8'h26: s=8'h98;  8'h27: s=8'h7a;
            8'h28: s=8'h33;  8'h29: s=8'h54;  8'h2A: s=8'h0b;  8'h2B: s=8'h43;
            8'h2C: s=8'hed;  8'h2D: s=8'hcf;  8'h2E: s=8'hac;  8'h2F: s=8'h62;
            
            8'h30: s=8'he4;  8'h31: s=8'hb3;  8'h32: s=8'h1c;  8'h33: s=8'ha9;
            8'h34: s=8'hc9;  8'h35: s=8'h08;  8'h36: s=8'he8;  8'h37: s=8'h95;
            8'h38: s=8'h80;  8'h39: s=8'hdf;  8'h3A: s=8'h94;  8'h3B: s=8'hfa;
            8'h3C: s=8'h75;  8'h3D: s=8'h8f;  8'h3E: s=8'h3f;  8'h3F: s=8'ha6;
            
            8'h40: s=8'h47;  8'h41: s=8'h07;  8'h42: s=8'ha7;  8'h43: s=8'hfc;
            8'h44: s=8'hf3;  8'h45: s=8'h73;  8'h46: s=8'h17;  8'h47: s=8'hba;
            8'h48: s=8'h83;  8'h49: s=8'h59;  8'h4A: s=8'h3c;  8'h4B: s=8'h19;
            8'h4C: s=8'he6;  8'h4D: s=8'h85;  8'h4E: s=8'h4f;  8'h4F: s=8'ha8;
            
            8'h50: s=8'h68;  8'h51: s=8'h6b;  8'h52: s=8'h81;  8'h53: s=8'hb2;
            8'h54: s=8'h71;  8'h55: s=8'h64;  8'h56: s=8'hda;  8'h57: s=8'h8b;
            8'h58: s=8'hf8;  8'h59: s=8'heb;  8'h5A: s=8'h0f;  8'h5B: s=8'h4b;
            8'h5C: s=8'h70;  8'h5D: s=8'h56;  8'h5E: s=8'h9d;  8'h5F: s=8'h35;
            
            8'h60: s=8'h1e;  8'h61: s=8'h24;  8'h62: s=8'h0e;  8'h63: s=8'h5e;
            8'h64: s=8'h63;  8'h65: s=8'h58;  8'h66: s=8'hd1;  8'h67: s=8'ha2;
            8'h68: s=8'h25;  8'h69: s=8'h22;  8'h6A: s=8'h7c;  8'h6B: s=8'h3b;
            8'h6C: s=8'h01;  8'h6D: s=8'h21;  8'h6E: s=8'h78;  8'h6F: s=8'h87;
            
            8'h70: s=8'hd4;  8'h71: s=8'h00;  8'h72: s=8'h46;  8'h73: s=8'h57;
            8'h74: s=8'h9f;  8'h75: s=8'hd3;  8'h76: s=8'h27;  8'h77: s=8'h52;
            8'h78: s=8'h4c;  8'h79: s=8'h36;  8'h7A: s=8'h02;  8'h7B: s=8'he7;
            8'h7C: s=8'ha0;  8'h7D: s=8'hc4;  8'h7E: s=8'hc8;  8'h7F: s=8'h9e;
            
            8'h80: s=8'hea;  8'h81: s=8'hbf;  8'h82: s=8'h8a;  8'h83: s=8'hd2;
            8'h84: s=8'h40;  8'h85: s=8'hc7;  8'h86: s=8'h38;  8'h87: s=8'hb5;
            8'h88: s=8'ha3;  8'h89: s=8'hf7;  8'h8A: s=8'hf2;  8'h8B: s=8'hce;
            8'h8C: s=8'hf9;  8'h8D: s=8'h61;  8'h8E: s=8'h15;  8'h8F: s=8'ha1;
            
            8'h90: s=8'he0;  8'h91: s=8'hae;  8'h92: s=8'h5d;  8'h93: s=8'ha4;
            8'h94: s=8'h9b;  8'h95: s=8'h34;  8'h96: s=8'h1a;  8'h97: s=8'h55;
            8'h98: s=8'had;  8'h99: s=8'h93;  8'h9A: s=8'h32;  8'h9B: s=8'h30;
            8'h9C: s=8'hf5;  8'h9D: s=8'h8c;  8'h9E: s=8'hb1;  8'h9F: s=8'he3;
            
            8'hA0: s=8'h1d;  8'hA1: s=8'hf6;  8'hA2: s=8'he2;  8'hA3: s=8'h2e;
            8'hA4: s=8'h82;  8'hA5: s=8'h66;  8'hA6: s=8'hca;  8'hA7: s=8'h60;
            8'hA8: s=8'hc0;  8'hA9: s=8'h29;  8'hAA: s=8'h23;  8'hAB: s=8'hab;
            8'hAC: s=8'h0d;  8'hAD: s=8'h53;  8'hAE: s=8'h4e;  8'hAF: s=8'h6f;
            
            8'hB0: s=8'hd5;  8'hB1: s=8'hdb;  8'hB2: s=8'h37;  8'hB3: s=8'h45;
            8'hB4: s=8'hde;  8'hB5: s=8'hfd;  8'hB6: s=8'h8e;  8'hB7: s=8'h2f;
            8'hB8: s=8'h03;  8'hB9: s=8'hff;  8'hBA: s=8'h6a;  8'hBB: s=8'h72;
            8'hBC: s=8'h6d;  8'hBD: s=8'h6c;  8'hBE: s=8'h5b;  8'hBF: s=8'h51;
            
            8'hC0: s=8'h8d;  8'hC1: s=8'h1b;  8'hC2: s=8'haf;  8'hC3: s=8'h92;
            8'hC4: s=8'hbb;  8'hC5: s=8'hdd;  8'hC6: s=8'hbc;  8'hC7: s=8'h7f;
            8'hC8: s=8'h11;  8'hC9: s=8'hd9;  8'hCA: s=8'h5c;  8'hCB: s=8'h41;
            8'hCC: s=8'h1f;  8'hCD: s=8'h10;  8'hCE: s=8'h5a;  8'hCF: s=8'hd8;
    
            8'hD0: s=8'h0a;  8'hD1: s=8'hc1;  8'hD2: s=8'h31;  8'hD3: s=8'h88;
            8'hD4: s=8'ha5;  8'hD5: s=8'hcd;  8'hD6: s=8'h7b;  8'hD7: s=8'hbd;
            8'hD8: s=8'h2d;  8'hD9: s=8'h74;  8'hDA: s=8'hd0;  8'hDB: s=8'h12;
            8'hDC: s=8'hb8;  8'hDD: s=8'he5;  8'hDE: s=8'hb4;  8'hDF: s=8'hb0;
            
            8'hE0: s=8'h89;  8'hE1: s=8'h69;  8'hE2: s=8'h97;  8'hE3: s=8'h4a;
            8'hE4: s=8'h0c;  8'hE5: s=8'h96;  8'hE6: s=8'h77;  8'hE7: s=8'h7e;
            8'hE8: s=8'h65;  8'hE9: s=8'hb9;  8'hEA: s=8'hf1;  8'hEB: s=8'h09;
            8'hEC: s=8'hc5;  8'hED: s=8'h6e;  8'hEE: s=8'hc6;  8'hEF: s=8'h84;
            
            8'hF0: s=8'h18;  8'hF1: s=8'hf0;  8'hF2: s=8'h7d;  8'hF3: s=8'hec;
            8'hF4: s=8'h3a;  8'hF5: s=8'hdc;  8'hF6: s=8'h4d;  8'hF7: s=8'h20;
            8'hF8: s=8'h79;  8'hF9: s=8'hee;  8'hFA: s=8'h5f;  8'hFB: s=8'h3e;
            8'hFC: s=8'hd7;  8'hFD: s=8'hcb;  8'hFE: s=8'h39;  8'hFF: s=8'h48;
        endcase
      endfunction
endmodule

module L(sbox_out, l_out);
    input [31:0] sbox_out;
    output [31:0] l_out;
    
    assign l_out = sbox_out ^ {sbox_out[29:0], sbox_out[31:30]} ^ {sbox_out[21:0], sbox_out[31:22]} ^ {sbox_out[13:0], sbox_out[31:14]} ^ {sbox_out[7:0], sbox_out[31:8]};
endmodule

module L_k (sbox_out, lk_out);
    input [31:0] sbox_out;
    output [31:0] lk_out;
    
    assign lk_out = sbox_out ^ {sbox_out[18:0], sbox_out[31:19]} ^ {sbox_out[8:0], sbox_out[31:9]};
endmodule
