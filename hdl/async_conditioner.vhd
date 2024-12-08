library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity async_conditioner is
	port (
		clk	: in	std_ulogic;
		rst	: in	std_ulogic;
		async	: in	std_ulogic;
		sync	: out	std_ulogic
	);
end entity async_conditioner;

architecture async_conditioner_arch of async_conditioner is

signal sync_input 	:	std_ulogic := '0';
signal sync_deb_input 	:	std_ulogic := '0';
signal pulse		: 	std_ulogic := '0';

component one_pulse is
	port (
		clk	: in	std_ulogic;
		rst	: in	std_ulogic;
		input	: in	std_ulogic;
		pulse	: out	std_ulogic
	);
end component one_pulse;

component debouncer is
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
end component debouncer;

component synchronizer is
	port (
		clk	: in 	std_ulogic;
		async	: in	std_ulogic;
		sync	: out	std_ulogic
	);
end component synchronizer;

begin

dut_deb : component debouncer
	generic map (
		clk_period 	=> 20 ns,
		debounce_time	=> 1000 ns
	)
	port map (
      		clk   => clk,
      		rst   => rst,
     	 	input => sync_input,
     		debounced  => sync_deb_input
   	);
dut_sync : component synchronizer
    port map (
      clk   => clk,
      async => async,
      sync  => sync_input
    );

sync <= sync_deb_input;

end architecture async_conditioner_arch;
