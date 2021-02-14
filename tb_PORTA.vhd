library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PORTA is
end;

architecture test of tb_PORTA is

component PORTA is
	Port (
        DDRx            : in    std_logic_vector(7 downto 0);
        PINx            : out   std_logic_vector(7 downto 0);
        PORTx           : in    std_logic_vector(7 downto 0);
        Px	            : inout std_logic_vector(7 downto 0);
		Clk				: in std_logic);
end component;

-- Constants
	constant f_FPGA : time := 20 ns;
-- Signals
    signal DDRx     : std_logic_vector(7 downto 0)  := (others => '0');
    signal PINx     : std_logic_vector(7 downto 0)  := (others => '0');
    signal PORTx    : std_logic_vector(7 downto 0)  := (others => '0');
    signal Px       : std_logic_vector(7 downto 0)  := (others => '0');
    signal Clk     	: std_logic  					:= '0';
begin

    dev_to_test:	PORTA
    port map(
        DDRx    => DDRx,
        PINx    => PINx,
        PORTx   => PORTx,
        Px     	=> Px,
        Clk     => Clk
    );
	
	-- Proceso para simular reloj
	clk_stimulus: process
	begin
		wait for f_FPGA/2;
		clk <= not clk;
	end process clk_stimulus;
	
	-- Proceso para simular manejo de datos
	data_stimulus: process
    begin
		Px<=(others => 'Z');
        -- -- Lectura Pull Up
        -- DDRx        <= "00000000";
        -- PORTx       <= "11111111";
        -- wait for 20 ns;
		-- --Lectura Alta Impedancia
		-- DDRx 		<= "00000000";
		-- PORTx		<= "00000000";
		-- wait for 20 ns;
		-- --Escritura de '0'
		-- DDRx        <= "11111111";
		-- PORTx       <= "00000000";
		-- wait for 20 ns;
		-- --Escritura de '1'
		-- DDRx        <= "11111111";
		-- PORTx       <= "11111111";
		-- wait for 20 ns;
		-- --Lectura de 0 en Px
		 -- DDRx        <= "00000000";
		 -- PORTx       <= "00000000";
		 -- Px			 <= "00000000";
        -- wait for 20 ns;
		-- --Lectura de 1 en Px
		 -- DDRx        <= "00000000";
		 -- PORTx       <= "00000000";
		 -- Px			 <= "11111111";
        -- wait for 20 ns;	
        DDRx        <= "00001111";
        PORTx       <= "00110011";
        wait for 20 ns;
		
		DDRx        <= "11110000";
        PORTx       <= "11001100";
		Px          <= "ZZZZ1100";
        wait for 20 ns;
	end process data_stimulus;
end test;