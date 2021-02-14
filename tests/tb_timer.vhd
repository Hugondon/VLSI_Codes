library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_timer is
end;

architecture test of tb_timer is

--Diseño de Timer
Component MyTimer is
	port(
		clk8M: in std_logic;
		muxoredge: in std_logic; --0 para mux, 1 para edge (siempre 0)
		tccr: in std_logic_vector(7 downto 0);
		ocr: in std_logic_vector(7 downto 0);
		tn: in std_logic;
	
		tifr: out std_logic_vector(7 downto 0);
		contador: out std_logic_vector(7 downto 0)
		);
end component;
    
-- Constants
	constant f_FPGA: time := 20 ns;
-- Signals
	signal  clk8M: std_logic:='0';
	signal	muxoredge: std_logic:='0'; --0 para mux, 1 para edge (siempre 0)
	signal	tccr: std_logic_vector(7 downto 0):="00000000";
	signal	ocr: std_logic_vector(7 downto 0):="00000000";
	signal	tn: std_logic:='0';
	
	signal	tifr: std_logic_vector(7 downto 0):="00000000";
	signal	contador: std_logic_vector(7 downto 0):="00000000";

begin
    dev_to_test:	MyTimer
        port map(clk8M,muxoredge,tccr,ocr,tn,tifr,contador);
	
	-- Proceso para simular reloj
	clk_stimulus: process
	begin
		wait for f_FPGA/2;
		clk8M <= not clk8M;
    end process clk_stimulus;
    
    data_stimulus: process
    begin
		muxoredge<='0';
		wait for 100 ns;
		ocr<="00001111"; --ocr a 15
		tccr<="00001001"; --bit 3 dice compare, bit 0 a 2 dicen modo   --110 falling, 111 rising
        wait for 20 ns;
		tn<='1';
		wait for 5 ns;
		tn<='0';
		wait for 40 ns;
		tn<='1';
		wait for 20 ns;
		tn<='0';
		wait for 20 ns;
		tn<='1';
		wait for 5 ns;
		tn<='0';
		wait for 40 ns;
		tn<='1';
		wait for 20 ns;
		tn<='0';
		
		
		
    end process data_stimulus;
	
end test;