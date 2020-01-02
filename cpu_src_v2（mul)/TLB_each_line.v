`timescale 1 ns / 1 ps

`define VPN_width 19
`define PFN_width 24

module TLB_each_line
(
    input rst,
    input clk,
    input [`VPN_width-1:0]in_VPN_instruction,
    input [`VPN_width-1:0]in_VPN_data,
    input [2:0]op,                  //001:TLBR,  010:TLBWI,  011:TLBWR  ,100:TLBP
    input Which_line_index,
    input Which_line_random,
    input [31:0]in_EntryHi,        //VPN2[31:13],   VPN2X[12:11],  EHINV[10],  ASIDX[9:8], ASID[7:0], attention: restore ASID of EntryHi in cp0 after TLBP
    input [31:0]in_EntryLo0,       //Fill[31:30],  PFN[29:6],  C[5:3],  D[2],  V[1],  G[0]
    input [31:0]in_EntryLo1,
    input unmapped_instruction,
    input unmapped_data,
    input load_store,         //1 means this operation is load or store, need to fetch 

    output hit_instruction,
    output hit_data,
    output [1:0]out_PFN_data_D,
    output TLBP_hit,
    output [2*`PFN_width-1:0]out_PFN_instruction,
    output [1:0]out_PFN_instruction_valid,
    output [2*`PFN_width-1:0]out_PFN_data,
    output [1:0]out_PFN_data_valid,
    output [31:0]out_EntryHi,
    output [31:0]out_EntryLo0, 
    output [31:0]out_EntryLo1
);

    reg [18:0]tlb_VPN;
    reg tlb_G;
    reg [7:0]tlb_ASID;
    reg [23:0]tlb_PFN0, tlb_PFN1;
    reg [2:0]tlb_C0, tlb_C1;
    reg tlb_D0, tlb_D1, tlb_V0, tlb_V1;

    initial begin  
        tlb_VPN <= 0;
        tlb_G <= 0;
        tlb_ASID <= 0;
        tlb_PFN0 <= 0;
        tlb_PFN1 <= 0;
        tlb_C0 <= 0;
        tlb_C1 <= 0;
        tlb_D0 <= 0;
        tlb_D1 <= 0;
        tlb_V0 <= 0;
        tlb_V1 <= 0;
    end

    assign hit_instruction      = ~unmapped_instruction & (in_VPN_instruction == tlb_VPN) & (tlb_G | (tlb_ASID == in_EntryHi[7:0])) & (tlb_V0 | tlb_V1);
    assign hit_data             = ~unmapped_data & load_store & (in_VPN_data == tlb_VPN) & (tlb_G | (tlb_ASID == in_EntryHi[7:0])) & (tlb_V0 | tlb_V1);
    assign TLBP_hit             = (op==3'b100) & (in_EntryHi[31:13] == tlb_VPN) & (tlb_G | (tlb_ASID == in_EntryHi[7:0])) & (tlb_V0 | tlb_V1);
    
    assign out_PFN_instruction       = hit_instruction   ? {tlb_PFN1, tlb_PFN0}           : {48{1'bz}};
    assign out_PFN_instruction_valid = hit_instruction ? {tlb_V1, tlb_V0}                 : 2'bzz;
    assign out_PFN_data         = hit_data          ? {tlb_PFN1, tlb_PFN0}                : {48{1'bz}};
    assign out_PFN_data_valid   = hit_data          ? {tlb_V1, tlb_V0}                    : 2'bzz;

    assign out_EntryHi          = Which_line_index  ? {tlb_VPN, 5'b00000, tlb_ASID}                     : {32{1'bz}};
    assign out_EntryLo0         = Which_line_index  ? {2'b00, tlb_PFN0, tlb_C0, tlb_D0, tlb_V0, tlb_G}  : {32{1'bz}};
    assign out_EntryLo1         = Which_line_index  ? {2'b00, tlb_PFN1, tlb_C1, tlb_D1, tlb_V1, tlb_G}  : {32{1'bz}};
    assign out_PFN_data_D       = hit_data          ? {tlb_D1 ,tlb_D0}                                  : 2'bzz;

    always @(posedge clk) begin
        if(~rst)    begin
            tlb_VPN <= 0;
            tlb_G <= 0;
            tlb_ASID <= 0;
            tlb_PFN0 <= 0;
            tlb_PFN1 <= 0;
            tlb_C0 <= 0;
            tlb_C1 <= 0;
            tlb_D0 <= 0;
            tlb_D1 <= 0;
            tlb_V0 <= 0;
            tlb_V1 <= 0;
        end
        else if(Which_line_index & (op==3'b010)) begin              //TLBWI
            tlb_VPN <= in_EntryHi[31:13];
            tlb_G <= in_EntryLo0[0] & in_EntryLo1[0];
            tlb_ASID <= in_EntryHi[7:0];
            tlb_PFN0 <= in_EntryLo0[29:6];
            tlb_PFN1 <= in_EntryLo1[29:6];
            tlb_C0 <= in_EntryLo0[5:3];
            tlb_C1 <= in_EntryLo1[5:3];
            tlb_D0 <= in_EntryLo0[2];
            tlb_D1 <= in_EntryLo1[2];
            tlb_V0 <= in_EntryLo0[1];
            tlb_V1 <= in_EntryLo1[1];
        end
        else if(Which_line_random & (op==3'b011)) begin             //TLBWR
            tlb_VPN <= in_EntryHi[31:13];
            tlb_G <= in_EntryLo0[0] & in_EntryLo1[0];
            tlb_ASID <= in_EntryHi[7:0];
            tlb_PFN0 <= in_EntryLo0[29:6];
            tlb_PFN1 <= in_EntryLo1[29:6];
            tlb_C0 <= in_EntryLo0[5:3];
            tlb_C1 <= in_EntryLo1[5:3];
            tlb_D0 <= in_EntryLo0[2];
            tlb_D1 <= in_EntryLo1[2];
            tlb_V0 <= in_EntryLo0[1];
            tlb_V1 <= in_EntryLo1[1];
        end
    end
endmodule