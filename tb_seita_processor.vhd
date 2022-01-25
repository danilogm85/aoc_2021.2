library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

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
	
	signal reset					:STD_LOGIC := '1';
	signal clk						:STD_LOGIC := '0';
	signal im_waddr				:std_logic_vector(31 downto 0) := x"00000000";
	signal im_we					:STD_LOGIC := '1';
	signal im_wd					:std_logic_vector(31 downto 0) := x"00000000";

begin
	
	seita_processor_pm: seita_processor port map(reset,clk,im_waddr,im_we,im_wd);	
	
	process
	
	 file mem_file: text open read_mode is "trabalho2-j.txt";
	 variable L: line;
	 variable ch: character;
	 variable i, index, result: integer;
	 variable data_tmp: std_logic_vector(31 downto 0);
	
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
		 
		while not endfile(mem_file) loop
			 readline(mem_file, L);
			 result := 0;
			 for i in 1 to 8 loop
				 read (L, ch);
				 if '0' <= ch and ch <= '9' then
					result := character'pos(ch) - character'pos('0');
				 elsif 'a' <= ch and ch <= 'f' then
					result := character'pos(ch) - character'pos('a')+10;
				 else report "Format error on line" & integer'image(index) severity error;
				 end if;
				 data_tmp(35-i*4 downto 32-i*4) := std_logic_vector(to_unsigned(result,4));
			 end loop;
			 im_waddr <= std_logic_vector(to_unsigned(index,32)); --4.194.304 = x"00400000" endereço inicial do PC
			 im_wd <= data_tmp;
			 clk <= '0';
			 wait for clk_period/2;
			 clk <= '1';
			 wait for clk_period/2;
			 index := index + 1;
		end loop;
		reset <= '0';
		im_we <= '0';
		
		CLOCK_LOOP : LOOP
		 clk <= '0';
		 WAIT FOR (clk_period/2);
		 clk <= '1';
		 WAIT FOR (clk_period/2);
		END LOOP CLOCK_LOOP;
		
	end process;

		  
end teste;