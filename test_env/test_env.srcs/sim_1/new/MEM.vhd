library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    port ( -- in
           clk: in std_logic;
           en: in std_logic;
           ALUResIn: in std_logic_vector(15 downto 0);
           RD2: in std_logic_vector(15 downto 0);
           MemWrite: in std_logic;			
           -- out
           MemData: out std_logic_vector(15 downto 0);
           ALUResOut: out std_logic_vector(15 downto 0));
end MEM;

architecture Behavioral of MEM is
-- Signals --
type mem_type is array (0 to 31) of std_logic_vector(15 downto 0);
signal mem: mem_type:= (X"000A", X"000B", X"000C", X"000D", X"000E", X"000F", X"0009", X"0008", others => X"0000");

begin
    -- Data Memory
    process(clk) 			
    begin
        if clk'event and clk = '1' then
            if en = '1' and MemWrite = '1' then
                mem(conv_integer(ALUResIn(4 downto 0))) <= RD2;			
            end if;
        end if;
    end process;

    -- outputs
    MemData <= mem(conv_integer(ALUResIn(4 downto 0)));
    ALUResOut <= ALUResIn;

end Behavioral;