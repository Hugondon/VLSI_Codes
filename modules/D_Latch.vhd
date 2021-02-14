LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
Entity D_Latch is
	port( 
		D, L     	 	: IN std_logic; 		-- D -> KEY0, L -> SW0
		Q, QN    		: OUT std_logic		-- Q -> LEDR0, QN -> LEDR1
		);
    end Entity D_Latch;
Architecture Beh of D_Latch is
	signal D2 : STD_LOGIC;						-- Valor provisional de D
    begin
	 D2 <= D when(L = '1')
	 else D2;										-- Si L no está en '1', valor no debe ser manipulable
	 Q <= D2;
	 QN <= NOT(D2);
end Beh;