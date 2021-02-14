library ieee;
use ieee.std_logic_1164.all;

entity EdgeDetectorB is
--clk8m: reloj de la fpga, pero ajustado a 8MHz para simular clk del Atmega16 (viene de ClkSelect)
--tn: pin controlado por el usuario para pulso externo (viene de ClkSelect/MyTimer)

--edgeout: salida conectada a mux que decide entre el prescaler o este componente (va a ClkSelect)
Port(
			clk8M: in std_logic;
			tn: in std_logic;
			edgeout: out std_logic
	);	
end EdgeDetectorB;

architecture behav of EdgeDetectorB is
component synchronizer is
port( 
	   D, CLK    	: IN std_logic; 			-- D -> KEY0, CLK -> SW0
		Q         	: OUT std_logic			-- Q -> LEDR0
);
End component;

component EdgeDetector is
port( 
    Q, CLK      	: IN std_logic; 			-- D -> KEY0, CLK -> SW0
    edgeout       : OUT std_logic			-- Q -> LEDR0
);
End component;
signal intedge: std_logic; 
 
begin
u1:synchronizer port map(tn,clk8M,intedge);
u2:EdgeDetector port map(intedge,clk8M,edgeout);
end behav;