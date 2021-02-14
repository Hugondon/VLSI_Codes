--Recibe (In):
--Para solicitarle algún registro:
--SelA: Dirección de registro solicitado
--SelB: Dirección de registro solicitado
--Manda (Out):
--RegAOut: Valor de registro solicitado
--RegBOut: Valor de registro solicitado

--Para pedirle que modifique un registro:
--Recibe (In):
	--EnableIn='1'
	--SelIn: Dirección del registro que se desea modificar
	--RegDataInSel: ¿Dónde se encuentra el valor que se desea subir?
	--RegDataInSel=01 MemRegData: bus de datos
	--RegDataInSel=00 ALUIn: vendría conectada de la ALU			--ALU
	--RegDataInSel=10 RegDataImm: Control logic no especificada	--Timer, Controlunit
	--RegDataInSel=11 RegAInternal: Copiar el contenido de un registro interno seleccionado con SelA
	

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity AVRRegisters is
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
end AVRRegisters;
	
architecture DataFlow of AVRRegisters is
constant NUM_REGS: integer := 96;

type REG_ARRAY is array (0 to NUM_REGS-1) of std_logic_vector(7 downto 0);
signal Registers		: REG_ARRAY :=
(
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000",
	"00000000", "00000000", "00000000", "00000000", "00000000", "00000000");

signal RegIn			: std_logic_vector(7 downto 0);
signal RegAInternal		: std_logic_vector(7 downto 0);
 
-- Timer
signal signalTCCR		: std_logic_vector(7 downto 0) := (others => '0');		-- 
signal signalOCR		: std_logic_vector(7 downto 0) := (others => '0');		-- Match
signal signalTIFR		: std_logic_vector(7 downto 0) := (others => '0');
signal signalTCNT		: std_logic_vector(7 downto 0) := (others => '0');
-- Puerto A
signal signalDDRA		: std_logic_vector(7 downto 0) := (others => '0');
signal signalPINA		: std_logic_vector(7 downto 0) := (others => '0');
signal signalPORTA		: std_logic_vector(7 downto 0) := (others => '0');
-- Puerto B
signal signalDDRB		: std_logic_vector(7 downto 0) := (others => '0');
signal signalPINB		: std_logic_vector(7 downto 0) := (others => '0');
signal signalPORTB		: std_logic_vector(7 downto 0) := (others => '0');


begin

RegAInternal <=Registers(conv_integer(SelA)) when (conv_integer(SelA)<NUM_REGS) else (others => 'X');
RegAOut<=RegAInternal;

RegBOut <=Registers(conv_integer(SelB)) when (conv_integer(SelB)<NUM_REGS) else (others => 'X');

-- Timer
signalTIFR	<= 	TIFR;
signalTCNT	<= 	TCNT;
OCR			<= Registers(92);  	-- 0x5C
TCCR 		<= Registers(83); 	-- 0x53

-- Puerto A
PORTA		<= Registers(59);	-- 0x3B
DDRA		<= Registers(58);	-- 0x3A
signalPINA	<= PINA;			-- 0x39 (57)

-- Puerto B
PORTB		<= Registers(56);	-- 0x38
DDRB		<= Registers(55);	-- 0x37
signalPINB	<= PINB;			-- 0x36 (54)


RegIn <= 	ALUIn			when (RegDataInSel = "00") else
			(others => 'Z')	when (RegDataInSel = "01") else
			RegDataImm		when (RegDataInSel = "10") else
			RegAInternal	when (RegDataInSel = "11") else
			(others => 'X');

WriteRegister: process(clock)
begin 
	if rising_edge(clock) then
		if (EnableIn='1') then
			Registers(to_integer(unsigned(SelIn))) <= RegIn;
		end if;
	-- TIMER
	Registers(88)	<= signalTIFR;		-- 0x58
	Registers(82)	<= signalTCNT;
	-- PUERTO A
	Registers(57)	<= signalPINA;
	-- PUERTO B
	Registers(54)	<= signalPINB;
	end if;	
end process WriteRegister;
end DataFlow;
	