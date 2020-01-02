/*
**  ���ߣ�����
**  ���ܣ�����cache��AXI����
**  ԭ��
*/

//`define CPU_D_CACHE_LINE_WIDTH 6  //CacheLine�Ĵ�С���ֽڵ�ַ����ȥ2����offset���ȣ���ֵ���ܴ���9
//`define CPU_D_TAG_WIDTH 20        //Tag�ĳ���
//`define CPU_D_NUM_ROADS 2	      //������·��
//`define CPU_I_CACHE_LINE_WIDTH 6
//`define CPU_I_TAG_WIDTH 20
//`define CPU_I_NUM_ROADS 2         //������·��			?

module cpu_axi#
(
    parameter CPU_D_CACHE_LINE_WIDTH = 6,   //width of cacheline
    parameter CPU_D_TAG_WIDTH = 20,         //width of tag
    parameter CPU_D_NUM_ROADS = 2,          //num of cacheline in one group
    parameter CPU_I_CACHE_LINE_WIDTH = 6,
    parameter CPU_I_TAG_WIDTH = 20,
    parameter CPU_I_NUM_ROADS = 2
)
(
    input 						clk,
    input 						rset,
	
    //cpu->dcache
    input 	[31:0]				cpu_d_addr,			//CPU访问地址
	input 	[3:0]				cpu_d_byteenable,	//CPU访问模式
	input 						cpu_d_read,			//CPU读命�??
	input 						cpu_d_write,		//CPU写命�??
	input 						cpu_d_hitwriteback,	//CPU强制写穿命令
	input 						cpu_d_hitinvalidate,//CPU强制失效命令
	input 	[31:0]				cpu_d_wrdata,		//CPU写数�??
	output 	[31:0]				cpu_d_rddata,		//发往CPU读到的数�??
	output 						cpu_d_stall,		//发往CPU停机等待信号
    input 						cpu_d_addr_illegel,
    input 						dcache_new_lw_ins,	//新的dcache访存请求
	input 						dcache_uncache,     //是否Uncache访问
    
	
    //cpu->icahce
    input 	[31:0]				cpu_i_addr,			//CPU访问地址
    input 	[3:0]				cpu_i_byteenable,	//CPU访问模式
    input 						cpu_i_read,			//CPU读命�??
    input 						cpu_i_hitinvalidate,//CPU强制失效命令
    output 	[31:0]				cpu_i_rddata,		//发往CPU读到的数�??
    output 						cpu_i_stall,		//发往CPU停机等待信号
    input 						cpu_i_addr_illegel,
    input 						icache_new_lw_ins,	//新的icache访存请求
	
    //axi->interface read address channel
	output 	[31:0]				axi_araddr,
    output 	[1:0]				axi_arburst,
    output 	[3:0]				axi_arcache,
    output 	[3:0]				axi_arid,
    output 	[7:0]				axi_arlen,
    output 	[1:0]				axi_arlock,
    output 	[2:0]				axi_arprot,
    output 	[2:0]				axi_arsize,
    output 						axi_arvaild,
	input 						axi_arready,
	//axi->interface read data channel
    input 	[31:0]				axi_rdata,
    input 	[3:0]				axi_rid,
    input 						axi_rlast,
    input 	[1:0]				axi_rresp,
    input 						axi_rvalid,
	output 						axi_rready,
    //axi->interface write address channel
	output 	[31:0]				axi_awaddr,
    output 	[1:0]				axi_awburst,
    output 	[3:0]				axi_awcache,
    output 	[3:0]				axi_awid,
    output 	[7:0]				axi_awlen,
    output 	[1:0]				axi_awlock,
    output 	[2:0]				axi_awprot,
    output 	[2:0]				axi_awsize,
    output 						axi_awvalid,
	input 						axi_awready,
	//axi->interface write data channel
	output 	[31:0]				axi_wdata,
    output 						axi_wlast,
    output 	[3:0]				axi_wstrb,
    output 	[3:0]				axi_wid,
	output 						axi_wvalid,
	input 						axi_wready,
	//axi->interface response channel
    input 	[3:0]				axi_bid,
    input 	[1:0]				axi_bresp,
    input 						axi_bvalid,
	output 						axi_bready
);
    //bus_interface->dcache
    wire 						AXI_d_rd_dready;
    wire 						AXI_d_rd_last;
    wire 	[31:0]				AXI_d_rd_data;
    wire 						AXI_d_wr_next;
    wire 						AXI_d_wr_ok;
    wire 						AXI_d_valid_clear;

    //dcache->bus_interface
    wire 	[31:0]				AXI_d_addr;
    wire 						AXI_d_addr_valid;
    wire 						AXI_d_we;
    wire 	[2:0]				AXI_d_size;
    wire 	[7:0]				AXI_d_lens;
    wire 						AXI_d_rd_rready;
    wire 	[31:0]				AXI_d_wr_data;
    wire 						AXI_d_wr_valid;
    wire 	[3:0]				AXI_d_byte_enable;
    wire 						AXI_d_wr_last;
    wire 						AXI_d_response_rready;

    //interface -> icache
    wire 						AXI_i_rd_dready;
    wire 						AXI_i_rd_last;
    wire 	[31:0]				AXI_i_rd_data;
    wire 						AXI_i_valid_clear;
	
    //icache->interface
    wire 	[31:0]				AXI_i_addr;
    wire 						AXI_i_addr_valid;
    wire 						AXI_i_we;
    wire 	[2:0]				AXI_i_size;
    wire 	[7:0]				AXI_i_lens;
    wire 						AXI_i_rd_rready;

    wire legal_cpu_i_read;
    wire legal_cpu_i_hitinvalidate;
    assign legal_cpu_i_read = cpu_i_addr_illegel ? 0 : cpu_i_read;
    assign legal_cpu_i_hitinvalidate = cpu_i_addr_illegel? 0 : cpu_i_hitinvalidate;
    
	AXI_interface u_axi_interface(
		.clk					(clk),
		.rset					(rset),
		
		//icache input
		.i_addr					(AXI_i_addr),
		.i_addr_valid			(AXI_i_addr_valid),
		.i_we					(AXI_i_we),
		.i_size					(AXI_i_size),
		.i_lens					(AXI_i_lens),
		.i_rready				(AXI_i_rd_rready),
		
		//icache output
		.i_valid_clear			(AXI_i_valid_clear),
		.i_rd_dready			(AXI_i_rd_dready),//cache的写使能信号
		.i_rd_data				(AXI_i_rd_data),
		.i_rlast				(AXI_i_rd_last),
		
		//dcache input
		.d_addr					(AXI_d_addr),
		.d_addr_valid			(AXI_d_addr_valid),
		.d_we					(AXI_d_we),
		.d_size					(AXI_d_size),
		.d_lens					(AXI_d_lens),
		.d_rready				(AXI_d_rd_rready),
		.d_wr_data				(AXI_d_wr_data),
		.d_wr_valid				(AXI_d_wr_valid),
		.d_byte_enable			(AXI_d_byte_enable),
		.d_resp_ready			(AXI_d_response_rready),
		.d_wr_wlast				(AXI_d_wr_last),
		
		//dcache output
		.d_valid_clear			(AXI_d_valid_clear),
		.d_rd_dready			(AXI_d_rd_dready),
		.d_rd_data				(AXI_d_rd_data),
		.d_wr_next				(AXI_d_wr_next),
		.d_wr_finish			(AXI_d_wr_ok),
		.d_rlast				(AXI_d_rd_last),
		
		//read addr
		.axi_araddr				(axi_araddr),
		.axi_arburst			(axi_arburst),
		.axi_arcache			(axi_arcache),
		.axi_arid				(axi_arid),
		.axi_arlen				(axi_arlen),
		.axi_arlock				(axi_arlock),
		.axi_arprot				(axi_arprot),
		.axi_arready			(axi_arready),
		.axi_arsize				(axi_arsize),
		.axi_arvalid			(axi_arvaild),
		
		//write addr
		.axi_awaddr				(axi_awaddr),
		.axi_awburst			(axi_awburst),
		.axi_awcache			(axi_awcache),
		.axi_awid				(axi_awid),
		.axi_awlen				(axi_awlen),
		.axi_awlock				(axi_awlock),
		.axi_awprot				(axi_awprot),
		.axi_awready			(axi_awready),
		.axi_awsize				(axi_awsize),
		.axi_awvalid			(axi_awvalid),
	
		//read data
		.axi_rdata				(axi_rdata),
		.axi_rid				(axi_rid),
		.axi_rlast				(axi_rlast),
		.axi_rready				(axi_rready),
		.axi_rresp				(axi_rresp),
		.axi_rvalid				(axi_rvalid),
	
		//write data
		.axi_wid				(axi_wid),
		.axi_wdata				(axi_wdata),
		.axi_wlast				(axi_wlast),
		.axi_wready				(axi_wready),
		.axi_wstrb				(axi_wstrb),
		.axi_wvalid				(axi_wvalid),

		//write response
		.axi_bid				(axi_bid),
		.axi_bready				(axi_bready),
		.axi_bresp				(axi_bresp),
		.axi_bvalid				(axi_bvalid)
	);
	
	DCache_with_UnCache #(
		.CACHE_LINE_WIDTH		(CPU_D_CACHE_LINE_WIDTH),	//CacheLine的大小，字节地址，减�??2等于offset长度，该值不能大�??9
		.TAG_WIDTH 				(CPU_D_TAG_WIDTH),			//Tag的长�??
		.NUM_ROADS				(CPU_D_NUM_ROADS)			//组相联路�??
	) u_DCache(
		// Clock and reset
		.rst					(rset),
		.clk					(clk),
		
		// AXI Bus input
		.AXI_rd_dready			(AXI_d_rd_dready),			//读访问，总线上数据就绪可写Cache的控制信�??
		.AXI_rd_last			(AXI_d_rd_last),			//读访�??,标识总线上当前数据是�??后一个数据字的控制信�??
		.AXI_rd_data			(AXI_d_rd_data),			//读访问�?�线给出的数�??
		.AXI_rd_addr_clear		(AXI_d_valid_clear),		//读请求地�??已经被响应信�??
	
		.AXI_wr_next			(AXI_d_wr_next),			//写访问，总线允许送下�??个数据的控制信号
		.AXI_wr_ok				(AXI_d_wr_ok),				//写访问，总线标识收到从设备最后一个ACK的控制信�??
		.AXI_wr_addr_clear		(AXI_d_valid_clear),		//写请求地�??已经被响应信�??
	
		//AXI Bus output
		.AXI_addr				(AXI_d_addr),				//送�?�线地址�??
		.AXI_addr_valid			(AXI_d_addr_valid),			//送�?�线地址有效的控制信�??
		.AXI_we					(AXI_d_we),					//送�?�线标记访问是读还是写的控制信号
		.AXI_size				(AXI_d_size),
		.AXI_lens				(AXI_d_lens),				//读访问，送�?�线size/length
		.AXI_rd_rready			(AXI_d_rd_rready),			//送�?�线，主设备就绪读数据的控制信号
	
		.AXI_wr_data			(AXI_d_wr_data),			//写访问，送�?�线的数�??
		.AXI_wr_dready			(AXI_d_wr_valid),			//写访问，送�?�线�??个字数据就绪的控制信�??
		.AXI_byte_enable		(AXI_d_byte_enable),		//写访问，送�?�线写字节使能的控制信号
		.AXI_wr_last			(AXI_d_wr_last),			//写访问，送�?�线表示当前数据是最后一个数据字的控制信�??
		.AXI_response_rready	(AXI_d_response_rready),
	
		// CPU i/f
		.cpu_addr				(cpu_d_addr),				//CPU访问地址
		.cpu_byteenable			(cpu_d_byteenable),			//CPU访问模式
		.cpu_read				(cpu_d_read),				//CPU读命�??
		.cpu_write				(cpu_d_write),				//CPU写命�??
		.cpu_hitwriteback		(cpu_d_hitwriteback),		//CPU强制写穿命令
		.cpu_hitinvalidate		(cpu_d_hitinvalidate),		//CPU强制失效命令
		.cpu_wrdata				(cpu_d_wrdata),				//CPU写数�??
		.cpu_rddata				(cpu_d_rddata),				//发往CPU读到的数�??
		.cpu_stall				(cpu_d_stall),				//发往CPU停机等待信号
		.cpu_addr_illegal		(cpu_d_addr_illegel),
		.new_lw_ins_tocache		(dcache_new_lw_ins),
		.cpu_kseg0_uncache      (dcache_uncache)
		//Debugger
	);
	
	ICache #(
		.CACHE_LINE_WIDTH		(CPU_I_CACHE_LINE_WIDTH),  //CacheLine的大小，字节地址，减�??2等于offset长度，该值不能大�??9
		.TAG_WIDTH 				(CPU_I_TAG_WIDTH),    		//Tag的长�??
		.NUM_ROADS				(CPU_I_NUM_ROADS)  		//组相联路�??
	) u_ICache(
		// Clock and reset
		.rst					(rset),
		.clk					(clk),
		
		// AXI Bus input
		.AXI_rd_dready			(AXI_i_rd_dready),			//读访问，总线上数据就绪可写Cache的控制信�??
		.AXI_rd_last			(AXI_i_rd_last),			//读访�??,标识总线上当前数据是�??后一个数据字的控制信�??
		.AXI_rd_data			(AXI_i_rd_data),			//读访问�?�线给出的数�??
		.AXI_rd_addr_clear		(AXI_i_valid_clear),		//读请求地�??已经被响应信�??
	
		.AXI_wr_next			(1'b0),						//写访问，总线允许送下�??个数据的控制信号
		.AXI_wr_ok				(1'b0),						//写访问，总线标识收到从设备最后一个ACK的控制信�??
		.AXI_wr_addr_clear		(1'b0),						//写请求地�??已经被响应信�??
	
		//AXI Bus output
		.AXI_addr				(AXI_i_addr),				//送�?�线地址�??
		.AXI_addr_valid			(AXI_i_addr_valid),			//送�?�线地址有效的控制信�??
		.AXI_we					(AXI_i_we),					//送�?�线标记访问是读还是写的控制信号
		.AXI_size				(AXI_i_size),
		.AXI_lens				(AXI_i_lens),				//读访问，送�?�线size/length
		.AXI_rd_rready			(AXI_i_rd_rready),			//送�?�线，主设备就绪读数据的控制信号
	
		.AXI_wr_data			( ),						//写访问，送�?�线的数�??
		.AXI_wr_dready			( ),						//写访问，送�?�线�??个字数据就绪的控制信�??
		.AXI_byte_enable        ( ),						//写访问，送�?�线写字节使能的控制信号
		.AXI_wr_last			( ),						//写访问，送�?�线表示当前数据是最后一个数据字的控制信�??
		.AXI_response_rready	( ),
	
		// CPU i/f
		.cpu_addr				(cpu_i_addr),				//CPU访问地址
		.cpu_byteenable			(cpu_i_byteenable),			//CPU访问模式
		.cpu_read				(cpu_i_read),				//CPU读命�??
		.cpu_write				(1'b0),						//CPU写命�??
		.cpu_hitwriteback		(1'b0),						//CPU强制写穿命令
		.cpu_hitinvalidate		(cpu_i_hitinvalidate),		//CPU强制失效命令
		.cpu_wrdata				('d0),						//CPU写数�??
		.cpu_rddata				(cpu_i_rddata),				//发往CPU读到的数�??
		.cpu_stall				(cpu_i_stall),				//发往CPU停机等待信号
		.cpu_addr_illegal		(cpu_i_addr_illegel),
		.new_lw_ins_tocache		(icache_new_lw_ins)
	);
    
    // 	UnCache u_Icache_UnCache(
    //     // Clock and reset
    //     .rst(rset),.clk(clk),
    //     // AXI Bus 
    //     //input
    //     .AXI_rd_dready(AXI_i_rd_dready),//�����ʣ����������ݾ�����дCache�Ŀ�����??
    //     .AXI_rd_last(AXI_i_rd_last),//����??,��ʶ�����ϵ�ǰ������??��һ�������ֵĿ�����??
    //     .AXI_rd_data(AXI_i_rd_data),//������???�߸�������??
    //     .AXI_rd_addr_clear(AXI_i_valid_clear),//�������??�Ѿ�����Ӧ��??

    //     .AXI_wr_next(1'b0),//д���ʣ�������������??�����ݵĿ����ź�
    //     .AXI_wr_ok(1'b0),//д���ʣ����߱�ʶ�յ����豸���һ��ACK�Ŀ�����??
    //     .AXI_wr_addr_clear(1'b0),//д�����??�Ѿ�����Ӧ��??

    //     //output
    //     .AXI_addr(AXI_i_addr),//��???�ߵ�ַ??
    //     .AXI_addr_valid(AXI_i_addr_valid),//��???�ߵ�ַ��Ч�Ŀ�����??
    //     .AXI_we(AXI_i_we),//��???�߱�Ƿ����Ƕ�����д�Ŀ����ź�
    //     .AXI_size(AXI_i_size),
    //     .AXI_lens(AXI_i_lens),//�����ʣ���???��size/length
    //     .AXI_rd_rready(AXI_i_rd_rready),//��???�ߣ����豸���������ݵĿ����ź�

    //     .AXI_wr_data( ),//д���ʣ���???�ߵ���??
    //     .AXI_wr_dready( ),//д���ʣ���???��??�������ݾ����Ŀ�����??
    //     .AXI_byte_enable( ),//д���ʣ���???��д�ֽ�ʹ�ܵĿ����ź�
    //     .AXI_wr_last( ),//д���ʣ���???�߱�ʾ��ǰ���������һ�������ֵĿ�����??
    //     .AXI_response_rready( ),

    //     // CPU i/f
    //     .cpu_addr(cpu_i_addr),//CPU���ʵ�ַ
    //     .cpu_byteenable(cpu_i_byteenable),//CPU����ģʽ
    //     .cpu_read(legal_cpu_i_read),//CPU����??
    //     .cpu_write(1'b0),//CPUд��??
    //     .cpu_hitwriteback(1'b0),//CPUǿ��д������
    //     .cpu_hitinvalidate(legal_cpu_i_hitinvalidate),//CPUǿ��ʧЧ����
    //     .cpu_wrdata(1'b0),//CPUд��??
    //     .cpu_rddata(cpu_i_rddata),//����CPU��������??
    //     .cpu_stall(cpu_i_stall),//����CPUͣ���ȴ��ź�
    //     .cpu_new_ins(icache_new_lw_ins)//CPU��һ����������ת������Cache�����µķô������ź�
    // );
	



endmodule