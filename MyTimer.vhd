library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--clk8M: reloj ajustado a 8 MHz (viene de Atmega16)
--muxoredge: pin de la fpga para seleccionar entre el edge detector(pin externo tn) o	prescaler (siempre 0) (viene de Atmega16)
--tccr: registro controlado por el usuario para definir comportamiento del contador(Modo timer WGM y Clock Selector CS) (viene de Atmega16)
--ocr: Registro controlado por el usuario para establecer el número del compare (viene de Atmega16)
--tn: pin controlado por el usuario para pulso externo (viene de Atmega16)


--match: pin que se activa cuando se hizo match
--tifr: vector que almacena registro que indica el tope de conteo (va a Atmega16/Controlunit)
--contador: vector que almacene el número que tiene el contador (va a Atmega16)
entity MyTimer is 
Port(
	clk8M		: in std_logic;
	muxoredge	: in std_logic; --0 para mux, 1 para edge (siempre 0)
	tccr		: in std_logic_vector(7 downto 0);
	ocr			: in std_logic_vector(7 downto 0);
	tn			: in std_logic;
	tifr		: out std_logic_vector(7 downto 0);
	contador	: out std_logic_vector(7 downto 0)
);
end MyTimer;


architecture Behavioral of MyTimer is
--SEÑALES Y CONSTANTES
constant topmax: std_logic_vector(7 downto 0):=(others=>'1'); --representar un FF para el compare
signal top: std_logic_vector(7 downto 0); --toma valor del ocr o del top max dependiendo del tccr
signal contadortemp: std_logic_vector(7 downto 0):=(others=>'0'); --valor del contador del timer
signal topcontrol: std_logic; --si se alcanzó el top
signal sclksel	: std_logic;
signal signalTCCR		: std_logic_vector(7 downto 0) := (others => '0');		-- 
signal signalOCR		: std_logic_vector(7 downto 0) := (others => '0');		-- Match
signal signalTIFR		: std_logic_vector(7 downto 0) := (others => '0');
signal cs				: std_logic_vector(2 downto 0) := (others => '0');
--COMPONENTES
component ControlLogic is
	Port(
	 cs: in std_logic_vector(2 downto 0);
	top: in std_logic;
	clk: in std_logic;
	contador: out std_logic_vector(7 downto 0)
);
end component;

component ClkSelect is
	port(	
	clk8M: in std_logic;
	tccr: in std_logic_vector(7 downto 0);
	tn: in std_logic;
	muxoredge: in std_logic;
	clkout: out std_logic
	);
end component;

 

begin
--LÓGICA
TIFR		<= signalTIFR;
signalTCCR	<= tccr;
signalOCR	<= ocr;
cs		 	<= tccr(2 downto 0);
--CONEXIONES
--elcontador: ControlLogic port map(topcontrol,tn,contadortemp);
elcontador	: 	ControlLogic port map(cs,topcontrol,sclksel,contadortemp);
elreloj		: 	ClkSelect port map(clk8M,signalTCCR,tn,'0',sclksel);

top <= signalOCR when signalTCCR(6)='0' AND signalTCCR(3)='1' else
		 --topmax when tccr(6)=0 AND tccr(3)=0 else
		 topmax;
topcontrol <= '1' when contadortemp=top else
			'0';
--compare con ocr0 bit 1 tifr 0x58 (OCF)
--conteo máximo bit 0 TIFR 0x58 (TOV)
--signalTIFR(1) <= '1' when topcontrol='1' AND (signalTCCR(6)='0' AND signalTCCR(3)='1') else
--			'0';
--signalTIFR(0) <= '1' when topcontrol='1' AND (signalTCCR(6)='0' NAND signalTCCR(3)='1') else --No sé si esto esté bien
--			'0';		
--match <= '1' when topcontrol='1' else
--			'0';
contador <=contadortemp;
banderatifr_proc: process(clk8M)
begin
	if topcontrol='1' AND (signalTCCR(6)='0' AND signalTCCR(3)='1') then
	signalTIFR(1)<='1';
	elsif topcontrol='1' AND (signalTCCR(6)='0' NAND signalTCCR(3)='1') then
	signalTIFR(0) <= '1';
	end if;
end process banderatifr_proc;


end Behavioral;