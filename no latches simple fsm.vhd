library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity last_chance is
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
end last_chance;


architecture Behavioral of last_chance is
signal testsignal : std_logic_vector(7 downto 0);

signal row : std_logic_vector(7 downto 0);
signal col : std_logic_vector(7 downto 0);

signal max : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal min : STD_LOGIC_VECTOR(7 downto 0) := (others => '1');

signal iter_i: std_logic_vector(7 downto 0) := (others => '0');
signal iter_j: std_logic_vector(7 downto 0) := (others => '0');
signal read_address : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
signal write_address : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 
signal delta: std_logic_vector(7 downto 0) := (others => '0');

type stateType is (init, reset, starting, read_row, read_next1, read_col, read_next2);
signal state_current, state_next : stateType; 
begin

    update_state: process(i_clk, i_rst) -- this process updates the current state of the Moore Machine
    begin
        if (i_rst = '0' and i_start = '0') then -- starting point for every simulation
            state_current <= init;
        elsif (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
            state_current <= state_next;
        end if;
        
    end process update_state; 


    -- Regular Moore Machine with the clock signal in the sensitivity list
    main: process(i_clk)
    begin
        if (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
        case state_current is
        when init =>
            o_en <= '1'; -- enables the operations

        when reset =>
            o_we <= '0'; -- read signal
           
        when starting =>
             o_address <= (others => '0'); -- starting address

        when read_row =>
            row <= i_data;
            -- note: writing directly o_address eliminates the nedd for extra states
            
        when read_next1 =>
            o_address <= (0 => '1', others => '0');
		    
        when read_col =>
            col <= i_data;
		    iter_i <= row;
		    
		    
		when read_next2 =>
            o_address <= (1 => '1', others => '0');
		
		when others =>
		    o_en <= '0';
		    o_we <= '0';
		    
	    end case;
        end if;
    end process main;

	
	-- this process serves as a switch for the choice of the next state 
    switch_state: process(i_clk)
    begin
    if (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
        case state_current is
            when init =>
                if (i_rst = '1') then
                    state_next <= reset;
                end if;

            when reset =>
                if (i_rst = '0') then
                    state_next <= starting;
                end if;
                
            when starting =>
                if (i_start = '1') then
                    state_next <= read_row;
                end if;
                
            when read_row =>
                state_next <= read_next1;
                
            when read_next1 =>
                state_next <= read_col;

            when read_col =>
				state_next <= read_next2;
				
		    when read_next2 =>
		        state_next <= read_next2;
                
        end case;
    end if;
    end process switch_state;
    

end Behavioral;