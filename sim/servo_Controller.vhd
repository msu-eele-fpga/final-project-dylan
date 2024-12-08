library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;

entity servo_Controller is
  port (
    clk : in std_logic; -- clk = 50 MHz = 20 ns
    rst : in std_logic;
    duty_cycle : in unsigned(7 downto 0);
    pwm_output : out std_logic
  );
end entity servo_Controller;

architecture servo_Controller_arch of servo_Controller is

signal clk_cnt : unsigned(31 downto 0) := (others => '0');
-- set clk_cnt_max to 1000000 (decimal) since servo works at 50 Hz = 20 mil ns = 1 mil cycles
signal clk_cnt_max : unsigned(31 downto 0) :=    "00000000000011110100001001000000";
-- set duty_cycle_max to 50k (decimal) since smallest pwm signal is 1 ms = 1 mil ns = 50k cycles
signal duty_cycle_max : unsigned(31 downto 0) := "00000000000000001100001101010000";


begin

	-- servo motors pwm has a start point at 1 ms (duty cycle = 5% since period = 50 Hz), thus the added 50000 (1 mil / 20 = 50k)
	-- duty_cycle can be between 0 and 255, and stop point for pwm is 2 ms (so our range is 1 mil to 2 mil), so time increment is 1 mil / 255 = 3921 ish
	-- as such, we multiple duty_cycle by 196 (~3921 / 20) to get from 1 mil (50k) to (almost) 2 mil (100k) in 15 increments
	duty_cycle_max <= (duty_cycle*196) + "00000000000000001100001101010000";

	clk_cnt_proc : process(clk,rst)
	begin
		if (rising_edge(clk)) then
		  if rst = '1' then
			 clk_cnt <= (others => '0');
			 pwm_output <= '0';
		  else
			 if clk_cnt <= duty_cycle_max and clk_cnt < clk_cnt_max then
				pwm_output <= '1';
				clk_cnt <= clk_cnt + 1;
			 elsif clk_cnt > duty_cycle_max and clk_cnt < clk_cnt_max then
				pwm_output <= '0';
				clk_cnt <= clk_cnt + 1;
			 elsif clk_cnt < duty_cycle_max and clk_cnt > clk_cnt_max then
				--shouldn't be possible ;)
			 else
				clk_cnt <= (others => '0');
			 end if;
		  end if;
		end if;
	end process;

end architecture;
