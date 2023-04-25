----------------------------------------------------------------------------------
-- University: UTCN
-- Student: Moldovan Maria
-- 
-- Date: April 2023
-- Module Name: instructionFetch - Behavioral
-- Project Name: MIPS16
-- Target Devices: Basys3
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity instructionFetch is
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
end instructionFetch;

architecture Behavioral of instructionFetch is
-- Signals --
type type_rom is array (0 to 31) of std_logic_vector(15 downto 0);
signal rom_mem: type_rom := ( -- Fibonacci.
                              -- calculeaza siru lu fibonacci incarcand initial 0 si 1 in reg.
                              -- scrie in mem la 2 adrese dif apoi citeste de acolo pt a verifica corectitudinea
                             B"001_000_001_0000000",     -- X"2080" -- ADDI $1, $0, 0
                             B"001_000_010_0000001",     -- X"2101" -- ADDI $2, $0, 1	
                             B"001_000_011_0000000",     -- X"2180" -- ADDI $3, $0, 0	
                             B"001_000_100_0000001",     -- X"2201" -- ADDI $4, $0, 1
                             B"011_011_001_0000000",     -- X"6C80" -- SW $1, 0($3)
                             B"011_100_010_0000000",     -- X"7100" -- SW $2, 0($4)
                             B"010_011_001_0000000",     -- X"4C80" -- LW $1, 0($3)
                             B"010_100_010_0000000",     -- X"5100" -- LW $2, 0($4)
                             B"000_001_010_101_0_000",   -- X"0550" -- ADD $5, $1, $2
                             B"000_000_010_001_0_000",   -- X"0110" -- ADD $1, $0, $2
                             B"000_000_101_010_0_000",   -- X"02A0" -- ADD $2, $0, $5
                             B"111_0000000001000",       -- X"E008" -- J 8
                             others => X"0000"); 		 -- NoOp (ADD $0, $0, $0)

signal pc_Q, iesire, pcAux, iesireBranchMux: std_logic_vector(15 downto 0) := (others => '0');
signal Address: std_logic_vector(7 downto 0);

begin 
    -- registru de PC
    process(clk)
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
    
    Address <= pc_Q(7 downto 0);
    Instruction <= rom_mem(conv_integer(Address));
    
    PCAux <= pc_Q + 1;
    PCinc <= PCAux;
    
    -- mux branch 
    process(PCAux, BranchSelect, BranchAddress)
    begin 
        if BranchSelect = '1' then 
            iesireBranchMux <= BranchAddress;
        else 
            iesireBranchMux <= PCAux;
        end if;
    end process;

    -- mux jump  
    process(PCAux, JumpSelect, JumpAddress)
    begin 
        if JumpSelect = '0' then 
            iesire <= iesireBranchMux;
        else 
            iesire <= JumpAddress;
        end if;
    end process;

end Behavioral;

-- PROGRAM DE TEST
-- Acest program testeaza toate instructiunile implementate,
-- folosind scrierea si citirea din memorie pentru verificare
-- si, de asemenea, instructiunile de salt BEQ si J.
--    B"000_001_000_010_0_000",   -- X"0420" -- ADD $2, $1, $0 
--    B"000_011_010_010_0_001",   -- X"0d21" -- SUB $2, $3, $2
--    B"000_000_010_010_1_010",   -- X"012A" -- SLL $2, $2, 1
--    B"000_000_010_010_1_011",   -- X"012b" -- SRL $2, $2, 1
--    B"000_011_010_100_0_100",   -- X"0d44" -- AND $4, $3, $2
--    B"000_101_100_100_0_101",   -- X"1645" -- OR $4, $5, $4
--    B"000_100_100_100_0_110",   -- X"1246" -- XOR $4, $4, $4
--    B"000_010_011_100_0_111",   -- X"09C7" -- SLT $4, $2, $3
--    B"001_000_100_0000100",     -- X"2204" -- ADDI $4, $0, 4
--    B"010_001_101_0000000",     -- X"4680" -- LW $5, 0($1)
--    B"011_100_101_0000000",     -- X"7280" -- SW $5, 0($4)
--    B"100_001_001_0000001",     -- X"8481" -- BEQ $1, $1, 1
--    B"101_100_101_0000100",     -- X"b284" -- ANDI $5, $4, 4
--    B"110_101_110_0000011",     -- X"d703" -- ORI $6, $5, 3
--    B"111_0000000000011",       -- X"E003" -- J 3

