
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0); -- pt ca am bifat bus
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0); -- logica negativa!
           cat : out STD_LOGIC_VECTOR (6 downto 0));  -- logica negativa!
end test_env;

architecture Behavioral of test_env is
--signal cnt: std_logic_vector(7 downto 0) := (others => '0');
signal cnt: std_logic_vector(3 downto 0) := (others => '0');
signal enable: std_logic;
signal rst: std_logic;
signal digits: std_logic_vector(15 downto 0) := (others => '0');

signal do_rom: std_logic_vector(15 downto 0) := (others => '0');
type ROM_type is array (0 to 255) of std_logic_vector(15 downto 0); -- 2^8 x 16
signal rom_var: ROM_type := (x"0001", x"0005", x"000A", others => x"0000");

type reg_array is array(0 to 15) of std_logic_vector(15 downto 0);
signal reg_file: reg_array := (x"0001", x"0201", x"2402", x"1003", x"1234", x"0321", x"0041", x"9907", others => x"0000");

signal we: std_logic; 
signal rd: std_logic_vector(15 downto 0);
signal rd1, rd2: std_logic_vector(15 downto 0) := (others => '0');

type bram_array is array(0 to 15) of std_logic_vector(15 downto 0);
signal bram_mem: bram_array := (x"0001", x"0201", x"2402", x"1003", x"1235", x"0321", x"0041", x"9907", others => x"0000"); 

signal do: std_logic_vector(15 downto 0) := (others => '0');

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

signal Instructions, nextPC: std_logic_vector(15 downto 0);

component IF_fetch is
    Port ( clk: in std_logic;
           rst: in std_logic;
           en: in std_logic;
           BranchAddress: in std_logic_vector(15 downto 0);
           JumpAddress: in std_logic_vector(15 downto 0);
           JumpSelect: in std_logic; -- Jump adica in test_env ii sw(0)
           BranchSelect: in std_logic; -- PCSrc adica in test_env ii sw(1)
           Instruction: out std_logic_vector(15 downto 0);
           nextPC: out std_logic_vector(15 downto 0));
end component;

component ID is
    Port ( clk: in std_logic;
           en: in std_logic;
           RegDst: in std_logic;
           Instr: in std_logic_vector(12 downto 0);
           RegWrite: in std_logic;
           ExtOp: in std_logic;
           wd: in std_logic_vector(15 downto 0);
           rd1, rd2: out std_logic_vector(15 downto 0);
           Ext_Imm: out std_logic_vector(15 downto 0); -- I-Type
           func: out std_logic_vector(2 downto 0); -- R-Type
           sa: out std_logic); -- R-Type
end component;

component MainControl is
     Port ( Instr: in std_logic_vector(15 downto 0);
           BrBNE: out std_logic;
           RegDst: out std_logic;
           ExtOp: out std_logic;
           ALUSrc: out std_logic;
           Branch: out std_logic;
           Jump: out std_logic;
           ALUOp: out std_logic_vector(2 downto 0);
           MemWrite: out std_logic;
           MemToReg: out std_logic;
           RegWr: out std_logic);
end component;

component EX is
    Port ( RD1: in std_logic_vector(15 downto 0);
           RD2: in std_logic_vector(15 downto 0);
           ALUSrc: in std_logic;
           Ext_Imm: in std_logic_vector(15 downto 0);
           nextPC: in std_logic_vector(15 downto 0);
           sa: in std_logic;
           func: in std_logic_vector(2 downto 0);
           ALUOp: in std_logic_vector(1 downto 0);
           Zero: out std_logic;
           ALURes: out std_logic_vector(15 downto 0);
           BranchAddress: out std_logic_vector(15 downto 0));
end component;

signal signalALUSrc: std_logic;
signal signalBranch, signalJump, signalMemWrite, signalMemToReg, signalSA, signalZero: std_logic;
signal signalALUOp : STD_LOGIC_VECTOR (2 downto 0);
signal func, sel: std_logic_vector (2 downto 0);

signal signalRegDst, signalExtOp, signalRegWrite: std_logic;
signal sum, signalExt_imm, iesire_ID: std_logic_vector(15 downto 0);

begin
    instruction_if: IF_fetch port map(clk => clk , rst => rst, en => enable, BranchAddress => x"0004", JumpAddress => x"0000", JumpSelect => sw(0), BranchSelect => sw(1), Instruction => Instructions, nextPC => nextPC);

    -- mux 
    process(sw(7)) 
    begin 
        if sw(7) = '1' then
            digits <= nextPc;
        else 
            digits <= Instructions;
        end if;
    end process;
    
    debouncer1: MPG port map(en => enable, input => btn(0), clock => clk);
    debouncer2: MPG port map(en => rst, input => btn(1), clock => clk);
    
    display: SSD port map (clk => clk, digits => digits, an => an, cat => cat);

    sum <= rd1 + rd2;
    
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
            when "000" => iesire_ID(15 downto 0) <= Instructions(15 downto 0);
            when "001" => iesire_ID(15 downto 0) <= nextPc(15 downto 0);
            when "010" => iesire_ID(15 downto 0) <= rd1(15 downto 0);
            when "011" => iesire_ID(15 downto 0) <= rd2(15 downto 0);
            when "100" => iesire_ID(15 downto 0) <= sum(15 downto 0); 
            when "101" => iesire_ID(15 downto 0) <= signalExt_imm(15 downto 0); 
            when others => iesire_ID(15 downto 0) <= x"0000";
        end case;
    end process;
    
    -- MainControl 
    mainCtrl: MainControl port map( Instr => Instructions, 
                                    RegDst => signalRegDst, 
                                    ExtOp => signalExtOp, 
                                    ALUSrc => signalALUSrc, 
                                    Branch => signalBranch, 
                                    Jump => signalJump, 
                                    ALUOp => signalALUOp, 
                                    MemWrite => signalMemWrite, 
                                    MemToReg => signalMemToReg, 
                                    RegWr => signalRegWrite);
                                    
    -- InstructionExecute
    InstructionExecute: EX port map( RD1 => rd1,
                                     RD2 => rd2,  
                                     ALUSrc => signalALUSrc,
                                     Ext_Imm => signalExt_imm,
                                     nextPC => nextPC,
                                     sa => signalSA,
                                     func => func,
                                     ALUOp => signalALUOp,
                                     Zero => signalZero, 
                                     ALURes => signalALURes,
                                     BranchAddress => x"0004");
end Behavioral;  
