`timescale 1 ns / 1 ps

`define VPN_width 19
`define PFN_width 24

module MMU #
(
    parameter TLB_entry_num = 16,       // num of tlb lines.
    parameter Entry_id_width = 4,       // width of the index for tlb lines
    parameter in_tlb_config_width = 142,   // width of the tlb-config bits from cp0
    parameter out_tlb_config_width = 160   // width of the tlb-config bits to cp0
)
(
    input                               rst,
    input                               clk,
    input                               unmapped_instruction,
    input                               unmapped_data,
    input                               load_store,         //1 means this operation is load or store, need to fetch 
    input   [2:0]                       op_type,            //001:TLBR,  010:TLBWI,  011:TLBWR  ,100:TLBP
    input   [31:0]                      Virtual_addr_instruction,
    input   [31:0]                      Virtual_addr_data,
    input   [in_tlb_config_width-1:0]   in_tlb_config,

    output  [out_tlb_config_width-1:0]  out_tlb_config,
    output  [31:0]                      Physical_addr_instruction,
    output  [31:0]                      Physical_addr_data,
    output                              TLB_miss_instruction,
    output                              TLB_invalid_instruction,
    output                              TLB_miss_data,
    output                              TLB_invalid_data,
    output                              TLB_forbid_modify
);
    wire [`VPN_width-1:0]       VPN_instruction;
    wire [`VPN_width-1:0]       VPN_data;
    wire [31:0]                 in_EntryHi;     // include VPN & ASID
    wire [31:0]                 in_EntryLo0;    // PFN1 & its flags
    wire [31:0]                 in_EntryLo1;    // PFN2 & its flags
    wire [Entry_id_width-1:0]   in_Index;
    wire [Entry_id_width-1:0]   in_Random;

    wire [31:0]                 out_EntryHi;
    wire [31:0]                 out_EntryLo0;
    wire [31:0]                 out_EntryLo1;
    wire [31:0]                 out_Index;
    wire [2*`PFN_width-1:0]     PFN_instruction;
    wire [1:0]                  PFN_instruction_valid;
    wire [2*`PFN_width-1:0]     PFN_data;
    wire [1:0]                  PFN_data_valid;
    wire [1:0]                  PFN_data_D;

    wire                        instruction_sel;
    wire                        data_sel;
    wire [31:0]                 after_sel_PFN_instruction;
    wire [31:0]                 after_sel_PFN_data;
    wire [31:0]                 offset_instruction;
    wire [31:0]                 offset_data;

    wire                        TLB_miss_instruction_temp;
    wire                        TLB_miss_data_temp;

    assign VPN_instruction  = Virtual_addr_instruction[31:13];
    assign instruction_sel  = Virtual_addr_instruction[12];
    assign VPN_data         = Virtual_addr_data[31:13];
    assign data_sel         = Virtual_addr_data[12];

    assign in_EntryHi       = in_tlb_config[31:0];
    assign in_EntryLo0      = in_tlb_config[63:32];
    assign in_EntryLo1      = in_tlb_config[95:64];
    assign in_Index         = in_tlb_config[95+Entry_id_width:96];
    assign in_Random        = in_tlb_config[101+Entry_id_width:102];

    TLB #(.TLB_entry_num(TLB_entry_num), .Entry_id_width(Entry_id_width))
        inst_TLB (rst, clk, op_type, VPN_instruction, VPN_data, in_EntryHi, in_EntryLo0, in_EntryLo1, in_Index, in_Random, unmapped_instruction, unmapped_data, load_store,
                    out_EntryHi, out_EntryLo0, out_EntryLo1, out_Index, PFN_instruction, PFN_instruction_valid, PFN_data, PFN_data_valid, TLB_miss_instruction_temp, TLB_miss_data_temp, PFN_data_D);

    assign out_tlb_config = {out_Index, out_EntryLo1, out_EntryLo0, out_EntryHi};

    assign TLB_miss_instruction     =   unmapped_instruction ? 1'b0 : TLB_miss_instruction_temp;
    assign TLB_miss_data            =   (~load_store | unmapped_data)        ? 1'b0 : TLB_miss_data_temp;
    assign TLB_invalid_instruction  =   unmapped_instruction ? 1'b0 :
                                        instruction_sel     ?   ~PFN_instruction_valid[1]   :   ~PFN_instruction_valid[0];
    assign TLB_invalid_data         =   (~load_store | unmapped_data)        ? 1'b0 :
                                        data_sel            ?   ~PFN_data_valid[1]          :   ~PFN_data_valid[0];
    assign TLB_forbid_modify        =   (~load_store | unmapped_data)        ? 1'b0 :
                                        data_sel            ?   ~PFN_data_D[1]              :   ~PFN_data_D[0];

    assign after_sel_PFN_instruction =  {(instruction_sel ? PFN_instruction[43:24] : PFN_instruction[19:0]), 12'b0};
    assign Physical_addr_instruction =  unmapped_instruction ? Virtual_addr_instruction : (after_sel_PFN_instruction | {20'b0, Virtual_addr_instruction[11:0]});

    assign after_sel_PFN_data = {(data_sel ? PFN_data[43:24] : PFN_data[19:0]), 12'b0};
    assign Physical_addr_data = (~load_store | unmapped_data) ? Virtual_addr_data : (after_sel_PFN_data | {20'b0, Virtual_addr_data[11:0]});
endmodule

module TLB #
(
    parameter TLB_entry_num = 16,       // num of tlb lines.
    parameter Entry_id_width = 4       // width of the index for tlb lines
)
(
    input                               rst,
    input                               clk,
    input   [2:0]                       op_type,            //001:TLBR,  010:TLBWI,  011:TLBWR  ,100:TLBP
    input   [`VPN_width-1:0]            in_VPN_instruction, // sel:[0], a tlb line includes 2 reflections from VPN to PFN, so that we need a bit signal to select
    input   [`VPN_width-1:0]            in_VPN_data,

    input [31:0]                        in_EntryHi,     // include VPN & ASID
    input [31:0]                        in_EntryLo0,    // PFN1 & its flags
    input [31:0]                        in_EntryLo1,    // PFN2 & its flags
    input [Entry_id_width-1:0]          in_Index,
    input [Entry_id_width-1:0]          in_Random,
    input                               unmapped_instruction,
    input                               unmapped_data,
    input                               load_store,         //1 means this operation is load or store, need to fetch 

    output [31:0]                       out_EntryHi,
    output [31:0]                       out_EntryLo0,
    output [31:0]                       out_EntryLo1,
    output [31:0]                       out_Index,
    output [2*`PFN_width-1:0]           out_PFN_instruction,
    output [1:0]                        out_PFN_instruction_valid,
    output [2*`PFN_width-1:0]           out_PFN_data,
    output [1:0]                        out_PFN_data_valid,
    output                              TLB_miss_instruction,
    output                              TLB_miss_data,
    output [1:0]                        out_PFN_data_D
);
     
    wire [TLB_entry_num-1:0]    Which_line_index;
    wire [TLB_entry_num-1:0]    Which_line_random;
    wire [TLB_entry_num-1:0]    entry_hit_instruction;
    wire [TLB_entry_num-1:0]    entry_hit_data;
    wire [TLB_entry_num-1:0]    TLBP_hit;

    genvar gv_i;
    generate
        for(gv_i = 0; gv_i < TLB_entry_num; gv_i = gv_i+1)    
            begin:  TLB_line
                TLB_each_line entry(rst, clk, in_VPN_instruction, in_VPN_data, op_type, Which_line_index[gv_i], Which_line_random[gv_i], in_EntryHi, in_EntryLo0, in_EntryLo1, unmapped_instruction, unmapped_data, load_store,
                    entry_hit_instruction[gv_i], entry_hit_data[gv_i], out_PFN_data_D, TLBP_hit[gv_i], out_PFN_instruction, out_PFN_instruction_valid, out_PFN_data, out_PFN_data_valid, out_EntryHi, out_EntryLo0, out_EntryLo1);
            end
    endgenerate

    my_decoder #(.output_width(TLB_entry_num), .input_width(Entry_id_width))
        bianma_index(in_Index, Which_line_index);
    my_decoder #(.output_width(TLB_entry_num), .input_width(Entry_id_width))
        bianma_random(in_Random, Which_line_random);

    my_encoder #(.output_width(32), .input_width(TLB_entry_num))
        yima(TLBP_hit, out_Index);

    // output signals
    assign TLB_miss_instruction     =   ~(|entry_hit_instruction);
    assign TLB_miss_data            =   ~(|entry_hit_data);
endmodule
    
module my_decoder #
(
    parameter output_width = 16, 
    parameter input_width = 4 
)
(
	input wire[input_width-1:0] in_data,
	output reg[output_width-1:0] out_data
);
	integer i;
	always @(*) begin
		for (i=0; i<output_width; i=i+1) begin
			if (in_data==i)     out_data[i]<=1;
			else                out_data[i]<=0;
		end
	end
endmodule

module my_encoder #
(
    parameter output_width = 16, 
    parameter input_width = 4 
)
(
	input wire[input_width-1:0] in_data,
	output reg[output_width-1:0] out_data
);
    initial begin out_data  <=  32'd0;  end
    integer i;
	always @(*) begin
		for (i=0; i<input_width; i=i+1) begin
			if (in_data[i]==1)      out_data<=i;
		end
	end
endmodule