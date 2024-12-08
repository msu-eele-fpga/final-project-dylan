# RGB controller driver for the DE10 Nano

In order to communicate with the on-board RGB LED controller, we need to create a driver for it. This driver will function very similarly to the LED Patterns driver.

## Building

The Makefile in this directory cross-compiles the driver. Update the `KDIR` variable to point to your linux-socfpga repository directory.

Run `make` in this directory to build the kernel module.

## Device tree node

Use the following device tree node:
```devicetree
rgb_controller: rgb_controller@ff27ad00 {
    compatible = "Raber,rgb_controller";
    reg = <0xff27ad00 16>;
};
```

## Notes / bugs :bug:

For whatever reason, the address ordering of the registers are GBR, even though the rest of my code orders them RGB... but it works!
For the base_period value, I ended up coding it as a base_frequency in my LED_Patterns program on the FPGA, so a higher value corresponds to a faster clock instead of a slower one.

## Register map

| Offset | Name         | R/W | Purpose                                                              |
|--------|--------------|-----|----------------------------------------------------------------------|
| 0x0    | period       | R/W | Sets the period of the PWM signals being sent to the RGB LED         |
| 0x4    | red_value    | R/W | Sets the duty cycle being sent to the red node on the RGB LED        |
| 0x8    | green_value  | R/W | Sets the duty cycle being sent to the green node on the RGB LED      |
| 0x8    | blue_value   | R/W | Sets the duty cycle being sent to the blue node on the RGB LED       |

## Documentation

N/A