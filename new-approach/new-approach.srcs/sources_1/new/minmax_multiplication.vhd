library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- structure of the inputs and outputs of this component
-- its purpose is to calculate min and max from a list of numbers in input
entity multiplication is
port (
    -- input ports
    i_clk: in std_logic;
    i_data : in std_logic_vector(7 downto 0);
    row : in std_logic_vector(7 downto 0);
    col : in std_logic_vector(7 downto 0);
    start: in std_logic;
    input_address: in std_logic_vector(15 downto 0);
    -- output ports
    min : out std_logic_vector(7 downto 0);
    max : out std_logic_vector(7 downto 0);
    finish: out std_logic;
    data_address : out std_logic_vector(15 downto 0)
);
end multiplication;

architecture Behavioral of multiplication is

--list of states for the FSM
type stateType is (reset, init, s1, s2, s3, stop);
signal state_current, state_next : stateType; 

-- internal signals 
signal min_val, max_val :  std_logic_vector(7 downto 0);
signal iter_i:  integer;
signal dimension: integer;
signal read_address :  std_logic_vector(15 downto 0);
signal test_signal :  std_logic;
begin

-- reset state and synchronization on the rising edge of the clock
Update: process(start, i_clk) 
begin
    if (start = '0') then
        state_current <= reset;
    elsif rising_edge(i_clk) then
        state_current <= state_next;
    end if;
end process Update;


-- main process that elaborates the signals and sends feedbacks to the main component
Moore: process(i_clk, start, i_data, input_address)
begin
if rising_edge(i_clk) then
    case state_current is
    when reset => -- default values for all the signals
        if (start = '1') then
            state_next <= init;
        end if;
        finish <= '0';
        max <= "00000000";
        min <= "00000000";
        data_address <= (1 => '1', others => '0');
        
        max_val <= "00000000";
        min_val <= "11111111";
        iter_i <= 0;
        dimension <= 0;
        read_address <= (1 => '1', others => '0');
        
    when init => -- serves for updating the out address
        test_signal <= '1';
        dimension <= to_integer(unsigned(row) * unsigned(col));
        
        
        state_next <= s1;
        
    when s1 =>
    -- when the input address signal is the same as the one that this component asked for, it receives the new input data value
        if (input_address = read_address) then  
            if (i_data > max_val) then --changes max value
                max_val <= i_data;
            end if;
            if (i_data < min_val) then --changes min value
                min_val <= i_data;
            end if;
            
            -- logic for reading all the numbers
            iter_i <= iter_i + 1;
            state_next <= s2;
        else
            state_next <= s1;
        end if;
        
    when s2 =>
    -- iteration mechanism that uses the multiplication to determine the last address to be reached
        if (iter_i = dimension) then
            read_address <= std_logic_vector(unsigned(read_address) + 1);
            state_next <= stop;
        else 
            read_address <= std_logic_vector(unsigned(read_address) + 1);
            state_next <= s3;
        end if;
        
    when s3 =>
        data_address <= read_address;
        state_next <= s1;
        
        
    when stop => -- does nothing and signals the main component that min and max are computed
        state_next <= stop;
        min <= min_val;
        max <= max_val;
        finish <= '1';
        
    end case;
end if;    
end process Moore;




end Behavioral;
