-- Progetto Reti Logiche, anno accademico 2020 / 2021
-- Componenti del gruppo di Lavoro:
--		- Simone Giampà, matricola: 909739, codice persona: 10659184
--		- Francesco Leone, matricola: matricola 910196, codice persona: 10659809
--
-- FPGA utilizzato per la sintesi del circuito in Vivado: xc7a200tfbg484-1

-- Approccio per la realizzazione del progetto: Finite State Machine

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- project's entity
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

-- signle architecture for a single component
architecture project of project_reti_logiche is

signal row, col : unsigned(7 downto 0);
signal max, min : unsigned(7 downto 0);

signal iter_i, iter_j: unsigned(7 downto 0); -- iterator variables for calculating max and min
signal iter_k, dimension: unsigned(15 downto 0); -- number of pixels in the image to be processed, and correspnding iterator
signal tmp_num_8bit: unsigned(7 downto 0); -- temporary signal variable
signal tmp_num_16bit: unsigned(15 downto 0); -- temporary signal variable
signal delta_val: unsigned(7 downto 0); --8 bits because it is comprised between 0 and 255
signal shift_level: unsigned(3 downto 0); -- 4 bits maximum, since delta is between 0 and 8
signal read_address : std_logic_vector(15 downto 0) := (others => '0'); -- used for reading from the memory
signal write_address : std_logic_vector(15 downto 0) := (others => '0'); -- used for writing in memory

-- list of the state for the FSM
type stateType is (
reset, starting, read_row, read_next, read_col, go_on,
mm0, mm1, mm2, mm3, mm4, 
delta, shift, s0, s1, s2, s2_shift, s3, s4, s5, conclusion, finish
);

