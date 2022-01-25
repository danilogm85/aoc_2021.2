library ieee;
use ieee.std_logic_1164.all;

--Este código apenas junta o alu decoder, main decoder e as entradas e saidas externas. Informações detalhadas são encontradas nos códigos do main decoder e alu decoder

entity ControlUnit is
	port(
			RESET			: in std_logic;
			ZERO			: in std_logic;
			GTZ			: in std_logic;
			Op 			: in std_logic_vector(5 downto 0);
			Funct			: in std_logic_vector(5 downto 0);
			
			PC_RST		: out std_logic;
			RF_RST		: out std_logic;
			RF_WE			: out std_logic;
			AluSrc		: out std_logic;
			DM_WE			: out std_logic;
			ExtType		: out std_logic;
			PCSrc			: out std_logic_vector(1 downto 0);
			WRegAddrSrc	: out std_logic_vector(1 downto 0);
			WRegDataSrc	: out std_logic_vector(2 downto 0);
			AluCtrl		: out std_logic_vector(2 downto 0)
		);
end ControlUnit;

architecture behavior of ControlUnit is

	signal ALU_JR, ALU_NOR, ALU_XOR	: std_logic;
	signal ALUOp							: std_logic_vector(1 downto 0);
	
	component ALU_Decoder is
		port(
			Funct	: in std_logic_vector(5 downto 0);
			ALUOp	: in std_logic_vector(1 downto 0);
			
			ALU_JR	: out std_logic;
			ALU_NOR	: out std_logic;
			ALU_XOR	: out std_logic;
			ALUCtrl	: out std_logic_vector(2 downto 0)
		);
	end component;
	
	component main_decoder is
		port(
			RESET:			in std_logic;
			opcode:			in std_logic_vector(5 downto 0);
			zero:				in std_logic;
			gtz:				in std_logic;
			jr:				in std_logic;
			xor_in:			in std_logic;
			nor_in:			in std_logic;
		
			pcrst:			out std_logic;
			rf_rst:			out std_logic;
			rf_we:			out std_logic;
			alusrc:			out std_logic;
			dm_we:			out std_logic;
			exttype:			out std_logic;
			pcsrc:			out std_logic_vector(1 downto 0);
			wregdatasrc:	out std_logic_vector(2 downto 0);
			wregaddsrc:		out std_logic_vector(1 downto 0);
			aluop:			out std_logic_vector(1 downto 0)
		);
	end component;
	
	begin
	
	u1 : ALU_Decoder	port map(Funct, ALUOp, ALU_JR, ALU_NOR, ALU_XOR, ALUCtrl);
	u2 : main_decoder	port map(RESET, Op, ZERO, GTZ, ALU_JR, ALU_XOR, ALU_NOR, PC_RST, RF_RST, RF_WE, AluSrc, 
										DM_WE, ExtType, PCSrc, WRegDataSrc, WRegAddrSrc, ALUOp);

end behavior;
