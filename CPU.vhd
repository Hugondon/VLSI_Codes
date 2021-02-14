------------------------------------------------------------------------------
-- Módulo:			CPU
--
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
--
-- Descripción:	    Implementación de CPU
--
-- Comentarios:	Ok
--
--
------------------------------------------------------------------------------

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity
entity CPU is		
	Port (	
        Clk					: in std_logic;
        Tn              : in std_logic;								-- Contador de Pulsos KEY0
        PA	         	: inout std_logic_vector(7 downto 0);	-- Puerto A: LEDG
		  TCNT				: out	  std_logic_vector(7 downto 0);	-- TCNT : LEDR
        PB              : inout std_logic_vector(7 downto 0));	-- Puerto B : SW
end CPU;

-- Arquitectura
architecture behavior of CPU is

-- Componentes
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
        Cons_En	: in		std_logic;
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
        -- Timer
        TCCR		:out std_logic_vector(7 downto 0);
        OCR			:out std_logic_vector(7 downto 0);
        TIFR		:in std_logic_vector(7 downto 0);
        TCNT		:in std_logic_vector(7 downto 0);
        -- Puerto
        DDRA		: out std_logic_vector(7 downto 0);
        PINA		: in std_logic_vector(7 downto 0);
        PORTA		: out std_logic_vector(7 downto 0);
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

Component PORTB is
	Port (
        DDRx            : in    std_logic_vector(7 downto 0);
        PINx            : out   std_logic_vector(7 downto 0);
        PORTx           : in    std_logic_vector(7 downto 0);
        Px	            : inout std_logic_vector(7 downto 0);
		Clk				: in std_logic);
end Component;

