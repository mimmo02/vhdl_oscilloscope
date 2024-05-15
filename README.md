
# Project VHDL Digital Storage Oscilloscope
The goal of this VHDL project is to create a simple Digital Storage Oscilloscope.
The system is implemented on the Leguan borad. A DAC provides the signal to be 
measured, and it is sampled with the ADC module. There are two different channels
and they can be displayed on a 1280x720 @60Hz screen, with the HDMI module.
The signals can be manipulated to have a better visualization, in amplitude, offset
time scale, trigger position and level.




## Authors

- [@Domenico Aquilino](https://moodle.bfh.ch/user/profile.php?id=61944)
- [@Lohann Steiner](https://moodle.bfh.ch/user/profile.php?id=64498)



## Documentation

[Leguan hardware documentation ](https://leguan.ti.bfh.ch/)

[PMOD-HDMI ](https://blackmesalabs.wordpress.com/2017/12/15/bml-hdmi-video-for-fpgas-over-pmod/)

[PMOD-AD1 ](https://digilent.com/reference/pmod/pmodad1/start)

[PMOD-DA2 ](https://digilent.com/reference/pmod/pmodda2/start?redirect=1)

[Quartus software](https://www.intel.com/content/www/us/en/collections/products/fpga/software/downloads.html?s=Newest&edition=lite&f:guidetmD240C377263B4C70A4EA0E452D0182CA=%5BIntel%C2%AE%20Quartus%C2%AE%20Prime%20Design%20Software%3BIntel%C2%AE%20Quartus%C2%AE%20Prime%20Lite%20Edition%3B18.1%5D)

## Running Tests

#### System test
The system works as follow:

- All the display elements are shown correctly
- The signal are shown correctly
- The offset, and the amplidute*' works correctly
- The time base works correclty
- The trigger works correctly
- The single shot acquisition works correctly
- the samples are stored and read correclty
- the paramter settings works proprely
- the ADC doesn't work (provided module has been used)

*' in the 4x amplitude the saturation is not implemented and the overshot signal goes back in the screen, the signal is correct but appears distorted.


#### Blocs tests
Here are the file names of all the testbenches

```bash
  tb_memory_stock.vhdl          [it works properly] [by Domenico Aquilino]
  tb_memory_handler.vhdl        [it works properly] [by Domenico Aquilino]
```

## Files Reference

#### Files List:

```vhdl 
dso_module.vhdl               [by both]
display_transmission.vhdl     [by Domenico Aquilino]
display_module.vhdl           [by Domenico Aquilino]
memory_stock.vhdl             [by Domenico Aquilino]
memory_handler.vhdl           [by Domenico Aquilino]
adc_module.vhdl               [by Lohann Steiner]
adc_spi.vhdl                  [by Lohann Steiner]
bcd_to_7seg.vhdl              [by Lohann Steiner]
debounce.vhdl                 [by Lohann Steiner]
dso_control.vhdl              [by Lohann Steiner]
multiplexer.vhdl              [by Lohann Steiner]
os_control.vhdl               [by Lohann Steiner]
```
#### Files description
| File| Description|
| :-------- | :-------|
| `dso_module.vhdl` | Top entity, whole Digital Storage Oscilloscope file|

| File | Description|
| :-------- | :-------|
| `display_transmission.vhdl` | provides all the necessary timing signals to communicate with the PMOD-HDMI |

| File | Description|
| :-------- | :-------|
| `display_module.vhdl` | responsable of display on the screen all the frames, with grid, offsets, trigger, and signals|

| File | Description|
| :-------- | :-------|
| `memory_stock.vhdl` | description of ram block, 8192 memory cells with 9 bits |

| File | Description|
| :-------- | :-------|
| `memory_handler.vhdl` | handler of the internal memory, store the samples from the ADC, and provides the samples to display the signal on the screen |

| File | Description|
| :-------- | :-------|
| `adc_module.vhdl` |  |

| File | Description|
| :-------- | :-------|
| `adc_spi.vhdl` | |

| File | Description|
| :-------- | :-------|
| `bcd_to_7seg.vhdl` | driver for the 7 segments display|

| File | Description|
| :-------- | :-------|
| `debounce.vhdl` | debouncer for the buttons|

| File | Description|
| :-------- | :-------|
| `dso_control.vhdl` | provides the control signals for the parameters|

| File | Description|
| :-------- | :-------|
| `multiplexer.vhdl` | driver for the led matrix

| File | Description|
| :-------- | :-------|
| `os_control.vhdl` | |



