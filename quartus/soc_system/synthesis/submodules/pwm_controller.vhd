library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;
entity pwm_controller is
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
    duty_cycle : in std_logic_vector(W_DUTY_CYCLE - 1 downto 0);
    rgb_output : out std_logic
  );
end entity pwm_controller;

architecture pwm_controller_arch of pwm_controller is

-- max PWM = 63.984375 ms (111111.111111) based off of assigned W and F values given in Table 1 of the HW9 pdf
-- min change in PWM = 0.015625 ms (1/64) = 15.625 us
-- min change with sensitivity of +-1 ns = 0.015625 ms = 15625 ns
-- max DC = 0.998046875 % (0-1 range) based off of assigned W and F
-- min change in DC = 0.001953125 % (0-1 range) (1/512) 
-- min change wrt time (with PWM = 0.015625 ms) = 3051.7578125 ns

signal period_in_time_int : integer := 50 * 1000000;
signal clk_cnt_max : unsigned(31 downto 0) := to_unsigned(50,32);
signal clk_cnt : unsigned(31 downto 0) := (others => '0');
signal duty_cycle_max : unsigned(31 downto 0) := (others => '0');

begin

-- based off a sensitivity of +-1 ns (see above calcs)
period_in_time_int <= ((to_integer(period(W_PERIOD-1 downto 6)) * 1000000) + (to_integer(period(5 downto 0)) * 15625))*2;
clk_cnt_max <= to_unsigned((period_in_time_int/CLK_PERIOD_NS),32);
-- multiplies the clk period by the duty cycle (a number between 0 and 512), then shifts that number to the right by 9 binary digits (F_DUTY_CYCLE)
-- to give the duty cycle wrt the clock period
-- the math: (clk_period * duty_cycle(0 to 512)) / 512 = amount of cycles the output should be on for  
duty_cycle_max <= shift_right(to_unsigned((to_integer(clk_cnt_max)*to_integer(unsigned(duty_cycle))),32),F_DUTY_CYCLE);

clk_cnt_proc : process(clk,rst)
begin
  if rst = '1' then
    clk_cnt <= (others => '0');
    rgb_output <= '0';
  else
    if clk_cnt < duty_cycle_max then
      rgb_output <= '1';
    else 
      rgb_output <= '0';
    end if;
    if clk_cnt < clk_cnt_max then 
      clk_cnt <= clk_cnt + 1;
    else
      clk_cnt <= (others => '0');
    end if;
  end if;
end process;

end architecture;