-- Señales y Constantes
constant FLASH_SIZE : integer := 2**13;
signal clk_div              : std_logic := '0';
-- PC
signal SignalPC_Address     : std_logic_vector(12 downto 0) := (others => '0');  
signal SignalIncrement      : std_logic_vector(6 downto 0) := (others => '0');
signal SignalCnt_En         : std_logic;
signal SignalReset_n        : std_logic;
-- CU
signal SignalOpcode         : std_logic_vector(15 downto 0);   
signal SignalIns            : std_logic_vector(4 downto 0); 
signal SignalSelA           : std_logic_vector(6 downto 0);
signal SignalSelB           : std_logic_vector(6 downto 0);
signal SignalEnableOut      : std_logic;
signal SignalRegDataOutSel  : std_logic_vector(1 downto 0);
signal SignalSelOut         : std_logic_vector(6 downto 0);
-- AR
signal SignalAluIn          : std_logic_vector(7 downto 0);
signal SignalRegAOut        : std_logic_vector(7 downto 0);
signal SignalRegBOut        : std_logic_vector(7 downto 0);
signal Signaltccrout		: std_logic_vector(7 downto 0);
signal Signalocrout			: std_logic_vector(7 downto 0);
signal Signaltifrin			: std_logic_vector(7 downto 0);
--TIMER
signal Signalmuxoredge		:std_logic  := '0';
signal Signaltccrin			:std_logic_vector(7 downto 0);
signal Signalocrin			:std_logic_vector(7 downto 0);
signal Signalcontador		:std_logic_vector(7 downto 0);
-- ALU
signal SignalSREG_En        : std_logic;
signal SignalCons_En        : std_logic;
-- PORTA
signal SignalDDRA           : std_logic_vector(7 downto 0);
signal SignalPORTA          : std_logic_vector(7 downto 0);
signal SignalPINA           : std_logic_vector(7 downto 0);
-- PORTB
signal SignalDDRB           : std_logic_vector(7 downto 0);
signal SignalPORTB          : std_logic_vector(7 downto 0);
signal SignalPINB           : std_logic_vector(7 downto 0);
-- Data Bus
signal SignalBus           : std_logic_vector(7 downto 0);
-- Flash 
subtype Opcode is std_logic_vector(15 downto 0);
type FLASH is array(natural range 0 to 17) of Opcode;
constant FLASHdata: FLASH := (
-- PRUEBA
"1110111100001111",	-- SER R16
"1011101100001010", 	-- OUT R16, DDRA
"0010011100000000", 	-- CLR R16
"1011101100000111",	-- OUT R16, DDRB
"1110101010011010",	-- LDI R25, 0b10101010
"1001010110010110",	-- LSR R25
"0010111101101001",	-- MOV R25, R22
"1011001100000110",  -- IN R16, PINB
"1001010100000000",	-- AND R22, R16
"0010001101100000",	-- L
"1110000000001010",	-- LDI R16, 0b00001010
"0000111100000110",	-- ADD R16, R255
"1011101100001011",	-- OUT .., R16
"1110000000001111", -- LDI R16, 15
"1011111100001100", -- OUT OCR, R16
"1110000000001110", -- LDI R16, 0b00001010   --110 falling, 111 rising 
"1011111100000011", -- OUT TCCR, R16
"0000000000000000");-- Colchón
signal Index : natural := 0;
begin
-- PC
Index 			<= to_integer(unsigned(SignalPC_Address)); 
SignalOpcode	<= FLASHdata(Index);
-- TCNT
TCNT				<= Signalcontador;
-- Divisor
    PC : PROGRAM_COUNTER
    port map(
        clk         => clk_div,
        Cnt_En      => SignalCnt_En,
        Reset_n     => SignalReset_n,
        Increment   => SignalIncrement,
        PC_Address  => SignalPC_Address
    );
    CU : CONTROL_UNIT
    port map(
        clk             => clk_div,
        Opcode          => SignalOpcode,
        Ins             => SignalIns,
        K               => SignalBus,
        SREG_En         => SignalSREG_En,
        Cons_En         => SignalCons_En,
        Cnt_En          => SignalCnt_En,
        PC_Reset        => SignalReset_n,
        Increment       => SignalIncrement,
        RegAIn          => SignalRegAOut,
        SelA            => SignalSelA,
        SelB            => SignalSelB,
        EnableOut       => SignalEnableOut,
        RegDataOutSel   => SignalRegDataOutSel,
        SelOut          => SignalSelOut
    );
    AR : AVRRegisters
    port map(
        clock           => clk_div,
        EnableIn        => SignalEnableOut,
        SelIn           => SignalSelOut,
        SelA            => SignalSelA,
        SelB            => SignalSelB,
        ALUIn           => SignalALUIn,
        RegDataImm      => SignalBus,
        RegDataInSel    => SignalRegDataOutSel,
        RegAOut         => SignalRegAOut,
        RegBOut         => SignalRegBOut,
		--TIMER
		tccr			=> Signaltccrout,
		ocr				=> Signalocrout,
        tifr			=> Signaltifrin,
        TCNT            => signalcontador,
        --PuertoA
        DDRA            => signalDDRA,
        PORTA           => signalPORTA,
        PINA            => signalPINA,
        --PuertoB
        DDRB            => signalDDRB,
        PORTB           => signalPORTB,
        PINB            => signalPINB
    );
    ALU0: ALU
    port map(
        clk     => clk_div,
        Rdi     => SignalRegAOut,
        Rr      => SignalRegBOut,
        K       => SignalBus,
        SREG_En => SignalSREG_En,
        Cons_En	=> SignalCons_En,
        SREG    => SignalBus,
        Rdo     => SignalAluIn,
        Ins     => SignalIns
    );
	TIMER: MyTimer
	port map(
		clk8M		=> clk_div,
		muxoredge=> Signalmuxoredge,
		tccr		=> Signaltccrout,
		ocr		=> Signalocrout,
		tn			=> Tn,
		tifr		=> Signaltifrin,
		contador	=> Signalcontador
	);
    PORTAx: PORTA
    port map(
        DDRx        => signalDDRA,
        PINx        => signalPINA,
        PORTx       => signalPORTA,
        Px          => PA,
        Clk         => clk_div 
    );
    PORTBx: PORTB
    port map(
        DDRx        => signalDDRB,
        PINx        => signalPINB,
        PORTx       => signalPORTB,
        Px          => PB,
        Clk         => clk_div 
    );


    clock_proc: process (Clk)
	variable cont: integer := 0;
	begin
		if rising_edge (Clk) then
				cont := cont + 1;
			if cont = 50000000/(8000000*2) then -- 8.33MHz
			--if cont = 50000000/(1000*2) then -- 1000 Hz

				cont := 0;
				clk_div <= NOT (clk_div);
			else
				clk_div <= clk_div;
			end if;	
		else
		cont := cont;
		end if;
	end process clock_proc;
end behavior;
