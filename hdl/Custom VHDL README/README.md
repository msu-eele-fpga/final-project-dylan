# Servo Controller VHDL for the DE10 Nano

In order to control my custom component, a micro servo, we need to code up a servo controller program and create a component for it.

## System Architecture

Here's a high-level, bottom-up explanation of how our servo controller program works:

First, we start off with the servo_Controller.vhd file. This file is basically just a PWM signal creator that takes in a duty cycle input from the user and spits out a PWM signal with a static period of 50 Hz (20ms), which is the period that the micro servo's I ordered function at. 

Moving on to our avalon file, servo_Controller_avalon.vhd. The avalon allows us to create a component of our servo controller file. All this file is doing is instantiating the servo controller and binding it to the avs memory-mapped slave interface, which we'll use later when we're setting up device drivers. 

## Register Map

For this component, we only needed to create a single register (the duty cycle). The program decides when to read or write to these registers depending on two separate signals, avs_read and avs_write. If they are asserted, the program looks at the avs_address to determine what register is being read or written to. Here is a very short table showing the duty cycle register with its respective address in memory.

| Register    | Address     |
| ----------- | ----------- |
| duty_cycle  | 0xff201000  |

## Implementation Details

To create and implement the servo controller component (instructions are courtesy of David Jenson, and were modified to fit this guide):

1. Open up platform designer and create a new component
2. In the component menu, set the name and display name both to servo_controller_avalon
3. In Files add the servo_Controller_avalon and servo_Controller files. Make sure the avalon file is set as the top file by double-clicking in the attributes column and checking the top-level file box. Analyze Synthesis Files - there shouldn't be any VHDL errors, but if there are, debug them.
4. In Signals & Int, delete any outputs under avalon_slave_0.
5. Click add interface and add a Clock Input. Rename to clk. Add a signal, and rename it to clk.
6. Click add interface and add a Reset Input. Rename to rst. Add a signal, and rename it to rst.
7. Click add interface and add a Conduit. Add a signal and name it pwm_output. Set its width to 1, its direction to output, and rename the signal type to pwm_output as well.
8. Select avalon_slave_0 , and set clock and reset to clk and rst with the dropdown menus. Click finish.
9. Back on the main page of Platform Designer, double-click on the component you just created to add it.
10. Connect clk and rst on the component to clk and clk_rst on fpga_clk.
11. Connect avalon_slave_0 on the component to master on jtag_master and h2f_lw_axi_master on hps.
12. Double click in the conduit row under the Export column in the component and rename to the name of the component (servo_controller_avalon).
13. Set Base to 0x0000_1000.
14. Click Generate HDL. NOTE: you will have to repeate this generation any time you change your VHDL code.
15. In the top menu under Generate, click Instantiation Template and copy the new signals at the end of the component declaration. Add those lines to the soc_system component declaration and instantiation in the project’s top level file (de10nano_top.vhd, located in the quartus folder).

For implementation details regarding wiring, see the top-level README for this project.