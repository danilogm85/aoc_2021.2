library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity dmem is -- data memory
 port(clk, we: in STD_LOGIC;
 a, wd: in STD_LOGIC_VECTOR (31 downto 0);
 rd: out STD_LOGIC_VECTOR (31 downto 0));
end;

architecture behave of dmem is
begin

	 process(clk,a,we,wd)
	 variable tmp :STD_LOGIC_VECTOR(31 downto 0);
	 type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	 variable mem: ramtype  :=(others => x"00000000");
	 begin
	 
	 -- read or write memory
	 
		 tmp := std_logic_vector(unsigned(a)-268500992);
		 if rising_edge(clk) then
			if (we='1') then mem (to_integer(unsigned(tmp(7 downto 2))  )  ):= wd;
			end if;
		 end if;
		 rd <= mem (to_integer(unsigned(tmp(7 downto 2))  )  );
		 
	 
	 end process;
	
end;