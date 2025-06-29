library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RISCV32i is
	Port (	i_CLK      : in  std_logic;
    		i_RSTn     : in  std_logic;
    		o_INST     : out std_logic_vector(31 downto 0);
    		o_OPCODE   : out std_logic_vector(6 downto 0);
    		o_RD_ADDR  : out std_logic_vector(4 downto 0);
    		o_RS1_ADDR : out std_logic_vector(4 downto 0);
    		o_RS2_ADDR : out std_logic_vector(4 downto 0);
    		o_RS1_DATA : out std_logic_vector(31 downto 0);
    		o_RS2_DATA : out std_logic_vector(31 downto 0);
    		o_IMM      : out std_logic_vector(31 downto 0);
    		o_ULA      : out std_logic_vector(31 downto 0);
    		o_MEM      : out std_logic_vector(31 downto 0)
    );
end RISCV32i;

architecture arch_1 of RISCV32i is
    -- Sinais internos ("fios") do processador
    signal w_RS1, w_RS2      : std_logic_vector(31 downto 0);
    signal w_ULA             : std_logic_vector(31 downto 0);
    signal w_ULAb            : std_logic_vector(31 downto 0);
    signal w_MEM             : std_logic_vector(31 downto 0);
    signal w_IMM             : std_logic_vector(31 downto 0);
    signal w_WRITE_DATA      : std_logic_vector(31 downto 0);
    signal w_PC, w_PC4       : std_logic_vector(31 downto 0);
    signal w_INST            : std_logic_vector(31 downto 0);
    signal w_ZERO            : std_logic;
    signal w_ALU_SRC         : std_logic;
    signal w_MEM2REG         : std_logic;
    signal w_REG_WRITE       : std_logic;
    signal w_MEM_READ        : std_logic;
    signal w_MEM_WRITE       : std_logic;
    signal w_BRANCH          : std_logic;
    signal w_ALUOP           : std_logic_vector(1 downto 0);
    signal w_PCSrc           : std_logic;
    signal w_PC_BRANCH_TARGET: std_logic_vector(31 downto 0);
    signal w_NEXT_PC         : std_logic_vector(31 downto 0);

begin
    -- Instanciação dos Módulos do Processador
    
    u_CONTROLE: entity work.controle
    port map (i_OPCODE=>w_INST(6 downto 0), o_ALU_SRC=>w_ALU_SRC, o_MEM2REG=>w_MEM2REG, o_REG_WRITE=>w_REG_WRITE, o_MEM_READ=>w_MEM_READ, o_MEM_WRITE=>w_MEM_WRITE, o_BRANCH=>w_BRANCH, o_ALUOP=>w_ALUOP);

    -- Lógica de Busca de Instrução e Controle do PC
    u_PC: entity work.ffd
    port map (i_DATA=>w_NEXT_PC, i_CLK=>i_CLK, i_RSTn=>i_RSTn, o_DATA=>w_PC);
    
    u_SOMA4: entity work.somador
    port map (i_A=>w_PC, i_B=>x"00000004", o_DATA=>w_PC4);

    u_SOMA_BRANCH: entity work.somador
    port map (i_A=>w_PC, i_B=>w_IMM, o_DATA=>w_PC_BRANCH_TARGET);

    -- O desvio ocorre se a instrução for um branch E o resultado da ULA for zero (para BEQ).
    w_PCSrc <= w_BRANCH and w_ZERO;

    u_MUX_PC: entity work.mux21
    port map (i_A=>w_PC4, i_B=>w_PC_BRANCH_TARGET, i_SEL=>w_PCSrc, o_MUX=>w_NEXT_PC);

    u_MEM_INST: entity work.memoria_instrucoes
    port map(i_ADDR=>w_PC, o_INST=>w_INST);
    
    -- Caminho de Dados Principal (Decodificação e Execução)
    u_GERADOR_IMM: entity work.gerador_imediato
    port map(i_INST=>w_INST, o_IMM=>w_IMM);

    u_BANCO_REGISTRADORES: entity work.banco_registradores
    port map (i_CLK=>i_CLK, i_RSTn=>i_RSTn, i_WRena=>w_REG_WRITE, i_WRaddr=>w_INST(11 downto 7), i_RS1=>w_INST(19 downto 15), i_RS2=>w_INST(24 downto 20), i_DATA=>w_WRITE_DATA, o_RS1=>w_RS1, o_RS2=>w_RS2);

    u_MUX_ULA: entity work.mux21
    port map (i_A=>w_RS2, i_B=>w_IMM, i_SEL=>w_ALU_SRC, o_MUX=>w_ULAb);
    
    u_ULA: entity work.ULA	
    port map(i_A=>w_RS1, i_B=>w_ULAb, i_ALUOP=>w_ALUOP, i_F3=>w_INST(14 downto 12), i_INST30=>w_INST(30), o_ZERO=>w_ZERO, o_ULA=>w_ULA);
    
    u_MEM_DADOS: entity work.memoria_dados
    port map (i_CLK=>i_CLK, i_RSTn=>i_RSTn, i_ADDR=>w_ULA, i_DATA=>w_RS2, i_WR=>w_MEM_WRITE, i_RD=>w_MEM_READ, o_DATA=>w_MEM);

    u_MUX_WB: entity work.mux21
    port map (i_A=>w_ULA, i_B=>w_MEM, i_SEL=>w_MEM2REG, o_MUX=>w_WRITE_DATA);
    
    -- Saídas para depuração
    o_INST<=w_INST; o_OPCODE<=w_INST(6 downto 0); o_RD_ADDR<=w_INST(11 downto 7); o_RS1_ADDR<=w_INST(19 downto 15); o_RS2_ADDR<=w_INST(24 downto 20); o_RS1_DATA<=w_RS1; o_RS2_DATA<=w_RS2; o_IMM<=w_IMM; o_ULA<=w_ULA; o_MEM<=w_MEM;

end arch_1;
