library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;

entity servo_Controller_avalon is
  port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    -- avalon memory-mapped slave interface
    avs_read : in std_logic;
    avs_write : in std_logic;
    avs_address : in std_logic_vector(1 downto 0);
    avs_readdata : out std_logic_vector(31 downto 0);
    avs_writedata : in std_logic_vector(31 downto 0);
    -- external I/O; export to top-level
    pwm_output : out std_logic
  );
end entity servo_Controller_avalon;

architecture servo_Controller_avalon_arch of servo_Controller_avalon is

component servo_Controller is
  port (
    clk : in std_logic; -- clk = 50 MHz = 20 ns
    rst : in std_logic;
	 duty_cycle : in unsigned(7 downto 0);
    pwm_output : out std_logic
  );
end component servo_Controller;

-- default duty_cycle of 1.5 ms = 127 (halfway between 0 and 255)
signal duty_cycle_sig 	: std_logic_vector(31 downto 0) := "00000000000000000000000001111111";

begin

  pm_lp : component servo_Controller
  port map (
	clk		=> clk,
	rst		=> rst,
	duty_cycle	=> unsigned(duty_cycle_sig(7 downto 0)),
	pwm_output => pwm_output
  );
  
  -- for read: 
  --		duty_cycle_sig = unused(31 downto 8) + duty_cycle(7 downto 0)
  avalon_register_read : process(clk)
  begin
    if rising_edge(clk) and avs_read = '1' then
	   case avs_address is
		  when "00"	=> avs_readdata <= duty_cycle_sig;
		  when others => null;
		end case;
	 end if;
  end process;
  
  -- for write: 
  -- 		period_sig = unused (31 downto 12) + period(11 downto 0)
  --		duty_cycle_R_sig = unused(31 downto 10) + duty_cycle_R(9 downto 0)
  --		duty_cycle_G_sig = unused(31 downto 10) + duty_cycle_G(9 downto 0)
  --		duty_cycle_B_sig = unused(31 downto 10) + duty_cycle_B(9 downto 0)
  avalon_register_write : process(clk)
  begin
    if rst = '1' then
		duty_cycle_sig 	<= "00000000000000000000000001111111";
	 elsif rising_edge(clk) and avs_write = '1' then
	   case avs_address is
		  when "00" => duty_cycle_sig <= avs_writedata;
		  when others => null;
		end case;
    end if;
  end process;

end architecture;