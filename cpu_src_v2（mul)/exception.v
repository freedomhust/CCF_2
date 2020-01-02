module exception(
    input           reset,
    input   [31:0]  Status,
    input           instruction_addr_illegal,
    input           TLB_miss_instruction,
    input           TLB_invalid_instruction,
    input           invalid_instruction,
    input           Integer_Overflow,
    input           syscall,
    input           break,
    input           data_addr_illegal,
    input           TLB_miss_data,
    input           TLB_invalid_data,
    input           TLB_forbid_modify,
    input   [31:0]  Ebase,
    input           in_delayslot,
    input   [31:0]  pc_current,
    input   [31:0]  data_address,
    input           load,
    input   [31:0]  Cause,
    input   [31:0]  ErrEPC,
    input   [31:0]  EPC,

    output  reg         is_exception_to_cp0,
    output  reg         flush,
    output  reg [31:0]  pc_after_exception,
    output  reg         BadVAddr_write_enable,
    output  reg         Context_BadVPN2_write_enable,
    output  reg         EntryHi_VPN2_write_enable,
    output  reg [31:0]  EPC_to_cp0,
    output  reg [4:0]   Cause_ExcCode_to_cp0,
    output  reg [31:0]  BadVAddr_to_cp0,
    output  reg [18:0]  Context_BadVPN2_to_cp0,
    output  reg [18:0]  EntryHi_VPN2_to_cp0
);

    initial begin
        is_exception_to_cp0 <= 1'b0;
        flush <= 1'b0;
        pc_after_exception <= 32'b0;
        BadVAddr_write_enable <= 1'b0;
        Context_BadVPN2_write_enable <= 1'b0;
        EntryHi_VPN2_write_enable <= 1'b0;
        EPC_to_cp0 <= 32'b0;
        Cause_ExcCode_to_cp0 <= 5'b0;
        BadVAddr_to_cp0 <= 32'b0;
        Context_BadVPN2_to_cp0 <= 19'b0;
        EntryHi_VPN2_to_cp0 <= 19'b0;
    end

    wire            Status_IE;
    assign  Status_IE = Status[0];
    wire    [7:0]   interrupt_signal;
    assign  interrupt_signal = Status[15:8];
    wire            Status_EXL;
    assign  Status_EXL = Status[1];
    wire            Status_ERL;
    assign  Status_ERL = Status[2];
    wire            Status_BEV;
    assign  Status_BEV = Status[22];
    wire            Cause_IV;
    assign  Cause_IV = Cause[23];

    //Priority of Exception
    wire    Reset;                          //The Cold Reset signal was asserted to the processor
    wire    Soft_Reset;                     //The Reset signal was asserted to the processor 
    wire    Debug_Single_Step;
    wire    Debug_Interrupt;
    wire    Imprecise_Debug_Data_Break;
    wire    Nonmaskable_Interrupt;          //NMI,The NMI signal was asserted to the processor
    wire    Machine_Check;
    wire    Interrupt;                      //An enabled interrupt occurred. 
    wire    Deferred_Watch;
    wire    Debug_Instruction_Break;
    wire    Watch_Instruction_fetch;
    wire    Address_Error_Instruction_fetch;//A non-word-aligned address was loaded into PC. 
    wire    TLB_Refill_Instruction_fetch;   //A TLB miss occurred on an instruction fetch.
    wire    TLB_Invalid_Instruction_fetch;  // The valid bit was zero in the TLB entry mapping the address referenced by an instruction fetch. 
    wire    TLB_Execute_Inhibit;
    wire    Cache_Error_Instruction_fetch;  //A cache error occurred on an instruction fetch. 
    wire    Bus_Error_Instruction_fetch;    //A bus error occurred on an instruction fetch. 
    wire    SDBBP;
    wire    Instruction_Validity_Exceptions;// Coprocessor Unusable(priority higher) or Reserved Instruction
    wire    Execution_Exception;            //An instruction-based exception occurred: Integer overflow, trap, system call, breakpoint, floating point, coprocessor 2 exception. 
    wire    Precise_Debug_Data_Break;
    wire    Watch_Data_access;
    wire    Address_Error_Data_access;      //An unaligned address, or an address that was inaccessible in the current processor mode was referenced, by a load or store instruction 
    wire    TLB_Refill_Data_access;         //A TLB miss occurred on a data access 
    wire    TLB_Invalid_Data_access;        //The valid bit was zero in the TLB entry mapping the address referenced by a load or store instruction 
    wire    TLB_Read_Inhibit;
    wire    TLB_Modified_Data_access;       //The dirty bit was zero in the TLB entry mapping the address referenced by a store instruction 
    wire    Cache_Error_Data_access;        //A cache error occurred on a load or store data reference
    wire    Bus_Error_Data_access;          //A bus error occurred on a load or store data reference


    assign    Reset                             =   ~reset;                          
    assign    Soft_Reset                        =   1'b0;              
    //assign    Debug_Single_Step                 =   ;
    //assign    Debug_Interrupt                   =   ;
    //assign    Imprecise_Debug_Data_Break        =   ;
    assign    Nonmaskable_Interrupt             =   1'b0;          
    //assign    Machine_Check                     =   ;
    assign    Interrupt                         =   Status_IE && (interrupt_signal != 8'h0) && ~(Status_ERL | Status_EXL);                      
    //assign    Deferred_Watch                    =   ;
    //assign    Debug_Instruction_Break           =   ;
    //assign    Watch_Instruction_fetch           =   ;
    assign    Address_Error_Instruction_fetch   =   instruction_addr_illegal;
    assign    TLB_Refill_Instruction_fetch      =   TLB_miss_instruction;   
    assign    TLB_Invalid_Instruction_fetch     =   TLB_invalid_instruction;  
    //assign    TLB_Execute_Inhibit               =   ;
    //assign    Cache_Error_Instruction_fetch     =   ;  
    //assign    Bus_Error_Instruction_fetch       =   ;    
    //assign    SDBBP                             =   ;
    assign    Instruction_Validity_Exceptions   =   invalid_instruction;
    assign    Execution_Exception               =   Integer_Overflow | syscall | break;            
    //assign    Precise_Debug_Data_Break          =   ;
    //assign    Watch_Data_access                 =   ;
    assign    Address_Error_Data_access         =   data_addr_illegal;      
    assign    TLB_Refill_Data_access            =   TLB_miss_data;         
    assign    TLB_Invalid_Data_access           =   TLB_invalid_data;        
    //assign    TLB_Read_Inhibit                  =   ;
    assign    TLB_Modified_Data_access          =   TLB_forbid_modify;       
    //assign    Cache_Error_Data_access           =   ;        
    //assign    Bus_Error_Data_access             =   ;          

    wire [31:0] exception_vector_base;
    assign exception_vector_base = (Reset | Soft_Reset | Nonmaskable_Interrupt) ? 32'hbfc00000 :
                                Status_BEV ? 32'hBFC00200 : 
                                //Cache_Error ? {3'b101, Ebase[28:12], 12'b0} :
                                {2'b10, Ebase[29:12], 12'b0};
    
    always @(*) begin
        is_exception_to_cp0 <= 1'b1;    //report to cp0 to update the EXL bit of Status Register of CP0
        flush <= 1'b1;
        BadVAddr_write_enable <= 1'b0;
        Context_BadVPN2_write_enable <= 1'b0;
        EntryHi_VPN2_write_enable <= 1'b0;
        EPC_to_cp0 <= in_delayslot ? (pc_current-32'd4) : pc_current;

        if(Reset) begin 
            pc_after_exception <= 32'hbfc00000;
            is_exception_to_cp0 <= 1'b0;
            flush <= 1'b0;
            pc_after_exception <= 32'b0;
            BadVAddr_write_enable <= 1'b0;
            Context_BadVPN2_write_enable <= 1'b0;
            EntryHi_VPN2_write_enable <= 1'b0;
            EPC_to_cp0 <= 32'b0;
            Cause_ExcCode_to_cp0 <= 5'd0;
            BadVAddr_to_cp0 <= 32'b0;
            Context_BadVPN2_to_cp0 <= 19'b0;
            EntryHi_VPN2_to_cp0 <= 19'b0;
            end
        //else if(Soft_Reset) begin end
        //else if(Debug_Single_Step) begin end
        //else if(Debug_Interrupt) begin end
        //else if(Imprecise_Debug_Data_Break) begin end
        /*esle if(Nonmaskable_Interrupt) begin
            NMI_to_cp0  <= 1'b1;
            pc_after_exception <= 32'hbfc00000; 
            end*/
        //else if(Machine_Check) begin end
        else if(Interrupt) begin        //more operation?
            Cause_ExcCode_to_cp0 <= 5'd0;
            pc_after_exception <= exception_vector_base + (Cause_IV ? 32'h200 : 32'h180);  
            end
        //else if(Deferred_Watch) begin end
        //else if(Debug_Instruction_Break) begin end
        //else if(Watch_Instruction_fetch) begin end
        else if(Address_Error_Instruction_fetch) begin
            Cause_ExcCode_to_cp0 <= 5'd4;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            BadVAddr_to_cp0 <= pc_current;
            BadVAddr_write_enable <= 1'b1;  
            end
        else if(TLB_Refill_Instruction_fetch) begin
            //if(Config3_CTXTC) xxxxx
            Cause_ExcCode_to_cp0 <= 5'd2;
            BadVAddr_to_cp0 <= pc_current;
            BadVAddr_write_enable <= 1'b1; 
            Context_BadVPN2_to_cp0 <= pc_current[31:13];
            Context_BadVPN2_write_enable <= 1'b1;
            EntryHi_VPN2_to_cp0 <= pc_current[31:13];
            EntryHi_VPN2_write_enable <= 1'b1;
            pc_after_exception <= exception_vector_base + (Status_EXL ? 32'h180 : 32'h0);  
            end
        else if(TLB_Invalid_Instruction_fetch) begin 
            Cause_ExcCode_to_cp0 <= 5'd2;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            BadVAddr_to_cp0 <= pc_current;
            BadVAddr_write_enable <= 1'b1; 
            Context_BadVPN2_to_cp0 <= pc_current[31:13];
            Context_BadVPN2_write_enable <= 1'b1;
            EntryHi_VPN2_to_cp0 <= pc_current[31:13];
            EntryHi_VPN2_write_enable <= 1'b1;
            end
        //else if(TLB_Execute_Inhibit) begin end
        //else if(Cache_Error_Instruction_fetch) begin end
        //else if(Bus_Error_Instruction_fetch) begin end
        //else if(SDBBP) begin end
        else if(Instruction_Validity_Exceptions) begin 
            Cause_ExcCode_to_cp0 <= 5'd10;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            //if(Coprocessor_Unusable) begin end
            //else if(Reserved_Instruction) begin end
            end
        else if(Execution_Exception) begin
            Cause_ExcCode_to_cp0 <= syscall ? 5'd8 :
                                    break ? 5'd9 : 5'd12;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            //else if(Integer_Overflow) begin end
            //else if(Trap) begin end
            //else if(syscall) begin end
            //else if(break) begin end
            //else if(Floating_Point) begin end
            //else if(Coprocessor_2) begin end
            end
        //else if(Precise_Debug_Data_Break) begin end
        //else if(Watch_Data_access) begin end
        else if(Address_Error_Data_access) begin
            Cause_ExcCode_to_cp0 <= load ? 5'd4 : 5'd5;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            BadVAddr_to_cp0 <= data_address;
            BadVAddr_write_enable <= 1'b1;  
            end
        else if(TLB_Refill_Data_access) begin 
            Cause_ExcCode_to_cp0 <= load ? 5'd2 : 5'd3;
            BadVAddr_to_cp0 <= data_address;
            BadVAddr_write_enable <= 1'b1; 
            Context_BadVPN2_to_cp0 <= data_address[31:13];
            Context_BadVPN2_write_enable <= 1'b1;
            EntryHi_VPN2_to_cp0 <= data_address[31:13];
            EntryHi_VPN2_write_enable <= 1'b1;
            pc_after_exception <= exception_vector_base + (Status_EXL ? 32'h180 : 32'h0);  
            end
        else if(TLB_Invalid_Data_access) begin
            Cause_ExcCode_to_cp0 <= load ? 5'd2 : 5'd3;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            BadVAddr_to_cp0 <= data_address;
            BadVAddr_write_enable <= 1'b1; 
            Context_BadVPN2_to_cp0 <= data_address[31:13];
            Context_BadVPN2_write_enable <= 1'b1;
            EntryHi_VPN2_to_cp0 <= data_address[31:13];
            EntryHi_VPN2_write_enable <= 1'b1;
            end
        //else if(TLB_Read_Inhibit) begin end
        else if(TLB_Modified_Data_access) begin 
            Cause_ExcCode_to_cp0 <= 5'd1;
            pc_after_exception <= exception_vector_base + 32'h180;     //General exception vector 
            BadVAddr_to_cp0 <= data_address;
            BadVAddr_write_enable <= 1'b1; 
            Context_BadVPN2_to_cp0 <= data_address[31:13];
            Context_BadVPN2_write_enable <= 1'b1;
            EntryHi_VPN2_to_cp0 <= data_address[31:13];
            EntryHi_VPN2_write_enable <= 1'b1;
            end
        //else if(Cache_Error_Data_access) begin end
        //else if(Bus_Error_Data_access) begin end
        else begin      //Unrecognized exception
            is_exception_to_cp0 <= 1'b0;
            flush <= 1'b0;
            end
        end
endmodule