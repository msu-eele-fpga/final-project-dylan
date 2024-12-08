# RGB LED Controller VHDL for the DE10 Nano

In order to control the RGB LED, we need to code up a RGB LED controller program and create a component for it.

## System Architecture

Here's a high-level, bottom-up explanation of how our rgb controller program works:

First, we start off with the pwm_controller.vhd file. Basically, what this file does is take in 2 user-selected inputs, the period and duty_cycle, and creates a pwm signal with that specified period and duty cycle.

Next, let's take a look at the rgb_Controller.vhd file. This program instantiates 3 of those pwm controllers for the RGB LED, mapping each individual output to an overall rgb output. As a note, each pwm controller takes in a unique duty cycle from the user, but they all share same period. 

Lastly we get to our avalon file, rgb_Controller_avalon.vhd. The avalon allows us to create a component of our rgb controller file and its subsidiaries. Basically, all this file is doing is instantiating the rgb controller and binding it to the avs memory-mapped slave interface, which we'll use later when we're setting up device drivers. 

## Register Map

For this component, we needed to create 4 registers for our signals (the overall period + each duty cycle for R,G, and B). The program decides when to read or write to these registers depending on two separate signals, avs_read and avs_write. If they are asserted, the program looks at the avs_address to determine what register is being read or written to. Here is a table showing the registers along with their respective addresses in memory.

| Register      | Address      |
| ------------- | ------------ |
| period        | 0xff27ad00   |
| duty_cycle_R  | 0xff27ad04   |
| duty_cycle_G  | 0xff27ad08   |
| duty_cycle_B  | 0xff27ad0C   |

## Implementation Details

To create and implement the rgb controller component (instructions are courtesy of David Jenson, and were modified to fit this guide):

1. Open up platform designer and create a new component
2. In the component menu, set the name and display name both to rgb_Controller_avalon
3. In Files add the rgb_Controller_avalon, rgb_Controller, and pwm_controller files. Make sure the avalon file is set as the top file by double-clicking in the attributes column and checking the top-level file box. Analyze Synthesis Files - there shouldn't be any VHDL errors, but if there are, debug them.
4. In Signals & Int , delete any outputs under avalon_slave_0.
5. Click add interface and add a Clock Input. Rename to clk. Add a signal, and rename it to clk.
6. Click add interface and add a Reset Input. Rename to rst. Add a signal, and rename it to rst.
7. Click add interface and add a Conduit. Add a signal and name it rgb_output. Rename the signal type to rgb_output as well.
8. Select avalon_slave_0 , and set clock and reset to clk and rst with the dropdown menus. Click finish.
9. Back on the main page of Platform Designer, double-click on the component you just created to add it.
10. Connect clk and rst on the component to clk and clk_rst on fpga_clk.
11. Connect avalon_slave_0 on the component to master on jtag_master and h2f_lw_axi_master on hps.
12. Double click in the conduit row under the Export column in the component and rename to the name of the component (rgb_controller_avalon).
13. Set Base to 0x0007_ad00.
14. Click Generate HDL. NOTE: you will have to repeate this generation any time you change your VHDL code.
15. In the top menu under Generate, click Instantiation Template and copy the new signals at the end of the component declaration. Add those lines to the soc_system component declaration and instantiation in the project’s top level file (de10nano_top.vhd, located in the quartus folder).

For implementation details regarding wiring, see the top-level README for this project.