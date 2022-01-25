library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--DATAPATH conforme o diagrama de microarquitetura
--	obs: as memorias de instruções e dados estão presentes no diagrama do datapath mas foram colocadas externas ao datapath no VHDL

entity datapath is -- MIPS datapath

	port(		--portas de conexão com as memórias e com a control unit
		 clk:						in STD_LOGIC;
		 pc_reset: 				in STD_LOGIC;
		 rf_reset:				in STD_LOGIC;
		 pc_src: 				in STD_LOGIC_VECTOR(1 downto 0);
		 rf_we:					in STD_LOGIC;
		 wreg_data:				in STD_LOGIC_VECTOR(2 downto 0);
		 wreg_addr:				in STD_LOGIC_VECTOR(1 downto 0);
		 alu_src:				in STD_LOGIC;
		 alu_ctrl:				in STD_LOGIC_VECTOR(2 downto 0);
--		 dm_we:					in STD_LOGIC;    -- ISSO VAI FICAR NO CONTROLADOR
		 exttype:				in STD_LOGIC;
		 dm_readdata:			in STD_LOGIC_VECTOR(31 downto 0);
		 instr:					in STD_LOGIC_VECTOR(31 downto 0);
		 
		 zero:					out STD_LOGIC;
		 gtz:						out STD_LOGIC;
		 pc_out:					out STD_LOGIC_VECTOR(31 downto 0);
		 alu_out:				out STD_LOGIC_VECTOR(31 downto 0);
		 dm_writedata:			out STD_LOGIC_VECTOR(31 downto 0)
		 );


end;

architecture rtl of datapath is

	---------------------------------COMPONENTS------------------------------
