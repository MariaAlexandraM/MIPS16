----------------------------------------------------------------------------------
-- University: UTCN
-- Student: Moldovan Maria
-- 
-- Date: April 2023
-- Module Name: MPG - Behavioral
-- Project Name: MIPS16
-- Target Devices: Basys3
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity MPG is
    Port ( -- in
           input: in std_logic;
           clock: in std_logic;
           -- out
           en: out std_logic);
end MPG;

architecture Behavioral of MPG is
-- Signals --
signal count_int: std_logic_vector(17 downto 0) := (others => '0');
signal Q1: std_logic := '0';
signal Q2: std_logic := '0';
signal Q3: std_logic := '0';

begin

    en <= Q2 AND (not Q3);

    process (clock)
    begin
        if clock = '1' and clock'event then
            count_int <= count_int + 1;
        end if;
    end process;

    process (clock)
    begin
        if clock'event and clock = '1' then
            if count_int(17 downto 0) = "111111111111111111" then
                Q1 <= input;
            end if;
        end if;
    end process;

    process (clock)
    begin
        if clock'event and clock = '1' then
            Q2 <= Q1;
            Q3 <= Q2;
        end if;
    end process;

end Behavioral;