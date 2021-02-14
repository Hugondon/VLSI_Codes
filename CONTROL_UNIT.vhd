-- Módulo:			CONTROL_UNIT
--
-- Alumnos:			Hugo Pérez, Francisco Polo, Daniel Arellano	
--
-- Descripción:	    Unidad de Control implementada con FSM.
--
-- Comentarios:	    ALURRInstruction para operaciones registro a registro
--                  ALURInstruction para operaciones de un solo registro
--                  ALUCInstruction para operaciones de un registro con una constante
--                  RegConsInstruction para instrucciones registro - constante
--                  RegTrasfInstruction para instrucciones de transferencia de datos
---------------------------------------------------------------------

-- Libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entity
entity CONTROL_UNIT is
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
end CONTROL_UNIT;

-- Architecture
architecture behavior of CONTROL_UNIT is

-- Signals and Constants
constant SREG_Address       : std_logic_vector(6 downto 0) := "1011111";
-- PROGRAM COUNTER
signal signalIncrement      : std_logic_vector(6 downto 0) := "0000001";
signal PCInstruction        : std_logic := '0';
-- CONTROL UNIT
signal ActualOpcode         : std_logic_vector(15 downto 0):= (others => '0');
signal registerDNum         : std_logic_vector(6 downto 0) := (others => '0');
signal registerRNum         : std_logic_vector(6 downto 0) := (others => '0');
signal dataToRegister       : std_logic_vector(7 downto 0) := (others => '0');
signal constantValue        : std_logic_vector(7 downto 0) := (others => '0');
signal ALURRInstruction     : std_logic := '0';
signal ALURInstruction      : std_logic := '0';
signal ALUCInstruction      : std_logic := '0';
signal HachiInstruction     : std_logic := '0';
signal NeronInstruction     : std_logic := '0';
signal RegConsInstruction   : std_logic := '0';
signal RegTransfInstruction : std_logic := '0';
signal RegIInstruction      : std_logic := '0';
signal RegOInstruction      : std_logic := '0';
-- INTERACTIONS
signal NumInst              : std_logic_vector(4 downto 0) := (others => '0');
signal countEnable          : std_logic := '0';
signal enableRegisters      : std_logic := '0';
signal RegistersSelection   : std_logic_vector(1 downto 0) := (others => '0');
signal selectedRegister     : std_logic_vector(6 downto 0) := (others => '0');
signal enableSREG           : std_logic := '0';
signal enableCons           : std_logic := '0';
signal receivedRegister     : std_logic_vector(7 downto 0) := (others => 'Z');
signal receivedRegister2    : std_logic_vector(7 downto 0) := (others => '0');
signal actualRegister       : std_logic_vector(6 downto 0) := (others => '0');
signal newCarry             : std_logic := '0';

-- FSM
type FSM is (FETCH, DECODE, EXECUTE, MEM, WB, STOPSTATE);
signal current_state    : FSM := FETCH;
signal next_state       : FSM := FETCH;	

