library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_instrucoes is
    port (
        i_ADDR     :in std_logic_vector(31 downto 0);
        o_INST     :out std_logic_vector(31 downto 0) 
    );
end entity memoria_instrucoes;

architecture arch_memoria_instrucoes of memoria_instrucoes is
    type t_ROM_ARRAY is array (0 to 1023) of std_logic_vector(7 downto 0);
    
    constant ROM : t_ROM_ARRAY := (
        -- Programa de Teste com Loop:
        -- Endereço 0x00: addi x5, x0, 3  (x5 = 3)
        0 => x"93", 1 => x"02", 2 => x"50", 3 => x"00",
        -- Endereço 0x04 (LOOP): addi x5, x5, -1 (decrementa x5)
        4 => x"13", 5 => x"82", 6 => x"F2", 7 => x"FF",
        -- Endereço 0x08: bne x5, x0, LOOP (se x5 != 0, volta para o endereço 4)
        8 => x"63", 9 => x"1C", 10 => x"02", 11 => x"FE",
        -- Endereço 0x0C (FIM): addi x6, x0, 100 (só executa quando o loop termina)
        12 => x"93", 13 => x"03", 14 => x"40", 15 => x"06",
        -- Restante da memória com NOP
        others => x"13" 
    );
begin
    -- Leitura em formato Little Endian
    o_INST <= ROM(to_integer(unsigned(i_ADDR)) + 3) & ROM(to_integer(unsigned(i_ADDR)) + 2) &
              ROM(to_integer(unsigned(i_ADDR)) + 1) & ROM(to_integer(unsigned(i_ADDR)));
end architecture arch_memoria_instrucoes;
