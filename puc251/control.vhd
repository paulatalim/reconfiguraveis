LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY control IS 
	PORT (
		opcode: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		clk, nrst: IN STD_LOGIC;
		c_flag, z_flag, v_flag: IN STD_LOGIC;
		
		Wreg_on_dext: OUT STD_LOGIC;
		reg_di_sel: OUT STD_LOGIC;
		alu_a_in_sel: OUT STD_LOGIC;
		alu_to_gpio_sel: OUT STD_LOGIC;
		reg_wr_ena: OUT STD_LOGIC;
		Wreg_wr_ena: OUT STD_LOGIC;
		Sel_RA_ou_Wreg: OUT STD_LOGIC;
		Men_to_Wreg_sel: OUT STD_LOGIC;
		
		flag_c_wr_ena, flag_z_wr_ena, flag_v_wr_ena: OUT STD_LOGIC;
		stack_push, stack_pop: OUT STD_LOGIC;
		mem_wr_ena, mem_rd_ena: OUT STD_LOGIC;
		inp, outp: OUT STD_LOGIC;
		
		alu_op: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		pc_ctrl: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF control IS
	TYPE state_type IS (rst, fetch, fet_dec_ex);
	SIGNAL pres_state, next_state: state_type;
BEGIN
	PROCESS(nrst, clk)
	BEGIN
		IF nrst = '0' THEN
			pres_state <= rst;
		ELSIF RISING_EDGE(CLK) THEN
			pres_state <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS(nrst, pres_state, opcode, c_flag, z_flag, v_flag)
	BEGIN
		Wreg_on_dext <= '0';
		reg_di_sel <= '0';
		alu_a_in_sel <= '0';
		alu_to_gpio_sel <= '0';
		reg_wr_ena <= '0';
		Wreg_wr_ena <= '0';
		Sel_RA_ou_Wreg <= '0';
		Men_to_Wreg_sel <= '0';
		
		flag_c_wr_ena <= '0';
		flag_z_wr_ena <= '0';
		flag_v_wr_ena <= '0';
		stack_push <= '0';
		stack_pop <= '0';
		mem_wr_ena <= '0';
		mem_rd_ena <= '0';
		inp <= '0';
		outp <= '0';
		
		alu_op <= "----";
		pc_ctrl <= "00";
		
		next_state <= pres_state;
		
		CASE pres_state IS
			WHEN rst =>
				next_state <= fetch;
			
			WHEN fetch =>
				next_state <= fet_dec_ex;
				pc_ctrl <= "11";
			
			WHEN fet_dec_ex =>
				CASE opcode(7 DOWNTO 6) IS
					-- ALU e dois registradores | ALU, um registrador e um imediato
					WHEN "00" | "01" =>
						CASE opcode(5 DOWNTO 3) IS
							WHEN "000" | "001" | "010" | "011" => 
								flag_v_wr_ena <= '1';
							WHEN OTHERS => NULL;
						END CASE;
						CASE opcode(5 DOWNTO 3) IS
							WHEN "000" => alu_op <= "0000";
							WHEN "001" => alu_op <= "0001";
							WHEN "010" => alu_op <= "0010";
							WHEN "011" => alu_op <= "0011";
							WHEN "100" => alu_op <= "0100";
							WHEN "101" => alu_op <= "0101";
							WHEN "110" => alu_op <= "0110";
							WHEN "111" => alu_op <= "1111";
							WHEN OTHERS => NULL;
						END CASE;
						IF opcode(0) = '1' THEN
							reg_wr_ena <= '1';
							reg_di_sel <= '1';
							Sel_RA_ou_Wreg <= '1';
						ELSE
							Wreg_wr_ena <= '1';
						END IF;
						IF opcode(7 DOWNTO 6) = "01" THEN
							alu_a_in_sel <= '1';
						END IF;
						flag_c_wr_ena <= '1';
						flag_z_wr_ena <= '1';
						pc_ctrl <= "11";
						next_state <= fet_dec_ex;
					
					-- ALU e um registrador
					WHEN "10" =>
						CASE opcode(5 DOWNTO 3) IS
							WHEN "000" => alu_op <= "1000";
							WHEN "001" => alu_op <= "1001";
							WHEN "010" => alu_op <= "1010";
							WHEN "011" => alu_op <= "1011";
							WHEN "100" => alu_op <= "1100";
							WHEN "101" => alu_op <= "1101";
							WHEN "110" => alu_op <= "1110";
							WHEN "111" => alu_op <= "0111";
							WHEN OTHERS => NULL;
						END CASE;
						IF opcode(0) = '1' THEN
							reg_wr_ena <= '1';
							reg_di_sel <= '1';
						ELSE
							Wreg_wr_ena <= '1';
						END IF;
						flag_c_wr_ena <= '1';
						flag_z_wr_ena <= '1';
						pc_ctrl <= "11";
						next_state <= fet_dec_ex;
					WHEN OTHERS => NULL;
				END CASE;
				
				CASE opcode(7 DOWNTO 5) IS
					-- Mem�ria e I/O
					WHEN "110" =>
						CASE opcode(4 DOWNTO 3) IS
							WHEN "00" =>
								mem_rd_ena <= '1';
								Wreg_wr_ena <= '1';
								Men_to_Wreg_sel <= '1';
							WHEN "01" =>
								mem_wr_ena <= '1';
								Wreg_on_dext <= '1';
							WHEN "10" =>
								inp <= '1';
								IF opcode(0) = '1' THEN
									reg_wr_ena <= '1';
								ELSE
									Wreg_wr_ena <= '1';
									Men_to_Wreg_sel <= '1';
								END IF;
							WHEN "11" =>
								outp <= '1';
								IF opcode(0) = '1' THEN
									alu_op <= "1111";
									alu_to_gpio_sel <= '1';
								ELSE
									Wreg_on_dext <= '1';
								END IF;
						END CASE;
						pc_ctrl <= "11";
						next_state <= fet_dec_ex;
					WHEN OTHERS => NULL;
				END CASE;
				
				CASE opcode(7 DOWNTO 4) IS
					-- Desvios Incondicionais 
					WHEN "1110" =>
						IF opcode(3) = '1' THEN
							stack_push <= '1';
						END IF;
						pc_ctrl <= "01";
						next_state <= fetch;
					WHEN OTHERS => NULL;
				END CASE;
					
				CASE opcode(7 DOWNTO 3) IS
					-- Desvios Condicionais e retorno
					WHEN "11110" =>
						CASE opcode(2 DOWNTO 1) IS
							WHEN "00" =>
								IF c_flag = '1' THEN
									next_state <= fetch;
								ELSE
									next_state <= fet_dec_ex;
								END IF;
								pc_ctrl <= "11";
							WHEN "01" =>
								IF z_flag = '1' THEN
									next_state <= fetch;
								ELSE
									next_state <= fet_dec_ex;
								END IF;
								pc_ctrl <= "11";
							WHEN "10" =>
								IF v_flag = '1' THEN
									next_state <= fetch;
								ELSE
									next_state <= fet_dec_ex;
								END IF;
								pc_ctrl <= "11";
							WHEN "11" =>
								pc_ctrl <= "10";
								stack_pop <= '1';
								next_state <= fetch;
							WHEN OTHERS => NULL;
						END CASE;
					WHEN "11111" =>
						pc_ctrl <= "11";
						next_state <= fet_dec_ex;
					WHEN OTHERS => NULL;
				END CASE;
		END CASE;
	END PROCESS;
END arch;