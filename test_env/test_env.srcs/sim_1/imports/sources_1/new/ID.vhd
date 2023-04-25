
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ID is
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
end ID;

architecture Behavioral of ID is
-- Signals --
type reg_array is array(0 to 7) of std_logic_vector(15 downto 0);
signal reg_file: reg_array := (others => x"0000");

signal WriteAddress: std_logic_vector(2 downto 0);
signal imm: std_logic_vector(6 downto 0);
signal immAux: std_logic_vector(15 downto 0);

begin

    -- rs <= Instr(12 downto 10);
    -- rt <= Instr(9 downto 7);
    -- rd <= Instr(6 downto 4);
    
    -- RegFile write 
    with RegDst select
        WriteAddress <= Instr(6 downto 4) when '1', -- rd
                        Instr(9 downto 7) when '0', -- rt
                        (others => '0') when others; -- unknown  
    
    -- Proces RegFile 
    process(clk) 
    begin 
        if rising_edge(clk) then 
            if en = '1' and RegWrite = '1' then 
                reg_file(conv_integer(WriteAddress)) <= wd;
            end if;
        end if;
    end process;
    
    -- ra1 <= Instr(12 downto 10);
    -- ra2 <= Instr(9 downto 7);
    
    -- RegFile read
    rd1 <= reg_file(conv_integer(Instr(12 downto 10))); -- rs
    rd2 <= reg_file(conv_integer(Instr(9 downto 7))); -- rt
    
    -- immediate extend
    Ext_Imm(6 downto 0) <= Instr(6 downto 0); 
    with ExtOp select -- sign extender
        Ext_Imm(15 downto 7) <= (others => Instr(6)) when '1', 
                                (others => '0') when '0',
                                (others => '0') when others;

    -- other outputs
    func <= Instr(2 downto 0);
    sa <= Instr(3);
    
end Behavioral;

