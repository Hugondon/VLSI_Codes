library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity tb_CPU is
end;

architecture test of tb_CPU is

-- Componentes
-- Diseño de CPU
Component CPU is		
	Port (
        Clk				: in std_logic;
        Tn              : in std_logic;
        PA              : inout std_logic_vector(7 downto 0);
        PB              : inout std_logic_vector(7 downto 0));	
end Component;
-- Diseño de PC 
-- Diseño de PC 
Component PROGRAM_COUNTER is
	Port (
        clk             : in std_logic;
        Cnt_En          : in std_logic;
        Reset_n         : in std_logic;
        Increment       : in std_logic_vector(6 downto 0);
        PC_Address      : out std_logic_vector(12 downto 0));
end Component;
-- Diseño de Unidad de Control
Component CONTROL_UNIT is
	Port (
        clk             : in std_logic;
        Opcode          : in std_logic_vector(15 downto 0);
        -- ALU
        Ins             : out std_logic_vector(4 downto 0);
        K               : out std_logic_vector(7 downto 0);
        SREG_En         : out std_logic;
        Cons_En         : out std_logic;
        -- PROGRAM_COUNTER
        Cnt_En          : out std_logic;
        PC_Reset        : out std_logic;
        Increment       : out std_logic_vector(6 downto 0);
        -- AVRRegisters
        RegAIn          : in  std_logic_vector(7 downto 0);
        SelA            : out std_logic_vector(6 downto 0);
        SelB            : out std_logic_vector(6 downto 0);
        EnableOut       : out std_logic;
        RegDataOutSel   : out std_logic_vector(1 downto 0);
        SelOut          : out std_logic_vector(6 downto 0));
end Component;
-- Diseño de ALU
Component ALU is
    port(
        clk     : in        std_logic;
        Rdi		: in     	std_logic_vector(7 DOWNTO 0);		-- Registro d
        Rdo     : out       std_logic_vector(7 downto 0);
        Rr		: in    	std_logic_vector(7 DOWNTO 0);		-- Registro r
        K       : in        std_logic_vector(7 downto 0);
        SREG_En : in        std_logic;
        SREG	: inout 	std_logic_vector(7 DOWNTO 0);		-- Registro SREG
        Ins	    : in 		std_logic_vector(4 DOWNTO 0)		-- Instrucción Recibida
    );
end Component;
-- Diseño de Bloque de Registros 
Component AVRRegisters is
    port(
        clock   		:in std_logic;
        EnableIn		:in std_logic;
        SelIn			:in std_logic_vector(6 downto 0);
        SelA			:in std_logic_vector(6 downto 0);
        SelB			:in std_logic_vector(6 downto 0);
        ALUIn			:in std_logic_vector(7 downto 0);
        RegDataImm		:in std_logic_vector(7 downto 0);
        RegDataInSel	:in std_logic_vector(1 downto 0);
        RegAOut			:out std_logic_vector(7 downto 0);
        RegBOut			:out std_logic_vector(7 downto 0);
        MemRegData	:inout std_logic_vector(7 downto 0);
        -- Timer
        TCCR		:out std_logic_vector(7 downto 0);
        OCR			:out std_logic_vector(7 downto 0);
        TIFR		:in std_logic_vector(7 downto 0);
        TCNT		:in std_logic_vector(7 downto 0);
        -- Puerto A
        DDRA		: out std_logic_vector(7 downto 0);
        PINA		: in std_logic_vector(7 downto 0);
        PORTA		: out std_logic_vector(7 downto 0);
        -- Puerto B
        DDRB		: out std_logic_vector(7 downto 0);
        PINB		: in std_logic_vector(7 downto 0);
        PORTB		: out std_logic_vector(7 downto 0));
    end Component;
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
-- Diseño de Puerto
Component PORTA is
	Port (
        DDRx            : in    std_logic_vector(7 downto 0);
        PINx            : out   std_logic_vector(7 downto 0);
        PORTx           : in    std_logic_vector(7 downto 0);
        Px	            : inout std_logic_vector(7 downto 0);
		Clk				: in std_logic);
end Component;
    
-- Constants
	constant f_FPGA: time := 20 ns;
-- Signals
    signal clk	: std_logic := '0';
	signal tn	: std_logic:='0';
    signal PA   : std_logic_vector(7 downto 0):="00000000";
    signal PB   : std_logic_vector(7 downto 0):="00000000";
begin
    dev_to_test:	CPU
        port map(clk,tn,PA,PB);
	
	-- Proceso para simular reloj
	clk_stimulus: process
	begin
		wait for f_FPGA/2;
		clk <= not clk;
    end process clk_stimulus;
    
    data_stimulus: process
    begin
        PA  <= (others => 'Z');
        PB  <= (others => 'Z');
        wait for 28 us;
        PB  <= "00001111";
        wait for 300 us;
    end process data_stimulus;
	
end test;