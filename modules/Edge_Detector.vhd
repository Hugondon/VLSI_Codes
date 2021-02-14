LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
Entity Edge_Detector is
	port( 
	    Q, CLK      	: IN std_logic; 			-- D -> KEY0, CLK -> SW0
	    edgeout        	: OUT std_logic			-- Q -> LEDR0
		);
    End Entity Edge_Detector;
Architecture Beh of Edge_Detector is
    Component FFD is
        port( 
            D, CLK, CLR    : IN std_logic; 
            Q, QN  			: OUT std_logic
            );
    end Component FFD;
    signal Q1, QN: STD_LOGIC;
    begin
        U0: FFD port map(Q, CLK, '0', Q1);  
        QN <= NOT(Q);
        edgeout <=  Q1 AND QN;
end Beh;