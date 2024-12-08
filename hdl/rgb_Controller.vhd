library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;

entity rgb_Controller is
  generic (
    -- CLK_PERIOD_NS = period in ns (set to 20 since clk = 50 MHz -> 20 ns)
    CLK_PERIOD_NS 	: integer := 20; -- in ns
    W_PERIOD		: integer := 12;
    F_PERIOD		: integer := 6;
    W_DUTY_CYCLE	: integer := 10;
    F_DUTY_CYCLE	: integer := 9
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    -- PWM repetition period in milliseconds;
    -- datatype (W.F) is individually assigned
    period : in unsigned(W_PERIOD - 1 downto 0);
    -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
    -- datatype (W.F) is individually assigned
    duty_cycle_R : in std_logic_vector(W_DUTY_CYCLE - 1 downto 0);
	 duty_cycle_G : in std_logic_vector(W_DUTY_CYCLE - 1 downto 0);
	 duty_cycle_B : in std_logic_vector(W_DUTY_CYCLE - 1 downto 0);
    rgb_output : out std_logic_vector(2 downto 0)
  );
end entity rgb_Controller;

architecture rgb_Controller_arch of rgb_Controller is

component pwm_controller is
  port (
    clk : in std_logic;
    rst : in std_logic;
    -- PWM repetition period in milliseconds;
    -- datatype (W.F) is individually assigned
    period : in unsigned(W_PERIOD - 1 downto 0);
    -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
    -- datatype (W.F) is individually assigned
    duty_cycle : in std_logic_vector(W_DUTY_CYCLE - 1 downto 0);
    rgb_output : out std_logic
  );
end component pwm_controller;

begin

  pwm_R : component pwm_controller
  port map (
	clk			=> clk,
	rst			=> rst,
	period		=> period,
	duty_cycle	=> duty_cycle_R,
	rgb_output		=> rgb_output(2)
  );
  
  pwm_G : component pwm_controller
  port map (
	clk			=> clk,
	rst			=> rst,
	period		=> period,
	duty_cycle	=> duty_cycle_G,
	rgb_output		=> rgb_output(1)
  );
  
  pwm_B : component pwm_controller
  port map (
	clk			=> clk,
	rst			=> rst,
	period		=> period,
	duty_cycle	=> duty_cycle_B,
	rgb_output		=> rgb_output(0)
  );
  
end architecture;