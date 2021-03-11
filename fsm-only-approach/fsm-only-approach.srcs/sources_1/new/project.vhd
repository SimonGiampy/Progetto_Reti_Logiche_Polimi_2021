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
signal delta: std_logic_vector(7 downto 0) := (others => '0');

type stateType is (init, reset, starting, read_row, read_col, min_max_1, min_max_2, looping, s7);
signal state_current, state_next : stateType; 
begin

    update_state: process(i_clk, i_rst) -- this process updates the current state of the Moore Machine
    begin
        if i_rst = '1' then
            state_current <= init;
        elsif (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
            state_current <= state_next;
        end if;
        
    end process update_state; 


    -- Regular Moore Machine
    -- moore: process (state_current) -- old version
    moore: process (i_clk)
    begin
    if (rising_edge(i_clk)) then
        case state_current is
        when init =>
            o_en <= '1';

        when reset =>
            o_we <= '0';
           
        when starting =>
             o_address <= tmp_addr;

        when read_row =>
            row <= i_data;
            tmp_addr <= (0 => '1', others => '0'); -- 0000 0001
            o_address <= tmp_addr;
		    
		    
        when read_col =>
            col <= i_data;
            tmp_addr <= (1 => '1', others => '0'); -- 0000 0010
            o_address <= tmp_addr;
		    iter_i <= row;
		    
		--when go_on => -- DO NOT remove this empty state
			

        when min_max_1 =>
            if (i_data > max) then --changes max value
                max <= i_data;
            end if;
            if (i_data < min) then --changes min value
                min <= i_data;
            end if;
            
            -- memory address increment by 1
            tmp_addr <= std_logic_vector(unsigned(tmp_addr) + 1);
            
            -- nested for cycle for reading row * col numbers
            iter_j <= std_logic_vector(unsigned(iter_j) + 1);
        
        when min_max_2 => -- temporary stop of the process
            o_address <= tmp_addr;
           
            if (unsigned(iter_j)  = unsigned(col)) then
                iter_i <= std_logic_vector(unsigned(iter_i) - 1);
                iter_j <= (others => '0');
            end if;
            
        when looping => --checks whether to loop or not
            
        when s7 =>
            delta <= std_logic_vector(unsigned(max) - unsigned(min));
            o_done <= '1';
        
        end case;
    end if;
    end process moore;

	
	-- this process serves as a switch for the choice of the next state 
    switch_state: process(i_clk)
    begin
    if (rising_edge(i_clk)) then
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
                --if (rising_edge(i_clk)) then
                    state_next <= read_col;
                --end if;

            when read_col =>
                --if (rising_edge(i_clk)) then
				    state_next <= min_max_1; --go on (empty state)
                --end if;
                
			--when go_on =>
			    --if (rising_edge(i_clk)) then
                    --state_next <= min_max_1;
                --end if;
            when min_max_1 =>
                --if (rising_edge(i_clk)) then
                    state_next <= min_max_2;
                --end if;
            when min_max_2 =>
                --if (rising_edge(i_clk)) then
				    state_next <= looping;
                --end if;
            when looping =>
                --if (rising_edge(i_clk)) then
                    if (unsigned(iter_i) = 0) then -- finishes reading the list of numbers
               		   state_next <= s7;
            	    else -- keeps reading the numbers
                	   state_next <= min_max_1;
            	    end if;
            	--end if;
            when s7 =>
            
        end case;
    end if;
    end process switch_state;
    

end Behavioral;