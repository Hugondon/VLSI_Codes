library ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE IEEE.NUMERIC_STD.ALL;
--mux que define si se usará reloj de 8MHz, prescaler o pulso externo
entity MuxPresc is
--clkIO: reloj de la fpga, pero ajustado a 8MHz para simular clk del Atmega16 (viene de ClkSelect)
--PSR10: no utilizado
--T0: pin controlado por el usuario para pulso externo (viene de ClkSelect/MyTimer)
--T0n: negado de T0
--CS: parte del TCCR que decide ajuste de prescaler (viene de ClkSelect/MyTimer)

--ClkT0: salida conectada a mux que decide entre el prescaler o este componente (va a ClkSelect)
port(
	ClkIO : in std_logic;
	PSR10: in std_logic;
	T0 : in std_logic;
	--T0n : in std_logic;
	CS : in std_logic_vector(2 downto 0);
	
	ClkT0 : out std_logic
);
end MuxPresc;

architecture behav of MuxPresc is
signal cnt_temp : std_logic_vector(9 downto 0) := "0000000000";	--Contador temporal utilizado
signal Clk8 :  std_logic;
signal Clk64 :  std_logic;
signal Clk256 :  std_logic;
signal Clk1024 :  std_logic;
signal nottn: std_logic:='1';
begin
	nottn<= not T0;
	--Contador de ClkIO
	process (PSR10, ClkIO)
	begin
		if PSR10 = '1' then
			cnt_temp <= "0000000000";
		elsif falling_edge(ClkIO) then
			cnt_temp <= cnt_temp + 1;
		end if;
	end process;
	
	--Switch case de cada prescaler
	clk8 <= cnt_temp(2);
	clk64 <= cnt_temp(5);
	clk256 <= cnt_temp(7);
	clk1024 <= cnt_temp(9);
	
	--Multiplexor Timer/Counter0 Clock Source
	with Cs select
		ClkT0 <= '0' when "000",
					ClkIO when "001",
					Clk8 when "010",
					Clk64 when "011",
					Clk256 when "100",
					Clk1024 when "101",
					nottn	 when "110",
					T0 when "111",
					'0' when others;
end behav;