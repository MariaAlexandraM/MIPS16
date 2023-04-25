library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity test_env is
    Port ( -- in
           clk: in std_logic;
           btn: in std_logic_vector (4 downto 0); -- pt ca am bifat bus
           sw: in std_logic_vector (15 downto 0);
           -- out
           led: out std_logic_vector (15 downto 0);
           an: out std_logic_vector (3 downto 0); -- logica negativa!
           cat: out std_logic_vector (6 downto 0));  -- logica negativa!
end test_env;

architecture Behavioral of test_env is
-- Components --
component MPG is
    Port ( en: out std_logic;
           input: in std_logic;
           clock: in std_logic);
end component;

component SSD is
    Port ( clk: in std_logic;
           digits: in std_logic_vector(15 downto 0);
           an: out std_logic_vector(3 downto 0);
           cat: out std_logic_vector(6 downto 0));
end component;

component IF_fetch is
    Port ( -- in
           clk: in std_logic;
           rst: in std_logic;
           en: in std_logic;
           BranchAddress: in std_logic_vector(15 downto 0);
           JumpAddress: in std_logic_vector(15 downto 0);
           JumpSelect: in std_logic; -- Jump adica in test_env ii sw(0)
           BranchSelect: in std_logic; -- PCSrc adica in test_env ii sw(1)
           -- out
           Instruction: out std_logic_vector(15 downto 0);
           PCinc: out std_logic_vector(15 downto 0));
end component;

component ID is
    Port ( -- in
           clk: in std_logic;
           en: in std_logic;
           RegDst: in std_logic;
           Instr: in std_logic_vector(12 downto 0);
           RegWrite: in std_logic;
           ExtOp: in std_logic;
           wd: in std_logic_vector(15 downto 0);
           -- out
           rd1, rd2: out std_logic_vector(15 downto 0);
           Ext_Imm: out std_logic_vector(15 downto 0); -- I-Type
           func: out std_logic_vector(2 downto 0); -- R-Type
           sa: out std_logic); -- R-Type
end component;

component MainControl is
     Port ( -- in 
           Instr: in std_logic_vector(15 downto 0);
           -- out
           BrBNE: out std_logic;
           RegDst: out std_logic;
           ExtOp: out std_logic;
           ALUSrc: out std_logic;
           Branch: out std_logic;
           Jump: out std_logic;
           ALUOp: out std_logic_vector(2 downto 0);
           MemWrite: out std_logic;
           MemToReg: out std_logic;
           RegWrite: out std_logic);
end component;

component EX is
    Port ( -- in 
           rd1: in std_logic_vector(15 downto 0);
           rd2: in std_logic_vector(15 downto 0);
           ALUSrc: in std_logic;
           Ext_Imm: in std_logic_vector(15 downto 0);
           PCinc: in std_logic_vector(15 downto 0);
           sa: in std_logic;
           func: in std_logic_vector(2 downto 0);
           ALUOp: in std_logic_vector(1 downto 0);
           -- out
           Zero: out std_logic;
           ALURes: out std_logic_vector(15 downto 0);
           BranchAddress: out std_logic_vector(15 downto 0));
end component;

component MEM is
    port ( -- in
           clk: in std_logic;
           en: in std_logic;
           ALUResIn: in std_logic_vector(15 downto 0);
           rd2: in std_logic_vector(15 downto 0);
           MemWrite: in std_logic;			
           -- out
           MemData: out std_logic_vector(15 downto 0);
           ALUResOut: out std_logic_vector(15 downto 0));
end component;

-- Signals --

signal Instruction, PCinc, rd1, rd2, WD, Ext_imm: std_logic_vector(15 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData: std_logic_vector(15 downto 0);
signal func: std_logic_vector(2 downto 0);
signal sa, zero: std_logic;
signal digits: std_logic_vector(15 downto 0);
signal signalEN, signalRST, PCSrc: std_logic; 
-- mainControl signals
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);

begin
    -- buttons: enable si reset
    en_btn: MPG port map(en => signalEN, input => btn(0), clock => clk);
    rst_btn: MPG port map(en => signalRST, input => btn(1), clock => clk);
    
    -- ssd displa
    display: SSD port map (clk => clk, digits => digits, an => an, cat => cat);

    instruction_decoder: ID port map(clk => clk, 
                                     en => enable, 
                                     RegDst => signalRegDst, 
                                     Instr => Instructions(12 downto 0), 
                                     RegWrite => signalRegWrite, 
                                     ExtOp => signalExtOp, 
                                     wd => sum, 
                                     rd1 => rd1, 
                                     rd2 => rd2, 
                                     Ext_Imm => signalExt_imm, 
                                     func => led(3 downto 1), 
                                     sa => led(0));

    -- MUX 
    process(sw(7 downto 5))
    begin
        case sw(7 downto 5) is
            when "000" => digits <= Instruction;
            when "001" => digits <= PCinc;
            when "010" => digits <= rd1;
            when "011" => digits <= rd2;
            when "100" => digits <= Ext_
            when "101" => digits <= signalExt_imm(15 downto 0); 
            when others => digits <= x"0000";
        end case;
    end process;
    
    -- MainControl 
                                    
    -- InstructionExecute
end Behavioral;  
