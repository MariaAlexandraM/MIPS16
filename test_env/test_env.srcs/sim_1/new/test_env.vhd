----------------------------------------------------------------------------------
-- University: UTCN
-- Student: Moldovan Maria
-- 
-- Date: April 2023
-- Module Name: test_env - Behavioral
-- Project Name: MIPS16
-- Target Devices: Basys3
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity test_env is
    Port ( -- in
           clk: in std_logic;
           btn: in std_logic_vector (4 downto 0); -- pt ca am bifat bus
           sw: in std_logic_vector (15 downto 0);
           -- out
           led: out std_logic_vector (15 downto 0);
           an: out std_logic_vector (3 downto 0); -- logica negativa!
           cat: out std_logic_vector (6 downto 0));  -- logica negativa!
end test_env;

architecture Behavioral of test_env is
-- Components --
component MPG is
    Port ( en: out std_logic;
           input: in std_logic;
           clock: in std_logic);
end component;

component SSD is
    Port ( clk: in std_logic;
           digits: in std_logic_vector(15 downto 0);
           an: out std_logic_vector(3 downto 0);
           cat: out std_logic_vector(6 downto 0));
end component;

component instructionFetch is
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
end component;

component instructionDecoder is
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
end component;

component mainControl is
     Port ( -- in 
           Instr: in std_logic_vector(15 downto 0);
           -- out
           RegDst: out std_logic;
           ExtOp: out std_logic;
           ALUSrc: out std_logic;
           Branch: out std_logic;
           Jump: out std_logic;
           ALUOp: out std_logic_vector(2 downto 0);
           MemWrite: out std_logic;
           MemToReg: out std_logic;
           RegWrite: out std_logic);
end component;

component executionUnit is
    Port ( -- in 
           rd1: in std_logic_vector(15 downto 0);
           rd2: in std_logic_vector(15 downto 0);
           ALUSrc: in std_logic;
           Ext_Imm: in std_logic_vector(15 downto 0);
           PCinc: in std_logic_vector(15 downto 0);
           sa: in std_logic;
           func: in std_logic_vector(2 downto 0);
           ALUOp: in std_logic_vector(1 downto 0);
           -- out
           Zero: out std_logic;
           ALURes: out std_logic_vector(15 downto 0);
           BranchAddress: out std_logic_vector(15 downto 0));
end component;

component MEM is
    port ( -- in
           clk: in std_logic;
           en: in std_logic;
           ALUResIn: in std_logic_vector(15 downto 0);
           rd2: in std_logic_vector(15 downto 0);
           MemWrite: in std_logic;			
           -- out
           MemData: out std_logic_vector(15 downto 0);
           ALUResOut: out std_logic_vector(15 downto 0));
end component;

-- Signals --

signal Instruction, PCinc, rd1, rd2, WD, Ext_imm: std_logic_vector(15 downto 0); 
signal JumpAddress, BranchAddress, ALUResIn, ALUResOut, MemData: std_logic_vector(15 downto 0);
signal func: std_logic_vector(2 downto 0);
signal sa, zero: std_logic;
signal digits: std_logic_vector(15 downto 0);
signal signalEN, signalRST, PCSrc: std_logic; 
-- mainControl signals
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite: std_logic;
signal ALUOp: std_logic_vector(2 downto 0);

begin
    -- buttons: enable si reset
    en_btn: MPG port map(en => signalEN, input => btn(0), clock => clk);
    rst_btn: MPG port map(en => signalRST, input => btn(1), clock => clk);
    
    -- branch control
    PCSrc <= Zero and Branch;

    -- jump address
    JumpAddress <= PCinc(15 downto 13) & Instruction(12 downto 0);

    -- MainControls
    inst_IF: instructionFetch port map ( clk => clk,
                                         rst => signalRST,
                                         en => signalEN,
                                         BranchAddress => BranchAddress,
                                         JumpAddress => JumpAddress,
                                         JumpSelect => Jump,
                                         BranchSelect => PCSrc,
                                         Instruction => Instruction,
                                         PCinc => PCinc);
    
    inst_ID: instructionDecoder port map ( clk => clk,
                                           en => signalEN,
                                           Instr => Instruction(12 downto 0),
                                           wd => WD,
                                           RegWrite => RegWrite,
                                           RegDst => RegDst,
                                           ExtOp => ExtOp,
                                           rd1 => RD1,
                                           rd2 => RD2,
                                           Ext_imm => Ext_imm,
                                           func => func,
                                           sa => sa);
    
    inst_MC: mainControl port map ( Instr => Instruction(15 downto 13),
                                    RegDst => RegDst,
                                    ExtOp => ExtOp,
                                    ALUSrc => ALUSrc,
                                    Branch => Branch,
                                    Jump => Jump,
                                    ALUOp => ALUOp,
                                    MemWrite => MemWrite,
                                    MemtoReg => MemtoReg,
                                    RegWrite => RegWrite);
    
    inst_EX: executionUnit port map ( PCinc => PCinc,
                                      rd1 => RD1,
                                      rd2 => RD2,
                                      Ext_imm => Ext_imm,
                                      func => func,
                                      sa => sa,
                                      ALUSrc => ALUSrc,
                                      ALUOp => ALUOp,
                                      BranchAddress => BranchAddress,
                                      ALURes => ALUResIn,
                                      Zero => Zero);
    
    inst_MEM: MEM port map ( clk => clk,
                             en => signalEN,
                             ALUResIn => ALUResIn,
                             RD2 => RD2,
                             MemWrite => MemWrite,
                             MemData => MemData,
                             ALUResOut => ALUResOut);

    -- MUX pt ssd
    process(sw(7 downto 5))
    begin
        case sw(7 downto 5) is
            when "000" => digits <= Instruction;
            when "001" => digits <= PCinc;
            when "010" => digits <= rd1;
            when "011" => digits <= rd2;
            when "100" => digits <= Ext_imm; 
            when "101" => digits <= ALUResIn; 
            when "110" => digits <= MemData; 
            when "111" => digits <= wd; 
            when others => digits <= x"0000";
        end case;
    end process;
    
    -- leds
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
    -- ssd display
    display: SSD port map (clk => clk, digits => digits, an => an, cat => cat);
    
end Behavioral;  
