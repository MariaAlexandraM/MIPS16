
library IEEE;
use IEEE.std_logic_1164.ALL;

entity MainControl is
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
end MainControl;

architecture Behavioral of MainControl is
begin
    process(Instr(15 downto 13))
    begin
    RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; Branch <= '0'; BrBNE <= '0';
    Jump <= '0'; ALUOp <= "000"; MemWrite <= '0'; MemToReg <= '0'; RegWr <= '0';
      case(Instr(15 downto 13)) is
         when "000" => RegDst <= '1'; RegWr <= '1'; -- R
         when "001" => ExtOp <= '1'; ALUSrc <= '1'; RegWr <= '1'; -- AADI
         when "010" =>  ExtOp <= '1'; ALUSrc <= '1'; RegWr <= '1'; MemToReg <= '1'; -- LW
         when "011" => ExtOp <= '1'; ALUSrc <= '1'; MemWrite <= '1'; -- SW
         when "100" => ExtOp <= '1'; Branch <= '1'; -- BEQ
         when "101" => ExtOp <= '1'; BrBNE <= '1'; -- BNE
         when "110" => ExtOp <= '1'; RegWr <= '1'; -- ANDI
         when "111" => Jump <= '1'; -- J
         when others => RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; Branch <= '0';
         Jump <= '0'; ALUOp <= "000"; MemWrite <= '0'; MemToReg <= '0'; RegWr <= '0';
       end case;
    end process;
    
end Behavioral;
