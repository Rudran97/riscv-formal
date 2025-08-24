module rvfi_wrapper (
	input         clock,
	input         reset,
	`RVFI_OUTPUTS
);

	(* keep *) reg                        pil_run_prg = 0;
	
	// (* keep *) `rvformal_rand_reg         pil_fetch_mem_valid;
	// (* keep *) `rvformal_rand_reg         pil_fetch_mem_ack;
	(* keep *) reg                        pil_fetch_mem_valid = 0;
	(* keep *) reg                        pil_fetch_mem_ack = 0;
	(* keep *) wire                       pol_fetch_mem_req;
	(* keep *) `rvformal_rand_reg [31:0]  piv_fetch_mem_rdata;
	(* keep *) wire               [31:0]  pov_fetch_mem_addr;

	(* keep *) `rvformal_rand_reg         pil_mem_valid;
	(* keep *) `rvformal_rand_reg         pil_mem_ack;
	// (* keep *) wire                      pil_mem_valid;
	// (* keep *) wire                      pil_mem_ack;
	(* keep *) wire                       pol_mem_req;
	(* keep *) wire                       pol_mem_wen;

	(* keep *) `rvformal_rand_reg [31:0]  piv_mem_rdata;
	(* keep *) wire               [31:0]  pov_mem_wdata;
	(* keep *) wire               [31:0]  pov_mem_addr;
	(* keep *) wire               [3:0]   pov_mem_byte_sel;

	(* keep *) `rvformal_rand_reg         pil_soft_irq;
	(* keep *) `rvformal_rand_reg         pil_timer_irq;
	(* keep *) `rvformal_rand_reg         pil_ext_irq;
    (* keep *) wire                       pol_irq_pending;

	svx32_core uut (
		.pil_clk		      (clock                 ),
        .pil_rst		      (reset                 ),
        .pil_run_prg          (1'b1                  ),

		// --- instruction fetch signals --- //
		.pil_fetch_mem_valid  (pil_fetch_mem_valid   ),
		.pil_fetch_mem_ack    (pil_fetch_mem_ack     ),
		.pol_fetch_mem_req    (pol_fetch_mem_req     ),
		.piv_fetch_mem_rdata  (piv_fetch_mem_rdata   ),
		.pov_fetch_mem_addr   (pov_fetch_mem_addr    ),

        // --- mem unit signals --- //
        .pil_mem_valid        (pil_mem_valid         ),
        .pil_mem_ack          (pil_mem_ack           ),
        .pol_mem_req          (pol_mem_req           ),
        .pol_mem_wen          (pol_mem_wen           ),

        .piv_mem_rdata        (piv_mem_rdata         ),
        .pov_mem_wdata        (pov_mem_wdata         ),
        .pov_mem_addr         (pov_mem_addr          ),
        .pov_mem_byte_sel     (pov_mem_byte_sel      ),

		// --- IRQs --- //
		.pil_soft_irq         (pil_soft_irq          ),
		.pil_timer_irq        (pil_timer_irq         ),
		.pil_ext_irq          (pil_ext_irq           ),
		.pol_irq_pending      (pol_irq_pending       ),

        // --- risc-v formal interface --- //
		`RVFI_CONN
	);

	always @(posedge clock) begin
		if (!reset) begin
			pil_run_prg <= 1;
		end
	end

	// always @(posedge clock) begin
	// 	pil_mem_ack <= pol_mem_req;
	// end

	// always @(posedge clock) begin
	// 	if (pil_mem_ack) begin
	// 		pil_mem_valid <= 1;
	// 	end else begin
	// 		pil_mem_valid <= 0;
	// 	end
	// end

	// Restrict fetch delay //
	always @(posedge clock) begin
		pil_fetch_mem_ack <= pol_fetch_mem_req;
	end

	always @(posedge clock) begin
		if (pil_fetch_mem_ack) begin
			pil_fetch_mem_valid <= 1;
		end else begin
			pil_fetch_mem_valid <= 0;
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

	// The async interrupt pins cannot stay high for more than 5 Clock cycle after the pol_irq_pending is
	// asserted.
	reg [4:0] irq_wait = 0;
	always @(posedge clock) begin
		irq_wait <= {irq_wait, pol_irq_pending && (pil_soft_irq || pil_timer_irq || pil_ext_irq)};
		assume (~irq_wait);
	end
`endif

endmodule

