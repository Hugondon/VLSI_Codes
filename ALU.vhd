---------------------------------------------------------------------
-- Archivo:			ALU.vhd
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
-- Descripción:		Implementación de funcionamiento de ALU de ATmega16
---------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-- Entidad
entity ALU is
port(
    clk     : in        std_logic;
    Rdi		: in     	std_logic_vector(7 DOWNTO 0);		-- Registro d
    Rdo     : out       std_logic_vector(7 downto 0);
    Rr		: in    	std_logic_vector(7 DOWNTO 0);		-- Registro r
	K       : in        std_logic_vector(7 downto 0);
	SREG_En	: in		std_logic;
	Cons_En	: in		std_logic;
	SREG	: inout 	std_logic_vector(7 DOWNTO 0);		-- Registro SREG
	Ins	    : in 		std_logic_vector(4 DOWNTO 0)		-- Instrucción Recibida
);
end ALU;
architecture beh of ALU is

-- Señales Definidas
signal Result 		: STD_LOGIC_VECTOR(7 DOWNTO 0) 	:= (others => '0');
signal s_k	  		: std_logic_vector(7 downto 0)	:= (others => 'Z');
signal signalSREG	: std_logic_vector(7 downto 0) 	:= (others => 'Z');

	begin
	-- Asignaciones para Registros
	s_k	<= 	K 	when K /= "ZZZZZZZZ" and Cons_En = '1' else
			s_k;
	Rdo 		<= Result;
    -- Ejecutar operaciones lógico/aritméticas

	with Ins select
	Result <= 	    Rdi + Rr 																															when "00000",	--  0 - ADD (Add two Registers)
					Rdi + Rr + SREG(0) 																													when "00001",	--  1 - ADC (Add with Carry two Registers)
					Rdi - Rr 																															when "00010",	--  2 - SUB (Substract two Registers)
					std_logic_vector(SIGNED(Rdi) - SIGNED(Rr)) 																				            when "00011",	--  3 - SUBI (Substract Constant from Registers)
					Rdi - Rr - SREG(0) 																													when "00100",	--  4 - SBC (Substract with Carry two Registers)
					Rdi and Rr																															when "00101",	--  5 - AND (Logical AND Registers)	
					Rdi and s_k																															when "00110",	--  6 - ANDI (Logical AND Register and Constant)
					Rdi or Rr																															when "00111",	--  7 - OR (Logical OR Registers)
					Rdi or s_k																															when "01000",	--  8 - ORI (Logical OR Register and Constant)
					Rdi xor Rr																															when "01001",	--  9 - EOR (Exclusive OR Registers)
					not(Rdi)																															when "01010",	-- 10 - COM (One's complement)
					not(Rdi) + 1																														when "01011",	-- 11 - NEG (Two's complement)
					Rdi or s_k																															when "01100",	-- 12 - SBR (Set Bit(s) in Register)
					Rdi and ("11111111" - s_k) 																										    when "01101",	-- 13 - CBR (Clear Bit(s) in Register)		
					Rdi + 1																																when "01110",	-- 14 - INC (Increment)		
					Rdi - 1																																when "01111",	-- 15 - DEC (Decrement)	
					"00000000"																															when "10000",	-- 16 - CLR (Clear Register)
					"11111111"																															when "10001",	-- 17 - SER (Set Register)
					--STD_LOGIC_VECTOR(TO_UNSIGNED((TO_INTEGER(UNSIGNED(Rdi))*TO_INTEGER(UNSIGNED(Rr))), 16))(7 DOWNTO 0)	when "10010",	-- 18 - MUL (Multiply Unsigned)	
					--STD_LOGIC_VECTOR(TO_SIGNED((TO_INTEGER(SIGNED(Rdi))*TO_INTEGER(SIGNED(Rr))), 16))(7 DOWNTO 0)			when "10011",	-- 19 - MULS (Multiply Signed)
					--STD_LOGIC_VECTOR(TO_UNSIGNED((TO_INTEGER(SIGNED(Rdi))*TO_INTEGER(UNSIGNED(Rr))), 16))(7 DOWNTO 0)		when "10100",	-- 20 - MULSU (Multiply Signed with Unsigned)
					Result																																when others;
	-- SREG
	signalSREG(7) <= 'Z';
	signalSREG(6) <= 'Z';
	signalSREG(5) <= 	(Rdi(3) and s_k(3) ) 	or (s_k(3) and not(Result(3))) or 	(Rdi(3) and not(Result(3))) when s_k /= "ZZZZZZZZ" and SREG_En = '1' else
						(Rdi(3) and Rr(3) ) 	or (Rr(3) and not(Result(3))) or 	(Rdi(3) and not(Result(3))) when s_k =	"ZZZZZZZZ" and SREG_En = '1' else
						signalSREG(5);
	signalSREG(4) <= 	signalSREG(2) XOR signalSREG(3) when SREG_En = '1' else
						signalSREG(4);				
	signalSREG(3) <= 	(Rdi(7) and s_k(7) 	and not(Result(7))) 	or (not(Rdi(7)) and not(s_k(7)) and Result(7)) when s_k /= 	"ZZZZZZZZ" and SREG_En = '1' else
						(Rdi(7) and Rr(7) 	and not(Result(7)))		or (not(Rdi(7)) and not(Rr(7)) 	and Result(7)) when s_k =	"ZZZZZZZZ" and SREG_En = '1' else
						signalSREG(3);		
	signalSREG(2) <= 	Result(7) when SREG_En = '1' else
						signalSREG(2);						
	signalSREG(1) <= not(Result(7)) and not(Result(6)) and not(Result(5)) and not(Result(4)) and not(Result(3)) and not(Result(2)) and not(Result(1)) and not(Result(0));					
	signalSREG(0) <= 	(Rdi(7) and s_k(7)) or (Rdi(7) and not(Result(7))) or (s_k(7) 	and not(Result(7))) when s_k /= 	"ZZZZZZZZ" and SREG_En = '1' 	else
						(Rdi(7) and Rr(7)) 	or (Rdi(7) and not(Result(7))) or (Rr(7) 	and not(Result(7))) when s_k =		"ZZZZZZZZ" and SREG_En = '1'	else
						signalSREG(0);

	-- http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf

    SREG_proc: process(clk)
	begin
		if(SREG_En = '1') then
			SREG			<= signalSREG;
		else
            SREG <= (others => 'Z');
        end if;
    end process SREG_proc;
end beh;
