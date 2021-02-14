library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

--Mux que decide entre Edge detector o prescaler
entity ClkSelect is
--clk8M: reloj ajustado a 8 MHz (viene de MyTimer/Atmega16)
--tccr: registro controlado por el usuario para definir comportamiento del contador(Modo timer WGM y Clock Selector CS) (viene de MyTimer/Atmega 16)
--tn: pin controlado por el usuario para pulso externo (viene de MyTimer/Atmega 16)
--muxoredge: pin de la fpga para seleccionar entre el edge detector(pin externo tn) o	prescaler (viene de MyTimer/Atmega 16)

--clkout: define si el timer funcionará con pulsos externos o con el prescalador (va a MyTimer)
port(	
	clk8M: in std_logic;
	tccr: in std_logic_vector(7 downto 0);
	tn: in std_logic;
	muxoredge: in std_logic;
	clkout: out std_logic
);
end ClkSelect;

architecture behav of ClkSelect is
--SEÑALES Y CONSTANTES
signal cs: std_logic_vector(2 downto 0);
--signal clk8M: std_logic;
signal muxout: std_logic;
--signal nottn: std_logic;
signal edgeout: std_logic;
signal signaltn: std_logic;

--COMPONENTES
--component DIVnHz is
--port(
--	CLOCK_50: IN STD_LOGIC;
--	clk_out: OUT STD_LOGIC
--);
--end component;

component EdgeDetectorB is
	Port(
			clk8M: in std_logic;
			tn: in std_logic;
			edgeout: out std_logic
	);
end component;
component MuxPresc is
port(
	ClkIO : in std_logic;
	PSR10: in std_logic;
	T0 : in std_logic;
	--T0n : inout std_logic;
	CS : in std_logic_vector(2 downto 0);
	
	ClkT0 : out std_logic
);
end component;



begin
--LÓGICA
--CONEXIONES
cs<=tccr(2 downto 0);
signaltn<=tn;
--u1:DIVnHz port map(clkin,clk8M);
u2:MuxPresc port map(clk8M,'0',signaltn,cs,muxout);
u3:EdgeDetectorB port map(clk8M,signaltn,edgeout);
clkout<=muxout when muxoredge='0' else
		  edgeout;
end behav;