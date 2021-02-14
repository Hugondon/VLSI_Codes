LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY DIVnHz is
	GENERIC( nHz : integer := 200);			-- Frecuencia deseada
	PORT(
	CLOCK_50: IN STD_LOGIC;
	clk_out: OUT STD_LOGIC
	);	
END DIVnHz;
ARCHITECTURE beh of DIVnHz is
	signal clk_div: STD_LOGIC;
	begin
	process (CLOCK_50)
	variable cont: integer := 0;
	begin
		if rising_edge (CLOCK_50) then
				cont := cont + 1;
			if cont = 50000000/(2*nHz) then -- 50MHz/Frecuencia deseada. ¿Aproximar a entero?
				cont := 0;
				clk_div <= NOT (clk_div);
			else
				clk_div <= clk_div;
			end if;	
		else
		cont := cont;
		end if;
	end process;
		clk_out <= clk_div;
end beh;