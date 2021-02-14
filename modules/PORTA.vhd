---------------------------------------------------------------------------
-- Módulo:			Puerto A
--
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
--
-- Descripción:	Implementación de los cuatro puertos
--
-- Comentarios:	Interactúa con I/O Registers (0x30 - 0x3B) y Bus de Datos
---------------------------------------------------------------------------
-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- Entity
entity PORTA is
	Port (
        DDRx            : in    std_logic_vector(7 downto 0);
        PINx            : out   std_logic_vector(7 downto 0);
        PORTx           : in    std_logic_vector(7 downto 0);
        Px	            : inout std_logic_vector(7 downto 0);
		Clk				: in std_logic);
end PORTA;
architecture behavior of PORTA is
--SEÑALES
--COMPONENTES
component PORTAin is
	Port(
	DDRx            : in    std_logic;
    PINx            : out   std_logic;
    PORTx           : in    std_logic;
    Px	            : inout std_logic;
	Clk				: in std_logic
);
end component;
begin

--Conexiones
pin7:PORTAin port map(DDRx(7),PINx(7),PORTx(7),Px(7),clk);
pin6:PORTAin port map(DDRx(6),PINx(6),PORTx(6),Px(6),clk);
pin5:PORTAin port map(DDRx(5),PINx(5),PORTx(5),Px(5),clk);
pin4:PORTAin port map(DDRx(4),PINx(4),PORTx(4),Px(4),clk);
pin3:PORTAin port map(DDRx(3),PINx(3),PORTx(3),Px(3),clk);
pin2:PORTAin port map(DDRx(2),PINx(2),PORTx(2),Px(2),clk);
pin1:PORTAin port map(DDRx(1),PINx(1),PORTx(1),Px(1),clk); 
pin0:PORTAin port map(DDRx(0),PINx(0),PORTx(0),Px(0),clk); 
end behavior;

