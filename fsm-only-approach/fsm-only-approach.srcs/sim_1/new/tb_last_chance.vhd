library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity tb_last_chance is
end tb_last_chance;


architecture tb_last of tb_last_chance is
constant c_CLOCK_PERIOD         : time := 15 ns;
signal   tb_done                : std_logic;
signal   mem_address            : std_logic_vector (15 downto 0) := (others => '0');
signal   tb_rst                 : std_logic := '0';
signal   tb_start               : std_logic := '0';
signal   tb_clk                 : std_logic := '0';
signal   mem_o_data,mem_i_data  : std_logic_vector (7 downto 0);
signal   enable_wire            : std_logic;
signal   mem_we                 : std_logic;


type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);

signal i: integer := 0;

signal RAM0: ram_type := (0 => std_logic_vector(to_unsigned(3, 8)), 
1 => std_logic_vector(to_unsigned(2, 8)), 
2 => std_logic_vector(to_unsigned(70, 8)), 
3 => std_logic_vector(to_unsigned(24, 8)), 
4 => std_logic_vector(to_unsigned(45, 8)), 
5 => std_logic_vector(to_unsigned(34, 8)), 
6 => std_logic_vector(to_unsigned(90, 8)), 
7 => std_logic_vector(to_unsigned(145, 8)), 
others => (others =>'0'));


component last_chance is
port (
i_clk         : in  std_logic;
i_rst         : in  std_logic;
i_start       : in  std_logic;
i_data        : in  std_logic_vector(7 downto 0);
o_address     : out std_logic_vector(15 downto 0);
o_done        : out std_logic;
o_en          : out std_logic;
o_we          : out std_logic;
o_data        : out std_logic_vector (7 downto 0)
);
end component last_chance;


begin
UUT: last_chance
port map (
i_clk      	=> tb_clk,
i_rst      	=> tb_rst,
i_start       => tb_start,
i_data    	=> mem_o_data,
o_address  	=> mem_address,
o_done      	=> tb_done,
o_en   	=> enable_wire,
o_we 		=> mem_we,
o_data    	=> mem_i_data
);

p_CLK_GEN : process is
begin
wait for c_CLOCK_PERIOD/2;
tb_clk <= not tb_clk;
end process p_CLK_GEN;


MEM : process(tb_clk)
begin
if tb_clk'event and tb_clk = '1' then
if enable_wire = '1' then
if i = 0 then
if mem_we = '1' then
RAM0(conv_integer(mem_address))  <= mem_i_data;
mem_o_data                      <= mem_i_data after 1 ns;
else
mem_o_data <= RAM0(conv_integer(mem_address)) after 1 ns;
end if;
end if;
end if;
end if;
end process;


test : process is
begin
-- wait for 100 ns;
wait for c_CLOCK_PERIOD;
tb_rst <= '1';
wait for c_CLOCK_PERIOD;
-- wait for 100 ns;
tb_rst <= '0';
wait for c_CLOCK_PERIOD;

wait for 100 ns; -- creates an error delay
tb_start <= '1';
wait for c_CLOCK_PERIOD;
wait until tb_done = '1';
wait for c_CLOCK_PERIOD;
tb_start <= '0';
wait until tb_done = '0';
wait for 100 ns;


end process test;
end tb_last;