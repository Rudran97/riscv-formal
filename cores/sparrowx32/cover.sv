module testbench (
	input clk,

	input  [6:0]  pitr_inst_v_opcode,
	input  [4:0]  pitr_inst_v_reg_rd,
	input  [2:0]  pitr_inst_v_funct3,
	input  [4:0]  pitr_inst_v_reg_rs1,
	input  [4:0]  pitr_inst_v_reg_rs2,
	input  [6:0]  pitr_inst_v_funct7,
    output [31:0] pov_addr,

	input         pil_mem_valid,
	input         pil_mem_ack,
	output        pol_mem_req,
	output        pol_mem_wen,
	input  [31:0] piv_mem_rdata,
	output [31:0] pov_mem_wdata,
	output [31:0] pov_mem_addr,
	output [3:0]  pov_mem_byte_sel,

);
	reg reset = 1;
	wire trap;

	always @(posedge clk)
		reset <= 0;

	`RVFI_WIRES

	svx32_core uut (
		.pil_clk		      (clk                 ),
        .pil_rst		      (reset               ),
        .pil_run_prg          (1'b1                ),
        .pitr_inst_v_opcode   (pitr_inst_v_opcode  ),
        .pitr_inst_v_reg_rd   (pitr_inst_v_reg_rd  ),
        .pitr_inst_v_funct3   (pitr_inst_v_funct3  ),
        .pitr_inst_v_reg_rs1  (pitr_inst_v_reg_rs1 ),
        .pitr_inst_v_reg_rs2  (pitr_inst_v_reg_rs2 ),
        .pitr_inst_v_funct7   (pitr_inst_v_funct7  ),
        .pov_addr             (pov_addr            ),

        // --- mem unit signals ---
        .pil_mem_valid        (pil_mem_valid       ),
        .pil_mem_ack          (pil_mem_ack         ),
        .pol_mem_req          (pol_mem_req         ),
        .pol_mem_wen          (pol_mem_wen         ),

        .piv_mem_rdata        (piv_mem_rdata       ),
        .pov_mem_wdata        (pov_mem_wdata       ),
        .pov_mem_addr         (pov_mem_addr        ),
        .pov_mem_byte_sel     (pov_mem_byte_sel    ),

        // --- risc-v formal interface ---
		`RVFI_CONN
	);

	integer count_dmemrd = 0;
	integer count_dmemwr = 0;
	integer count_longinsn = 0;
	// integer count_comprinsn = 0;

	always @(posedge clk) begin
		if (!reset && rvfi_valid) begin
			if (rvfi_mem_rmask)
				count_dmemrd <= count_dmemrd + 1;
			if (rvfi_mem_wmask)
				count_dmemwr <= count_dmemwr + 1;
			if (rvfi_insn[1:0] == 3)
				count_longinsn <= count_longinsn + 1;
			// if (rvfi_insn[1:0] != 3)
			// 	count_comprinsn <= count_comprinsn + 1;
		end
	end

	cover property (count_dmemrd);
	cover property (count_dmemwr);
	cover property (count_longinsn);
	// cover property (count_comprinsn);

	// cover property (count_dmemrd >= 1 && count_dmemwr >= 1 && count_longinsn >= 1 && count_comprinsn >= 1);
	// cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 2 && count_comprinsn >= 2);
	// cover property (count_dmemrd >= 3 && count_dmemwr >= 2 && count_longinsn >= 2 && count_comprinsn >= 2);
	// cover property (count_dmemrd >= 2 && count_dmemwr >= 3 && count_longinsn >= 2 && count_comprinsn >= 2);
	// cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 3 && count_comprinsn >= 2);
	// cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 2 && count_comprinsn >= 3);

	cover property (count_dmemrd >= 1 && count_dmemwr >= 1 && count_longinsn >= 1);
	cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 2);
	cover property (count_dmemrd >= 3 && count_dmemwr >= 2 && count_longinsn >= 2);
	cover property (count_dmemrd >= 2 && count_dmemwr >= 3 && count_longinsn >= 2);
	cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 3);
	cover property (count_dmemrd >= 2 && count_dmemwr >= 2 && count_longinsn >= 2);
endmodule
