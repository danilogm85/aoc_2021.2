library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--decodificador principal da control unit. Decodifica o campo OP das instruções e saídas do datapath. Para instruções do tipo R que necessitam da operação de outros
--componentes além da ALU (jr, xor e nor), o main decoder recebe do alu decoder sinais de controle (jr, xor_in,nor_in) que identificam que se trata de uma dessas instruções.

entity main_decoder is

	port(
		RESET:			in std_logic;	--master reset
		opcode:			in std_logic_vector(5 downto 0);	--campo opcode das instruções
		zero:				in std_logic;		--saida da ALU que sinaliza a igualdade entre dois numeros
		gtz:				in std_logic;		--saida do datapath que sinaliza que um numero é positivo
		jr:				in std_logic;		--vem do alu decoder
		xor_in:			in std_logic;			--vem do alu decoder
		nor_in:			in std_logic;			--vem do alu decoder
	
		pcrst:			out std_logic;			--sinal de rst do pc
		rf_rst:			out std_logic;			--sinal de rst do register file	
		rf_we:			out std_logic;			--write enable do rf
		alusrc:			out std_logic;			--controle do mux q escolhe a origem da entrada B da ALU
		dm_we:			out std_logic;			--write enable da data memory
		exttype:			out std_logic;		--seleciona o tipo de extensao (com zeros ou conservando o sinal)
		pcsrc:			out std_logic_vector(1 downto 0);	--seleção do mux que define a origem do endereço da proxima instrução
		wregdatasrc:	out std_logic_vector(2 downto 0);		--seleção do mux que define a origem do dado a ser escrito em um registrador do rf
		wregaddsrc:		out std_logic_vector(1 downto 0);	--seleção do mux que define a origem do endereço para escrita de um registrador do rf
		aluop:			out std_logic_vector(1 downto 0)	--vai para o alu decoder para escolher determinada operação aritmética em instruções
										--	que não sao do tipo r mas demandam uso da ALU
	);
end;

