module testbench (
	input clk,

	input  [31:0] piv_fetch_mem_rdata,
    output [31:0] pov_fetch_mem_addr,

	input         pil_mem_valid,
	input         pil_mem_ack,
	output        pol_mem_req,
	output        pol_mem_wen,
	input  [31:0] piv_mem_rdata,
	output [31:0] pov_mem_wdata,
	output [31:0] pov_mem_addr,
	output [3:0]  pov_mem_byte_sel,
);

	(* keep *) reg     pil_fetch_mem_valid = 0;
	(* keep *) reg     pil_fetch_mem_ack = 0;
	(* keep *) wire    pol_fetch_mem_req;

	reg reset = 1;
	wire trap;

	typedef enum { 
		idle_st,
		access_valid_st,
		wait_next_st
	} fetch_state_t;

	fetch_state_t fetch_fsm_curr_t, fetch_fsm_next_t;

	always @(posedge clk)
		reset <= 0;

	`RVFI_WIRES

	svx32_core uut (
		.pil_clk		      (clk                 ),
        .pil_rst		      (reset               ),
        .pil_run_prg          (1'b1                ),

		// --- instruction fetch signals --- //
		.pil_fetch_mem_valid  (pil_fetch_mem_valid   ),
		.pil_fetch_mem_ack    (pil_fetch_mem_ack     ),
		.pol_fetch_mem_req    (pol_fetch_mem_req     ),
		.piv_fetch_mem_rdata  (piv_fetch_mem_rdata   ),
		.pov_fetch_mem_addr   (pov_fetch_mem_addr    ),

        // --- mem unit signals --- //
        .pil_mem_valid        (pil_mem_valid       ),
        .pil_mem_ack          (pil_mem_ack         ),
        .pol_mem_req          (pol_mem_req         ),
        .pol_mem_wen          (pol_mem_wen         ),

        .piv_mem_rdata        (piv_mem_rdata       ),
        .pov_mem_wdata        (pov_mem_wdata       ),
        .pov_mem_addr         (pov_mem_addr        ),
        .pov_mem_byte_sel     (pov_mem_byte_sel    ),

        // --- risc-v formal interface --- //
		`RVFI_CONN
	);

	// Acknowledge/valid logic: assert as long as core holds request high
	always_ff @(posedge clock or posedge reset) begin
		if (reset) begin
			pil_fetch_mem_ack   <= 1'b0;
			pil_fetch_mem_valid <= 1'b0;
		end else begin
			if (pol_fetch_mem_req) begin
				// Core requests -> keep ack/valid high
				pil_fetch_mem_ack   <= 1'b1;
				pil_fetch_mem_valid <= 1'b1;
			end else begin
				// Core releases request -> drop ack/valid
				pil_fetch_mem_ack   <= 1'b0;
				pil_fetch_mem_valid <= 1'b0;
			end
		end
	end

	reg [7:0] count = 0;
	always @(posedge clk) begin
		// cover(rvfi_valid);
		if (reset)
			count <= 0;
		else if (rvfi_valid)
			count <= count + 1;
		cover(count == 5);  // prove 10 retirements are possible
	end

endmodule
