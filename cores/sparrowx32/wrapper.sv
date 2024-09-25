module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);

	(* keep *) `rvformal_rand_reg [6:0]   pitr_inst_v_opcode;
	(* keep *) `rvformal_rand_reg [11:7]  pitr_inst_v_reg_rd;
	(* keep *) `rvformal_rand_reg [14:12] pitr_inst_v_funct3;
	(* keep *) `rvformal_rand_reg [19:15] pitr_inst_v_reg_rs1;
	(* keep *) `rvformal_rand_reg [24:20] pitr_inst_v_reg_rs2;
	(* keep *) `rvformal_rand_reg [31:25] pitr_inst_v_funct7;
	(* keep *) wire               [31:0]  pov_addr;

	(* keep *) reg                       pil_mem_valid = 0;
	(* keep *) `rvformal_rand_reg        pil_mem_ack;
	(* keep *) wire                      pol_mem_req;
	(* keep *) wire                      pol_mem_wen;

	(* keep *) `rvformal_rand_reg [31:0] piv_mem_rdata;
	(* keep *) wire               [31:0] pov_mem_wdata;
	(* keep *) wire               [31:0] pov_mem_addr;
	(* keep *) wire               [3:0]  pov_mem_byte_sel;

	svx32_core uut (
		.pil_clk		      (clock               ),
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

	always @(posedge clock) begin
		if (pil_mem_ack) begin
			pil_mem_valid <= 1;
		end else begin
			pil_mem_valid <= 0;
		end
	end

`ifdef SPARROWX32_FAIRNESS
	(* keep *) reg [2:0] data_req_pending_cycles = 0;
	(* keep *) reg [2:0] data_rsp_pending_cycles = 0;
	(* keep *) reg       data_rsp_pending_valid = 0;

	always @(posedge clock) begin
		if(pol_mem_req && !pil_mem_ack) begin
			data_req_pending_cycles <= data_req_pending_cycles + 1;
		end else begin
			data_req_pending_cycles <= 0;
		end

		if(data_rsp_pending_valid <= 1) begin
			data_rsp_pending_cycles <= data_rsp_pending_cycles + 1;
		end
		if(pil_mem_valid) begin
			data_rsp_pending_valid <= 0;
			data_rsp_pending_cycles <= 0;
		end
		if(pol_mem_req && pil_mem_ack && !pol_mem_wen) begin
			data_rsp_pending_valid <= 1;
		end
		restrict(~rvfi_trap && data_req_pending_cycles < 4 && data_rsp_pending_cycles < 4);
	end
`endif

endmodule

