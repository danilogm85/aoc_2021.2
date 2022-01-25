library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--memória de instruções. Realiza leitura assíncrona. Foi necessário colocar uma porta de escrita para poder inicializar a memória a partir
--do arquivo com código de máquina no test bench, já que o quartus nao suporta leitura de arquivos em tempo de compilação. Tentamos inicializar 
--a memória a partir de arquivo MIF, mas para isso era necessário usar uma megafunction de uma ROM, porém essa ROM possuia leitura sincrona e isso
--não ia funcionar nesse projeto

entity imem is 
 port(clk, we: in STD_LOGIC;
 ra, wa, wd: in STD_LOGIC_VECTOR (31 downto 0);
 rd: out STD_LOGIC_VECTOR (31 downto 0));
end;

architecture behave of imem is
	
begin

	 process(clk,we,ra,wa,wd)
	 variable tmp :STD_LOGIC_VECTOR(31 downto 0);
	 type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);	--memória de 64 palavras de 32 bits
	 variable mem: ramtype;
	 begin
	 
	 -- read or write memory

		 if rising_edge(clk) then
			if (we='1') then mem (to_integer(unsigned(wa(5 downto 0)))):= wd;	--a escrita ocorre de 1 em 1 endereço, então utilizamos 
			end if;									-- 6 bits a partir do bit 0 para endereçar
		 end if;
		 tmp := std_logic_vector(unsigned(ra)-4194304);		--programa começa no endereço x00400000, então aqui ocorre a conversão
		 rd <= mem (   to_integer(   unsigned(tmp(7 downto 2))  )  )    ;	--para leitura, o PC pula de 4 em 4, então aqui ocorre a divisão por 4
											-- e a utilização de apenas 6 bits de endereçamento para os 64 endereços
	 end process;
	
end;
