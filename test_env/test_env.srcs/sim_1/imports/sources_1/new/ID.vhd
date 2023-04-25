
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ID is
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
end ID;

architecture Behavioral of ID is

-- Components --
component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

-- Signals --
type reg_array is array(0 to 7) of std_logic_vector(15 downto 0);
signal reg_file: reg_array;
signal wa, ra1, ra2: std_logic_vector(2 downto 0); -- WriteAddress
signal rs, rt, rd: std_logic_vector(2 downto 0);
signal imm: std_logic_vector(6 downto 0);
signal immAux: std_logic_vector(15 downto 0);
begin

    -- rs <= Instr(12 downto 10);
    -- rt <= Instr(9 downto 7);
    -- rd <= Instr(6 downto 4);
    
    -- MUX WriteAddress
    process(RegDst, rt, rd) 
    begin 
        if RegDst = '0' then wa <= Instr(12 downto 10); -- rt;
                        else wa <= Instr(6 downto 4); -- rd;
        end if; 
    end process;
    
    -- Proces RegFile 
    process(clk, en, RegWrite) 
    begin 
        if rising_edge(clk) then 
            if en = '1' and RegWrite = '1' then 
                reg_file(conv_integer(wa)) <= wd;
            end if;
        end if;
    end process;
    
    ra1 <= Instr(12 downto 10);
    ra2 <= Instr(9 downto 7);
    rd1 <= reg_file(conv_integer(Instr(12 downto 10))); 
    rd2 <= reg_file(conv_integer(Instr(9 downto 7)));
    
    -- Extindere 
    process(ExtOp) 
    begin 
        if ExtOp = '0' 
            -- imm <= Instr(6 downto 0);
            then immAux <= "000000000" & Instr(6 downto 0);
        else 
            if Instr(6) = '1' then 
                immAux <= "111111111" & Instr(6 downto 0);
            else 
                immAux <= "000000000" & Instr(6 downto 0);
            end if;
        end if;
    end process;
    
    --   ExtZero <= "000000000" & (Instr(6 downto 0));
    --   ExtSign <= Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6) & Instr(6 downto 0);
    --   Ext_Imm <= ExtZero when ExtOp = '0' else ExtSign;
    
    Ext_Imm <= immAux;
    
    func <= Instr(2 downto 0);
    sa <= Instr(3);
    
end Behavioral;

