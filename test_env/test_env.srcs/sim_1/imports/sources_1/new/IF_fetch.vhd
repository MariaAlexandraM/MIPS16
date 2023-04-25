library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity IF_fetch is
    Port ( clk: in std_logic;
           rst: in std_logic;
           en: in std_logic;
           BranchAddress: in std_logic_vector(15 downto 0);
           JumpAddress: in std_logic_vector(15 downto 0);
           JumpSelect: in std_logic; -- Jump adica in test_env ii sw(0)
           BranchSelect: in std_logic; -- PCSrc adica in test_env ii sw(1)
           Instruction: out std_logic_vector(15 downto 0);
           nextPC: out std_logic_vector(15 downto 0));
end IF_fetch;

architecture Behavioral of IF_fetch is
type instruction_memory is array (0 to 31) of std_logic_vector(15 downto 0);
signal mem_sgn: instruction_memory := ( B"001_000_001_0000000", 	-- X"2080" -- ADDI $1, $0, 0 
                                        B"001_000_010_0000001", 	-- X"2101" -- ADDI $2, $0, 1 
                                        B"001_000_011_0000000", 	-- X"2180" -- ADDI $3, $0, 0 
                                        B"001_000_100_0000001", 	-- X"2201" -- ADDI $4, $0, 1 
                                        B"011_011_001_0000000", 	-- X"6C80" -- SW $1, 0($3) 
                                        B"011_100_010_0000000", 	-- X"7100" -- SW $2, 0($4) 
                                        B"010_011_001_0000000", 	-- X"4C80" -- LW $1, 0($3)
                                        B"010_100_010_0000000", 	-- X"4C80" -- LW $2, 0($4)
                                        B"000_001_010_101_0_000", 	-- X"0550" -- ADD $5, $1, $2 
                                        B"000_000_010_001_0_000", 	-- X"0110" -- ADD $1, $0, $2 
                                        B"000_000_101_010_0_000", 	-- X"02A0" -- ADD $2, $0, $5
                                        B"111_0000000001000", 		-- X"E008" -- J 8
                                        others => X"0000"); 		-- NoOp (ADD $0, $0, $0)
signal pc_Q, iesire, nextPcCopy, iesireBranchMux: std_logic_vector(15 downto 0);
signal Address: std_logic_vector(4 downto 0);

begin 
    -- registru de PC
    process(clk, en, rst)
       begin
           if rst = '1' then
                pc_Q <= x"0000";
           else 
               if clk'event and clk = '1' then
                   if en = '1' then
                       pc_Q <= iesire;
                   end if;
               end if;
           end if;
       end process;
    
    Address <= pc_Q(4 downto 0);
    Instruction <= mem_sgn(conv_integer(Address));
    nextPc <= 1 + pc_Q;
    nextPcCopy <= 1 + pc_Q;
    
    -- mux branch 
    process(nextPcCopy, BranchSelect, BranchAddress)
    begin 
        if BranchSelect = '1' then 
            iesireBranchMux <= BranchAddress;
        else 
            iesireBranchMux <= nextPcCopy;
        end if;
    end process;

    -- mux jump  
    process(nextPcCopy, JumpSelect, JumpAddress)
    begin 
        if JumpSelect = '0' then 
            iesire <= iesireBranchMux;
        else 
            iesire <= JumpAddress;
        end if;
    end process;

end Behavioral;