--Agregarlos aqui 
type Instruction is (None, LDI, ADD, SUB, AAND, OOR, EOR, COM, NEG, SBR, CBR, INC, DEC, CLR, SER, MOV, LSL, LSR, RROL, RROR, BRNE, IIN, OOUT);
signal current_instruction  : Instruction := None;
begin
-- CONTROL UNIT
ActualOpcode    <= Opcode;
-- PC
PC_Reset        <= '1';
Cnt_En          <= countEnable;
Increment       <= signalIncrement;
-- ALU
Ins             <= NumInst;
K               <= dataToRegister;
SREG_En         <= enableSREG;
Cons_En         <= enableCons;
-- AVRRegisters 
SelA            <= registerDNum;
SelB            <= registerRNum;
EnableOut       <= enableRegisters;
RegDataOutSel   <= RegistersSelection;
SelOut          <= selectedRegister;
    Control_proc : process(clk)
    begin
    if(rising_edge(clk)) then
        case next_state is
            when FETCH =>
                current_instruction <= None;
                current_state       <= FETCH;
            -- PC
            countEnable     <= '0';
            signalIncrement <= (others => '0');
            -- ALU
                enableSREG          <= '0';
            -- AVRRegisters
                enableRegisters     <= '0';
                RegistersSelection  <= (others => 'Z');
                dataToRegister      <= (others => 'Z');
                next_state          <= DECODE;
            when DECODE =>
            current_state <= DECODE;
            -- Reset Registers
                registerDNum <= (others => '0');
                registerRNum <= (others => '0');
            -- Instruction Decoding
                if ActualOpcode(15 downto 10) = "000011" then
                -- ADD and LSL
                    if ActualOpcode(8 downto 4) = ActualOpcode(9)&ActualOpcode(3 downto 0) then 
                    -- LSL
                        current_instruction <= LSL;
                        registerDNum        <= "00"&ActualOpcode(8 downto 4);
                        HachiInstruction    <= '1';
                        next_state          <= EXECUTE;
                    else
                    -- ADD
                        current_instruction <= ADD;
                        registerDNum        <= "00"&ActualOpcode(8 downto 4);
                        registerRNum        <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);
                        ALURRInstruction    <= '1';
                        NumInst             <= "00000";
                        next_state          <= EXECUTE;
                    end if;
                elsif ActualOpcode(15 downto 10) = "000110" then
                    current_instruction <= SUB;
                -- SUB
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);
                    registerRNum    <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);                
                    ALURRInstruction  <= '1';
                    NumInst         <= "00010";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 10) = "001000" then
                    current_instruction <= AAND;
                -- AND
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);
                    registerRNum    <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);                
                    ALURRInstruction  <= '1';
                    NumInst         <= "00101";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 10) = "001010" then
                    current_instruction <= OOR;
                -- OR
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);
                    registerRNum    <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);                
                    ALURRInstruction<= '1';
                    NumInst         <= "00111";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 10) = "001001" then 
                -- EOR/CLR
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);
                    registerRNum    <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);                
                    ALURRInstruction  <= '1';
                    if registerDNum = registerRNum then
                        current_instruction <= CLR;
                        NumInst         <= "10000"; -- CLR
                    else
                        current_instruction <= EOR;
                        NumInst         <= "01001"; -- EOR
                    end if;
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0000" then
                    current_instruction <= COM;
                -- COM
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);               
                    ALURInstruction  <= '1';
                    NumInst         <= "01010";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0001" then
                    current_instruction <= NEG;
                -- NEG
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);               
                    ALURInstruction  <= '1';
                    NumInst         <= "01011";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 12) = "0110" then
                    current_instruction <= SBR;
                -- SBR
                    registerDNum    <= "00"&std_logic_vector(to_unsigned(to_integer(unsigned(ActualOpcode(7 downto 4))) + 16, 5)); 
                    constantValue       <= ActualOpcode(11 downto 8)&ActualOpcode(3 downto 0);         
                    ALUCInstruction <= '1';
                    NumInst         <= "01100";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 12) = "0111" then
                    current_instruction <= CBR;
                -- CBR
                    registerDNum <= "00"&std_logic_vector(to_unsigned(to_integer(unsigned(ActualOpcode(7 downto 4))) + 16, 5)); 
                    constantValue <= ActualOpcode(11 downto 8)&ActualOpcode(3 downto 0);         
                    ALUCInstruction  <= '1';
                    NumInst         <= "01101";
                    next_state <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0011" then
                    current_instruction <= INC;
                -- INC
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);               
                    ALURInstruction  <= '1';
                    NumInst         <= "01110";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "1010" then
                    current_instruction <= DEC;
                -- DEC
                    registerDNum    <= "00"&ActualOpcode(8 downto 4);               
                    ALURInstruction  <= '1';
                    NumInst         <= "01111";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 8) = "11101111" and ActualOpcode(3 downto 0) = "1111" then
                    current_instruction <= SER;
                -- SER
                    registerDNum <= "00"&std_logic_vector(to_unsigned(to_integer(unsigned(ActualOpcode(7 downto 4))) + 16, 5));            
                    ALURInstruction  <= '1';
                    NumInst         <= "10001";
                    next_state      <= EXECUTE;
                elsif ActualOpcode(15 downto 10) = "111101" and ActualOpcode(2 downto 0) = "001" then
                    current_instruction <= BRNE;
                -- BRNE
                    PCInstruction       <= '1';
                    signalIncrement     <= ActualOpcode(9 downto 3);
                    next_state          <= MEM;
                elsif ActualOpcode(15 downto 10) = "001011" then
                    current_instruction <= MOV;
                -- MOV
                    registerDNum            <= "00"&ActualOpcode(8 downto 4);
                    registerRNum            <= "00"&ActualOpcode(9)&ActualOpcode(3 downto 0);    
                    RegTransfInstruction    <= '1';          
                    next_state              <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0110" then
                    current_instruction <= LSR;
                -- LSR
                    registerDNum        <= "00"&ActualOpcode(8 downto 4); 
                    HachiInstruction     <= '1';        
                    next_state          <= EXECUTE;
                elsif ActualOpcode(15 downto 10) = "000111" then 
                    current_instruction <= RROL;
                -- RROL
                    registerDNum        <= "00"&ActualOpcode(8 downto 4);
                    actualRegister      <= "00"&ActualOpcode(8 downto 4);      
                    NeronInstruction    <= '1';  
                    next_state          <= EXECUTE;
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0111" then
                    current_instruction <= RROR;
                -- RROR
                    registerDNum        <= "00"&ActualOpcode(8 downto 4); 
                    actualRegister      <= "00"&ActualOpcode(8 downto 4);                  
                    NeronInstruction    <= '1';  
                    next_state          <= EXECUTE;
                elsif ActualOpcode(15 downto 12) = "1110" then
                    current_instruction <= LDI;
                -- LDI
                    registerDNum        <= "00"&std_logic_vector(to_unsigned(to_integer(unsigned(ActualOpcode(7 downto 4))) + 16, 5));
                    constantValue       <= ActualOpcode(11 downto 8)&ActualOpcode(3 downto 0);  
                    RegConsInstruction  <= '1';
                    next_state          <= WB;
                elsif ActualOpcode(15 downto 11) = "10110" then
                    current_instruction <= IIN;
                -- IN
                    registerDNum        <= "00"&ActualOpcode(8 downto 4);
                    registerRNum        <= '0'&ActualOpcode(10 downto 9)&ActualOpcode(3 downto 0);
                    RegIInstruction     <= '1';
                    next_state          <= EXECUTE;
                elsif ActualOpcode(15 downto 11) = "10111" then
                    current_instruction <= OOUT;
                -- OUT
                    registerDNum        <= "00"&ActualOpcode(8 downto 4);
                    registerRNum        <= '0'&ActualOpcode(10 downto 9)&ActualOpcode(3 downto 0);
                    RegOInstruction     <= '1';
                    next_state          <= EXECUTE;    
                elsif ActualOpcode(15 downto 0) = "0000000000000000" then
                    next_state          <= STOPSTATE;               
                end if;
            when EXECUTE =>
                current_state <= EXECUTE;
                if ALURRInstruction = '1' or ALURInstruction = '1' then
                    -- AVRRegisters
                    enableSREG          <= '1';
                    enableRegisters     <= '1';
                    selectedRegister    <= SREG_Address;   -- 0x5F
                    RegistersSelection  <= "10";
                    dataToRegister      <= (others => 'Z');
                    next_state <= WB;
                elsif ALUCInstruction = '1' then
                    dataToRegister      <= constantValue;     
                    enableCons          <= '1';               
                    next_state <= MEM;            
                elsif HachiInstruction = '1' then 
                    -- HABILITAR ESCRITURA
                    enableRegisters     <= '1';
                    -- DAR DIRECCIÓN DE REGISTRO A ESCRIBIR
                    selectedRegister    <= registerDNum;
                    -- ¿CÓMO LO RECIBIRÁ? CONSTANTE DESDE CONTROL UNIT
                    RegistersSelection  <= "10";  
                    if ActualOpcode(15 downto 10) = "000011" then
                        -- LSL
                        dataToRegister <=   RegAIn(6 downto 0)&'0';
                        -- Guardamos Carry
                        newCarry            <= RegAIn(7);
                    elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0110"  then
                        -- LSR        
                        dataToRegister <=   '0'&RegAIn(7 downto 1);
                        -- Guardamos Carry
                        newCarry            <= RegAIn(0);                
                    end if;
                next_state <= WB;
                elsif NeronInstruction = '1' then
                    -- Recibimos contenido de registro
                    receivedRegister    <= RegAIn;
                    receivedRegister2   <= RegAIn;
                    -- Pedimos contenido de SREG
                    registerDNum        <= SREG_Address;
                    next_state <= MEM;
                elsif RegTransfInstruction = '1' then
                    -- MOV
                    -- DAR DIRECCIÓN DE REGISTRO A ESCRIBIR
                    selectedRegister    <= registerDNum;
                    next_state <= WB;
                elsif RegIInstruction = '1' then
                    selectedRegister    <= registerDNum;
                    next_state <= WB;
                elsif RegOInstruction = '1' then
                    selectedRegister    <= std_logic_vector(to_unsigned(to_integer(unsigned(RegisterRNum)) + 32, 7));
                    next_state <= WB;
                end if;
            when MEM =>
            current_state <= MEM;
            if PCInstruction = '1' then
                -- BRNE
                registerDNum    <= SREG_Address;
            elsif NeronInstruction = '1' then
                receivedRegister    <= RegAIn;
                -- Habilitamos escritura
                enableRegisters     <= '1';
                selectedRegister    <= actualRegister;
                RegistersSelection   <= "10";
                if ActualOpcode(15 downto 10) = "000111" then
                -- RROL
                dataToRegister      <= receivedRegister2(6 downto 0)&RegAIn(0);
                elsif ActualOpcode(15 downto 9) = "1001010" and ActualOpcode(3 downto 0) = "0111" then
                -- RROR 
                dataToRegister      <= RegAIn(0)&receivedRegister2(7 downto 1);
                end if;
            elsif ALUCInstruction = '1' then
                enableSREG          <= '1';
                enableCons          <= '0';
                enableRegisters     <= '1';
                selectedRegister    <= SREG_Address;   -- 0x5F
                RegistersSelection  <= "10";
                dataToRegister      <= (others => 'Z');
            end if;
            next_state <= WB;
            when WB => 
                -- PC
                countEnable         <= '1';
                current_state       <= WB;
                signalIncrement     <= "0000001";
            if RegConsInstruction = '1' then
                RegConsInstruction  <= '0';
                -- HABILITAR ESCRITURA
                enableRegisters     <= '1';
                -- DAR DIRECCIÓN DE REGISTRO A ESCRIBIR
                selectedRegister    <= registerDNum;
                -- ¿CÓMO LO RECIBIRÁ?
                RegistersSelection  <= "10";
                -- ¿QUÉ VAMOS A ESCRIBIRLE?
                dataToRegister      <= constantValue;
                next_state <= FETCH;
            elsif ALURRInstruction = '1' or ALURInstruction = '1' or ALUCInstruction = '1' then
                -- Señales
                ALURRInstruction    <= '0';
                ALURInstruction     <= '0';
                ALUCInstruction     <= '0';
                -- HABILITAR ESCRITURA
                enableSREG          <= '0';
                enableRegisters     <= '1';
                -- DAR DIRECCIÓN DE REGISTRO A ESCRIBIR
                selectedRegister    <= registerDNum;
                -- ¿CÓMO LO RECIBIRÁ? SALIDA DE ALU
                RegistersSelection  <= "00";  
                next_state <= FETCH;     
            elsif HachiInstruction = '1' then
                HachiInstruction    <= '0';
                enableRegisters     <= '1';
                selectedRegister    <= SREG_Address;   -- 0x5F
                RegistersSelection  <= "10";
                dataToRegister      <= "ZZZZZZZ"&newCarry;
                next_state <= FETCH; 
            elsif NeronInstruction  = '1' then
                NeronInstruction    <= '0';
                receivedRegister    <= (others => '0');
                receivedRegister2   <= (others => '0');
                enableRegisters     <= '1';
                selectedRegister    <= SREG_Address;   -- 0x5F
                RegistersSelection  <= "10";
                dataToRegister      <= receivedRegister(7 downto 1)&receivedRegister2(0);
                next_state <= FETCH; 
            elsif RegTransfInstruction = '1' then
                -- MOV
                RegTransfInstruction  <= '0';
                -- HABILITAR ESCRITURA
                enableRegisters     <= '1';
                -- ¿CÓMO LO RECIBIRÁ?
                RegistersSelection  <= "11";
                -- ¿QUÉ VAMOS A ESCRIBIRLE?
                 registerDNum <= registerRNum;
                 next_state <= FETCH;
            elsif PCInstruction = '1' then
                PCInstruction   <= '0';
                if RegAIn(1) = '0' then   
                    signalIncrement <= ActualOpcode(9 downto 3);
                end if;
                next_state  <= FETCH;
            elsif RegIInstruction = '1' then
                RegIInstruction     <= '0';
                enableRegisters     <= '1';
                RegistersSelection  <= "11";
                registerDNum        <= std_logic_vector(to_unsigned(to_integer(unsigned(RegisterRNum)) + 32, 7));
                next_state          <= FETCH;
            elsif RegOInstruction = '1' then
                RegOInstruction     <= '0';
                enableRegisters     <= '1';
                RegistersSelection  <= "11";
                registerDNum        <= registerDNum;
                next_state          <= FETCH;
            end if;
            when STOPSTATE =>
                next_state  <= STOPSTATE;
        end case;
    else
        current_state   <= current_state;
        next_state      <= next_state;
    end if;
    end process Control_proc;
end behavior;