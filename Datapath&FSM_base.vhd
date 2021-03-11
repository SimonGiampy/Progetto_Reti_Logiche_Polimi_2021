library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity project_reti_logiche is
port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    o_address : out std_logic_vector(15 downto 0);
    o_done : out std_logic;
    o_en : out std_logic;
    o_we : out std_logic;
    o_data : out std_logic_vector (7 downto 0)
);
end project_reti_logiche;


architecture Behavioral of project_reti_logiche is
component Datapath is
    port( i_clk: in std_logic; 
          i_rst : in std_logic;
          i_data : in std_logic_vector(7 downto 0);
          o_address : out std_logic_vector(15 downto 0);
          r1_load : in std_logic;
          row_load : in std_logic;
          col_load : in std_logic;
          add_addr: in std_logic
          );
end component;
signal r1_load, row_load, col_load, add_addr : std_logic;
type S is (S0, S1, S2, S3, S4);
signal cur_state, next_state : S;
begin
  DATAPATH0: Datapath port map(
        i_clk,
        i_rst,
        i_data,
        o_address,
        r1_load,
        row_load,
        col_load,
        add_addr
        );      

      process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
      process(cur_state, i_start)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= S1;
                end if;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S4;
            end case;
     end process;
     
     process(cur_state)
     begin
        r1_load <= '0';
        row_load <= '0';
        col_load <= '0';
        add_addr <= '0';
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        case cur_state is
            when S0 =>
            when S1 =>
                add_addr <= '1';
                o_en<= '1';                
            when S2 =>
                add_addr <= '1';
                o_en<= '1';
                col_load <= '1';
            when S3 =>
                o_en<= '1';
            when S4 =>
                row_load <= '1';
                
            end case;
    end process;
    

end Behavioral;

-----------------------------------------------------------------------------

-- Datapath
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Datapath is 
port( i_clk: in std_logic; 
          i_rst : in std_logic;
          i_data : in std_logic_vector(7 downto 0);
          o_address : out std_logic_vector(15 downto 0);
          r1_load : in std_logic;
          row_load : in std_logic;
          col_load : in std_logic;
          add_addr : in std_logic
          );
end Datapath;

architecture Behavioral of Datapath is 
signal o_reg1, row, col : std_logic_vector (7 downto 0);
signal tmp_addr: std_logic_vector (15 downto 0);
constant uno : std_logic_vector(15 downto 0) := (0 => '1', others => '0'); 
begin

    --leggo dalla memoria
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000"; 
        elsif rising_edge(i_clk) then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    
    --scrivo righe
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            row <= "00000000"; 
        elsif rising_edge(i_clk) then
            if(row_load = '1') then
                row <= i_data;
            end if;
        end if;
    end process;
    
    
    --scrivo colonne
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            col <= "00000000"; 
        elsif rising_edge(i_clk) then
           if(col_load = '1') then
                col <= i_data;
            end if;
        end if;
    end process;
    
    
    --incremento indirizzo da leggere/scrivere
     process(i_clk, i_rst)
     begin
        if(i_rst = '1') then
            tmp_addr <= (others => '0'); --il reset ci viene dato solo all'inizio quindi va bene azzereare
        elsif rising_edge(i_clk) then
            if(add_addr = '1') then
                tmp_addr <= std_logic_vector(unsigned(tmp_addr) + unsigned(uno));
                o_address <= tmp_addr;
            end if;
        end if;
     end process;
    
    
    
end Behavioral;
