/*
**  作�?�：林力�?
**  功能：数据cache\uncache，与AXI接口对接实现AXI协议
*/

/*
dcache_with_uncache实现的是�?个带有uncache访问功能的cache,可用于数据cache�?
内部有dcache\uncache模块实例化各�?个，可以根据地址区间选择访问请求经过的模�?
*/

//`define UNCACHE_OFFSET 16'h1faf //根据�?要特定该地址段uncache访问
`define UNCACHE_OFFSET 8'h10 	//根据�?要特定该地址段uncache访问


module DCache_with_UnCache #(parameter
	CACHE_LINE_WIDTH 	= 6,	//CacheLine的大小，字节地址，减�?2等于offset长度，该值不能大�?9
	TAG_WIDTH 			= 20,	//Tag的长�?
	NUM_ROADS 			= 2		//组相联路�?
	`define NUM_CACHE_GOUPS (2 ** `INDEX_WIDTH)
) (
	// Clock and reset
	input  wire rst,
	input  wire clk,

	// AXI Bus 
	//input
    input wire AXI_rd_dready,//读访问，总线上数据就绪可写Cache的控制信�?
    input wire AXI_rd_last,//读访�?,标识总线上当前数据是�?后一个数据字的控制信�?
    input wire[31:0] AXI_rd_data,//读访问�?�线给出的数�?
    input wire AXI_rd_addr_clear,//读请求地�?已经被响应，可以清除请求信号

    input wire AXI_wr_next,//写访问，总线允许送下�?个数据的控制信号
    input wire AXI_wr_ok,//写访问，总线标识收到从设备最后一个ACK的控制信�?
    input wire AXI_wr_addr_clear,//写请求地�?已经被响应，可以清除请求信号

    //output
    output wire [31:0]AXI_addr,//送�?�线地址�?
    output wire  AXI_addr_valid,//送�?�线地址有效的控制信号，意味�?总线访问请求
    output wire  AXI_we,//送�?�线标记访问是读还是写的控制信号
    output wire [2:0]AXI_size,
    output wire [7:0]AXI_lens,//读访问，送�?�线size/length
    output wire  AXI_rd_rready,//送�?�线，主设备就绪读数据的控制信号

    output wire [31:0]AXI_wr_data,//写访问，送�?�线的数�?
    output wire AXI_wr_dready,//写访问，送�?�线�?个字数据就绪的控制信�?
    output wire [3:0]AXI_byte_enable,//写访问，送�?�线写操作各个字节使能的控制信号
    output wire AXI_wr_last,//写访问，送�?�线表示当前数据是最后一个数据字的控制信�?
    output wire AXI_response_rready,//写访问，送�?�线表示就绪接收从设备ACK的信�?

	// CPU i/f
	input  wire [31:0] cpu_addr,//CPU访问地址
	input  wire [3:0]  cpu_byteenable,//CPU访问模式
	input  wire        cpu_read,//CPU读命�?
	input  wire        cpu_write,//CPU写命�?
	input  wire        cpu_hitwriteback,//CPU强制写穿命令
	input  wire        cpu_hitinvalidate,//CPU强制失效命令
	input  wire		   cpu_kseg0_uncache,//是否是uncache访问
	input  wire [31:0] cpu_wrdata,//CPU写数�?
	output wire [31:0] cpu_rddata,//发往CPU读到的数�?
	output wire        cpu_stall,//发往CPU停机等待信号


	input  wire        cpu_addr_illegal,//CPU地址错信�?
	input  wire        new_lw_ins_tocache//CPU上一周期正常运转，到达Cache的是新的访存请求信号
);

	//如果illegal 终止访存，取消CPU访存指令
	wire addr_illegal;
	wire [3:0] legal_cpu_byteenable;
	wire legal_cpu_read;
	wire legal_cpu_write;
	wire legal_cpu_hitwriteback;
	wire legal_cpu_hitinvalidate;
	assign addr_illegal = cpu_addr_illegal;
	assign legal_cpu_byteenable = addr_illegal? 4'b0000 : cpu_byteenable;
	assign legal_cpu_read = addr_illegal? 0 : cpu_read;
	assign legal_cpu_write = addr_illegal? 0 : cpu_write;
	assign legal_cpu_hitwriteback = addr_illegal? 0 : cpu_hitwriteback;
	assign legal_cpu_hitinvalidate = addr_illegal? 0 : cpu_hitinvalidate;

	//判断地址是否cacheable，这里做了简化处理，在MIPS体系结构下该功能交给MMU处理，由MMU给出控制信号
	// wire cpu_kseg0_uncache;
	//assign cpu_kseg0_uncache  = (cpu_addr[31:16]==`UNCACHE_OFFSET) && (cpu_read || cpu_write);
	// assign cpu_kseg0_uncache  = (cpu_addr[31:24]==`UNCACHE_OFFSET) && (cpu_read || cpu_write);

	//信号声明
    wire DCache_AXI_rd_dready;
    wire DCache_AXI_rd_last;
    wire [31:0] DCache_AXI_rd_data;
    wire DCache_AXI_rd_addr_clear;
    wire DCache_AXI_wr_next;
    wire DCache_AXI_wr_ok;
    wire DCache_AXI_wr_addr_clear;
    wire [31:0]DCache_AXI_addr;
    wire DCache_AXI_addr_valid;
    wire DCache_AXI_we;
    wire [2:0]DCache_AXI_size;
    wire [7:0]DCache_AXI_lens;
    wire DCache_AXI_rd_rready;
    wire [31:0]DCache_AXI_wr_data;
    wire DCache_AXI_wr_dready;
    wire[3:0]DCache_AXI_byte_enable;
    wire DCache_AXI_wr_last;
    wire DCache_AXI_response_rready;
	wire [31:0] DCache_cpu_addr;
	wire [3:0]  DCache_cpu_byteenable;
	wire DCache_cpu_read;
	wire DCache_cpu_write;
	wire DCache_cpu_hitwriteback;
	wire DCache_cpu_hitinvalidate;
	wire [31:0] DCache_cpu_wrdata;
	wire [31:0] DCache_cpu_rddata;
	wire        DCache_cpu_stall;

	wire UnCache_AXI_rd_dready;
    wire UnCache_AXI_rd_last;
    wire [31:0] UnCache_AXI_rd_data;
    wire UnCache_AXI_rd_addr_clear;
    wire UnCache_AXI_wr_next;
    wire UnCache_AXI_wr_ok;
    wire UnCache_AXI_wr_addr_clear;
    wire [31:0]UnCache_AXI_addr;
    wire UnCache_AXI_addr_valid;
    wire UnCache_AXI_we;
    wire [2:0]UnCache_AXI_size;
    wire [7:0]UnCache_AXI_lens;
    wire UnCache_AXI_rd_rready;
    wire [31:0]UnCache_AXI_wr_data;
    wire UnCache_AXI_wr_dready;
    wire[3:0]UnCache_AXI_byte_enable;
    wire UnCache_AXI_wr_last;
    wire UnCache_AXI_response_rready;
	wire [31:0] UnCache_cpu_addr;
	wire [3:0]  UnCache_cpu_byteenable;
	wire UnCache_cpu_read;
	wire UnCache_cpu_write;
	wire UnCache_cpu_hitwriteback;
	wire UnCache_cpu_hitinvalidate;
	wire [31:0] UnCache_cpu_wrdata;
	wire [31:0] UnCache_cpu_rddata;
	wire        UnCache_cpu_stall;

	//如果uncache高电平使用UnCache输入输出，否则使用DCache输入输出
	//input
	assign UnCache_AXI_rd_dready = AXI_rd_dready;
	assign DCache_AXI_rd_dready = AXI_rd_dready;
	assign UnCache_AXI_rd_last = AXI_rd_last;
	assign DCache_AXI_rd_last = AXI_rd_last;
	assign UnCache_AXI_rd_data = AXI_rd_data;
	assign DCache_AXI_rd_data = AXI_rd_data;
	assign UnCache_AXI_rd_addr_clear = AXI_rd_addr_clear;
	assign DCache_AXI_rd_addr_clear = AXI_rd_addr_clear;

	assign UnCache_AXI_wr_next = AXI_wr_next;
	assign DCache_AXI_wr_next = AXI_wr_next;
	assign UnCache_AXI_wr_ok = AXI_wr_ok;
	assign DCache_AXI_wr_ok = AXI_wr_ok;
	assign UnCache_AXI_wr_addr_clear = AXI_wr_addr_clear;
	assign DCache_AXI_wr_addr_clear = AXI_wr_addr_clear;

    //output
    assign AXI_addr = cpu_kseg0_uncache? UnCache_AXI_addr : DCache_AXI_addr ;//送�?�线地址�?
    assign AXI_addr_valid = cpu_kseg0_uncache? UnCache_AXI_addr_valid : DCache_AXI_addr_valid ;//送�?�线地址有效的控制信�?
    assign AXI_we = cpu_kseg0_uncache? UnCache_AXI_we : DCache_AXI_we ;//送�?�线标记访问是读还是写的控制信号
    assign AXI_size = cpu_kseg0_uncache? UnCache_AXI_size : DCache_AXI_size ;
    assign AXI_lens = cpu_kseg0_uncache? UnCache_AXI_lens : DCache_AXI_lens ;//读访问，送�?�线size/length
    assign AXI_rd_rready = cpu_kseg0_uncache? UnCache_AXI_rd_rready : DCache_AXI_rd_rready ;//送�?�线，主设备就绪读数据的控制信号

    assign AXI_wr_data = cpu_kseg0_uncache? UnCache_AXI_wr_data : DCache_AXI_wr_data ;//写访问，送�?�线的数�?
    assign AXI_wr_dready = cpu_kseg0_uncache? UnCache_AXI_wr_dready : DCache_AXI_wr_dready ;//写访问，送�?�线�?个字数据就绪的控制信�?
    assign AXI_byte_enable = cpu_kseg0_uncache? UnCache_AXI_byte_enable : DCache_AXI_byte_enable ;//写访问，送�?�线写字节使能的控制信号
    assign AXI_wr_last = cpu_kseg0_uncache? UnCache_AXI_wr_last : DCache_AXI_wr_last ;//写访问，送�?�线表示当前数据是最后一个数据字的控制信�?
    assign AXI_response_rready = cpu_kseg0_uncache?  UnCache_AXI_response_rready : DCache_AXI_response_rready ;

	// CPU i/f

	assign UnCache_cpu_byteenable = cpu_kseg0_uncache? legal_cpu_byteenable : 0 ;//CPU访问模式
	assign UnCache_cpu_read = cpu_kseg0_uncache? legal_cpu_read : 0 ;//CPU读命�?
	assign UnCache_cpu_write = cpu_kseg0_uncache? legal_cpu_write : 0 ;//CPU写命�?
	assign UnCache_cpu_hitwriteback = cpu_kseg0_uncache? legal_cpu_hitwriteback : 0 ;//CPU强制写穿命令
	assign UnCache_cpu_hitinvalidate = cpu_kseg0_uncache? legal_cpu_hitinvalidate : 0 ;//CPU强制失效命令


	assign DCache_cpu_byteenable = cpu_kseg0_uncache? 0 : legal_cpu_byteenable ;//CPU访问模式
	assign DCache_cpu_read = cpu_kseg0_uncache? 0 : legal_cpu_read ;//CPU读命�?
	assign DCache_cpu_write = cpu_kseg0_uncache? 0 : legal_cpu_write ;//CPU写命�?
	assign DCache_cpu_hitwriteback = cpu_kseg0_uncache? 0 : legal_cpu_hitwriteback ;//CPU强制写穿命令
	assign DCache_cpu_hitinvalidate = cpu_kseg0_uncache? 0 : legal_cpu_hitinvalidate ;//CPU强制失效命令

	wire [31:0]cpu_addr_real;
	assign cpu_addr_real = {cpu_addr[31:2],2'b00};
	assign UnCache_cpu_addr = cpu_addr;
	assign DCache_cpu_addr = cpu_addr_real;

	assign UnCache_cpu_wrdata = cpu_wrdata;
	assign DCache_cpu_wrdata = cpu_wrdata;

	//CPU output
	assign cpu_rddata = addr_illegal? 0:(cpu_kseg0_uncache?  UnCache_cpu_rddata : DCache_cpu_rddata) ;//发往CPU读到的数�?
	assign cpu_stall = cpu_kseg0_uncache? UnCache_cpu_stall : DCache_cpu_stall ;//发往CPU停机等待信号

	DCache #(
		.CACHE_LINE_WIDTH(CACHE_LINE_WIDTH),	//CacheLine的大小，字节地址，减�?2等于offset长度，该值不能大�?9
		.TAG_WIDTH (TAG_WIDTH),	//Tag的长�?
		.NUM_ROADS(NUM_ROADS)	//组相联路�?
	) u_inter_DCache(
		// Clock and reset
		.rst(rst),
		.clk(clk),
		// AXI Bus 
		//input
	    .AXI_rd_dready(DCache_AXI_rd_dready),//读访问，总线上数据就绪可写Cache的控制信�?
	    .AXI_rd_last(DCache_AXI_rd_last),//读访�?,标识总线上当前数据是�?后一个数据字的控制信�?
	    .AXI_rd_data(DCache_AXI_rd_data),//读访问�?�线给出的数�?
	    .AXI_rd_addr_clear(DCache_AXI_rd_addr_clear),//读请求地�?已经被响应信�?

	    .AXI_wr_next(DCache_AXI_wr_next),//写访问，总线允许送下�?个数据的控制信号
	    .AXI_wr_ok(DCache_AXI_wr_ok),//写访问，总线标识收到从设备最后一个ACK的控制信�?
	    .AXI_wr_addr_clear(DCache_AXI_wr_addr_clear),//写请求地�?已经被响应信�?

	    //output
	    .AXI_addr(DCache_AXI_addr),//送�?�线地址�?
	    .AXI_addr_valid(DCache_AXI_addr_valid),//送�?�线地址有效的控制信�?
	    .AXI_we(DCache_AXI_we),//送�?�线标记访问是读还是写的控制信号
	    .AXI_size(DCache_AXI_size),
	    .AXI_lens(DCache_AXI_lens),//读访问，送�?�线size/length
	    .AXI_rd_rready(DCache_AXI_rd_rready),//送�?�线，主设备就绪读数据的控制信号

	    .AXI_wr_data(DCache_AXI_wr_data),//写访问，送�?�线的数�?
	    .AXI_wr_dready(DCache_AXI_wr_dready),//写访问，送�?�线�?个字数据就绪的控制信�?
	    .AXI_byte_enable(DCache_AXI_byte_enable),//写访问，送�?�线写字节使能的控制信号
	    .AXI_wr_last(DCache_AXI_wr_last),//写访问，送�?�线表示当前数据是最后一个数据字的控制信�?
	    .AXI_response_rready(DCache_AXI_response_rready),

		// CPU i/f
		.cpu_addr(DCache_cpu_addr),//CPU访问地址
		.cpu_byteenable(DCache_cpu_byteenable),//CPU访问模式
		.cpu_read(DCache_cpu_read),//CPU读命�?
		.cpu_write(DCache_cpu_write),//CPU写命�?
		.cpu_hitwriteback(DCache_cpu_hitwriteback),//CPU强制写穿命令
		.cpu_hitinvalidate(DCache_cpu_hitinvalidate),//CPU强制失效命令
		.cpu_wrdata(DCache_cpu_wrdata),//CPU写数�?
		.cpu_rddata(DCache_cpu_rddata),//发往CPU读到的数�?
		.cpu_stall(DCache_cpu_stall)//发往CPU停机等待信号
	);


	UnCache u_inter_UnCache(
		// Clock and reset
		.rst(rst),.clk(clk),
		// AXI Bus 
		//input
	    .AXI_rd_dready(UnCache_AXI_rd_dready),//读访问，总线上数据就绪可写Cache的控制信�?
	    .AXI_rd_last(UnCache_AXI_rd_last),//读访�?,标识总线上当前数据是�?后一个数据字的控制信�?
	    .AXI_rd_data(UnCache_AXI_rd_data),//读访问�?�线给出的数�?
	    .AXI_rd_addr_clear(UnCache_AXI_rd_addr_clear),//读请求地�?已经被响应信�?

	    .AXI_wr_next(UnCache_AXI_wr_next),//写访问，总线允许送下�?个数据的控制信号
	    .AXI_wr_ok(UnCache_AXI_wr_ok),//写访问，总线标识收到从设备最后一个ACK的控制信�?
	    .AXI_wr_addr_clear(UnCache_AXI_wr_addr_clear),//写请求地�?已经被响应信�?

	    //output
	    .AXI_addr(UnCache_AXI_addr),//送�?�线地址�?
	    .AXI_addr_valid(UnCache_AXI_addr_valid),//送�?�线地址有效的控制信�?
	    .AXI_we(UnCache_AXI_we),//送�?�线标记访问是读还是写的控制信号
	    .AXI_size(UnCache_AXI_size),
	    .AXI_lens(UnCache_AXI_lens),//读访问，送�?�线size/length
	    .AXI_rd_rready(UnCache_AXI_rd_rready),//送�?�线，主设备就绪读数据的控制信号

	    .AXI_wr_data(UnCache_AXI_wr_data),//写访问，送�?�线的数�?
	    .AXI_wr_dready(UnCache_AXI_wr_dready),//写访问，送�?�线�?个字数据就绪的控制信�?
	    .AXI_byte_enable(UnCache_AXI_byte_enable),//写访问，送�?�线写字节使能的控制信号
	    .AXI_wr_last(UnCache_AXI_wr_last),//写访问，送�?�线表示当前数据是最后一个数据字的控制信�?
	    .AXI_response_rready(UnCache_AXI_response_rready),

		// CPU i/f
		.cpu_addr(UnCache_cpu_addr),//CPU访问地址
		.cpu_byteenable(UnCache_cpu_byteenable),//CPU访问模式
		.cpu_read(UnCache_cpu_read),//CPU读命�?
		.cpu_write(UnCache_cpu_write),//CPU写命�?
		.cpu_hitwriteback(UnCache_cpu_hitwriteback),//CPU强制写穿命令
		.cpu_hitinvalidate(UnCache_cpu_hitinvalidate),//CPU强制失效命令
		.cpu_wrdata(UnCache_cpu_wrdata),//CPU写数�?
		.cpu_rddata(UnCache_cpu_rddata),//发往CPU读到的数�?
		.cpu_stall(UnCache_cpu_stall),//发往CPU停机等待信号
		.cpu_new_ins(new_lw_ins_tocache)//CPU上一周期正常运转，到达Cache的是新的访存请求信号
	);

endmodule
