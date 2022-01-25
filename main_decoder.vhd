library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity main_decoder is

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
end;

architecture behavior of main_decoder is

	begin
	
	process(opcode,zero,gtz,xor_in,nor_in,jr,RESET) is
	begin
		if(RESET = '1') then
			pcrst <= '1';
			rf_rst <= '1';
		else
			pcrst <= '0';
			rf_rst <= '0';
		end if;
		
		dm_we <= '0';
		exttype <= '0';
    
		case opcode is
      when "000000" =>
        if((jr = '0') and (xor_in = '0') and (nor_in = '0')) then
          pcsrc <= "00";
          rf_we <= '1';
          wregdatasrc <= "000";
          wregaddsrc <= "01";
          alusrc <= '0';
          aluop <= "10";
           
        elsif((jr = '0') and (xor_in = '0') and (nor_in = '1')) then
          pcsrc <= "00";
          rf_we <= '1';
          wregdatasrc <= "011";
          wregaddsrc <= "01";
          alusrc <= '0';
          aluop <= "10";

        elsif((jr = '0') and (xor_in = '1') and (nor_in = '0')) then
          pcsrc <= "00";
          rf_we <= '1';
          wregdatasrc <= "010";
          wregaddsrc <= "01";
          alusrc <= '0';
          aluop <= "10";

        elsif((jr = '1') and (xor_in = '0') and (nor_in = '0')) then
          pcsrc <= "11";
          rf_we <= '0';
          wregdatasrc <= "000";
          wregaddsrc <= "00";
          alusrc <= '0';
          aluop <= "00";
			
			else
			  rf_we <= '0';
			  alusrc <= '0';
			  pcsrc <= "00";
			  wregdatasrc <= "000";
			  wregaddsrc <= "00";
			  aluop <= "00";
        end if;

      when "100011" =>
          rf_we <= '1';
          alusrc <= '1';
          pcsrc <= "00";
          wregdatasrc <= "001";
          wregaddsrc <= "00";
          aluop <= "00";

      when "101011" =>
          rf_we <= '0';
          alusrc <= '1';
          dm_we <= '1';
          pcsrc <= "00";
          wregdatasrc <= "000";
          wregaddsrc <= "00";
          aluop <= "00";
          
      when "000100" =>
		  rf_we <= '0';
        alusrc <= '0';
        wregdatasrc <= "000";
        wregaddsrc <= "00";
        aluop <= "00";
        
		  if(zero = '1') then
          pcsrc <= "01";
		  else
			 pcsrc <= "00";
        end if;

      when "000010" =>
        rf_we <= '0';
        alusrc <= '0';
        pcsrc <= "10";
        wregdatasrc <= "000";
        wregaddsrc <= "00";
        aluop <= "00";

      when "000011" =>
        rf_we <= '1';
        alusrc <= '0';
        pcsrc <= "10";
        wregdatasrc <= "100";
        wregaddsrc <= "10";
        aluop <= "00";

      when "000111" =>
		  rf_we <= '0';
        wregdatasrc <= "000";
        wregaddsrc <= "00";
        alusrc <= '0';
        aluop <= "00";
		  
        if(gtz = '1') then
          pcsrc <= "01";
		  else
		    pcsrc <= "00";
        end if;
        
      when "001000" =>
        rf_we <= '1';
        alusrc <= '1';
        pcsrc <= "00";
        wregdatasrc <= "000";
        wregaddsrc <= "00";
        aluop <= "00";

      when "001101" =>
        pcsrc <= "00";
        rf_we <= '1';
        wregdatasrc <= "000";
        wregaddsrc <= "00";
        alusrc <= '1';
        aluop <= "11";
        exttype <= '1';
        
      when "001111" =>
        rf_we <= '1';
        alusrc <= '0';
        pcsrc <= "00";
        wregdatasrc <= "110";
        wregaddsrc <= "00";
        aluop <= "00";

      when others =>
			rf_we <= '0';
			alusrc <= '0';
			pcsrc <= "00";
			wregdatasrc <= "000";
			wregaddsrc <= "00";
			aluop <= "00";
      
    end case;
	end process;
end behavior;