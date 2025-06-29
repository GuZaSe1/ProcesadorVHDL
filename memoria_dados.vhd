library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all; -- BIBLIOTECA PADRÃO

entity memoria_dados is
  port(
    i_CLK, i_RSTn   : in std_logic;
    i_ADDR, i_DATA  : in std_logic_vector(31 downto 0);
    i_WR, i_RD      : in std_logic;
    o_DATA          : out std_logic_vector(31 downto 0)
  );
end memoria_dados;

architecture arch_memoria_dados of memoria_dados is
    type t_RAM_ARRAY is array(0 to 1023) of std_logic_vector(7 downto 0);
    signal RAM: t_RAM_ARRAY := (others => (others => '0'));
begin
    process(i_CLK, i_RSTn)
    begin
        if rising_edge(i_CLK) then
            if(i_WR = '1') then
                -- CONVERSÃO EXPLÍCITA E SEGURA
                RAM(to_integer(unsigned(i_ADDR)) + 0) <= i_DATA(7 downto 0);
                RAM(to_integer(unsigned(i_ADDR)) + 1) <= i_DATA(15 downto 8);
                RAM(to_integer(unsigned(i_ADDR)) + 2) <= i_DATA(23 downto 16);
                RAM(to_integer(unsigned(i_ADDR)) + 3) <= i_DATA(31 downto 24);
            end if;
        end if;
    end process;

    o_DATA <= RAM(to_integer(unsigned(i_ADDR)) + 3) &
              RAM(to_integer(unsigned(i_ADDR)) + 2) &
              RAM(to_integer(unsigned(i_ADDR)) + 1) &
              RAM(to_integer(unsigned(i_ADDR)) + 0)
              when i_RD = '1' else (others => 'Z');
end arch_memoria_dados;
