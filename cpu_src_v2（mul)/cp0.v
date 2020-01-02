`timescale 1 ns / 1 ps

`define cp0_Index       {5'd0,3'd0}
`define cp0_Random      {5'd1,3'd0}
`define cp0_EntryLo0    {5'd2,3'd0}
`define cp0_EntryLo1    {5'd3,3'd0}
`define cp0_Context     {5'd4,3'd0}
`define cp0_PageMask    {5'd5,3'd0}
`define cp0_BadVAddr    {5'd8,3'd0}
`define cp0_EntryHi     {5'd10,3'd0}
`define cp0_Compare     {5'd11,3'd0}
`define cp0_Status      {5'd12,3'd0}
`define cp0_Cause       {5'd13,3'd0}
`define cp0_EPC         {5'd14,3'd0}
`define cp0_EBase       {5'd15,3'd1}
`define cp0_Config1     {5'd16,3'd1}
`define cp0_Config4     {5'd16,3'd4}
`define cp0_ErrEPC      {5'd30,3'd0}

module cp0 #
(
    parameter in_tlb_config_width = 160,
    parameter out_tlb_config_width = 142,
    parameter TLB_Entry_num = 16
)
(
    input   cp0_enable,

    input   clk,
    input   rst,
    input   write_enable,
    input   [4:0]read_reg_num,
    input   [2:0]read_reg_sel,
    input   [4:0]write_reg_num,
    input   [2:0]write_reg_sel,
    input   [31:0]write_data,
    input   [in_tlb_config_width-1:0]in_tlb_config,
    input   tlbp,
    input   tlbr,
    input   is_exception,
    input   BadVAddr_write_enable,
    input   Context_BadVPN2_write_enable,
    input   EntryHi_VPN2_write_enable,
    input   [31:0]EPC_from_exception,
    input   [4:0]Cause_ExcCode_from_exception,
    input   [31:0]BadVAddr_from_exception,
    input   [18:0]Context_BadVPN2_from_exception,
    input   [18:0]EntryHi_VPN2_from_exception,
    input   in_delayslot,
    input   eret,
    output  [out_tlb_config_width-1:0]out_tlb_config,
    output  [31:0]read_data,
    output  [31:0]out_EPC,
    output  [31:0]out_ErrEPC,
    output  [31:0]out_Status,
    output  [31:0]out_EBase,
    output  [31:0]out_Cause,
    output  [31:0]eret_pc
);

    wire [31:0] in_tlb_config_EntryHi;
    wire [31:0] in_tlb_config_EntryLo0;
    wire [31:0] in_tlb_config_EntryLo1;
    wire [31:0] in_tlb_config_Index;
    //wire [31:0] in_tlb_config_PageMask;
    

    reg [31:0]  cp0_reg_Index;
    reg [31:0]  cp0_reg_Random;
    reg [31:0]  cp0_reg_EntryLo0;
    reg [31:0]  cp0_reg_EntryLo1;
    //reg [31:0]  cp0_reg_PageMask;
    reg [31:0]  cp0_reg_EntryHi;
    reg [31:0]  cp0_reg_Compare;
    reg [31:0]  cp0_reg_Config1;
    reg [31:0]  cp0_reg_Config4;
    reg [31:0]  cp0_reg_EPC;
    reg [31:0]  cp0_reg_ErrEPC;
    reg [31:0]  cp0_reg_Status;
    reg [31:0]  cp0_reg_EBase;
    reg [31:0]  cp0_reg_Cause;
    reg [31:0]  cp0_reg_BadVAddr;
    reg [31:0]  cp0_reg_Context;

    wire [31:0]  cp0_reg_Index_temp;
    wire [31:0]  cp0_reg_Random_temp;
    wire [31:0]  cp0_reg_EntryLo0_temp;
    wire [31:0]  cp0_reg_EntryLo1_temp;
    //wire [31:0]  cp0_reg_PageMask_temp;
    wire [31:0]  cp0_reg_EntryHi_temp;
    wire [31:0]  cp0_reg_Compare_temp;
    wire [31:0]  cp0_reg_Config4_temp;
    wire [31:0]  cp0_reg_EPC_temp;
    wire [31:0]  cp0_reg_ErrEPC_temp;
    wire [31:0]  cp0_reg_Status_temp;
    wire [31:0]  cp0_reg_EBase_temp;
    wire [31:0]  cp0_reg_Cause_temp;
    wire [31:0]  cp0_reg_BadVAddr_temp;
    wire [31:0]  cp0_reg_Context_temp;

    initial begin
            cp0_reg_Index               <=  0;
            cp0_reg_Random              <=  TLB_Entry_num - 1;
            cp0_reg_EntryLo0            <=  0;
            cp0_reg_EntryLo1            <=  0;
            //cp0_reg_PageMask            <=  0;
            cp0_reg_EntryHi             <=  0;
            cp0_reg_Compare             <=  0;
            cp0_reg_Config1[30:25]      <=  TLB_Entry_num - 1;
            {cp0_reg_Config1[31],cp0_reg_Config1[24:0]} <= 0;
            cp0_reg_Config4             <=  0;
            cp0_reg_EPC                 <=  0;
            cp0_reg_ErrEPC              <=  EPC_from_exception;
            cp0_reg_Status              <=  32'h00400001; //BEV=1,IE=1 is required for FuncTest
            cp0_reg_EBase               <=  32'h80000000;
            cp0_reg_Cause               <=  0;
            cp0_reg_BadVAddr            <=  0;
            cp0_reg_Context             <=  0;
    end

    assign in_tlb_config_EntryHi    = in_tlb_config[31:0];
    assign in_tlb_config_EntryLo0   = in_tlb_config[63:32];
    assign in_tlb_config_EntryLo1   = in_tlb_config[95:64];
    assign in_tlb_config_Index      = in_tlb_config[127:96];
    //assign in_tlb_config_PageMask   = in_tlb_config[159:128];
    assign out_tlb_config           = {cp0_reg_Random[5:0], cp0_reg_Index[5:0], cp0_reg_EntryLo1, cp0_reg_EntryLo0, cp0_reg_EntryHi};
    assign out_EPC                  = cp0_reg_EPC;
    assign out_ErrEPC               = cp0_reg_ErrEPC;
    assign out_Status               = cp0_reg_Status;
    assign out_EBase                = {2'b10, cp0_reg_EBase[29:12], 12'b0};  //异常基址
    assign out_Cause                = cp0_reg_Cause;

    //读CP0相关寄存�??????????
    assign read_data = ({read_reg_num, read_reg_sel} == `cp0_Index)     ? cp0_reg_Index :
                        ({read_reg_num, read_reg_sel} == `cp0_Random)   ? cp0_reg_Random :
                        ({read_reg_num, read_reg_sel} == `cp0_EntryLo0) ? cp0_reg_EntryLo0:
                        ({read_reg_num, read_reg_sel} == `cp0_EntryLo1) ? cp0_reg_EntryLo1:
                        //({read_reg_num, read_reg_sel} == `cp0_PageMask) ? cp0_reg_PageMask:
                        ({read_reg_num, read_reg_sel} == `cp0_EntryHi)  ? cp0_reg_EntryHi:
                        ({read_reg_num, read_reg_sel} == `cp0_Compare)  ? cp0_reg_Compare:
                        ({read_reg_num, read_reg_sel} == `cp0_Config1)  ? cp0_reg_Config1:
                        ({read_reg_num, read_reg_sel} == `cp0_Config4)  ? cp0_reg_Config4 :
                        ({read_reg_num, read_reg_sel} == `cp0_EPC)      ? cp0_reg_EPC :
                        ({read_reg_num, read_reg_sel} == `cp0_ErrEPC)   ? cp0_reg_ErrEPC :
                        ({read_reg_num, read_reg_sel} == `cp0_Status)   ? cp0_reg_Status :
                        ({read_reg_num, read_reg_sel} == `cp0_EBase)    ? {2'b10, cp0_reg_EBase[29:12], 12'b0} :
                        ({read_reg_num, read_reg_sel} == `cp0_Cause)    ? cp0_reg_Cause :
                        ({read_reg_num, read_reg_sel} == `cp0_BadVAddr) ? cp0_reg_BadVAddr :
                        ({read_reg_num, read_reg_sel} == `cp0_Context)  ? cp0_reg_Context : 0;

    //写CP0相关寄存�??????????
    always @(posedge clk) begin
        if(~rst)    begin
            cp0_reg_Index               <=  0;
            cp0_reg_Random              <=  TLB_Entry_num - 1;
            cp0_reg_EntryLo0            <=  0;
            cp0_reg_EntryLo1            <=  0;
            //cp0_reg_PageMask            <=  0;
            cp0_reg_EntryHi             <=  0;
            cp0_reg_Compare             <=  0;
            cp0_reg_Config1[30:25]      <=  TLB_Entry_num - 1;
            {cp0_reg_Config1[31],cp0_reg_Config1[24:0]} <= 0;
            cp0_reg_Config4             <=  0;
            cp0_reg_EPC                 <=  0;
            cp0_reg_ErrEPC              <=  EPC_from_exception;
            cp0_reg_Status              <=  32'h00400001; //BEV=1,IE=1 is required for FuncTest
            cp0_reg_EBase               <=  32'h80000000;
            cp0_reg_Cause               <=  0;
            cp0_reg_BadVAddr            <=  0;
            cp0_reg_Context             <=  0;
        end
        else if(cp0_enable) begin
            cp0_reg_Index          <=  cp0_reg_Index_temp;
            cp0_reg_Random         <=  cp0_reg_Random_temp;
            cp0_reg_EntryLo0       <=  cp0_reg_EntryLo0_temp;
            cp0_reg_EntryLo1       <=  cp0_reg_EntryLo1_temp;
            //cp0_reg_PageMask       <=  cp0_reg_PageMask_temp;
            cp0_reg_EntryHi        <=  cp0_reg_EntryHi_temp;
            cp0_reg_Compare        <=  cp0_reg_Compare_temp;
            cp0_reg_Config4        <=  cp0_reg_Config4_temp;
            cp0_reg_EPC            <=  cp0_reg_EPC_temp;
            cp0_reg_ErrEPC         <=  cp0_reg_ErrEPC_temp;
            cp0_reg_Status         <=  cp0_reg_Status_temp;
            cp0_reg_EBase          <=  cp0_reg_EBase_temp;
            cp0_reg_Cause          <=  cp0_reg_Cause_temp;
            cp0_reg_BadVAddr       <=  cp0_reg_BadVAddr_temp;
            cp0_reg_Context        <=  cp0_reg_Context_temp;
        end
    end

    assign cp0_reg_Index_temp           =   tlbp ? in_tlb_config_Index :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Index)) ? write_data : cp0_reg_Index;
    assign cp0_reg_Random_temp          =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Random)) ? write_data : cp0_reg_Random;
    assign cp0_reg_EntryLo0_temp        =   tlbr ? in_tlb_config_EntryLo0 :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_EntryLo0)) ? write_data : cp0_reg_EntryLo0;
    assign cp0_reg_EntryLo1_temp        =   tlbr ? in_tlb_config_EntryLo1 :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_EntryLo1)) ? write_data : cp0_reg_EntryLo1;
    //assign cp0_reg_PageMask_temp        =   tlbr ? in_tlb_config_PageMask :
    //                                        (write_enable & ({write_reg_num, write_reg_sel}==`cp0_PageMask)) ? write_data : cp0_reg_PageMask;
    assign cp0_reg_EntryHi_temp         =   (is_exception & EntryHi_VPN2_write_enable) ? {EntryHi_VPN2_from_exception, cp0_reg_EntryHi[12:0]} :
                                            tlbr ? in_tlb_config_EntryHi :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_EntryHi)) ? write_data : cp0_reg_EntryHi;
    assign cp0_reg_Compare_temp         =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Compare)) ? write_data : cp0_reg_Compare;
    assign cp0_reg_Config4_temp         =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Config4)) ? write_data : cp0_reg_Config4;
    assign cp0_reg_EPC_temp             =   (is_exception & ~cp0_reg_Status[1]) ? EPC_from_exception :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_EPC))     ? write_data : cp0_reg_EPC;
    assign cp0_reg_ErrEPC_temp          =   is_exception ? EPC_from_exception :
                                            (write_enable & ({write_reg_num, write_reg_sel}==`cp0_ErrEPC))  ? write_data : cp0_reg_ErrEPC;
    assign cp0_reg_Status_temp          =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Status))  ? write_data : 
                                            (eret & cp0_reg_Status[2]) ? {cp0_reg_Status[31:3],1'b0,cp0_reg_Status[1:0]} :
                                            (eret & ~(cp0_reg_Status[2])) ? {cp0_reg_Status[31:2],1'b0,cp0_reg_Status[0]} : cp0_reg_Status;
    assign cp0_reg_EBase_temp           =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_EBase))    ? {2'b10,write_data[29:12],12'b0} : cp0_reg_EBase;
    assign cp0_reg_Cause_temp[31]       =   (is_exception & ~cp0_reg_Status[1]) ? in_delayslot : cp0_reg_Cause[31];
    assign cp0_reg_Cause_temp[30:7]     =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Cause))   ? {7'b0,write_data[23],13'h0,write_data[9:8],1'b0} : cp0_reg_Cause[30:7];
    assign cp0_reg_Cause_temp[6:0]      =   is_exception ? {Cause_ExcCode_from_exception, 2'b0} : {cp0_reg_Cause[6:2],2'b0};   //记录异常原因
    assign cp0_reg_Context_temp[31:23]  =   (write_enable & ({write_reg_num, write_reg_sel}==`cp0_Context)) ? write_data[31:23] : cp0_reg_Context[31:23];
    assign cp0_reg_Context_temp[22:0]   =   (is_exception & Context_BadVPN2_write_enable) ? {Context_BadVPN2_from_exception,4'b0} : {cp0_reg_Context[22:4],4'b0};
    assign cp0_reg_BadVAddr_temp        =   (is_exception & BadVAddr_write_enable) ? BadVAddr_from_exception : cp0_reg_BadVAddr;
    assign eret_pc                      =   cp0_reg_Status[2] ? cp0_reg_ErrEPC : cp0_reg_EPC;
endmodule
            