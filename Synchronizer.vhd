LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
Entity Synchronizer is
	port( 
	   D, CLK    	: IN std_logic; 			-- D -> KEY0, CLK -> SW0
		Q         	: OUT std_logic			-- Q -> LEDR0
		);
    End Entity Synchronizer;
Architecture Beh of Synchronizer is
    Component FFD is
        port( 
            D, CLK, CLR    : IN std_logic; 
            Q, QN  			: OUT std_logic
            );
    end Component FFD;
	 component D_Latch is
	 port( 
			D, L     	 	: IN std_logic; 		-- D -> KEY0, L -> SW0
			Q, QN    		: OUT std_logic		-- Q -> LEDR0, QN -> LEDR1
	 );
    end component;
    signal Q1 : STD_LOGIC;
    begin
		U0: D_Latch port map(D, CLK, Q1);
		U1: FFD port map(Q1, CLK, '0', Q);
end Beh;