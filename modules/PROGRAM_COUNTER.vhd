---------------------------------------------------------------------
-- Módulo:			PROGRAM_COUNTER
--
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
--
-- Descripción:	    Modifica PC de acuerdo a valor de entrada 
--
-- Comentarios:	    reset_n es activo en '0'
--                  Cnt_En es activo en '1'
---------------------------------------------------------------------

-- Librerías
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entidad
entity PROGRAM_COUNTER is
	Port (
        clk             : in std_logic;
        Cnt_En          : in std_logic;
        Reset_n         : in std_logic;
        Increment       : in std_logic_vector(6 downto 0);
        PC_Address      : out std_logic_vector(12 downto 0));
end PROGRAM_COUNTER;

-- Arquitectura
architecture behavior of PROGRAM_COUNTER is

-- Señales
signal currentPC    : std_logic_vector(12 downto 0) := (others => '0');
begin

    increment_proc: process(clk)
    begin
        if (reset_n = '0') then
            currentPC <= (others => '0');
        else
            if (rising_edge(clk) and Cnt_En = '1') then
                currentPC <= std_logic_vector(signed(currentPC) + signed(Increment));
            else
                currentPC <= currentPC;
            end if;
        end if;
    end process increment_proc;

PC_Address <= currentPC;
end behavior;
