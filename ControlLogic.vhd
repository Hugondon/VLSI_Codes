library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Realiza el conteo y lo reinicia si se llegó al top
entity ControlLogic is
--top: Se activa si se llegó al top (viene de MyTimer)
--clk: Reloj proveido por ClkSelect (pulso externo o prescaler) (viene de MyTimer)

--contador: valor del contador (va a MyTimer)
Port(
	cs: in std_logic_vector(2 downto 0);
	top: in std_logic;
	clk: in std_logic;
	contador: out std_logic_vector(7 downto 0)
);
end ControlLogic;

architecture Behavioral of ControlLogic is

signal contadortemp: std_logic_vector (7 downto 0):=(others=>'0');
signal nowfall: std_logic:='0';
signal nowrise: std_logic:='1';

begin	
	process(clk)
	begin
	if rising_edge(clk) then
		if cs="110" then
			if nowfall='1' then
				if (top='0') then
					if contadortemp="11111111" then
						contadortemp<=(others=>'0');
					else
						contadortemp<=contadortemp+'1';
					end if;
				else
					contadortemp <= (others => '0');
				end if;
			end if;
			nowfall<='1';
			nowrise<='0';
		else
			if nowrise='1' then
				if (top='0') then
					if contadortemp="11111111" then
						contadortemp<=(others=>'0');
					else
						contadortemp<=contadortemp+'1';
					end if;
				else
					contadortemp <= (others => '0');
				end if;
			end if;
			nowfall<='0';
			nowrise<='1';
		end if;
	end if;
	end process;
	contador <=contadortemp;
 
end Behavioral;