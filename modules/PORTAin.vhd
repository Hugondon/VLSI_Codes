---------------------------------------------------------------------------
-- Módulo:			Port individual
--
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
--
-- Descripción:	Implementación de un solo pin
--
-- Comentarios:	
---------------------------------------------------------------------------
-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
-- Entity
entity PORTAin is
	Port (
        DDRx            : in    std_logic;
        PINx            : out   std_logic;
        PORTx           : in    std_logic;
        Px	            : inout std_logic;
		Clk				: in std_logic);
end PORTAin;

-- Architecture
architecture behavior of PORTAin is
--SEÑALES Y CONSTANTES
--signal signalddrx0: std_logic:='1';
signal signalPx		: std_logic;
signal signalPINx	: std_logic:='0';
--signal signalPORTx: std_logic;
begin

signalPx <= 	PORTx when DDRx='1' 			  else
				'H'   when DDRx='0' and PORTx='1' else
				'Z';
				--signalddrx0;
Px			<= signalPx;
signalPINx	<= Px;
PINx		<= signalPINx;
end behavior;