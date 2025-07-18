LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;

ENTITY ram_2048x8 IS 
	PORT (
		addr: IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		dio: INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		clk_in, nrst: IN STD_LOGIC;
		mem_wr_en, mem_rd_en: IN STD_LOGIC
	);
END ENTITY;

ARCHITECTURE arch OF ram_2048x8 IS
	TYPE ram_array IS ARRAY (0 TO 2047) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL memory : ram_array;
BEGIN
	-- L�gica sequencial para escrita.
	PROCESS(clk_in, nrst)
	BEGIN
		IF nrst = '0' THEN
			memory <= (others => (others => '0'));
		ELSIF RISING_EDGE(clk_in) THEN
			IF mem_wr_en = '1' THEN	
				memory(conv_integer(addr)) <= dio;
			END IF;
		END IF;
	END PROCESS;
	
	-- L�gica combinacional para leitura.
	dio <= memory(conv_integer(addr)) WHEN mem_rd_en = '1' ELSE (others => 'Z');
END arch;