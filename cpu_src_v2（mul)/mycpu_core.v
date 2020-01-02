
module mycpu_core #
(
	parameter CONTROL_BUS_WIDTH = 35,
	parameter CP0_to_MMU_tlb_config_width = 108,
	parameter MMU_to_CP0_tlb_config_width = 128,
	parameter TLB_entry_num = 4,       // num of tlb lines.
	parameter Entry_id_width = 2,       // width of the index for tlb lines
	
	//cache_axi
	parameter CPU_D_CACHE_LINE_WIDTH = 6,   //width of cacheline
    parameter CPU_D_TAG_WIDTH = 20,         //width of tag
    parameter CPU_D_NUM_ROADS = 2,          //num of cacheline in one group
    parameter CPU_I_CACHE_LINE_WIDTH = 6,
    parameter CPU_I_TAG_WIDTH = 20,
    parameter CPU_I_NUM_ROADS = 2
)
(
	// cpuʱ�Ӻ͸�λ�ź�
	input wire 				aclk,
    input wire 				aresetn,
	
	// �ⲿӲ���ж�����
	input	[5:0]			interrupt,
	
	// AXI4����
	// ����ַͨ��
    output 	[3:0]			arid,
    output 	[31:0]			araddr,
    output 	[7:0]			arlen,
    output 	[2:0]			arsize,
    output 	[1:0]			arburst,
    output 	[1:0]			arlock,
    output 	[3:0]			arcache,
    output 	[2:0]			arprot,
    output 					arvalid,
    input wire 				arready,
	// ������ͨ��
    input 	[3:0]			rid,
    input 	[31:0]			rdata,
    input 	[1:0]			rresp,
    input 					rlast,
    input 					rvalid,
    output 					rready,
	// д��ַͨ��
    output 	[3:0]			awid,
    output 	[31:0]			awaddr,
    output 	[7:0]			awlen,
    output 	[2:0]			awsize,
    output 	[1:0]			awburst,
    output 	[1:0]			awlock,
    output 	[3:0]			awcache,
    output 	[2:0]			awprot,
    output 					awvalid,
    input 					awready,
	// д����ͨ��
    output 	[3:0]			wid,
    output 	[31:0]			wdata,
    output 	[3:0]			wstrb,
    output 					wlast,
    output 					wvalid,
    input 					wready,
	// д��Ӧͨ��
    input 	[3:0]			bid,
    input 	[1:0]			bresp,
    input 					bvalid,
    output 					bready
	
    //debug interface
    //output 	[31:0]			debug_wb_pc,
    //output 	[3:0]			debug_wb_rf_wen,
    //output 	[4:0]			debug_wb_rf_wnum,
    //output 	[31:0]			debug_wb_rf_wdata
);

	//----global---
	reg 					rst;
	wire 					rst_pc;
	wire 					rst_ifid;
	wire 					rst_idex;
	wire 					rst_exmem;
	wire 					rst_memwb;
	wire 					pc_enable;
	wire 					ifid_enable;
	wire 					idex_enable;
	wire 					exmem_enable;
	wire 					memwb_enable;
	wire 					ins_stall;
    wire 					data_stall;
    wire 					load_use;
    wire 					is_diving;
    wire 					special_pop;

	//-----if stage---
	wire   [31:0]			pc_if;
	wire   [31:0]			instruction_if;
	wire 					illegal_pc_if;
	wire 					in_delayslot_if;
	wire   [31:0]			physical_pc;   

	//-----id stage---
	wire 	[31:0]			instruction_id;
	wire 	[31:0]			pc_id;
	wire 	[4:0]			rs_id;
	wire 	[4:0]			rt_id;
	wire 	[4:0]			rd_id;
	wire 	[5:0]			op_id;
	wire 	[5:0]			func_id;
	wire 	[15:0]			imm16_id;
	wire 	[25:0]			imm26_id;
	wire 	[31:0]			imm32_id;
	wire 	[4:0]			shamt_id;
	wire 	[2:0]			sel_id;
	wire 	[`CONTROL_BUS_WIDTH:0]	control_id;
	wire	[2:0]			tlb_op_id;
	wire 	[10:0]			bj_num_id;
	wire 	[31:0]			rdata1_id;
	wire 	[31:0]			rdata2_id;
	wire 	[31:0]			real_rdata1_id;
	wire 	[31:0]			real_rdata2_id;
	wire 					is_bj_id;
	wire 	[31:0]			bj_address_id;
	wire 	[1:0]			ext_sel_id;
	wire 					r1_sel_id;
	wire 					r2_sel_id;
	wire 	[4:0]			r1_id;
	wire 	[4:0]			r2_id;
	wire 	[1:0]			rw_sel_id;
	wire 	[4:0]			rw_id;
	wire 	[63:0]			hilo_id;
	wire 	[63:0]			real_hilo_id;
	wire 					r1_r_id;
	wire 					r2_r_id;
	wire 					illegal_pc_id;
	wire 					in_delayslot_id;

	//-----ex stage---
	wire 	[`CONTROL_BUS_WIDTH:0]	control_ex;
	wire 	[4:0]			r1_ex;
	wire 	[4:0]			r2_ex;
	wire 	[4:0]			rw_ex;
	wire 	[31:0]			rdata1_ex;
	wire 	[31:0]			rdata2_ex;
	wire 	[31:0]			imm32_ex;
	wire 	[31:0]			pc_ex;
	wire 	[2:0]			sel_ex;
	wire 	[63:0]			hilo_ex;
	wire 	[31:0]			cp0_data_ex;
	wire 	[4:0]			rd_ex;
	wire 	[31:0]			alu_a_ex;
	wire 	[31:0]			alu_b_ex;
	wire 	[4:0]			aluop_ex;
	wire 	[1:0]			add_sub_ex;
	wire 	[31:0]			alu_r1_ex;
	wire 	[31:0]			alu_r2_ex;
	wire 	[31:0]			alu_r1_ex_no_mult_ex;
	wire 	[31:0]			alu_r2_ex_no_mult_ex;
	wire 					overflow_ex;
	wire 	[1:0]			alua_sel_ex;
	wire 	[1:0]			alub_sel_ex;
	wire 					illegal_pc_ex;
	wire 					in_delayslot_ex;
	wire 					load_ex;
	wire 	[2:0]			din_sel_ex;
	wire 	[2:0] 			load_store_ex;
	wire 	[1:0]			hilo_mode_ex;
	wire   	[4:0]           lsb_ex;

	//-----mem stage--
	wire 	[`CONTROL_BUS_WIDTH:0]	control_mem;
	wire 	[4:0]			rw_mem;
	wire 	[31:0]			alu_r1_mem;
	wire 	[31:0]			alu_r2_mem;
	wire 	[31:0]			rdata1_mem;
	wire 	[31:0]			rdata2_mem;
	wire 	[31:0]			pc_mem;
	wire 	[2:0]			sel_mem;
	wire 	[63:0]			hilo_mem;
	wire 	[31:0]			cp0_data_mem;
	wire 	[4:0]			rd_mem;
	wire 					overflow_mem;
	wire 	[31:0]			DMout_mem;
	wire 	[3:0]			mode_mem;
	wire 					load_mem;
	wire 	[1:0]			hilo_mode_mem;
	wire 	[2:0]			load_store_mem;
	wire 	[31:0]			dram_wdata_mem;
	wire 					data_addr_illegal_mem;
	wire 					illegal_pc_mem;
	wire 	[2:0]			din_sel_mem;
	wire 					not_nop_mem;
	wire 	[31:0]			physical_dm_addr;

	//-----wb stage---
	wire 	[`CONTROL_BUS_WIDTH:0]	control_wb;
	wire 	[4:0]			rw_wb;
	wire 	[31:0]			alu_r1_wb;
	wire 	[31:0]			alu_r2_wb;
	wire 	[31:0]			DMout_wb;
	wire 	[31:0]			real_DMout_wb;
	wire 	[31:0]			pc_wb;
	wire 	[2:0]			sel_wb;
	wire 	[63:0]			hilo_wb;
	wire 	[31:0]			cp0_data_wb;
	wire 	[31:0]			rdata1_wb;
	wire 	[31:0]			rdata2_wb;
	wire 	[4:0]			rd_wb;
	wire 	[31:0]			reg_din_wb;
	wire 	[1:0]			hilo_mode_wb;
	wire 	[2:0]			din_sel_wb;
	wire 					reg_we_wb;
	wire					cp0_we_wb;
	wire 	[2:0]			load_store_wb;
	
	//cp0 exception
	wire 	[31:0]			cp0_data_id;
	wire 	[31:0]			cp0_EBase;
	wire 	[31:0]			cp0_EPC;
	wire   	[31:0]          cp0_ErrEPC;
	wire	[31:0]			cp0_Status;
	wire	[31:0]			cp0_Cause;
	wire					BadVAddr_write_enable;
	wire					Context_BadVPN2_write_enable;
	wire					EntryHi_VPN2_write_enable;
	wire 	[31:0]			EPC_to_cp0;
	wire	[4:0]			Cause_ExcCode_to_cp0;
	wire	[31:0]			BadVAddr_to_cp0;
	wire	[18:0]			Context_BadVPN2_to_cp0;
	wire	[18:0]			EntryHi_VPN2_to_cp0;

	wire 					is_exception_to_cp0;

	wire 					is_exception_mem;
	wire 	[31:0]			exception_new_pc;
	wire	[31:0]			eret_pc;
	
	wire 					invalid_inst_mem;
	wire 					syscall_mem;
	wire 					break_mem;
	wire 					eret_mem;
	wire 					in_delayslot_mem;
	
	//MMU
	wire   [CP0_to_MMU_tlb_config_width-1:0]   cp0_to_mmu_tlb_config;
    wire   [31:0]          	mapped_pc_data;
    wire                   	unmapped_data;
    wire                    uncache_data;
    wire   [MMU_to_CP0_tlb_config_width-1:0]   mmu_to_cp0_tlb_config;
    wire   [31:0]          	mapped_pc_instruction;
    wire                   	unmapped_instruction;  
	wire					TLB_miss_instruction;
	wire					TLB_invalid_instruction;
	wire					TLB_miss_data;
	wire					TLB_invalid_data;
	wire					TLB_forbid_modify;
	
	initial begin 	
		rst<=0;	
	end

	// pipeline stall signals
	assign pc_enable    = ~(data_stall | ins_stall | is_diving | special_pop | load_use & (~(is_exception_mem|eret_mem)) | (control_id[12] | control_ex[12] | control_mem[12]));	
	assign ifid_enable  = ~(data_stall | ins_stall | is_diving | special_pop | load_use & (~(is_exception_mem|eret_mem)));
	assign idex_enable  = ~(data_stall | ins_stall | is_diving | special_pop);
	assign exmem_enable = ~(data_stall | ins_stall | is_diving);
	assign memwb_enable = ~(data_stall | ins_stall | is_diving);

	// reset signals
	assign rst_pc    = aresetn;
	assign rst_ifid  = aresetn & (~ifid_enable | rst & ~(is_exception_mem|eret_mem) & ~((~is_bj_id)&bj_num_id[10]) & ~(control_id[12] | control_ex[12] | control_mem[12]));
	assign rst_idex  = aresetn & (~idex_enable | rst & ~load_use & ~(is_exception_mem|eret_mem) & ~(control_ex[12] | control_mem[12]));
	assign rst_exmem = aresetn & (~exmem_enable | rst & ~special_pop & ~(is_exception_mem|eret_mem) & ~(control_mem[12])) ;
	assign rst_memwb = aresetn & (~memwb_enable | rst & ~(is_exception_mem|eret_mem));
	 
    // for debug
	//wire debug_reg_we_wb;
	//assign debug_wb_pc = pc_wb;
	//assign debug_wb_rf_wen = {debug_reg_we_wb,debug_reg_we_wb,debug_reg_we_wb,debug_reg_we_wb};
    //assign debug_reg_we_wb = reg_we_wb & memwb_enable;
	//assign debug_wb_rf_wnum = rw_wb;
	//assign debug_wb_rf_wdata = reg_din_wb;

	assign rw_sel_id  		= control_id[8:7];
	assign r1_sel_id  		= control_id[4];
	assign r2_sel_id  		= control_id[5];
	assign ext_sel_id 		= control_id[14:13];
	assign r1_r_id    		= control_id[19];
	assign r2_r_id    		= control_id[20];

	assign aluop_ex      	= {control_ex[34], control_ex[3:0]};
	assign alua_sel_ex   	= control_ex[16:15];
	assign alub_sel_ex   	= control_ex[18:17];
	assign load_ex       	= control_ex[21];
	assign add_sub_ex    	= control_ex[33:32];
	assign din_sel_ex    	= control_ex[11:9];
	assign load_store_ex 	= control_ex[31:29];
	assign hilo_mode_ex  	= control_ex[24:23];

	assign hilo_mode_mem    = control_mem[24:23];
	assign load_mem         = control_mem[21];
	assign eret_mem         = control_mem[27];
	assign break_mem        = control_mem[26];
	assign syscall_mem      = control_mem[25];
	assign invalid_inst_mem = control_mem[28];
	assign load_store_mem   = control_mem[31:29];
	assign din_sel_mem      = control_mem[11:9];
	assign not_nop_mem      = control_mem[22];

	assign hilo_mode_wb 	= control_wb[24:23];
	assign reg_we_wb 		= control_wb[6];
	assign cp0_we_wb 		= control_wb[12];
	assign din_sel_wb 		= control_wb[11:9];
	assign load_store_wb 	= control_wb[31:29];

	//------------global----------
	always @(posedge aclk) begin
		rst <= aresetn;
	end
	
	reg pcif_new_ins_tocache;
	always@(posedge aclk)begin
		if(!rst)begin
			pcif_new_ins_tocache <= 1'b1;
		end else begin
			pcif_new_ins_tocache <= pc_enable;
		end
	end
	
	reg mem_new_ins_tocache;
	always@(posedge aclk)begin
		if(!rst)begin
			mem_new_ins_tocache <= 1'b1;
		end else begin
			mem_new_ins_tocache <= exmem_enable;
		end
	end
	
	
	//------global components------
	conflict u_conflict(
		.r1_r_id			(r1_r_id),
		.r2_r_id			(r2_r_id),
		.r1_id				(r1_id),
		.r2_id				(r2_id),
		.rw_ex				(rw_ex),
		.rw_mem				(rw_mem),
		.load_ex			(load_ex),
		.load_mem			(load_mem),
		.conflict_stall		(load_use)
    );

	
	addr_map u_addr_map_pc(
		.addr_in			(pc_if),
		.addr_out			(mapped_pc_instruction),
		.unmapped			(unmapped_instruction),
		.uncache			()
	);
	
	addr_map u_addr_map_dm(
		.addr_in			(alu_r1_mem),
		.addr_out			(mapped_pc_data),
		.unmapped 			(unmapped_data),
		.uncache			(uncache_data)
	);
	
	MMU #
	(
		.in_tlb_config_width(CP0_to_MMU_tlb_config_width),
		.out_tlb_config_width(MMU_to_CP0_tlb_config_width),
		.TLB_entry_num(TLB_entry_num),
		.Entry_id_width(Entry_id_width)
	)
	cpu_mmu (
		//input							
		.rst							(rst),
		.clk							(aclk),
		.unmapped_instruction			(unmapped_instruction),
		.unmapped_data					(unmapped_data),
		.load_store						(load_mem | (|load_store_mem)),
		.op_type						(tlb_op_id),
		.Virtual_addr_instruction		(mapped_pc_instruction),
		.Virtual_addr_data				(mapped_pc_data),
		.in_tlb_config					(cp0_to_mmu_tlb_config),

		//output
		.out_tlb_config					(mmu_to_cp0_tlb_config),
		.Physical_addr_instruction		(physical_pc),
		.Physical_addr_data				(physical_dm_addr),
		.TLB_miss_instruction			(TLB_miss_instruction),
		.TLB_invalid_instruction		(TLB_invalid_instruction),
		.TLB_miss_data					(TLB_miss_data),
		.TLB_invalid_data				(TLB_invalid_data),
		.TLB_forbid_modify				(TLB_forbid_modify)
	);
	
	//------pipeline components------
	//------------IF stage-----------
	// cpu pc ����
	pc u_pc(
		.clk				(aclk),
		.resetn				(rst_pc),

      	.pc_en				(pc_enable),
		.is_branch			(is_bj_id),
      	.branch_address		(bj_address_id),
      	.is_exception		(is_exception_mem),
      	.exception_new_pc	(exception_new_pc),
		.is_eret			(eret_mem),
		.eret_pc			(eret_pc),
		
		.pc_reg(pc_if)
	);

	//------------IF_ID stage-----------
	IF_ID u_IF_ID(
	    .clk				(aclk),
		.rset				(rst_ifid),
		
	    .stall				(ifid_enable),
	    
	    .instruction_in		(instruction_if),
	    .PC_in				(pc_if),
	    .illegal_pc_in		(illegal_pc_if),
	    .in_delayslot_in 	(in_delayslot_if),

	    .instruction_out	(instruction_id),
	    .PC_out				(pc_id),
	    .illegal_pc_out		(illegal_pc_id),
	    .in_delayslot_out	(in_delayslot_id)
	);

	//--------------ID stage---------
	decoder u_decoder(
		.instruction		(instruction_id),

		.rs					(rs_id),
		.rt					(rt_id),
		.rd					(rd_id),
		.op					(op_id),
		.func				(func_id),
		.imm16				(imm16_id),
		.imm26				(imm26_id),
		.shamt				(shamt_id),
		.sel				(sel_id)
	);

	redirect_reg_id u_redirect_reg_id(
		.real_rdata1_id		(real_rdata1_id),
		.real_rdata2_id		(real_rdata2_id),
		
		.rdata1_id     		(rdata1_id),
		.rdata2_id     		(rdata2_id),
		.alu_r1_ex     		(alu_r1_ex_no_mult_ex),
		.alu_r1_mem    		(alu_r1_mem),
		.hilo_ex       		(hilo_ex),
		.hilo_mem      		(hilo_mem),
		.cp0_data_ex   		(cp0_data_ex),
		.cp0_data_mem  		(cp0_data_mem),
		.pc_ex         		(pc_ex),
		.pc_mem        		(pc_mem),
		.r1_r_id       		(r1_r_id),
		.r2_r_id       		(r2_r_id),
		.r1_id         		(r1_id),
		.r2_id         		(r2_id),
		.din_sel_ex    		(din_sel_ex),
		.din_sel_mem   		(din_sel_mem),
		.rw_ex         		(rw_ex),
		.rw_mem        		(rw_mem)
	);
	
	controller u_controller(
		.op					(op_id),
		.func				(func_id),
		.rs					(rs_id),
		.rt					(rt_id),
		.shamt      		(shamt_id),

		.control_bus		(control_id),
		.tlb_op				(tlb_op_id),
		.branch_jump		(bj_num_id),
		.in_delayslot		(in_delayslot_if)
	);

	extend u_extend(
		.ext_sel			(ext_sel_id),
		.shamt				(shamt_id),
		.imm16				(imm16_id),

		.imm32				(imm32_id)
	);

	regfiles u_regs(
		.clk				(aclk),
        .rst				(rst),
		
        .rdata1				(rdata1_id),
        .rdata2				(rdata2_id),

        .we					(reg_we_wb),
        .waddr				(rw_wb),
        .wdata				(reg_din_wb),
        .raddr1				(r1_id),
        .raddr2				(r2_id)
	);

	hilo_reg u_hilo_reg(
		.clk				(aclk),
        .resetn				(rst),
        
		.rdata				(hilo_id),
  
        .mode				(hilo_mode_wb),
        .rdata1_wb			(rdata1_wb),
        .alu_r1_wb			(alu_r1_wb),
        .alu_r2_wb			(alu_r2_wb)
    );

	reg_read_select u_reg_read_select(
		.rs_id				(rs_id),
		.rt_id				(rt_id),
		.r1_sel_id			(r1_sel_id),
		.r2_sel_id			(r2_sel_id),

		.r1					(r1_id),
		.r2					(r2_id)
    );

	reg_write_select u_reg_write_select(
		.rt_id				(rt_id),
		.rd_id				(rd_id),
		.rw_sel_id			(rw_sel_id),

		.rw					(rw_id)
    );

    Branch_Jump_ID	u_branch_jump(
	    .bj_type_ID			(bj_num_id[9:0]),
	    .num_a_ID			(real_rdata1_id),
	    .num_b_ID			(real_rdata2_id),
	    .imm_b_ID			(imm16_id),
	    .imm_j_ID			(imm26_id),
	    .JR_addr_ID			(real_rdata1_id),
	    .PC_ID				(pc_id),

	    .Branch_Jump		(is_bj_id),
	    .BJ_address			(bj_address_id)
	);

	special_pop u_special_pop(
		.load_store			(load_store_ex),
		.alu_r1_ex			(alu_r1_ex),
		.not_nop_mem		(not_nop_mem),

		.special_pop		(special_pop)
	);

	//------------ID_EX stage---------
	ID_EX u_ID_EX(
		//input
	    .clk				(aclk),
		.rset				(rst_idex),
		
	    .stall				(idex_enable),
	    
	    .control_signal_in	(control_id),
	    .register1_in		(r1_id),
	    .register2_in		(r2_id),
	    .registerW_in		(rw_id),
	    .value_A_in			(real_rdata1_id),
	    .value_B_in			(real_rdata2_id),
	    .value_Imm_in		(imm32_id),
	    .PC_in				(pc_id),
	    .sel_in				(sel_id),
	    .HILO_in			(real_hilo_id),
	    .cp0_data_in		(cp0_data_id),
	    .cp0_rw_reg_in		(rd_id),
	    .illegal_pc_in     	(illegal_pc_id),
	    .in_delayslot_in   	(in_delayslot_id),
		.lsb_in 			(shamt_id),
	
		//ouput
	    .control_signal_out	(control_ex),
	    .register1_out		(r1_ex),
	    .register2_out		(r2_ex),
	    .registerW_out		(rw_ex),
	    .value_A_out		(rdata1_ex),
	    .value_B_out		(rdata2_ex),
	    .value_Imm_out		(imm32_ex),
	    .PC_out				(pc_ex),
	    .sel_out			(sel_ex),
	    .HILO_out			(hilo_ex),
	    .cp0_data_out		(cp0_data_ex),
	    .cp0_rw_reg_out		(rd_ex),
	    .illegal_pc_out    	(illegal_pc_ex),
	    .in_delayslot_out  	(in_delayslot_ex),
		.lsb_out			(lsb_ex)
	);

	//--------------EX stage---------
	ALU u_alu(
	    .X					(alu_a_ex),
	    .Y					(alu_b_ex),
	    .S					(aluop_ex),
		.msb				(rd_ex),
		.lsb 				(lsb_ex),
	    .add_sub			(add_sub_ex),
	    .rst     			(rst),
	    .flush   			(is_exception_mem),
	    .clk     			(aclk),

		.Result1        	(alu_r1_ex),
		.Result2        	(alu_r2_ex),
		.Result1_no_mult	(alu_r1_ex_no_mult_ex),
		.Result2_no_mult	(alu_r2_ex_no_mult_ex),
	    .overflow			(overflow_ex),
	    .is_diving			(is_diving)
    );
    
    alu_select u_alu_select(
		.alua_sel_ex		(alua_sel_ex),
		.alub_sel_ex		(alub_sel_ex),
		.rdata1_ex			(rdata1_ex),
		.rdata2_ex			(rdata2_ex),
		.extern_ex			(imm32_ex),

		.alu_a				(alu_a_ex),
		.alu_b				(alu_b_ex)
    );

    redirect_hilo_id u_redirect_hilo_id(
    	.hilo_id      		(hilo_id),
    	.alu_r1_ex    		(alu_r1_ex),
    	.alu_r2_ex    		(alu_r2_ex),
    	.alu_r1_mem   		(alu_r1_mem),
    	.alu_r2_mem   		(alu_r2_mem),
    	.rdata1_ex    		(rdata1_ex),
    	.rdata1_mem   		(rdata1_mem),
    	.hilo_mode_ex 		(hilo_mode_ex),
    	.hilo_mode_mem		(hilo_mode_mem),
		
    	.real_hilo_id 		(real_hilo_id)
	);

	//------------EX_MEM stage---------	
	EX_MEM _EX_MEM(
		//input
	    .clk				(aclk),
		.rset				(rst_exmem),
	    .stall				(exmem_enable),
	    
	    .control_signal_in	(control_ex),
	    .registerW_in		(rw_ex),
	    .value_ALU_in	   	(alu_r1_ex),
	    .value_ALU2_in     	(alu_r2_ex),
	    .rdata1_in         	(rdata1_ex),
	    .rdata2_in		   	(rdata2_ex),
	    .PC_in				(pc_ex),
	    .sel_in				(sel_ex),
	    .HILO_in			(hilo_ex),
	    .cp0_data_in		(cp0_data_ex),
	    .cp0_rw_reg_in     	(rd_ex),
	    .overflow_in       	(overflow_ex),
	    .illegal_pc_in     	(illegal_pc_ex),
	    .in_delayslot_in   	(in_delayslot_ex),
	
		//ouput
	    .control_signal_out	(control_mem),
	    .registerW_out		(rw_mem),
	    .value_ALU_out 	   	(alu_r1_mem),
	   	.value_ALU2_out    	(alu_r2_mem),
	   	.rdata1_out        	(rdata1_mem),
	    .rdata2_out		   	(rdata2_mem),
	    .PC_out				(pc_mem),
	    .sel_out			(sel_mem),
	    .HILO_out			(hilo_mem),
	    .cp0_data_out		(cp0_data_mem),
	    .cp0_rw_reg_out    	(rd_mem),
	    .overflow_out      	(overflow_mem),
	    .illegal_pc_out    	(illegal_pc_mem),
	    .in_delayslot_out  	(in_delayslot_mem)
	);

	//------------MEM stage--------
	dram_mode u_dram_mode(
		.load_store_mem				(load_store_mem),
		.data_sram_addr_byte_mem	(alu_r1_mem[1:0]),

		.mode_mem					(mode_mem)
	);

	dm_in_select u_dm_in_select(
		.rdata2_mem					(rdata2_mem),
		.load_store_mem				(load_store_mem),
		.data_sram_addr_byte_mem	(alu_r1_mem[1:0]),

		.dram_wdata_mem				(dram_wdata_mem)
	);
	
	illegal_addr u_illegal_addr(
		.instruction_addr			(pc_if),
		.data_addr					(alu_r1_mem),
		.load_store_mem				(load_store_mem),
		.Status_KSU					(cp0_Status[4:3]),

		.instruction_addr_illegal	(illegal_pc_if),
		.data_addr_illegal			(data_addr_illegal_mem)
	);

	//-----------MEM_WB stage--------
	MEM_WB u_MEM_WB(
		//input
	    .clk				(aclk),
		.rset				(rst_memwb),
	    .stall				(memwb_enable),
	    
	    .control_signal_in	(control_mem),
	    .registerW_in		(rw_mem),
	    .value_ALU_in      	(alu_r1_mem),
	    .value_ALU2_in     	(alu_r2_mem),
	    .value_Data_in		(DMout_mem),
	    .PC_in				(pc_mem),
	    .sel_in				(sel_mem),
	    .HILO_in			(hilo_mem),
	    .cp0_data_in		(cp0_data_mem),
	    .rdata1_in         	(rdata1_mem),
	    .rdata2_in			(rdata2_mem),
	    .cp0_rw_reg_in		(rd_mem),
	
		//ouput
	    .control_signal_out	(control_wb),
	    .registerW_out		(rw_wb),
	    .value_ALU_out     	(alu_r1_wb),
	    .value_ALU2_out    	(alu_r2_wb),
	    .value_Data_out		(DMout_wb),
	    .PC_out				(pc_wb),
	    .sel_out			(sel_wb),
	    .HILO_out			(hilo_wb),
	    .cp0_data_out		(cp0_data_wb),
	    .rdata1_out        	(rdata1_wb),
	    .rdata2_out			(rdata2_wb),
	    .cp0_rw_reg_out		(rd_wb)
	);

	//-------------CP0---------------
	cp0 #
	(
		.in_tlb_config_width(MMU_to_CP0_tlb_config_width),
		.out_tlb_config_width(CP0_to_MMU_tlb_config_width),
		.TLB_Entry_num(TLB_entry_num)
	)
	u_cp0(
		//input
		.clk 								(aclk),	
		.rst 								(rst),
		.read_reg_num						(rd_id),
		.read_reg_sel						(sel_id),
		.write_enable 						(cp0_we_wb),
		.write_reg_num						(rd_wb),
		.write_reg_sel						(sel_wb),
		.write_data							(rdata2_wb),			//or rdata1_wb????
		.in_tlb_config						(mmu_to_cp0_tlb_config),
		.tlbp 								(tlb_op_id == 3'b100),
		.tlbr 								(tlb_op_id == 3'b001),
		.is_exception						(is_exception_to_cp0),
		.BadVAddr_write_enable				(BadVAddr_write_enable),
		.Context_BadVPN2_write_enable		(Context_BadVPN2_write_enable),
		.EntryHi_VPN2_write_enable			(EntryHi_VPN2_write_enable),
		.EPC_from_exception					(EPC_to_cp0),
		.Cause_ExcCode_from_exception		(Cause_ExcCode_to_cp0),
		.BadVAddr_from_exception			(BadVAddr_to_cp0),
		.Context_BadVPN2_from_exception		(Context_BadVPN2_to_cp0),
		.EntryHi_VPN2_from_exception		(EntryHi_VPN2_to_cp0),
		.in_delayslot         				(in_delayslot_mem),
		.eret 								(eret_mem),
		.cp0_enable							(exmem_enable),

		//output
		.out_tlb_config						(cp0_to_mmu_tlb_config),
		.read_data							(cp0_data_id),
		.out_EPC							(cp0_EPC),
		.out_ErrEPC							(cp0_ErrEPC),
		.out_Status 						(cp0_Status),
		.out_EBase							(cp0_EBase),
		.out_Cause							(cp0_Cause),
		.eret_pc							(eret_pc)
	);

	//-------------exception---------------
	exception u_exception(
		//input
		.reset							(rst),
		.Status							(cp0_Status),
		.instruction_addr_illegal		(illegal_pc_mem),
		.TLB_miss_instruction			(TLB_miss_instruction),
		.TLB_invalid_instruction		(TLB_invalid_instruction),
		.invalid_instruction			(invalid_inst_mem),
		.Integer_Overflow				(overflow_mem),
		.syscall						(syscall_mem),
		.break							(break_mem),
		.data_addr_illegal				(data_addr_illegal_mem),
		.TLB_miss_data					(TLB_miss_data),
		.TLB_invalid_data				(TLB_invalid_data),
		.TLB_forbid_modify				(TLB_forbid_modify & load_store_mem[2] & (load_store_mem[1] | load_store_mem[0])),	//the instruction is store, but this page is forbid to modify(read only)
		.Ebase							(cp0_EBase),
		.in_delayslot					(in_delayslot_mem),
		.pc_current						(pc_mem),
		.data_address					(alu_r1_mem),
		.load							((load_store_mem == 3'b010) || (load_store_mem == 3'b011) || (load_store_mem == 3'b100)),
		.Cause							(cp0_Cause),
		.ErrEPC							(cp0_ErrEPC),
		.EPC							(cp0_EPC),

		//output
		.is_exception_to_cp0			(is_exception_to_cp0),
		.flush							(is_exception_mem),
		.pc_after_exception				(exception_new_pc),
		.BadVAddr_write_enable			(BadVAddr_write_enable),
		.Context_BadVPN2_write_enable	(Context_BadVPN2_write_enable),
		.EntryHi_VPN2_write_enable		(EntryHi_VPN2_write_enable),
		.EPC_to_cp0						(EPC_to_cp0),
		.Cause_ExcCode_to_cp0			(Cause_ExcCode_to_cp0),
		.BadVAddr_to_cp0				(BadVAddr_to_cp0),
		.Context_BadVPN2_to_cp0			(Context_BadVPN2_to_cp0),
		.EntryHi_VPN2_to_cp0			(EntryHi_VPN2_to_cp0)
	);

	//--------------WB stage---------
	DMout_select_extend u_DMout_select_extend(
		.load_store_wb			(load_store_wb),
		.DMout_wb(DMout_wb),
		.data_sram_addr_byte_wb	(alu_r1_wb[1:0]),

		.real_DMout_wb			(real_DMout_wb)
	);

	reg_din_select u_reg_din_select(
		.alu_r_wb			(alu_r1_wb),
		.pc_wb				(pc_wb),
		.DMout_wb			(real_DMout_wb),
		.cp0_d1_wb			(cp0_data_wb),
		.HI_wb				(hilo_wb[63:32]),
		.LO_wb				(hilo_wb[31:0]),
		.reg_din_sel		(din_sel_wb),

		.reg_din			(reg_din_wb)
    );

	//-------------AXI4 interface-----------
	cpu_axi#
    (
        .CPU_D_CACHE_LINE_WIDTH(CPU_D_CACHE_LINE_WIDTH),   //width of cacheline
        .CPU_D_TAG_WIDTH(CPU_D_TAG_WIDTH),                 //width of tag
        .CPU_D_NUM_ROADS(CPU_D_NUM_ROADS),                 //num of cacheline in one group
        .CPU_I_CACHE_LINE_WIDTH(CPU_I_CACHE_LINE_WIDTH),
        .CPU_I_TAG_WIDTH(CPU_I_TAG_WIDTH),
        .CPU_I_NUM_ROADS(CPU_I_NUM_ROADS)
    )
	u_cpu_axi(
	    .clk				(aclk),
	    .rset				(rst & aresetn),
		
	    .cpu_d_addr			(physical_dm_addr),
		.cpu_d_byteenable	(mode_mem),
		.cpu_d_read			(load_mem),
		.cpu_d_write		(|mode_mem),
		.cpu_d_hitwriteback	(1'b0),
		.cpu_d_hitinvalidate(1'b0),
		.cpu_d_wrdata		(dram_wdata_mem),
		.cpu_d_rddata		(DMout_mem),
		.cpu_d_stall		(data_stall),
		.cpu_d_addr_illegel	(data_addr_illegal_mem),
		.dcache_new_lw_ins	(mem_new_ins_tocache),
		.dcache_uncache     (uncache_data),
		
	    .cpu_i_addr			(physical_pc),
	    .cpu_i_byteenable	(4'b1111),
	    .cpu_i_read			(1'b1),
	    .cpu_i_hitinvalidate(1'b0),
	    .cpu_i_rddata		(instruction_if),
	    .cpu_i_stall		(ins_stall),
		.cpu_i_addr_illegel	(illegal_pc_if),
		.icache_new_lw_ins	(pcif_new_ins_tocache),
		
	    .axi_araddr			(araddr),
	    .axi_arburst		(arburst),
	    .axi_arcache		(arcache),
	    .axi_arid			(arid),
	    .axi_arlen			(arlen),
	    .axi_arlock			(arlock),
	    .axi_arprot			(arprot),
	    .axi_arsize			(arsize),
	    .axi_arvaild		(arvalid),
		.axi_arready		(arready),
		
	    .axi_rdata			(rdata),
	    .axi_rid			(rid),
	    .axi_rlast			(rlast),
	    .axi_rresp			(rresp),
	    .axi_rvalid			(rvalid),
		.axi_rready			(rready),
		
		.axi_awaddr			(awaddr),
	    .axi_awburst		(awburst),
	    .axi_awcache		(awcache),
	    .axi_awid			(awid),
	    .axi_awlen			(awlen),
	    .axi_awlock			(awlock),
	    .axi_awprot			(awprot),
	    .axi_awsize			(awsize),
	    .axi_awvalid		(awvalid),
	    .axi_awready		(awready),
		
		.axi_wdata			(wdata),
	    .axi_wlast			(wlast),
	    .axi_wstrb			(wstrb),
	    .axi_wvalid			(wvalid),
	    .axi_wid			(wid),
	    .axi_wready			(wready),
		
	    .axi_bid			(bid),
	    .axi_bresp			(bresp),
	    .axi_bvalid			(bvalid),	    
	    .axi_bready			(bready)
	);

endmodule