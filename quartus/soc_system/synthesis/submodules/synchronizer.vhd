library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity synchronizer is
port (
	clk	: in 	std_ulogic;
	async	: in	std_ulogic;
	sync	: out	std_ulogic
);
end entity synchronizer;

architecture synchronizer_arch of synchronizer is
	signal in_between : std_ulogic;
	begin
		process (clk)
			begin
			if (rising_edge(clk)) then
				in_between <= async;
				sync <= in_between;
			end if;
		end process;
end architecture synchronizer_arch;