--SAO 14 COMPONENTES DIFERENTES

  component register_file is
    port 
    (
      a1	                  : in std_logic_vector	(4 downto 0);
		a2	                  : in std_logic_vector	(4 downto 0);
		a3	                  : in std_logic_vector	(4 downto 0);
		wd3	               : in std_logic_vector	(31 downto 0);
      reset	    				: in std_logic;
		clk	    				: in std_logic;
		we3	    				: in std_logic;
		
      rd1              		: out std_logic_vector (31 downto 0);
      rd2              		: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component alu is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(2 downto 0);
		
      r              		: out std_logic_vector (31 downto 0);
      zero              	: out std_logic
    );
	end component;
	
  component program_counter is
    port 
    (
      pl	                  : in std_logic_vector	(31 downto 0);
      reset	    				: in std_logic;
		clk	    				: in std_logic;
		
		pc							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component mux_6x1 is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		c	                  : in std_logic_vector	(31 downto 0);
		d	                  : in std_logic_vector	(31 downto 0);
      e	                  : in std_logic_vector	(31 downto 0);
		f	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(2 downto 0);	
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component mux_4x1 is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		c	                  : in std_logic_vector	(31 downto 0);
		d	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(1 downto 0);	
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component mux_3x1 is
    port 
    (
      a	                  : in std_logic_vector	(4 downto 0);
		b	                  : in std_logic_vector	(4 downto 0);
		c	                  : in std_logic_vector	(4 downto 0);
		sel	               : in std_logic_vector	(1 downto 0);	
		
		o							: out std_logic_vector (4 downto 0)
    );
	end component;
	
  component mux_2x1 is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic;	
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component somador is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		
		s							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component xor_32bit is
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		
		x							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component sign_extend is
    port 
    (
      i	                  : in std_logic_vector	(15 downto 0);
		sel_type             : in std_logic;
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
	
  component shift_two_32bit is
    port 
    (
      i	                  : in std_logic_vector	(31 downto 0);
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
  component shift_four_16bit is
    port 
    (
      i	                  : in std_logic_vector	(15 downto 0);
		
		o							: out std_logic_vector (31 downto 0)
    );
	end component;
	
--  component not_32bit is
--    port 
--    (
--      i	                  : in std_logic_vector	(31 downto 0);
--		
--		o							: out std_logic_vector (31 downto 0);
--    );
--	end component;
	
	---------------------------------COMPONENTS------------------------------
	
	
	----------------------------------SIGNALS--------------------------------
	--15 SINAIS
	--sinais de interconxeão dos componentes conforme o diagrama
	signal pc_plus4			:STD_LOGIC_VECTOR(31 downto 0);		--1
	signal pc_branch			:STD_LOGIC_VECTOR(31 downto 0);		--2
	signal pc_jump				:STD_LOGIC_VECTOR(31 downto 0);		--3
	signal pc_jr				:STD_LOGIC_VECTOR(31 downto 0);		--4
	signal pl_pc				:STD_LOGIC_VECTOR(31 downto 0);		--5
	signal ext_imm				:STD_LOGIC_VECTOR(31 downto 0);		--6
	signal write_reg_addr	:STD_LOGIC_VECTOR(4 downto 0);		--7
	signal write_reg_data	:STD_LOGIC_VECTOR(31 downto 0);		--8
	signal ext_imm_sh2		:STD_LOGIC_VECTOR(31 downto 0);		--9
	signal imm_sh4				:STD_LOGIC_VECTOR(31 downto 0);		--10
	signal read_reg1			:STD_LOGIC_VECTOR(31 downto 0);		--11
	signal read_reg2			:STD_LOGIC_VECTOR(31 downto 0);		--12
	signal alu_in_b			:STD_LOGIC_VECTOR(31 downto 0);		--13
	signal xor_out				:STD_LOGIC_VECTOR(31 downto 0);		--14
	signal nor_out				:STD_LOGIC_VECTOR(31 downto 0);		--15
	signal alu_result			:STD_LOGIC_VECTOR(31 downto 0);
	signal pc					:STD_LOGIC_VECTOR(31 downto 0);
	
	----------------------------------SIGNALS--------------------------------	
	
	begin
	
	pc_jump <= pc_plus4(31 downto 28) & instr(25 downto 0) & "00";--produz o sinal PC jump deslocando o imediato 2 vezes e utilizando os 4 bits mais significativos do PC+4
	gtz <= not(read_reg1(31));	--Se o sinal do registrador é positivo, GTZ é ativado, indicando que o numero é maior que zero
	nor_out <= not(alu_result);	--NOR = NOT(OR)
	alu_out <= alu_result;		--envia o resultado da alu para o alu_out que será conectado à memoria de dados
	pc_out <= pc;			--para conectar o PC à memória de instruções
--	xor_out <= read_reg1 XOR read_reg2;
	dm_writedata <= read_reg2;	--para conectar a memória de dados à saida da porta 2 do banco de registros
	pc_jr <= read_reg1;		--para instrução jr, o mux do PC deve receber a leitura do registrador selecionado
	
		--realiza todas as conexoes de acordo com o diagrama
	register_file_pm: register_file port map(instr(25 downto 21),instr(20 downto 16),write_reg_addr,write_reg_data,rf_reset,clk,rf_we,read_reg1,read_reg2);
	alu_pm: alu port map(read_reg1,alu_in_b,alu_ctrl,alu_result,zero);
	pc_pm: program_counter port map(pl_pc,pc_reset,clk,pc);
	mux_6x1_pm: mux_6x1 port map(alu_result,dm_readdata,xor_out,nor_out,pc_plus4,imm_sh4,wreg_data,write_reg_data);
	mux_4x1_pm: mux_4x1 port map(pc_plus4,pc_branch,pc_jump,pc_jr,pc_src,pl_pc);
	mux_3x1_pm: mux_3x1 port map(instr(20 downto 16),instr(15 downto 11),"11111",wreg_addr,write_reg_addr);	
	mux_2x1_pm: mux_2x1 port map(read_reg2,ext_imm,alu_src,alu_in_b);
	somador1_pm: somador port map(pc,x"00000004",pc_plus4);
	somador2_pm: somador port map(ext_imm_sh2,imm_sh4,pc_branch);
	xor_32bit_pm: xor_32bit port map(read_reg1,read_reg2,xor_out);
	sign_extend_pm: sign_extend port map(instr(15 downto 0),exttype,ext_imm);
	shift_two_32bit_pm: shift_two_32bit port map(ext_imm,ext_imm_sh2);
	shift_four_16bit_pm: shift_four_16bit port map(instr(15 downto 0),imm_sh4);
--	not_32bit_pm: not_32bit port map(alu_out,nor_out);
	
end;


------------------------------------------------------
-- register_file
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
--use IEEE.NUMERIC_STD.all;
use IEEE.NUMERIC_STD.all;

entity register_file is		--banco de 32 registradores de 32 bits com 2 portas de leitura e uma de escrita
    port 
    (
      a1	                  : in std_logic_vector	(4 downto 0);
		a2	                  : in std_logic_vector	(4 downto 0);
		a3	                  : in std_logic_vector	(4 downto 0);
		wd3	               : in std_logic_vector	(31 downto 0);
      reset	    				: in std_logic;
		clk	    				: in std_logic;
		we3	    				: in std_logic;
		
      rd1              		: out std_logic_vector (31 downto 0);
      rd2              		: out std_logic_vector (31 downto 0)
    );
end entity;
	
	
architecture rtl of register_file is

	type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	signal mem: ramtype;
	
	begin
 -- three-ported register file
 -- read two ports combinationally
 -- write third port on rising edge of clk
 -- register 0 hardwired to 0
 -- note: for pipelined processor, write third port
  --on falling edge of clk
	process(clk,we3,a3,reset) 
	begin
		if (reset = '1') then
         for i in 0 to 31 loop
             mem(i) <= x"00000000";
          end loop;
		elsif (rising_edge(clk) AND (we3='1')) then
			mem(to_integer(unsigned(a3))) <= wd3;
      end if;
	end process;
	
	process(a1,a2,mem) 
	begin
	
		if (to_integer(unsigned(a1)) = 0) then rd1 <= x"00000000";
				-- register 0 holds 0
		else rd1 <= mem(to_integer(unsigned(a1)));
		end if;
		
		if (to_integer(unsigned(a2)) = 0) then rd2 <= x"00000000";
		else rd2 <= mem(to_integer(unsigned(a2)));
		end if;
		
	end process;
	
end rtl;

	
------------------------------------------------------
-- alu
------------------------------------------------------	
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity alu is	--ALU com suporte para 7 operações, com 3 bits para seleção da operação
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(2 downto 0);
		
      r              		: out std_logic_vector (31 downto 0);
      zero              	: out std_logic
    );
end entity;
	
architecture rtl of alu is
	
	begin
	
	process(a,b,sel)
	begin
		zero <= '0';
		case sel is	--operações de acordo com a tabela verdade do livro do casal Harris
			when "000" =>	r <= a AND	--AND
			b;
			when "001" =>	r <= a OR b;	--OR
			when "010" =>	r <= std_logic_vector(signed(a)+ signed(b));	--ADD
			when "011" =>	r <= x"00000000";	--not used
			when "100" =>	r <= a AND not(b);		--AB'
			when "101" =>	r <= a OR not(b);		--A+B'
			when "110" =>		--SUB
				r <= std_logic_vector(signed(a)- signed(b));
				if(a = b) then 		--Verifica se é zero
					zero <= '1';
				else
					zero <= '0';
				end if;
			when "111" =>	--SLT
				if(a < b) then 
					r <= x"FFFFFFFF";
				else
					r <= x"00000000";
				end if;
			when others => r <= x"00000000";
			
		end case;
		
	end process;

end rtl;
	
------------------------------------------------------
-- program_counter
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity program_counter is	--REGISTRADOR SÍNCRONO COM RESET ASSINCRONO PARA O ENDEREÇO x00400000, que é o local de inicio do programa no mapa de memória MIPS
    port 
    (
      pl	                  : in std_logic_vector	(31 downto 0);
      reset	    				: in std_logic;
		clk	    				: in std_logic;
		
		pc							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of program_counter is

	begin
	process(clk, reset, pl) 
	begin
		if (reset = '1') then
			pc <= x"00400000";
		elsif (rising_edge(clk)) then pc <= pl;
		end if;
	end process;

end rtl;
	
------------------------------------------------------
-- mux_6x1
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
entity mux_6x1 is	--MUX que escolhe a origem dos dados de escrita de registradores
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		c	                  : in std_logic_vector	(31 downto 0);
		d	                  : in std_logic_vector	(31 downto 0);
      e	                  : in std_logic_vector	(31 downto 0);
		f	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(2 downto 0);	
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of mux_6x1 is

	begin
	
	process(sel,a,b,c,d,e,f)
	begin
		case sel is	--seleção de acordo com o diagrama
			when "000" =>	o <= a;
			when "001" =>	o <= b;
			when "010" =>	o <= c;
			when "011" =>	o <= d;
			when "100" =>	o <= e;
			when "101" =>	o <= f;
			when others => o <= x"00000000";
		end case;
	end process;

end rtl;

	 
------------------------------------------------------
-- mux_4x1
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	 
entity mux_4x1 is		--MUX que seleciona a origem do endereço a ser armazenado no PC
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		c	                  : in std_logic_vector	(31 downto 0);
		d	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic_vector	(1 downto 0);	
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of mux_4x1 is

	begin
	
	process(sel,a,b,c,d)
	begin
		case sel is	--seleção de acordo com o diagrama
			when "00" =>	o <= a;
			when "01" =>	o <= b;
			when "10" =>	o <= c;
			when "11" =>	o <= d;
			when others => o <= x"00000000";
		end case;
	end process;

end rtl;
	

------------------------------------------------------
-- mux_3x1
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;	
	
	
entity mux_3x1 is	--Seleciona a origem do endereço do registrador de escrita
    port 
    (
      a	                  : in std_logic_vector	(4 downto 0);
		b	                  : in std_logic_vector	(4 downto 0);
		c	                  : in std_logic_vector	(4 downto 0);
		sel	               : in std_logic_vector	(1 downto 0);	
		
		o							: out std_logic_vector (4 downto 0)
    );
end entity;
	
architecture rtl of mux_3x1 is

	begin
	
	process(sel,a,b,c)
	begin
		case sel is	--Seleção de acordo com o diagrama
			when "00" 	=>	o <= a;
			when "01" 	=>	o <= b;
			when "10" 	=>	o <= c;
			when others => o <= "00000";
		end case;
	end process;

end rtl;
	
	
------------------------------------------------------
-- mux_2x1
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity mux_2x1 is		--Mux que seleciona a origem do segundo operando da ALU
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		sel	               : in std_logic;	
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of mux_2x1 is

	begin
	
	process(sel,a,b)
	begin
		case sel is	
			when '0' =>	o <= a;		--Porta RD2 do reg file
			when '1' =>	o <= b;		--Imediato extendido
			when others => o <= x"00000000";
		end case;
	end process;

end rtl;

	
------------------------------------------------------
-- somador
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity somador is	--somador 32 bits
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		
		s							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of somador is

	begin
	
	process(a,b)
	begin
		s <= std_logic_vector(signed(a) + signed(b));
	end process;

end rtl;
	

------------------------------------------------------
-- sign_extend
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity sign_extend is	--Extensor de imediato com seleção do tipo de extensão (de sinal ou de zero)
    port 
    (
      i	                  : in std_logic_vector	(15 downto 0);
		sel_type             : in std_logic;
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of sign_extend is

	begin
	
	process(i, sel_type)
	begin
		if(sel_type='1') then		--SEL=1 gera a extensão de zero
			o <= x"0000" & i(15 downto 0);
		else
			if(i(15) = '0') then	--SEL=0 gera a extensão do sinal do imediato
				o <= x"0000" & i(15 downto 0);
			else
				o <= x"FFFF" & i(15 downto 0);
			end if;
		end if;
	end process;

end rtl;


------------------------------------------------------
-- shift_two_32bit
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity shift_two_32bit is	--deslocador de dois para a esquerda
    port 
    (
      i	                  : in std_logic_vector	(31 downto 0);
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of shift_two_32bit is

	begin
	
	process(i)
	begin
		o <= i(29 downto 0) & "00";
	end process;

end rtl;

	
------------------------------------------------------
-- shift_four_16bit
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity shift_four_16bit is    --deslocador de quatro(hexa) para a esquerda
    port 
    (
      i	                  : in std_logic_vector	(15 downto 0);
		
		o							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of shift_four_16bit is

	begin
	
	process(i)
	begin
		o <= i(15 downto 0) & x"0000";
	end process;

end rtl;
	
	
------------------------------------------------------
-- xor_32bit
------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
	
	
entity xor_32bit is	--realiza XOR entre 2 vetores de 32 bits
    port 
    (
      a	                  : in std_logic_vector	(31 downto 0);
		b	                  : in std_logic_vector	(31 downto 0);
		
		x							: out std_logic_vector (31 downto 0)
    );
end entity;
	
architecture rtl of xor_32bit is

	begin
	
	process(a,b)
	begin
		x <= a XOR b;
	end process;

end rtl;
