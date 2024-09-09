library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use work.core_pkg.all;

entity tb_svx32_core is
end entity;

architecture tb of tb_svx32_core is

	constant cl_RESET    : std_logic := '1';
	constant cl_NOTRESET : std_logic := '0';
	constant cl_ENABLE   : std_logic := '1';
	constant cl_DISABLE  : std_logic := '0';

	constant ci_IF_opcode_l : integer := 0;
	constant ci_IF_opcode_u : integer := 6;

	constant ci_IF_rd_l : integer := 7;
	constant ci_IF_rd_u : integer := 11;

	constant ci_IF_funct3_l : integer := 12;
	constant ci_IF_funct3_u : integer := 14;

	constant ci_IF_rs1_l : integer := 15;
	constant ci_IF_rs1_u : integer := 19;

	constant ci_IF_rs2_l : integer := 20;
	constant ci_IF_rs2_u : integer := 24;

	constant ci_IF_funct7_l : integer := 25;
	constant ci_IF_funct7_u : integer := 31;
	
	signal pil_clk             : std_logic := '0';
	signal pil_rst             : std_logic := cl_RESET;
	signal pil_run_prg         : std_logic := cl_DISABLE;
    signal pitr_inst_v_opcode  : std_logic_vector(6 downto 0);
    signal pitr_inst_v_reg_rd  : std_logic_vector(4 downto 0);
    signal pitr_inst_v_funct3  : std_logic_vector(2 downto 0);
    signal pitr_inst_v_reg_rs1 : std_logic_vector(4 downto 0);
    signal pitr_inst_v_reg_rs2 : std_logic_vector(4 downto 0);
    signal pitr_inst_v_funct7  : std_logic_vector(6 downto 0);
	signal pol_core_hlt        : std_logic;
	signal pov_addr            : std_logic_vector(31 downto 0);
	signal pil_mem_valid       : std_logic := cl_DISABLE;
	signal pil_mem_ack         : std_logic := cl_DISABLE;
	signal pol_mem_req         : std_logic;
	signal pol_mem_wen         : std_logic;
	signal piv_mem_rdata       : std_logic_vector(31 downto 0) := (others => '0');
	signal pov_mem_wdata       : std_logic_vector(31 downto 0);
	signal pov_mem_addr        : std_logic_vector(31 downto 0);
	signal pov_mem_byte_sel    : std_logic_vector(3 downto 0);

	--- signals and constants declared for mem_module ---
	constant cv_base_seg0 : std_logic_vector := "00";
	constant cv_base_seg1 : std_logic_vector := "01";
	constant cv_base_seg2 : std_logic_vector := "10";

	signal sl_mem_valid    : std_logic;
	signal sl_mem_ack      : std_logic;
	signal sl_mem_req      : std_logic;
	signal sl_mem_wen      : std_logic;
	signal sv_mem_addr     : std_logic_vector(31 downto 0);
	signal sv_mem_rdata    : std_logic_vector(31 downto 0);
	signal sv_mem_wdata    : std_logic_vector(31 downto 0);
	signal sv_mem_byte_sel : std_logic_vector(3 downto 0);

	signal su_address_byte0 : unsigned(31 downto 2);
	signal su_address_byte1 : unsigned(31 downto 2);
	signal su_address_byte2 : unsigned(31 downto 2);
	signal su_address_byte3 : unsigned(31 downto 2);

	type t_mem_state is (idle_st, access_valid_st);
	signal st_mem_state : t_mem_state;

	alias av_mem_seg_sel : std_logic_vector(1 downto 0) is sv_mem_addr(1 downto 0);

	type tav_mem is array (0 to 15) of std_logic_vector(7 downto 0);
	signal stav_mem0, stav_mem1, stav_mem2, stav_mem3 : tav_mem := (others => (others => '1'));

	signal sl_mem0_wen   : std_logic;
	signal sv_mem0_addr  : std_logic_vector(3 downto 0);
	signal sv_mem0_wdata : std_logic_vector(7 downto 0);
	signal sv_mem0_rdata : std_logic_vector(7 downto 0);

	signal sl_mem1_wen   : std_logic;
	signal sv_mem1_addr  : std_logic_vector(3 downto 0);
	signal sv_mem1_wdata : std_logic_vector(7 downto 0);
	signal sv_mem1_rdata : std_logic_vector(7 downto 0);

	signal sl_mem2_wen   : std_logic;
	signal sv_mem2_addr  : std_logic_vector(3 downto 0);
	signal sv_mem2_wdata : std_logic_vector(7 downto 0);
	signal sv_mem2_rdata : std_logic_vector(7 downto 0);

	signal sl_mem3_wen   : std_logic;
	signal sv_mem3_addr  : std_logic_vector(3 downto 0);
	signal sv_mem3_wdata : std_logic_vector(7 downto 0);
	signal sv_mem3_rdata : std_logic_vector(7 downto 0);

	--- signals declared for program memory ---
	constant cs_dir_init_file    : string := "/home/rudran/Documents/01_GitProjects/SparrowX32/test/tb/";
	constant cs_init_file_format : string := "hex";

	type tav_pmem is array (0 to 63) of std_logic_vector(31 downto 0);

	impure function ifc_init_ram_file (s_file_name : in string) return tav_pmem is
		file f_mem_file                                : text;
		variable vln_mem_line                          : line;
		variable vtv_mem_content                       : tav_pmem;
		variable vbv_bit_line                          : bit_vector(vtv_mem_content(0)'range);
	begin
		if cs_dir_init_file /= "" then
			file_open(f_mem_file, s_file_name, read_mode);
			for ii in tav_pmem'low to tav_pmem'high loop
				if not endfile(f_mem_file) then
					readline(f_mem_file, vln_mem_line);
					if cs_init_file_format = "bin" then
						read(vln_mem_line, vbv_bit_line);
						vtv_mem_content(ii) := to_stdlogicvector(vbv_bit_line);
					elsif cs_init_file_format = "hex" then
						hread(vln_mem_line, vbv_bit_line);
						vtv_mem_content(ii) := to_stdlogicvector(vbv_bit_line);
					else
						report "***WRONG MEM VALUE***" severity failure;
					end if;
				else
					vtv_mem_content(ii) := X"00000000";
				end if;
			end loop;
		end if;
		return vtv_mem_content;
	end function;

	signal stav_pmem : tav_pmem := ifc_init_ram_file(s_file_name => cs_dir_init_file & "pmem_init.txt");

	signal sv_pmem_addr  : std_logic_vector(31 downto 0);
	signal sv_pmem_rdata : std_logic_vector(31 downto 0);

	function ifc_to_hstring (v_hex : in bit_vector) return string is
		variable vln_line              : LINE;
	begin
		hwrite(vln_line, v_hex);
		return vln_line.all;
	end function ifc_to_hstring;

	constant ct_clk_period : time := 8.333333333333333 ns;

begin

	-----------------------------------------------------------------------------------------------------
	-------------------------------------- Memory Module Unit -------------------------------------------
	-----------------------------------------------------------------------------------------------------

	sl_mem_req  <= pol_mem_req;
	sv_mem_addr <= pov_mem_addr;

	proc_mem_module : process (pil_clk, pil_rst)
	begin
		if pil_rst = cl_RESET then
			sl_mem_valid    <= cl_DISABLE;
			sl_mem_ack      <= cl_DISABLE;
			sv_mem_byte_sel <= (others => '0');
			st_mem_state    <= idle_st;
		elsif rising_edge(pil_clk) then
			sl_mem_ack      <= cl_DISABLE;
			sl_mem_valid    <= cl_DISABLE;
			sl_mem_wen      <= cl_DISABLE;
			sv_mem_wdata    <= (others => '0');
			sv_mem_byte_sel <= (others => '0');
			case st_mem_state is
				when idle_st =>
					if sl_mem_req = cl_ENABLE then
						sl_mem_wen      <= pol_mem_wen;
						sv_mem_wdata    <= pov_mem_wdata;
						sv_mem_byte_sel <= pov_mem_byte_sel;
						case av_mem_seg_sel is
							when cv_base_seg0 =>
								su_address_byte0 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte1 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte2 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte3 <= unsigned(sv_mem_addr(31 downto 2));
							when cv_base_seg1 =>
								su_address_byte0 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte1 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte2 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte3 <= unsigned(sv_mem_addr(31 downto 2));
							when cv_base_seg2 =>
								su_address_byte0 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte1 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte2 <= unsigned(sv_mem_addr(31 downto 2));
								su_address_byte3 <= unsigned(sv_mem_addr(31 downto 2));
							when others =>
								su_address_byte0 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte1 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte2 <= unsigned(sv_mem_addr(31 downto 2)) + 1;
								su_address_byte3 <= unsigned(sv_mem_addr(31 downto 2));
						end case;
						sl_mem_ack   <= cl_ENABLE;
						st_mem_state <= access_valid_st;
					end if;
				when access_valid_st =>
					sl_mem_valid <= cl_ENABLE;
					st_mem_state <= idle_st;
			end case;
		end if;
	end process proc_mem_module;

	sv_mem_rdata <= sv_mem3_rdata & sv_mem2_rdata & sv_mem1_rdata & sv_mem0_rdata;

	--- memory blocks ---

	sl_mem0_wen   <= sv_mem_byte_sel(0) and sl_mem_wen;
	sv_mem0_addr  <= std_logic_vector(su_address_byte0(5 downto 2));
	sv_mem0_wdata <= sv_mem_wdata(7 downto 0);

	proc_mem0 : process (pil_clk) is
	begin
		if rising_edge(pil_clk) then
			if sl_mem0_wen = '1' then
				stav_mem0(to_integer(unsigned(sv_mem0_addr))) <= sv_mem0_wdata;
			end if;
		end if;
	end process proc_mem0;

	sv_mem0_rdata <= stav_mem0(to_integer(unsigned(sv_mem0_addr)));

	sl_mem1_wen   <= sv_mem_byte_sel(1) and sl_mem_wen;
	sv_mem1_addr  <= std_logic_vector(su_address_byte1(5 downto 2));
	sv_mem1_wdata <= sv_mem_wdata(15 downto 8);

	proc_mem1 : process (pil_clk) is
	begin
		if rising_edge(pil_clk) then
			if sl_mem1_wen = '1' then
				stav_mem1(to_integer(unsigned(sv_mem1_addr))) <= sv_mem1_wdata;
			end if;
		end if;
	end process proc_mem1;

	sv_mem1_rdata <= stav_mem1(to_integer(unsigned(sv_mem1_addr)));

	sl_mem2_wen   <= sv_mem_byte_sel(2) and sl_mem_wen;
	sv_mem2_addr  <= std_logic_vector(su_address_byte2(5 downto 2));
	sv_mem2_wdata <= sv_mem_wdata(23 downto 16);

	proc_mem2 : process (pil_clk) is
	begin
		if rising_edge(pil_clk) then
			if sl_mem2_wen = '1' then
				stav_mem2(to_integer(unsigned(sv_mem2_addr))) <= sv_mem2_wdata;
			end if;
		end if;
	end process proc_mem2;

	sv_mem2_rdata <= stav_mem2(to_integer(unsigned(sv_mem2_addr)));

	sl_mem3_wen   <= sv_mem_byte_sel(3) and sl_mem_wen;
	sv_mem3_addr  <= std_logic_vector(su_address_byte3(5 downto 2));
	sv_mem3_wdata <= sv_mem_wdata(31 downto 24);

	proc_mem3 : process (pil_clk) is
	begin
		if rising_edge(pil_clk) then
			if sl_mem3_wen = '1' then
				stav_mem3(to_integer(unsigned(sv_mem3_addr))) <= sv_mem3_wdata;
			end if;
		end if;
	end process proc_mem3;

	sv_mem3_rdata <= stav_mem3(to_integer(unsigned(sv_mem3_addr)));

	-----------------------------------------------------------------------------------------------------
	------------------------------------ Program Memory Module ------------------------------------------
	-----------------------------------------------------------------------------------------------------

	sv_pmem_addr <= "00" & pov_addr(31 downto 2);

	proc_pmem : process (sv_pmem_addr)
	begin
		sv_pmem_rdata <= stav_pmem(to_integer(unsigned(sv_pmem_addr)));
	end process;

	-----------------------------------------------------------------------------------------------------
	-------------------------------------- DUT : CORE Module --------------------------------------------
	-----------------------------------------------------------------------------------------------------

	pil_mem_valid <= sl_mem_valid;
	pil_mem_ack   <= sl_mem_ack;
	piv_mem_rdata <= sv_mem_rdata;

	pitr_inst_v_opcode  <= sv_pmem_rdata(ci_IF_funct7_u downto ci_IF_funct7_l);
	pitr_inst_v_reg_rd  <= sv_pmem_rdata(ci_IF_rs2_u downto ci_IF_rs2_l);
	pitr_inst_v_funct3  <= sv_pmem_rdata(ci_IF_rs1_u downto ci_IF_rs1_l);
	pitr_inst_v_reg_rs1 <= sv_pmem_rdata(ci_IF_funct3_u downto ci_IF_funct3_l);
	pitr_inst_v_reg_rs2 <= sv_pmem_rdata(ci_IF_rd_u downto ci_IF_rd_l);
	pitr_inst_v_funct7  <= sv_pmem_rdata(ci_IF_opcode_u downto ci_IF_opcode_l);

	dut_svx32_core : entity work.svx32_core
		port map(
			pil_clk             => pil_clk,
			pil_rst             => pil_rst,
			pil_run_prg         => pil_run_prg,
			pol_core_hlt        => pol_core_hlt,
			pitr_inst_v_opcode  => pitr_inst_v_opcode,
			pitr_inst_v_reg_rd  => pitr_inst_v_reg_rd,
			pitr_inst_v_funct3  => pitr_inst_v_funct3,
			pitr_inst_v_reg_rs1 => pitr_inst_v_reg_rs1,
			pitr_inst_v_reg_rs2 => pitr_inst_v_reg_rs2,
			pitr_inst_v_funct7  => pitr_inst_v_funct7,
			pov_addr            => pov_addr,
			pil_mem_valid       => pil_mem_valid,
			pil_mem_ack         => pil_mem_ack,
			pol_mem_req         => pol_mem_req,
			pol_mem_wen         => pol_mem_wen,
			piv_mem_rdata       => piv_mem_rdata,
			pov_mem_wdata       => pov_mem_wdata,
			pov_mem_addr        => pov_mem_addr,
			pov_mem_byte_sel    => pov_mem_byte_sel
		);

	pil_clk <= not pil_clk after ct_clk_period / 2;
	pil_rst <= cl_NOTRESET after ct_clk_period * 2;

	proc_stimuli : process

		procedure pr_dump_ram (
			seg3, seg2, seg1, seg0 : in tav_mem
		) is
			file f_mem_file        : text;
			variable vln_mem_line  : line;
			variable vs_hex_string : string(1 to 26);
		begin
			file_open(f_mem_file, cs_dir_init_file & "ram_dump.txt", write_mode);
			write(vln_mem_line, string'("            03  02  01  00"));
			writeline(f_mem_file, vln_mem_line);
			write(vln_mem_line, string'("--------------------------"));
			writeline(f_mem_file, vln_mem_line);
			for ii in tav_mem'low to tav_mem'high loop
				vs_hex_string := ifc_to_hstring(v_hex => to_bitvector(std_logic_vector(to_unsigned(4 * ii, 32)))) & "    " & ifc_to_hstring(to_bitvector(seg3(ii))) & "  " & ifc_to_hstring(to_bitvector(seg2(ii))) & "  " & ifc_to_hstring(to_bitvector(seg1(ii))) & "  " & ifc_to_hstring(to_bitvector(seg0(ii)));
				write(vln_mem_line, vs_hex_string);
				writeline(f_mem_file, vln_mem_line);
			end loop;
			write(vln_mem_line, string'("--------------------------"));
			writeline(f_mem_file, vln_mem_line);
		end procedure;

	begin
		wait for ct_clk_period * 5;

		pil_run_prg <= cl_ENABLE;

		wait for 6 us;
		assert stav_mem3(15) = X"01" and pol_core_hlt = cl_DISABLE report "*** ERR : EXIT CODE ***" severity warning;

		pr_dump_ram(seg3 => stav_mem3, seg2 => stav_mem2, seg1 => stav_mem1, seg0 => stav_mem0);

		wait for ct_clk_period;
		assert false report "*** END OF SIMULATION!!! ***" severity failure;
	end process proc_stimuli;

end architecture;