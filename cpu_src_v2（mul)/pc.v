
module pc(
	input 			clk,
	input 			resetn,
    
    input 			pc_en,
    input 			is_branch, 			//分支模块跳转信号
    input [31:0] 	branch_address, 	//来自分支模块的跳转地址
    input 			is_exception, 		//异常模块跳转信号
    input [31:0] 	exception_new_pc, 	//来自异常模块的跳转地址
    input           is_eret,
    input [31:0]    eret_pc,
	
	output reg[31:0] 	pc_reg
);
    
	parameter PC_INITIAL = 32'hbfc00000; //第一条指令开始执行的位置

    reg[31:0] pc_next;

    always @(*) begin
        if (!resetn) begin
          pc_next <= PC_INITIAL;
        end
        else if(pc_en) begin //根据信号决定PC的下一个值，异常优先于跳转，优先于普通自增
            if(is_exception) begin
                pc_next <= exception_new_pc;
            end
            else if(is_branch) begin
                pc_next <= branch_address;
            end
            else if(is_eret) begin
                pc_next <= eret_pc;
            end
            else begin
                pc_next <= pc_reg + 32'd4;
            end
        end
        else begin 
            pc_next <= pc_reg;
        end
    end

    always @(posedge clk) begin
        pc_reg <= pc_next;
    end
	
endmodule