library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity one_pulse is
	port (
		clk	: in	std_ulogic;
		rst	: in	std_ulogic;
		input	: in	std_ulogic;
		pulse	: out	std_ulogic
	);
end entity one_pulse;

architecture one_pulse_arch of one_pulse is

signal pulse_sig    	: std_ulogic := '0';
signal pulse_enable	: std_ulogic := '0';
begin

	process (clk,rst)
	begin
	  if rising_edge(clk) then
		  if input = '1' and pulse_enable = '0' then
			 pulse_sig <= '1';
			 pulse_enable <= '1';
		  elsif input = '0' then
			 pulse_enable <= '0';
		  end if;
		  
		  if pulse_enable = '1' then
			 pulse_sig <= '0';
		  end if;
	  end if;
	end process;
		
	pulse <= pulse_sig;

end architecture one_pulse_arch;