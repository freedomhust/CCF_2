//wait for test

module illegal_addr (
	input [31:0]		instruction_addr,
	input [31:0]		data_addr,
	input [2:0]			load_store_mem,
	input [1:0]			Status_KSU,		//00:Kernel Mode, 01::SuperVisor Mode, 10:User Mode, 11:Reserved
	
	output reg			instruction_addr_illegal,
	output reg 			data_addr_illegal
);

	initial begin	
		instruction_addr_illegal <= 1'b0;
		data_addr_illegal <= 1'b0;
	end
	
	always @(*) begin
		//An instruction is fetched from an address that is not aligned on a word boundary.
		instruction_addr_illegal <= instruction_addr[1] | instruction_addr[0];
		
		case(Status_KSU)
			2'b01: begin	//A reference is made to a kernel address space from Supervisor Mode.
				if(instruction_addr[31:29] != 3'b110 && instruction_addr[31] != 1'b0)	
					instruction_addr_illegal <= 1'b1;
				if(data_addr[31:29] != 3'b110 && data_addr[31] != 1'b0)	
					data_addr_illegal <= 1'b1;
				else	//A load or store word instruction is executed in which the address is not aligned on a word boundary.
						//A load or store halfword instruction is executed in which the address is not aligned on a halfword boundary
					case(load_store_mem)
						3'b010,3'b011,3'b110: begin	//lh,lhu,sh
							data_addr_illegal <= data_addr[0];
						end
						3'b100,3'b111: begin	//lw,sw
							data_addr_illegal <= data_addr[1] | data_addr[0];
						end
						default: begin
							data_addr_illegal <= 1'b0;
						end
					endcase
			end
			2'b10,2'b11: begin	//A reference is made to a kernel address space or a supervisor address space from User Mode.
				if(instruction_addr[31] != 1'b0)	instruction_addr_illegal <= 1'b1;
				if(data_addr[31] != 1'b0)	data_addr_illegal <= 1'b1;
				else
					case(load_store_mem)
						3'b010,3'b011,3'b110: begin	//lh,lhu,sh
							data_addr_illegal <= data_addr[0];
						end
						3'b100,3'b111: begin	//lw,sw
							data_addr_illegal <= data_addr[1] | data_addr[0];
						end
						default: begin
							data_addr_illegal <= 1'b0;
						end
					endcase
			end
		endcase
	end
endmodule