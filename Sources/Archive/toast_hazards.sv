`timescale 1ns / 1ps

import toast_def_pkg ::*;

module toast_hazards

	`ifdef CUSTOM_DEFINE
		#(parameter REG_DATA_WIDTH  = `REG_DATA_WIDTH,
		  parameter REGFILE_ADDR_WIDTH = `REGFILE_ADDR_WIDTH
		  )
	`else 
		#(parameter REG_DATA_WIDTH  = 32,
		  parameter REGFILE_ADDR_WIDTH  = 5
		 )
    `endif

	(
    input  logic                          clk_i,
    input  logic                          resetn_i,
       
    output logic                          stall_o,          // pipeline stall signal
	       
 	output logic                          IF_ID_flush_o,    // flush IF and ID in case of branch or jump taken
 	output logic                          EX_flush_o,       // flush EX if branch taken


	input  logic [31:0]                   IF_instruction_i, // used to check for Data hazard
	input  logic 						  ID_mem_rd_en_i,   // is an ID instrn a load?
	input  logic [REGFILE_ADDR_WIDTH-1:0] ID_rd_addr_i,     
    input  logic                          EX_branch_en_i,
    input  logic                          ID_jump_en_i

	);
    
    /*
    DATA LOAD HAZARD DETECTION
    
    Checks for the following conditions:
    1) is a load instruction present in ID pipeline reg?
    2a) does the next instruction (in IF pipeline reg) read any registers?
    2b) are any of the registers to be read dependent on the load?
    
    if all true, stall the pipeline.
    
    IF_Rs1_addr    = Instruction[19:15];
    IF_Rs2_addr    = Instruction[24:20];
    */
    
    wire [6:0] opcode = IF_instruction_i[6:0]; // internal 
    

    always_comb begin
        if(ID_mem_rd_en_i == 1) begin
            if( ( (opcode == `OPCODE_OP) || (opcode == `OPCODE_BRANCH) || (opcode == `OPCODE_STORE) ) &&
                ( (ID_rd_addr_i == IF_instruction_i[19:15]) || (ID_rd_addr_i == IF_instruction_i[24:20]) )
              )     
            begin
                stall_o = 1;
            end else if( ( (opcode == `OPCODE_OP_IMM) ||(opcode == `OPCODE_LOAD) )  &&
                         ( (ID_rd_addr_i == IF_instruction_i[19:15]) )
                       )
            begin
                stall_o = 1;
            end     
            else stall_o = 0;   
        end
        else stall_o = 0;
    end
                
    /*
    CONTROL HAZARD DETECTION FOR BRANCH:
    
    -> if a branch or jump is taken, the pipeline needs to be flushed for two cycles.
        -> a flush is defined as setting all control signals to 0, effectively
           replacing whatever instructions were being processed with NOP

    -> it is unknown whether a branch or jump is taken until the end of EX stage.
    -> if a branch is taken, IF, ID, and EX need to be flushed.
    -> if a jump is taken, only IF and ID need to be flushed.       
    */
    
    reg IF_ID_Flush1_i; // internal 1
    reg IF_ID_Flush2_i; // internal 2

    assign IF_ID_flush_o = (IF_ID_Flush1_i || IF_ID_Flush2_i);
    
    
    always_comb begin
        if((EX_branch_en_i == 1) || (ID_jump_en_i == 1)) IF_ID_Flush1_i = 1;
        else                                      IF_ID_Flush1_i = 0;
    end

    
    always@(posedge clk_i) begin
        if(resetn_i == 1'b0) IF_ID_Flush2_i <= 0;
        else                IF_ID_Flush2_i <= IF_ID_Flush1_i;
        
    end

    always_comb begin
        if(EX_branch_en_i == 1) EX_flush_o = 1;
        else                  EX_flush_o = 0;
    end
    
    
endmodule