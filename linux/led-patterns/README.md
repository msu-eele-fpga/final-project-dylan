# LED Patterns driver for the DE10 Nano

In order to communicate with the on-board LED Patterns component, we need to create a driver for it.  

## Building

The Makefile in this directory cross-compiles the driver. Update the `KDIR` variable to point to your linux-socfpga repository directory.

Run `make` in this directory to build the kernel module.

## Device tree node

Use the following device tree node:
```devicetree
led_patterns: led_patterns@ff200000 {
    compatible = "Raber,led_patterns";
    reg = <0xff200000 16>;
};
```

## Notes / bugs :bug:

For the base_period value, I ended up coding it as a base_frequency in my LED_Patterns program on the FPGA, so a higher value corresponds to a faster clock instead of a slower one.
There are a couple bugs with regards to my LED Patterns program on the FPGA, but I ended up not having time to fix them. Here's a quick list of what I've encountered:
- When the program starts up, you need to hit the reset button (KEY1) before it starts working (totally a feature).
- When hps_led_control gets set back to hardware mode after being in software mode, the patterns and clock stop updating until you hit the reset button (KEY1).
- The base_period is a little glitchy, sometimes when the adjusting the base_period using the driver, the clock, the patterns, or even both, will stop presenting on the leds. Also, it can be a little temperamental about properly working when you send values over 0xFFF to it (at least in my experience).

## Register map

| Offset | Name            | R/W | Purpose                                                              |
|--------|-----------------|-----|----------------------------------------------------------------------|
| 0x0    | hps_led_control | R/W | Determines whether leds are controlled by hardware or software       |
| 0x4    | base_period     | R/W | Sets the frequency for the led pattern clock                         |
| 0x8    | led_reg         | R/W | Manual control of what leds are lit up when in hps software mode     |

## Documentation

N/A