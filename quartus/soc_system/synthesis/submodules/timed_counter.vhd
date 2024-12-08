library ieee;
use ieee.std_logic_1164.all;

entity timed_counter is
generic (
	clk_period 	: time;
	count_time	: time 
);
port (
		clk		: in 	std_ulogic;
		enable		: in	boolean;
		done		: out	boolean
);
end entity timed_counter;

architecture timed_counter_arch of timed_counter is

constant COUNTER_LIMIT : integer := count_time/clk_period;

signal counter	: integer range 0 to COUNTER_LIMIT;

begin

counter_process : process(clk)
	begin
	
	if (enable) then
		if (rising_edge(clk)) then  
			if (counter = (COUNTER_LIMIT)) then
				counter <= 0;
				done <= true;
			elsif (counter < COUNTER_LIMIT) then
				counter <= counter + 1;
				done <= false;
			else 
				--should never happen
			end if;
		end if;
	else
		counter <= 0;
		done <= false;
	end if;

end process;

end architecture timed_counter_arch;