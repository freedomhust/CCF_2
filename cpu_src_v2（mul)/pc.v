
module pc(
	input 			clk,
	input 			resetn,
    
    input 			pc_en,
    input 			is_branch, 			//��֧ģ����ת�ź�
    input [31:0] 	branch_address, 	//���Է�֧ģ�����ת��ַ
    input 			is_exception, 		//�쳣ģ����ת�ź�
    input [31:0] 	exception_new_pc, 	//�����쳣ģ�����ת��ַ
    input           is_eret,
    input [31:0]    eret_pc,
	
	output reg[31:0] 	pc_reg
);
    
	parameter PC_INITIAL = 32'hbfc00000; //��һ��ָ�ʼִ�е�λ��

    reg[31:0] pc_next;

    always @(*) begin
        if (!resetn) begin
          pc_next <= PC_INITIAL;
        end
        else if(pc_en) begin //�����źž���PC����һ��ֵ���쳣��������ת����������ͨ����
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