architecture behavior of main_decoder is

	begin
	
	process(opcode,zero,gtz,xor_in,nor_in,jr,RESET) is
	begin
		if(RESET = '1') then		--se o master reset estiver presente reseta o estado arquitetural para o inicial
			pcrst <= '1';
			rf_rst <= '1';
		else
			pcrst <= '0';
			rf_rst <= '0';
		end if;
		
		dm_we <= '0';	--Por padrão o write enable da data memory fica desativado
		exttype <= '0';	--extensão padrão com conservação do sinal do imediato
    
		case opcode is		--define as saidas para cada opcode ou entradas provenientes do datapath/alu decoder, de acordo com a tabela verdade
      when "000000" =>
        if((jr = '0') and (xor_in = '0') and (nor_in = '0')) then		--instruções do tipo R gerenciadas pelo alu decoder
          pcsrc <= "00";	--pc recebe próxima instrução
          rf_we <= '1';		--permite escrita no register file
          wregdatasrc <= "000";		--o dado de escrita será proveniente da saida da ALU
          wregaddsrc <= "01";	--endereço do registrador de escrita vindo dos bits 15:11 da instrução, correspondentes ao registrador rd das instruções tipo r
          alusrc <= '0';	--entrada B da alu vem do register file
          aluop <= "10";	--pede pra ALU olhar o funct
           
        elsif((jr = '0') and (xor_in = '0') and (nor_in = '1')) then		--INSTRUÇÃO NOR
          pcsrc <= "00";
          rf_we <= '1';		--permite escrita no register file
          wregdatasrc <= "011";	--o dado de escrita será proveniente do caminho que realiza uma not com o resultado da ALU
          wregaddsrc <= "01";	--endereço do registrador de escrita vindo dos bits 15:11 da instrução, correspondentes ao registrador rd das instruções tipo r
          alusrc <= '0';	--entrada B da alu vem do register file
          aluop <= "10";	--pede pra ALU olhar o funct

        elsif((jr = '0') and (xor_in = '1') and (nor_in = '0')) then		--INSTRUÇÃO XOR
          pcsrc <= "00";	
          rf_we <= '1';		
          wregdatasrc <= "010";		--o dado de escrita será proveniente da XOR
          wregaddsrc <= "01";
          alusrc <= '0';
          aluop <= "10";

        elsif((jr = '1') and (xor_in = '0') and (nor_in = '0')) then		--INSTRUÇÃO JR
          pcsrc <= "11";		--a próxima instrução virá do registrador selecionado
          rf_we <= '0';			--desativa a escrita de registrador
          wregdatasrc <= "000";		--dont care
          wregaddsrc <= "00";		--dont care
          alusrc <= '0';		--dont care
          aluop <= "00";		
			
			else				--dont care
			  rf_we <= '0';
			  alusrc <= '0';
			  pcsrc <= "00";
			  wregdatasrc <= "000";
			  wregaddsrc <= "00";
			  aluop <= "00";
        end if;

      when "100011" =>				--INSTRUÇÃO LW
          rf_we <= '1';		--Permite escrita de reg
          alusrc <= '1';	--segundo operando da ALU será o imediato extendido, que será somado com o endereço de base presente no registrador RS (bits 21:25 da instr)
          pcsrc <= "00";	
          wregdatasrc <= "001";		--Dado a ser escrito no reg proveniente da data memory
          wregaddsrc <= "00";		--endereço do reg a receber a word definido pelos bits 20:16 da instrução, campo rt da instrução tipo I
          aluop <= "00";		--Manda alu decoder pedir uma soma para a alu

      when "101011" =>				--INSTRUÇÃO SW
          rf_we <= '0';
          alusrc <= '1';	--segundo operando da ALU será o imediato extendido, que será somado com o endereço de base presente no registrador RS (bits 21:25 da instr)
          dm_we <= '1';		--permite escrita na data memory
          pcsrc <= "00";
          wregdatasrc <= "000";			
          wregaddsrc <= "00";		--dont care
          aluop <= "00";		
          
      when "000100" =>			--INSTRUÇÃO BEQ
		  rf_we <= '0';
        alusrc <= '0';
        wregdatasrc <= "000";		
        wregaddsrc <= "00";
        aluop <= "00";
        
		  if(zero = '1') then	
          pcsrc <= "01";		--Se os registradores forem iguais, o próximo PC será o (imediato*4)+pc+4
		  else
			 pcsrc <= "00";	--Senao, segue o programa normalmente
        end if;

      when "000010" =>			--INSTRUÇÃO J
        rf_we <= '0';		
        alusrc <= '0';
        pcsrc <= "10";			--Pc rebece o endereço do imediato
        wregdatasrc <= "000";		--dont cares
        wregaddsrc <= "00";
        aluop <= "00";

      when "000011" =>			--INSTRUÇÃO JAL
        rf_we <= '1';			--permite escrita no registrador
        alusrc <= '0';			
        pcsrc <= "10";			--PC recebe o endereço do imediato
        wregdatasrc <= "100";		--ra <= PC+4
        wregaddsrc <= "10";		--resgistrador 31(ra)
        aluop <= "00";

      when "000111" =>			--INSTRUÇÃO BGTZ
		  rf_we <= '0';
        wregdatasrc <= "000";		--dont cares
        wregaddsrc <= "00";
        alusrc <= '0';
        aluop <= "00";
		  
        if(gtz = '1') then
          pcsrc <= "01";	--se rs é gtz, pc<=pc+4+imm*4
		  else
		    pcsrc <= "00";	--senao, segue pra proxima instrução
        end if;
        
      when "001000" =>			--INSTRUÇÃO ADDI
        rf_we <= '1';		--permite escrita no reg
        alusrc <= '1';		--alu realiza soma com o imediato
        pcsrc <= "00";		
        wregdatasrc <= "000";	--dado a ser gravado no reg virá da ALU
        wregaddsrc <= "00";	--registrador que receberá o resultado presente nos bits 20:16 da instr, registrador rt das instruções tipo I
        aluop <= "00";		--solicita uma soma da ALU

      when "001101" =>			--INSTRUÇÃO ORI
        pcsrc <= "00";
        rf_we <= '1';			
        wregdatasrc <= "000";	
        wregaddsrc <= "00";
        alusrc <= '1';		--ALU fara uma OR com o imediato
        aluop <= "11";		--solicita uma OR da ALU
        exttype <= '1';		--extende o imediato com zeros
        
      when "001111" =>			--INSTRUÇÃO LUI
        rf_we <= '1';			
        alusrc <= '0';		
        pcsrc <= "00";
        wregdatasrc <= "110";		--escreve no registrador selecionado o imediato deslocado para a esquerda, jogando-o para a parte mais significativa
        wregaddsrc <= "00";
        aluop <= "00";

      when others =>			--para instruções desconhecidas, seta todas as saidas para 0
			rf_we <= '0';
			alusrc <= '0';
			pcsrc <= "00";
			wregdatasrc <= "000";
			wregaddsrc <= "00";
			aluop <= "00";
      
    end case;
	end process;
end behavior;
