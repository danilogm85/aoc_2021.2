library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--VHDL top-level entity do processador. Esse código junta o datapath, control unit e memórias
--foi necessário adicionar uma porta de escrita para a memória de instruções por motivos explicados no cabeçalho do imem.vhdl

entity seita_processor is

	port	
	(
		reset					:in STD_LOGIC;		--Master reset do processador
		clk					:in STD_LOGIC;		--Master clock
		im_waddr				:in std_logic_vector(31 downto 0);	--Endereço de escrita da memória de instruções
		im_we					:in STD_LOGIC;				--Enable de escrite na memoria de instruções
		im_wd					:in std_logic_vector(31 downto 0)	--Dados para escrita da memoria de instruções
	
	);

end;

architecture rtl of seita_processor is

	component datapath is -- MIPS datapath

		port(		--PORTAS DO DATAPATH, INFORMAÇÕES MAIS DETALHADAS EM datapath.vhdl
			 clk:						in STD_LOGIC;
			 pc_reset: 				in STD_LOGIC;
			 rf_reset:				in STD_LOGIC;
			 pc_src: 				in STD_LOGIC_VECTOR(1 downto 0);
			 rf_we:					in STD_LOGIC;
			 wreg_data:				in STD_LOGIC_VECTOR(2 downto 0);
			 wreg_addr:				in STD_LOGIC_VECTOR(1 downto 0);
			 alu_src:				in STD_LOGIC;
			 alu_ctrl:				in STD_LOGIC_VECTOR(2 downto 0);
			 exttype:				in STD_LOGIC;
			 dm_readdata:			in STD_LOGIC_VECTOR(31 downto 0);
			 instr:					in STD_LOGIC_VECTOR(31 downto 0);
			 
			 zero:					out STD_LOGIC;
			 gtz:						out STD_LOGIC;
			 pc_out:					out STD_LOGIC_VECTOR(31 downto 0);
			 alu_out:				out STD_LOGIC_VECTOR(31 downto 0);
			 dm_writedata:			out STD_LOGIC_VECTOR(31 downto 0)
			 );

	end component;
	
	
	
	component ControlUnit is	
		port(	--PORTAS DA CONTROL UNIT, INFORMAÇÕES MAIS DETALHADAS EM ControlUnit.VHDL
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
	end component;
	
	
	
	component dmem is
	
	 port(		--PORTAS DA MEMÓRIA DE DADOS, INFORMAÇÕES MAIS DETALHADAS EM dmem.vhdl
			clk, we: in STD_LOGIC;
			a, wd: in STD_LOGIC_VECTOR (31 downto 0);
			rd: out STD_LOGIC_VECTOR (31 downto 0)
		 );
	
	end component;
	
	component imem is
	
	 port(		--PORTAS DA MEMÓRIA DE INSTRUÇÕES, INFORMAÇÕES MAIS DETALHADAS EM imem.vhdl
			clk, we: in STD_LOGIC;
			ra, wa, wd: in STD_LOGIC_VECTOR (31 downto 0);
			rd: out STD_LOGIC_VECTOR (31 downto 0)
		 );
	
	end component;

		--SINAIS DE INTERCONEXÃO ENTRE OS BLOCOS, CONFORME OS DIAGRAMAS
	signal pc_out			:std_logic_vector(31 downto 0);
	signal instr			:std_logic_vector(31 downto 0);
	signal alu_out			:std_logic_vector(31 downto 0);
	signal dm_writedata	:std_logic_vector(31 downto 0);
	signal dm_readdata	:std_logic_vector(31 downto 0);
	signal dm_we			:STD_LOGIC;

	signal pc_rst			:std_logic;
	signal rf_rst			:std_logic;
	signal rf_we			:std_logic;
	signal zero				:std_logic;
	signal gtz				:std_logic;	
	signal alu_src			:std_logic;	
	signal exttype			:std_logic;
	signal opcode			:std_logic_vector(5 downto 0);
	signal funct			:std_logic_vector(5 downto 0);
	signal wreg_data		:std_logic_vector(2 downto 0);
	signal wreg_addr		:std_logic_vector(1 downto 0);
	signal alu_ctrl		:std_logic_vector(2 downto 0);
	signal pc_src			:std_logic_vector(1 downto 0);

begin
	--CONEXÃO ENTRE OS BLOCOS, CONFORME OS DIAGRAMAS
	opcode 	<= instr(31 downto 26);
	funct 	<= instr(5 downto 0);
	
	datapath_pm: 		datapath port map(clk,pc_rst,rf_rst,pc_src,rf_we,wreg_data,wreg_addr,alu_src,alu_ctrl,exttype,dm_readdata,instr,zero,gtz,pc_out,alu_out,dm_writedata);
	control_unit_pm: 	ControlUnit port map(reset,zero,gtz,opcode,funct,pc_rst,rf_rst,rf_we,alu_src,dm_we,exttype,pc_src,wreg_addr,wreg_data,alu_ctrl);
	dm_pm: 				dmem port map(clk,dm_we,alu_out,dm_writedata,dm_readdata);
	im_pm: 				imem port map(clk,im_we,pc_out,im_waddr,im_wd,instr);
	
	
end;
