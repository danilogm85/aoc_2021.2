library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity imem is -- data memory
 port(clk, we: in STD_LOGIC;
 ra, wa, wd: in STD_LOGIC_VECTOR (31 downto 0);
 rd: out STD_LOGIC_VECTOR (31 downto 0));
end;

architecture behave of imem is
	
begin

	 process(clk,we,ra,wa,wd)
	 variable tmp :STD_LOGIC_VECTOR(31 downto 0);
	 type ramtype is array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	 variable mem: ramtype;
	 begin
	 
	 -- read or write memory

		 if rising_edge(clk) then
			if (we='1') then mem (to_integer(unsigned(wa(5 downto 0)))):= wd;
			end if;
		 end if;
		 tmp := std_logic_vector(unsigned(ra)-4194304);
		 rd <= mem (   to_integer(   unsigned(tmp(7 downto 2))  )  )    ;

	 end process;
	
end;