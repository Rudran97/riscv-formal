module testbench (
	input         pil_clk,
	input  [31:0] piv_inst,

	output [31:0] pov_addr,
	output        pol_core_hlt
);

	reg pil_rst 	= 1;
	reg pil_run_prg = 0;

    assign pitr_inst_v_opcode  = piv_inst[6:0];
    assign pitr_inst_v_reg_rd  = piv_inst[11:7];
    assign pitr_inst_v_funct3  = piv_inst[14:12];
    assign pitr_inst_v_reg_rs1 = piv_inst[19:15];
    assign pitr_inst_v_reg_rs2 = piv_inst[24:20];
    assign pitr_inst_v_funct7  = piv_inst[31:25];

	always @(posedge pil_clk)
		pil_rst 	<= 0;

	always @(posedge pil_clk)
		pil_run_prg <= 1;

	`RVFI_WIRES

	svx32_core uut (
		.pil_clk		      (pil_clk             ),
        .pil_rst		      (pil_rst             ),
        .pil_run_prg          (pil_run_prg         ),
        .pol_core_hlt         (pol_core_hlt        ),
        .pitr_inst_v_opcode   (pitr_inst_v_opcode  ),
        .pitr_inst_v_reg_rd   (pitr_inst_v_reg_rd  ),
        .pitr_inst_v_funct3   (pitr_inst_v_funct3  ),
        .pitr_inst_v_reg_rs1  (pitr_inst_v_reg_rs1 ),
        .pitr_inst_v_reg_rs2  (pitr_inst_v_reg_rs2 ),
        .pitr_inst_v_funct7   (pitr_inst_v_funct7  ),
        .pov_addr             (pov_addr            ),

        // --- mem unit signals ---
        .pil_mem_valid        (1'b0			       ),
        .pil_mem_ack          (1'b0			       ),
        // .pol_mem_req       (pol_mem_req         ),
        // .pol_mem_wen       (pol_mem_wen         ),

        .piv_mem_rdata        (31'b0               ),
        // .pov_mem_wdata     (pov_mem_wdata       ),
        // .pov_mem_addr      (pov_mem_addr        ),
        // .pov_mem_byte_sel  (pov_mem_byte_sel    ),

        // --- risc-v formal interface ---
		`RVFI_CONN
	);

	(* keep *) wire                                spec_valid;
	(* keep *) wire                                spec_trap;
	(* keep *) wire [                       4 : 0] spec_rs1_addr;
	(* keep *) wire [                       4 : 0] spec_rs2_addr;
	(* keep *) wire [                       4 : 0] spec_rd_addr;
	(* keep *) wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_rd_wdata;
	(* keep *) wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_pc_wdata;
	(* keep *) wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_addr;
	(* keep *) wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_rmask;
	(* keep *) wire [`RISCV_FORMAL_XLEN/8 - 1 : 0] spec_mem_wmask;
	(* keep *) wire [`RISCV_FORMAL_XLEN   - 1 : 0] spec_mem_wdata;

	rvfi_isa_rv32i isa_spec (
		.rvfi_valid    (rvfi_valid    ),
		.rvfi_insn     (rvfi_insn     ),
		.rvfi_pc_rdata (rvfi_pc_rdata ),
		.rvfi_rs1_rdata(rvfi_rs1_rdata),
		.rvfi_rs2_rdata(rvfi_rs2_rdata),
		.rvfi_mem_rdata(rvfi_mem_rdata),

		.spec_valid    (spec_valid    ),
		.spec_trap     (spec_trap     ),
		.spec_rs1_addr (spec_rs1_addr ),
		.spec_rs2_addr (spec_rs2_addr ),
		.spec_rd_addr  (spec_rd_addr  ),
		.spec_rd_wdata (spec_rd_wdata ),
		.spec_pc_wdata (spec_pc_wdata ),
		.spec_mem_addr (spec_mem_addr ),
		.spec_mem_rmask(spec_mem_rmask),
		.spec_mem_wmask(spec_mem_wmask),
		.spec_mem_wdata(spec_mem_wdata)
	);

	always @* begin
		if (!pil_rst && rvfi_valid && !rvfi_trap) begin
			if (rvfi_insn[6:0] != 7'b1110011)
				assert(spec_valid && !spec_trap);
		end
	end
endmodule
