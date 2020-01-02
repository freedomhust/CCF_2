/*
**	���ߣ�����
**	���ܣ������߼���ԪALU��������������ѡ��
**	ԭ��
*/
module alu_select(
	input 		[1:0]		alua_sel_ex,	//EX�Σ�ALU�ĵ�һ����������ѡ���ź�
	input 		[1:0]		alub_sel_ex,	//EX�Σ�ALU�ĵڶ�����������ѡ���ź�
	input 		[31:0]		rdata1_ex,		//ͨ�üĴ����ĵ�һ·���
	input 		[31:0]		rdata2_ex,		//ͨ�üĴ����ĵڶ�·���
	input 		[31:0]		extern_ex,		//��������չ�Ľ��
	
	output reg	[31:0]		alu_a,			//ALU�ĵ�һ·����
	output reg	[31:0]		alu_b			//ALU�ĵڶ�·����
);

	// ���ݿ��������ɵı�Ž���ALU��������ѡ��
	// ѡ���źŵı��������źű�������Ҫ����·����ѡ��һ·
	always @* begin
		case(alua_sel_ex)
			2'b00: begin
				alu_a <= rdata1_ex;
			end // 2'b00:
			2'b01: begin
				alu_a <= rdata2_ex;
			end // 2'b01:
			2'b10: begin
				alu_a <= extern_ex;
			end // 2'b10:
			default: begin
				alu_a <= 32'h0;
			end // default:
		endcase
	end

	// ���˴ӼĴ���ֵ����������չ�Ľ����ѡ�񣬻�����ѡ����16������luiָ����Ҫ��
	always @* begin
		case(alub_sel_ex)
			2'b00: begin
				alu_b <= rdata2_ex;
			end // 2'b00:
			2'b01: begin
				alu_b <= extern_ex;
			end // 2'b01:
			2'b10: begin
				alu_b <= 32'h0;
			end // 2'b10:
			2'b11: begin
				alu_b <= 32'd16;
			end // 2'b11:
			default: alu_b <= 32'h0;
		endcase
	end
	
endmodule
