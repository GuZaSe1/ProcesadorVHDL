library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- BIBLIOTECA PADRÃO

entity somador is
	Port (	i_A, i_B  : in  std_logic_vector(31 downto 0); 
            o_DATA    : out std_logic_vector(31 downto 0) 
         );
end somador;

architecture arch_1 of somador is
begin
    -- OPERAÇÃO EXPLÍCITA E SEGURA (assumindo soma com sinal)
	o_DATA <= std_logic_vector(signed(i_A) + signed(i_B));
end arch_1;
