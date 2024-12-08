library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std;
use std.standard.all;

entity rgb_Controller_avalon is
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
    rgb_output : out std_logic_vector(2 downto 0)
  );
end entity rgb_Controller_avalon;

architecture rgb_Controller_avalon_arch of rgb_Controller_avalon is

component rgb_Controller is
  generic (
    -- CLK_PERIOD_NS = period in ns (set to 20 since clk = 50 MHz -> 20 ns)
    CLK_PERIOD_NS 	: integer := 20 -- in ns
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    -- PWM repetition period in milliseconds;
    -- datatype (W.F) is individually assigned
    period : in unsigned(11 downto 0);
    -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
    -- datatype (W.F) is individually assigned
    duty_cycle_R : in std_logic_vector(9 downto 0);
	 duty_cycle_G : in std_logic_vector(9 downto 0);
	 duty_cycle_B : in std_logic_vector(9 downto 0);
    rgb_output : out std_logic_vector(2 downto 0)
  );
end component rgb_Controller;

signal period_sig 		: std_logic_vector(31 downto 0) :=    "00000000000000000000100000000000";
signal duty_cycle_R_sig 	: std_logic_vector(31 downto 0) := "00000000000000000000001000000000";
signal duty_cycle_G_sig 	: std_logic_vector(31 downto 0) := "00000000000000000000001100000000";
signal duty_cycle_B_sig 	: std_logic_vector(31 downto 0) := "00000000000000000000001110000000";

begin

  pm_lp : component rgb_Controller
  port map (
	clk		=> clk,
	rst		=> rst,
	period	=> unsigned(period_sig(11 downto 0)),
	duty_cycle_R	=> duty_cycle_R_sig(9 downto 0),
	duty_cycle_G	=> duty_cycle_G_sig(9 downto 0),
	duty_cycle_B	=> duty_cycle_B_sig(9 downto 0),
	rgb_output => rgb_output
  );
  
  -- for read: 
  -- 		period_sig = unused (31 downto 12) + period(11 downto 0)
  --		duty_cycle_R_sig = unused(31 downto 10) + duty_cycle_R(9 downto 0)
  --		duty_cycle_G_sig = unused(31 downto 10) + duty_cycle_G(9 downto 0)
  --		duty_cycle_B_sig = unused(31 downto 10) + duty_cycle_B(9 downto 0)
  avalon_register_read : process(clk)
  begin
    if rising_edge(clk) and avs_read = '1' then
	   case avs_address is
		  when "00"	=> avs_readdata <= period_sig;
		  when "01"	=> avs_readdata <= duty_cycle_R_sig;
		  when "10"	=> avs_readdata <= duty_cycle_G_sig;
		  when "11"	=> avs_readdata <= duty_cycle_B_sig;
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
	   period_sig 			<= "00000000000000000000100000000000";
		duty_cycle_R_sig 	<= "00000000000000000000010000000000";
		duty_cycle_G_sig 	<= "00000000000000000000011000000000";
		duty_cycle_B_sig 	<= "00000000000000000000011100000000";
	 elsif rising_edge(clk) and avs_write = '1' then
	   case avs_address is
		  when "00" => period_sig <= avs_writedata;
		  when "01" => duty_cycle_R_sig <= avs_writedata;
		  when "10" => duty_cycle_G_sig <= avs_writedata;
		  when "11" => duty_cycle_B_sig <= avs_writedata;
		  when others => null;
		end case;
    end if;
  end process;

end architecture;