LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
Entity FFD is
	port( 
		D, CLK, CLR    : IN std_logic;	-- D -> KEY0, CLK -> SW0, CLR -> SW1
		Q, QN    		: OUT std_logic	-- Q -> LEDR0, QN -> LEDR1
		);
    end Entity FFD;
Architecture Beh of FFD is
    begin
        process(CLK)
            begin
            if(rising_edge(CLK)) then  -- Activo en Flanco de Subida
                Q   <= D;
                QN  <= NOT(D);
            end if;
				if(CLR = '1') then					
					 Q 	<= '0';
					 QN 	<= '1';
				end if;
        end process;
end Beh;