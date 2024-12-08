library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debouncer is
	generic (
		clk_period	: time := 20 ns;
		debounce_time	: time
	);
	port (
		clk		: in	std_ulogic;
		rst		: in	std_ulogic;
		input		: in	std_ulogic;
		debounced	: out	std_ulogic
	);
end entity debouncer;

architecture debouncer_arch of debouncer is

signal debounce_limit 	: natural := (debounce_time / clk_period)-1;
signal debounce_count  	: integer := 0;
signal debounce_value	: std_ulogic := '0';
signal debounce_done	: boolean := true;

begin	
	
	process(input,clk)
	begin
	if (rst = '1') then
			debounce_value <= '0';
			debounce_done <= true;
			debounce_count <= 0;
	else
		if (debounce_done) then
			if (rising_edge(clk) and input = (not debounce_value)) then
				debounce_value <= input;
				debounce_done <= false;
			elsif (rising_edge(clk)) then
				debounce_value <= input;
			end if;
			
		end if;
		if ((not debounce_done) and rising_edge(clk)) then
			if (debounce_count < debounce_limit) then
				debounce_count <= debounce_count + 1;
			elsif (debounce_count = debounce_limit or debounce_count > debounce_limit) then
				debounce_count <= 0;
				debounce_done <= true;
			end if;
		end if;
	end if;
	end process;

	debounced <= debounce_value;

end architecture debouncer_arch;