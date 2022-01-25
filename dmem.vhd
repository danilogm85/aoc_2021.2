library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--memória de dados

entity dmem is -- data memory
 port(clk, we: in STD_LOGIC;
 a, wd: in STD_LOGIC_VECTOR (31 downto 0);
 rd: out STD_LOGIC_VECTOR (31 downto 0));
end;

architecture behave of dmem is
begin

	 process(clk,a,we,wd)
	 variable tmp :STD_LOGIC_VECTOR(31 downto 0);
	 type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);		--a memória possui 64 palavras de 32 bits cada
	 variable mem: ramtype  :=(others => x"00000000");	--inicializando tudo em zero
	 begin
	 
	 -- read or write memory
	 	--a memória será enxergada externamente como possuindo 32 bits para endereçamento, mas internamente possui apenas 6 bits de endereçamento
		 -- e 64 endereços. O programa começa a buscar informações na memória a partir do endereço x10010000, então o endereço é convertido a seguir
		 tmp := std_logic_vector(unsigned(a)-268500992);	
		 if rising_edge(clk) then	--escrita sincrona
			if (we='1') then mem (to_integer(unsigned(tmp(7 downto 2))  )  ):= wd;	--extrai-se os bits 7:2 do endereço, de forma que o acesso a memória se da sempre
			end if;									--em multiplos de 4, já que as memórias normalmente são endereçadas em 8 bits
		 end if;									--	mas a MIPS trabalha com palavras de 32 bits
		 rd <= mem (to_integer(unsigned(tmp(7 downto 2))  )  );		--leitura assincrona
		 
	 
	 end process;
	
end;
