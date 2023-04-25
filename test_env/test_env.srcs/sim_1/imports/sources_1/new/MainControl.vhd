
library IEEE;
use IEEE.std_logic_1164.ALL;

entity MainControl is
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
end MainControl;

architecture Behavioral of MainControl is
begin
    process(Instr)
    begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
        Branch <= '0'; Jump <= '0'; MemWrite <= '0';
        MemtoReg <= '0'; RegWrite <= '0';
        ALUOp <= "000";
        case (Instr) is 
            when "000" => -- R type
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "000";
            when "001" => -- ADDI
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "001";
            when "010" => -- LW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "001";
            when "011" => -- SW
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "001";
            when "100" => -- BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "010";
            when "101" => -- ANDI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "101";
            when "110" => -- ORI
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "110";
            when "111" => -- J
                Jump <= '1';
            when others => 
                RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0'; 
                Branch <= '0'; Jump <= '0'; MemWrite <= '0';
                MemtoReg <= '0'; RegWrite <= '0';
                ALUOp <= "000";
        end case;
    end process;		
    
end Behavioral;
