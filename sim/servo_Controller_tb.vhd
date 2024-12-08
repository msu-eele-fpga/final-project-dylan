library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;

entity servo_Controller_tb is
end entity servo_Controller_tb;

architecture testbench of servo_Controller_tb is

  constant CLK_PERIOD : time := 20 ns;

  component servo_Controller is
	port (
	  clk : in std_logic; -- clk = 50 MHz = 20 ns
   	  rst : in std_logic;
    	  duty_cycle : in unsigned(7 downto 0);
    	  pwm_output : out std_logic
	);
  end component servo_Controller;

  signal clk_tb         : std_logic := '0';
  signal rst_tb         : std_logic := '0';
  signal duty_cycle_tb  : unsigned(7 downto 0) := "00000000";
  signal pwm_output_tb	: std_logic := '0';

begin

  dut : component servo_Controller
    port map (
      clk   	=> clk_tb,
      rst 	=> rst_tb,
      duty_cycle => duty_cycle_tb,
      pwm_output => pwm_output_tb
    );

  pwm_generator : process is
  begin

    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;

  end process pwm_generator;

  -- Create bp_timer signal
  dc_stim : process is
  begin

    rst_tb	<= '1';
    wait for 10 * CLK_PERIOD;

    rst_tb	<= '0';

    duty_cycle_tb <= "01111111";
    wait for 500 * (1000*1000*CLK_PERIOD);

    duty_cycle_tb <= "00000000";
    wait for 500 * (1000*1000*CLK_PERIOD);

    duty_cycle_tb <= "11111111";
    wait for 500 * (1000*1000*CLK_PERIOD);

    wait;

  end process dc_stim;

end architecture testbench;