signal state : stateType; -- there is a single variable for the state representation
begin

	-- Regular Moore Machine with the only the clock signal in the sensitivity list
	Moore: process(i_clk)
	begin
	if (rising_edge(i_clk)) then -- synchronization on the rising edge of the clock
	
		if (i_rst = '1') then
			state <= reset; -- initial state is the reset state
		elsif (i_rst = '0') then -- otherwise it calculates the signals values according to the current state
			case state is 
			when reset => -- resets to the default values
			    -- input signals and component's signals
				row <= (others => '0');
				col <= (others => '0');
				max <= (others => '0');
				min <= (others => '1'); -- 255
				read_address <= (others => '0');
				write_address <= (others => '0');
				iter_i <= (others => '0');
				iter_j <= (others => '0');
				iter_k <= (others => '0');
				dimension <= (others => '0');
				shift_level <= (others => '0');
				delta_val <= (others => '0');
				tmp_num_8bit <= (others => '0');
				tmp_num_16bit <= (others => '0');
				-- output default signals
				o_done <= '0';
				o_en <= '0';
				o_we <= '0';
				o_data <= (others => '0');
				o_address <= (others => '0');  -- starting address
				
				-- goes to the next state when start goes high
				if (i_start = '1') then
					o_we <= '0'; -- read signal
					o_en <= '1'; -- enables the operations
					state <= starting;
				end if;

			when starting => -- waits for the address loading
				state <= read_row;
	
			when read_row => -- reads the row value
				row <= unsigned(i_data);
				o_address <= (0 => '1', others => '0');
				state <= read_next;
				
			when read_next => -- address loading state
				read_address <= (1 => '1', others => '0');
				state <= read_col;
				
			when read_col => -- read the column value
				col <= unsigned(i_data);
				state <= go_on;
				o_address <= read_address;
			
			when go_on => -- address loading state
				-- in the case the matrix is empty, there are no more calculations to do, nor writing in memory
			    if (row = "00000000" or col = "00000000") then 
			        state <= conclusion;
			    else
			        state <= mm0;
			    end if;
				
			when mm0 => -- reads number in input
				tmp_num_8bit <= unsigned(i_data);
				state <= mm1;
				
			when mm1 => -- updates min and max values
				if (tmp_num_8bit > max) then -- changes max value
					max <= tmp_num_8bit;
				end if;
				if (tmp_num_8bit < min) then -- changes min value
					min <= tmp_num_8bit;
				end if;
				iter_j <= iter_j + 1;
				state <= mm2;
			
			when mm2 => -- iteration cycle mechanism for calculating max and min values
				if (iter_j = col) then 
					iter_j <= (others => '0');
					iter_i <= iter_i + 1;
					read_address <= std_logic_vector(unsigned(read_address) + 1);
					state <= mm4;
				else
					state <= mm3;
					read_address <= std_logic_vector(unsigned(read_address) + 1);
				end if;
				
			when mm3 => -- updates address in output
				o_address <= read_address;
				state <= go_on;
				
			when mm4 => --checks whether to keep looping or not
				if (iter_i = row) then -- loop finishes
					state <= delta; 
				else
					o_address <= read_address; -- loops and address update
					state <= go_on;
				end if;
				
			when delta => -- calculates the delta value
				delta_val <= max - min;
				dimension <= unsigned(read_address) - 2; -- number of elements to read and write
				state <= shift;
				write_address <= read_address; -- starting point for writing in memory
				
			when shift => -- calculates the shift value
				if (delta_val = 0) then
					shift_level <= "1000"; -- 8
				elsif (delta_val = 1 or delta_val = 2) then
					shift_level <= "0111"; -- 7
				elsif (delta_val >= 3 and delta_val <= 6) then
					shift_level <= "0110"; -- 6
				elsif (delta_val >= 7 and delta_val <= 14) then
					shift_level <= "0101"; -- 5
				elsif (delta_val >= 15 and delta_val <= 30) then
					shift_level <= "0100"; -- 4
				elsif (delta_val >= 31 and delta_val <= 62) then
					shift_level <= "0011"; -- 3
				elsif (delta_val >= 63 and delta_val <= 126) then
					shift_level <= "0010"; -- 2
				elsif (delta_val >= 127 and delta_val <= 254) then
					shift_level <= "0001"; -- 1
				elsif (delta_val = 255) then    
					shift_level <= "0000";
				end if;
				iter_k <= (0 => '1', others => '0'); -- equal to 1
				read_address <= (1 => '1', others => '0'); -- starting point for reading in memory
				
				state <= s0;
				
			when s0 => -- starts reading one number per time and modifying it
				o_we <= '0';
				o_address <= read_address;
				state <= s1;
				
			when s1 => -- increment reading address
				read_address <= std_logic_vector(unsigned(read_address) + 1);
				state <= s2;
				
			when s2 =>
				-- calculates the difference of the current pixel value and the minimum value
				-- representation in 8 bits
				tmp_num_8bit <= unsigned(i_data) - min;
				state <= s2_shift;
				
		    when s2_shift =>
		        -- the number previously calculated is expanded from 8bits up to 16 bits
		        --    so other 8 "0" bits are added to the left of the number
		        -- shifting to the left requires more bits, and trailing zeroes are to be added
		        tmp_num_16bit <= shift_left("00000000" & tmp_num_8bit, to_integer(shift_level));
		        state <= s3;
		        
			when s3 => -- new value calculated
				if (tmp_num_16bit >= 255) then
					tmp_num_16bit <= "0000000011111111"; -- 255 in binary, 16 bits
				end if;
				o_we <= '1';
				o_address <= write_address;
				state <= s4;
				
			when s4 => -- increment write address
				write_address <= std_logic_vector(unsigned(write_address) + 1);
				state <= s5;
				
			when s5 => -- writes in output the new calculated value
			    -- tmp_num gest shrinked down to the last 8 bits so it is compatible with o_data (8bits)
				o_data <= std_logic_vector(tmp_num_16bit(7 downto 0)); 
				
				if (iter_k = dimension) then -- iteration cycle for calculating all the new values
					state <= conclusion;
				else
					iter_k <= iter_k + 1; -- looping back
					state <= s0;
				end if;
				
			when conclusion => -- sets the done signal to high and then awaits for a new image in input
				o_we <= '0';
				o_done <= '1';
				o_en <= '0';
				state <= finish;
				
		    when finish => -- completes the cycle and starts a new one if start goes low again
		        if (i_start = '0') then
		            o_done <= '0';
		            state <= reset; -- goes back to the reset state when a new image is going to be processed
		        end if;
			
			end case;
		end if;
	end if;
	end process Moore;
	
end project;