LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY reg_bank IS 
	PORT (
		regn_di: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		regn_wr_sel, regn_rd_sel: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		clk_in, nrst: IN STD_LOGIC;
		c_flag_in, z_flag_in, v_flag_in: IN STD_LOGIC;
		regn_wr_ena, c_flag_wr_ena, z_flag_wr_ena, v_flag_wr_ena: IN STD_LOGIC; 
		regn_do: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		c_flag_out, z_flag_out, v_flag_out: OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE arch OF reg_bank IS
	SIGNAL R0, R1, R2, R3: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
	-- C�digo Sequencial para a parte de escrita.
	PROCESS(clk_in, nrst)
	BEGIN
		IF nrst = '0' THEN
			R0 <= (others => '0');
			R1 <= (others => '0');
			R2 <= (others => '0');
			R3 <= (others => '0');
		ELSIF RISING_EDGE(clk_in) THEN	
			IF regn_wr_ena = '1' THEN
				CASE regn_wr_sel IS
					WHEN "00" => R0 <= regn_di;
					WHEN "01" => R1 <= regn_di;
					WHEN "10" => R2 <= regn_di;
					WHEN "11" => R3 <= regn_di;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;
			
			-- Flags c, z e v possuem prioridade.
			IF c_flag_wr_ena = '1' THEN
				R3(0) <= c_flag_in;
			END IF;
			IF z_flag_wr_ena = '1' THEN
				R3(1) <= z_flag_in;
			END IF;
			IF v_flag_wr_ena = '1' THEN
				R3(2) <= v_flag_in;
			END IF;
		END IF;
	END PROCESS;
	
	-- C�digo Concorrente para a parte de leitura.
	regn_do <= R0 WHEN regn_rd_sel = "00" ELSE
			   R1 WHEN regn_rd_sel = "01" ELSE
			   R2 WHEN regn_rd_sel = "10" ELSE
			   R3;
			   
	c_flag_out <= R3(0);
	z_flag_out <= R3(1);
	v_flag_out <= R3(2);
	
END arch;