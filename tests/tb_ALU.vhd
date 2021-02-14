library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU is
end;

architecture test of tb_ALU is

component ALU is
    port(
        clk     : in        std_logic;
        Rdi		: in     	std_logic_vector(7 DOWNTO 0);		-- Registro d
        Rdo     : out       std_logic_vector(7 downto 0);
        Rr		: in    	std_logic_vector(7 DOWNTO 0);		-- Registro r
        K       : in        std_logic_vector(7 downto 0);
        SREG_En	: in		std_logic;
        SREG	: inout 	std_logic_vector(7 DOWNTO 0);		-- Registro SREG
        Ins	    : in 		std_logic_vector(4 DOWNTO 0)		-- Instrucción Recibida
    );
end component;

-- Constants
	constant f_FPGA: time := 20 ns;
-- Signals
signal clk      : std_logic := '0';
signal Rdi      : std_logic_vector(7 downto 0);
signal Rdo      : std_logic_vector(7 downto 0);
signal Rr       : std_logic_vector(7 downto 0);
signal K        : std_logic_vector(7 downto 0) := (others => 'Z');
signal SREG_En  : std_logic := '1';
signal SREG     : std_logic_vector(7 downto 0) := (others => '0');
signal Ins      : std_logic_vector(4 downto 0) := (others => '0');

begin

	dev_to_test: ALU
    port map(
        clk     => clk,
        Rdi     => Rdi,
        Rdo     => Rdo,
        Rr      => Rr,
        K       => K,
        SREG_En => SREG_En,
        SREG    => SREG,
        Ins     => Ins);
	
	-- Proceso para simular reloj
	clk_stimulus: process
	begin
		wait for f_FPGA/2;
		clk <= not clk;
	end process clk_stimulus;

	-- Proceso para simular manejo de datos
	data_stimulus: process
    begin
        -- Pruebas para banderas
        -- Prueba INC
        Rdi <= "11111111";
        Rr  <= "00000000";
        Ins <= "01110";
        -- Deberían activarse: H, Z, C
        wait for 20 ns;
        Rdi <= "01111111";
        Rr  <= "00000000";
        Ins <= "01110";
        -- Deberían activarse: H, V
        wait for 20 ns;
        -- Prueba DEC
        Rdi <= "00000001";
        Ins <= "01111";
        wait for 20 ns;
        -- Prueba CLR
        Rdi <= "10101010";
        Ins <= "10000";
        wait for 20 ns;
        -- Prueba LSL
        Rdi <= "10001000";
        Ins <= "10101";
        -- SREG(0) en '1'. Result = "00010000"
        wait for 20 ns;
        -- Prueba ROL
        Rdi <= "10001000";
        Ins <= "10111";
        -- SREG(0) en '1'. Result = "00010001"
        wait for 20 ns;
        -- Prueba LSL
        Rdi <= "00001000";
        Ins <= "10101";
        -- SREG(0) en '0'. Result = "00010000"
        wait for 20 ns;
        -- Prueba ROL
        Rdi <= "10001000";
        Ins <= "10111";
        -- SREG(0) en '1'. Result = "00010000"
        wait for 20 ns;
        Rdi <= "00000000";
        Rr  <= "00000000";
        Ins <= "00000";
        wait for 20 ns;
        -- Prueba LSR
        Rdi <= "10000001";
        Ins <= "10110";
        -- SREG(0) en '1'. Result = "01000000"
        wait for 20 ns;
        -- Prueba ROR
        Rdi <= "00001110";
        Ins <= "11000";
        -- SREG(0) en '0'. Result = "00000111"

        wait for 500 us;
	end process data_stimulus;

end test;