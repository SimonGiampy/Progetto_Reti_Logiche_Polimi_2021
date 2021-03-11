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
