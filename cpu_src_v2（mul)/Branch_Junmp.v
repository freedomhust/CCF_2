/*
**  ���ߣ�����
**  �޸ģ�����
**  ���ܣ�jump��branchָ����ת�ж�
**  ԭ��
*/

//bָ����Ҫ��4����jָ���Ҫ

`define BRANCH_BEQ 		32'd1
`define BRANCH_BNE 		32'd2
`define BRANCH_BGEZ 	32'd4
`define BRANCH_BGTZ 	32'd8
`define BRANCH_BLEZ 	32'd16
`define BRANCH_BLTZ 	32'd32
`define BRANCH_BLTZAL 	32'd64
`define BRANCH_BGEZAL 	32'd128
`define J_JAL 			32'd256
`define JALR_JR 		32'd512

module Branch_Jump_ID(
	input wire [9:0]			bj_type_ID, //10����תָ�һλ����һ�֣�������������� Ϊ�˽�ʡλ���Ļ�����10��ѡ������4λ��ѡ���źŸ���
    input wire [31:0]			num_a_ID,  	//ͨ�üĴ���1��ֵ
    input wire [31:0]			num_b_ID,  	//ͨ�üĴ���2��ֵ
    input wire [15:0]			imm_b_ID,  	//16λ������
    input wire [25:0]			imm_j_ID,  	//26λ������
    input wire [31:0]			JR_addr_ID, //ͨ�üĴ�����ֵ��JRָ���Ŀ���ַ��ʵ������num_a_ID��ͬһ��ֵ
    input wire [31:0]			PC_ID,     	//ID�ε�PC
    
	output reg 					Branch_Jump,//�Ƿ���ת���͵�PCģ��
    output reg [31:0]			BJ_address	//bran��jump��Ŀ���ַ
);
    

    wire sign;
    wire [31:0]imm_b_ID_32;
    assign sign = imm_b_ID[15];
    assign imm_b_ID_32 = { sign,sign,sign,sign,sign,sign,sign,sign,
                           sign,sign,sign,sign,sign,sign,sign,sign, imm_b_ID }; //������չ

    //����Ŀ���ַ
    always@(*)begin
      case (bj_type_ID)
        `BRANCH_BEQ:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID == num_b_ID);
        end 
        `BRANCH_BNE:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID != num_b_ID);
        end
        `BRANCH_BGEZ:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID[31]==0||num_a_ID== 0);
        end
        `BRANCH_BLEZ:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID[31]==1||num_a_ID== 0);
        end
        `BRANCH_BGTZ:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= ( num_a_ID[31]==0 && (num_a_ID != 0));
        end
        `BRANCH_BLTZ:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID[31]==1&&num_a_ID > 0);
        end
        `BRANCH_BLTZAL:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID[31]==1&&num_a_ID > 0);
        end
        `BRANCH_BGEZAL:begin
            BJ_address <= (imm_b_ID_32 << 2) + PC_ID + 32'd4;
            Branch_Jump <= (num_a_ID[31]==0||num_a_ID == 0);
        end
        `J_JAL:begin
            BJ_address[1:0] <= 2'b0;
            BJ_address[31:28] <= PC_ID[31:28];
            BJ_address[27:2] <= imm_j_ID[25:0];
            Branch_Jump <= 1'b1;
        end
        `JALR_JR:begin
            BJ_address <= JR_addr_ID;
            Branch_Jump <= 1'b1;
        end
        default: begin
           BJ_address <= PC_ID + 32'd4;
           Branch_Jump <= 1'b0;
        end
      endcase
    end
	
endmodule