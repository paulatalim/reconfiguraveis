LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Decoder IS
PORT (
	i: IN STD_LOGIC_VECTOR(7 DOWNTO 0);-- sele��o
	ei: IN STD_LOGIC; -- enable
	a: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	gs: OUT STD_LOGIC;
	eo: OUT STD_LOGIC
);
END ENTITY;

ARCHITECTURE arch1 OF Decoder IS
	SIGNAL input_merge: STD_LOGIC_VECTOR(8 DOWNTO 0);
BEGIN
	input_merge <= ei & i;
	WITH i SELECT
		a <= "111" WHEN "00000001" | "00000000" | ei = '1' else,
			 "000" WHEN i(7) = '0' else,
			 "001" WHEN i(6) = '0' else,
			 "010" WHEN i(5) = '0' else,
			 "011" WHEN i(4) = '0' else,
			 "100" WHEN i(3) = '0' else,
			 "101" WHEN i(2) = '0' else,
			 "110" WHEN i(1) = '0' else,
			 "111" WHEN OTHERS; -- disabled
END arch1;