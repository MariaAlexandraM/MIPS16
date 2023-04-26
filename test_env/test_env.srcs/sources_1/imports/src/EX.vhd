----------------------------------------------------------------------------------
-- University: UTCN
-- Student: Moldovan Maria
-- 
-- Date: April 2023
-- Module Name: executionUnit - Behavioral
-- Project Name: MIPS16
-- Target Devices: Basys3
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity executionUnit is
    Port ( -- in 
           RD1: in std_logic_vector(15 downto 0);
           RD2: in std_logic_vector(15 downto 0);
           ALUSrc: in std_logic;
           Ext_Imm: in std_logic_vector(15 downto 0);
           PCinc: in std_logic_vector(15 downto 0);
           sa: in std_logic;
           func: in std_logic_vector(2 downto 0);
           ALUOp: in std_logic_vector(2 downto 0);
           -- out
           Zero: out std_logic;
           ALURes: out std_logic_vector(15 downto 0);
           BranchAddress: out std_logic_vector(15 downto 0));
end executionUnit;

architecture Behavioral of executionUnit is
-- Signals --
signal ALUCtrl: std_logic_vector(2 downto 0);
signal ALUIn1, ALUIn2: std_logic_vector(15 downto 0);
signal ALUResAux: std_logic_vector(15 downto 0);

begin
  -- MUX for ALU input 2
    with ALUSrc select
        ALUIn2 <= RD2 when '0', 
	              Ext_Imm when '1',
	              (others => '0') when others;
			  
    -- ALU Control
    process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- R type 
                case func is
                    when "000" => ALUCtrl <= "000"; -- add
                    when "001" => ALUCtrl <= "001"; -- sub
                    when "010" => ALUCtrl <= "010"; -- sll
                    when "011" => ALUCtrl <= "011"; -- srl
                    when "100" => ALUCtrl <= "100"; -- and
                    when "101" => ALUCtrl <= "101"; -- or
                    when "110" => ALUCtrl <= "110"; -- xor
                    when "111" => ALUCtrl <= "111"; -- slt
                    when others => ALUCtrl <= (others => '0'); -- unknown
                end case;
            when "001" => ALUCtrl <= "000"; -- +
            when "010" => ALUCtrl <= "001"; -- -
            when "101" => ALUCtrl <= "100"; -- &
            when "110" => ALUCtrl <= "101"; -- |
            when others => ALUCtrl <= (others => '0'); -- unknown
        end case;
    end process;

    -- ALU
    process(ALUCtrl, RD1, AluIn2, sa, ALUResAux)
    begin
        case ALUCtrl  is
            when "000" => -- add
                ALUResAux <= RD1 + ALUIn2;
            when "001" =>  -- sub
                ALUResAux <= RD1 - ALUIn2;                                    
            when "010" => -- sll
                case sa is
                    when '1' => ALUResAux <= ALUIn2(14 downto 0) & "0";
                    when '0' => ALUResAux <= ALUIn2;
                    when others => ALUResAux <= (others => '0');
                 end case;
            when "011" => -- srl
                case sa is
                    when '1' => ALUResAux <= "0" & ALUIn2(15 downto 1);
                    when '0' => ALUResAux <= ALUIn2;
                    when others => ALUResAux <= (others => '0');
                end case;
            when "100" => -- and
                ALUResAux <= RD1 and ALUIn2;		
            when "101" => -- or
                ALUResAux <= RD1 or ALUIn2; 
            when "110" => -- xor
                ALUResAux <= RD1 xor ALUIn2;		
            when "111" => -- slt
                if (signed(RD1) < signed(ALUIn2)) then
                    ALUResAux <= x"0001";
                else 
                    ALUResAux <= x"0000";
                end if;
            when others => -- unknown
                ALUResAux <= (others => '0');              
        end case;

        -- zero detector
        case ALUResAux is
            when X"0000" => Zero <= '1';
            when others => Zero <= '0';
        end case;
    
    end process;

    -- ALU result
    ALURes <= ALUResAux;

    -- generate branch address
    BranchAddress <= PCinc + Ext_Imm;

end Behavioral;
