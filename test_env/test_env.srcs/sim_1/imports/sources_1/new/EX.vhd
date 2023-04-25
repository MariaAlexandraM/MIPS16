library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity EX is
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
end EX;

architecture Behavioral of EX is
signal ALUCtrl: std_logic_vector(2 downto 0);
signal A, B: std_logic_vector(15 downto 0);
begin
    process(ALUOp, func)
             begin
                case ALUOp is
                when "00" =>
                   case func is
                     when "000" => ALUCtrl <= "000"; --add
                     when "001" => ALUCtrl <= "001"; --sub
                     when "010" => ALUCtrl <= "010"; --sll
                     when "011" => ALUCtrl <= "011"; --srl
                     when "100" => ALUCtrl <= "100"; --and
                     when "101" => ALUCtrl <= "101"; --or
                     when "110" => ALUCtrl <= "110"; --xor
                     when "111" => ALUCtrl <= "010"; --sllv
                     when others => ALUCtrl <= (others => 'X');
                   end case;
                when "01" => ALUCtrl <= "000"; --add
                when "10" => ALUCtrl <= "001"; --sub
                when "11" => ALUCtrl <= "100"; --and
                when others => ALUCtrl <= (others => 'X'); 
                end case;  
             end process;
            
            A <= RD1;
            B <= RD2 when ALUSrc = '0' else Ext_Imm;

    process(RD1, RD2, ALUCtrl, sa)
    begin
        case ALUCtrl is 
             when "000" => ALURes <= RD1 + RD2;
             when "001" => ALURes <= RD1 - RD2;
             when "010" => ALURes <= RD1(14 downto 0) & '0';
             when "011" => ALURes <= '0' & RD1(15 downto 1);
             when "100" => ALURes <= RD1 and RD2;
             when "101" => ALURes <= RD1 or RD2;
             when "110" => ALURes <= RD1 xor RD2;
             when others => ALURes <= (others => 'X');
        end case;
    end process;
    Zero <= '1' when RD1 = RD2 else '0';
    BranchAddress <= Ext_Imm + nextPC;

end Behavioral;
