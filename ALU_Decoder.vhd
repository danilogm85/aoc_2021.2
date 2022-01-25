library ieee;
use ieee.std_logic_1164.all;

entity ALU_Decoder is
	port(
			Funct	: in std_logic_vector(5 downto 0);
			ALUOp	: in std_logic_vector(1 downto 0);
			
			ALU_JR	: out std_logic;
			ALU_NOR	: out std_logic;
			ALU_XOR	: out std_logic;
			ALUCtrl	: out std_logic_vector(2 downto 0)
		);
end ALU_Decoder;

architecture behavior of ALU_Decoder is
begin

	process(Funct,ALUOp) is
	begin
		case ALUOp is
			when "00" =>
				ALU_JR	<= '0';
				ALU_NOR	<= '0';
				ALU_XOR	<= '0';
				ALUCtrl	<=	"010"; --ADD
			
			when "01" =>
				ALU_JR	<= '0';
				ALU_NOR	<= '0';
				ALU_XOR	<= '0';
				ALUCtrl	<=	"110"; --SUBTRACT
			
			when "11" =>
				ALU_JR	<= '0';
				ALU_NOR	<= '0';
				ALU_XOR	<= '0';
				ALUCtrl	<=	"001"; --OR
				
			when "10" => 			 --VERIFICA CAMPO FUNCT
				case Funct is
					when "100000" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"010"; --ADD
						
					when "100010" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"110"; --SUBTRACT
						
					when "100100" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"000"; --AND
						
					when "100101" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"001"; --OR
						
					when "101010" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"111"; --SET LESS THAN
						
					when "100111" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '1';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"001"; --OR
						
					when "001000" =>
						ALU_JR	<= '1';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"011"; --ALU NOT USED
						
					when "100110" =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '1';
						ALUCtrl	<=	"011"; --ALU NOT USED
						
					when others =>
						ALU_JR	<= '0';
						ALU_NOR	<= '0';
						ALU_XOR	<= '0';
						ALUCtrl	<=	"011"; --ALU NOT USED
				end case;
			
			when others =>
				ALU_JR	<= '0';
				ALU_NOR	<= '0';
				ALU_XOR	<= '0';
				ALUCtrl	<=	"011"; --ALU NOT USED
		end case;
	end process;

end behavior;