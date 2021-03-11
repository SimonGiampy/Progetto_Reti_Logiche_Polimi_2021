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
signal testsignal : std_logic_vector(7 downto 0);

signal row : std_logic_vector(7 downto 0);
signal col : std_logic_vector(7 downto 0);

signal max : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal min : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

signal iter_i: std_logic_vector(7 downto 0) := (others => '0');
signal iter_j: std_logic_vector(7 downto 0) := (others => '0');
signal tmp_addr : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
signal tmp_num: std_logic_vector(7 downto 0) := (others => '0');
signal dimension: std_logic_vector(15 downto 0) := (others => '0');

type stateType is (S0, S1, S2, S3, S4, S5, S6, S7, S8);
signal state_current, state_next : stateType; 
begin

    update: process(i_clk, i_rst) -- this process updates the current state of the Moore Machine
    begin
        if i_rst = '1' then
            state_current <= s0;
        elsif (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
            state_current <= state_next;
        end if;
    end process update; 
    
    process(state_current, i_start)
    begin
        state_next <= state_current;
        case state_current is
            when S0 =>
                if i_start = '1' then
                    state_next <= S1;
                end if;
            when S1 =>
                state_next <= S2;
            when S2 =>
                 state_next <= S3;
            when S3 =>
                 state_next <= S4;
            when S4 =>
                state_next <= S5;
            when S5 =>
                state_next <= S6;
            when S6 =>
                state_next <= S7;
            when S7 =>
                if unsigned(iter_i) <= unsigned(dimension) then
                    state_next <= S6;
                else
                    state_next <= S8;
                end if;
            when S8 =>
                    state_next <= S8;
        end case;
    end process;
    
    process(state_current)
    begin
        case state_current is 
        when S0 =>
            o_we <= '0';
            o_en <= '1';
       when S1 =>
            o_address <= tmp_addr;
            tmp_addr <= std_logic_vector(unsigned(tmp_addr) + 1);
       when S2 => 
            row <= i_data; 
            o_address <= tmp_addr;
       when S3 =>
            tmp_addr <= std_logic_vector(unsigned(tmp_addr) + 1);
            
      when S4 =>
            o_address <= tmp_addr;
            col <= i_data;
      when S5 =>
            dimension <= std_logic_vector(unsigned(row) * unsigned (col));
      when S6 =>
            if(i_data < min) then
                min <= i_data;
             end if;
             if(i_data > max) then
                max <= i_data;
             end if;
             tmp_addr <= std_logic_vector(unsigned(tmp_addr) + 1);
             iter_i <= std_logic_vector(unsigned(iter_i) + 1);
       when S7 =>
            o_address <= tmp_addr;
       when S8 =>
       end case;
     end process;
        


    

end Behavioral;