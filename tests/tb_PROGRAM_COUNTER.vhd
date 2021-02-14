library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PROGRAM_COUNTER is
end;

architecture test of tb_PROGRAM_COUNTER is
component PROGRAM_COUNTER is
        Port (
            clk             : in std_logic;
            Cnt_En          : in std_logic;
            Reset_n         : in std_logic;
            Increment       : in std_logic_vector(5 downto 0);
            PC_Address      : out std_logic_vector(12 downto 0));
end Component;

-- Constants
	constant f_FPGA: time := 20 ns;
-- Signals
signal clk          : std_logic := '0';
signal Cnt_En       : std_logic := '0';
signal Reset_n      : std_logic := '1';
signal Increment    : std_logic_vector(5 downto 0) := (others => '0');
signal PC_Address   : std_logic_vector(12 downto 0) := (others => '0');

begin

    dev_to_test: PROGRAM_COUNTER
    port map(
        clk         => clk,
        Cnt_En      => Cnt_En,
        Reset_n     => Reset_n,
        Increment   => Increment,
        PC_Address  => PC_Address);
	-- Proceso para simular reloj
	clk_stimulus: process
	begin
		wait for f_FPGA/2;
		clk <= not clk;
	end process clk_stimulus;

	-- Proceso para simular manejo de datos
	data_stimulus: process
    begin
        wait for 20 ns;
        Cnt_En  <= '1';
        -- Incrementos positivos
        Increment   <= "000000";
        wait for 20 ns;
        Increment   <= "000001";    
        wait for 20 ns;
        Increment   <= "000111";
        wait for 20 ns;
        -- Incrementos negativos
        Increment   <= "111111";      
        wait for 500 us;
	end process data_stimulus;

end test;