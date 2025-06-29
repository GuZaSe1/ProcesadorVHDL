-- Arquivo 8: ffd.vhd
library IEEE;
use IEEE.std_logic_1164.all;
entity ffd is
    port (
        i_DATA    : in  std_logic_vector(31 downto 0);
        i_CLK     : in  std_logic;
        i_RSTn    : in  std_logic;
        o_DATA    : out std_logic_vector(31 downto 0)
    );
end entity ffd;
architecture arch_ffd of ffd is
begin
    process( i_CLK, i_RSTn)
    begin
        if i_RSTn = '0' then
            o_DATA <= (others => '0');
        elsif rising_edge(i_CLK) then        
            o_DATA <= i_DATA;
        end if;
    end process;
end arch_ffd;
