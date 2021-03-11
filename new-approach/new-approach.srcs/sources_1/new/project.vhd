library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- project standard entity definition
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

component MINMAX is
port (
    -- input ports of the component
    i_clk: in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    row : in std_logic_vector(7 downto 0);
    col : in std_logic_vector(7 downto 0);
    start: in std_logic;
    input_address: in std_logic_vector(15 downto 0);
    -- output ports of the component
    min : out std_logic_vector(7 downto 0);
    max : out std_logic_vector(7 downto 0);
    finish: out std_logic;
    data_address : out std_logic_vector(15 downto 0)
);
end component;

    type stateType is (init, reset, starting, read_row, read_col, mm1, mm2, mm3, stop);
    signal state_current, state_next : stateType; 
    
    signal row, col, max, min : std_logic_vector(7 downto 0);
    signal response_addr, new_address : std_logic_vector(15 downto 0);
    signal is_done: std_logic;
    signal ready: std_logic;

begin

STRUCT: MINMAX port map (
i_clk => i_clk, i_data => i_data, input_address => response_addr, row => row, col => col, start => ready, -- input ports mapping
min => min, max => max, finish => is_done, data_address => new_address -- output ports mapping
);

-- updates current state and initial state of the FSM
Update: process(i_start, i_rst, i_clk) 
begin
    if (i_rst = '0' and i_start = '0') then
        state_current <= init;
    elsif rising_edge(i_clk) then
        state_current <= state_next;
    end if;
end process Update;        
 


-- signal elaborations and interactions with the external components
Moore: process(i_clk, i_rst, i_start, i_data)
begin
if (rising_edge(i_clk)) then
    case state_current is
    when init =>
        if (i_rst = '1') then
            state_next <= reset;
            o_done <= '0';
        end if;
        
    when reset =>
        if (i_rst = '0') then
            state_next <= starting;
            o_en <= '1';
            o_we <= '0';
        end if;
        
    when starting =>    
        if (i_start = '1') then
            state_next <= read_row;
            o_address <= (others => '0');
        end if;
        
    when read_row =>
        state_next <= read_col;
        row <= i_data;
        o_address <= (0 => '1', others => '0');
        
    when read_col =>
        col <= i_data;
        o_address <= (1 => '1', others => '0');
        response_addr <= (1 => '1', others => '0');
        state_next <= mm1;
        
    when mm1 =>
        ready <= '1';
        state_next <= mm2;
    when mm2 =>
        if (is_done = '0') then
            o_address <= new_address;
            state_next <= mm3;
        else
            state_next <= stop;
        end if;
    when mm3 =>
        if (is_done = '0') then
            response_addr <= new_address;
            state_next <= mm2;
        else
            state_next <= stop;
        end if;
    when stop =>
        state_next <= stop;
        
    end case;
end if;
end process Moore;




end Behavioral;





