library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--Teste do processador

entity tb_seita_processor is
end;

architecture teste of tb_seita_processor is


	component seita_processor is

		port
		(
			reset					:in STD_LOGIC;
			clk					:in STD_LOGIC;
			im_waddr				:in std_logic_vector(31 downto 0);
			im_we					:in STD_LOGIC;
			im_wd					:in std_logic_vector(31 downto 0)

		);

	end component;


	constant clk_period : time := 10ns;
	
	signal reset					:STD_LOGIC := '1';	--Inicia em 1 para inicializar o estado arquitetural
	signal clk						:STD_LOGIC := '0';
	signal im_waddr				:std_logic_vector(31 downto 0) := x"00000000";	
	signal im_we					:STD_LOGIC := '1';	--Inicia em 1 para escrever na instruction memory
	signal im_wd					:std_logic_vector(31 downto 0) := x"00000000";

begin
	
	seita_processor_pm: seita_processor port map(reset,clk,im_waddr,im_we,im_wd);	
	
	process
	
	 file mem_file: text open read_mode is "trabalho2-j.txt";	--Inicializa arquivo que contem o código de máquina e as variaveis para iterar sobre ele
	 variable L: line;	
	 variable ch: character;
	 variable i, index, result: integer;
	 variable data_tmp: std_logic_vector(31 downto 0);	--Variavel auxiliar para definir os dados de escrita da IM
	
	begin
	
		for i in 0 to 63 loop -- set all contents low
			im_waddr <= std_logic_vector(to_unsigned(i,32));
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
		end loop;
		index := 0; 
		 --FILE_OPEN (mem_file, "C:\Users\Primetals\Documents\Quartus Projetos\Trabalho AOC\seita_processor\file.dat",READ_MODE);
		 
		while not endfile(mem_file) loop	--Loop enquanto o arquivo nao acabar
			 readline(mem_file, L);
			 result := 0;
			 for i in 1 to 8 loop		--Loop para ler os 8 caracteres HEXA da instrução
				 read (L, ch);		--Le o caractere no indice i
				 if '0' <= ch and ch <= '9' then	--Verificando máscara do código da instrução
					result := character'pos(ch) - character'pos('0');
				 elsif 'a' <= ch and ch <= 'f' then
					result := character'pos(ch) - character'pos('a')+10;
				 else report "Format error on line" & integer'image(index) severity error;	--Se a mascara estiver incorreta, reporta o erro
				 end if;
				 data_tmp(35-i*4 downto 32-i*4) := std_logic_vector(to_unsigned(result,4));	--Escreve o caractere nos bits correspondentes da variavel auxiliar
			 end loop;
			 im_waddr <= std_logic_vector(to_unsigned(index,32)); --assim que acaba de ler a instrução, seta o endereço de escrita para index
			 im_wd <= data_tmp;	--coloca a instrução na porta de escrita
			 clk <= '0';
			 wait for clk_period/2;
			 clk <= '1';
			 wait for clk_period/2; --pulso de clock para registrar
			 index := index + 1;	--segue para próxima instrução
		end loop;
		reset <= '0';	--Desliga o reset para iniciar o programa
		im_we <= '0';	--Desativa escrita da IM
		
		CLOCK_LOOP : LOOP	--Inicia clock para rodar o programa
		 clk <= '0';
		 WAIT FOR (clk_period/2);
		 clk <= '1';
		 WAIT FOR (clk_period/2);
		END LOOP CLOCK_LOOP;
		
	end process;

		  
end teste;
