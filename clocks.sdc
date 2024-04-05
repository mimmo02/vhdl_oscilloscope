# You have to replace <ENTITY_PORT_NAME_xxx> with the name of the Clock port
# of your top entity
set_time_unit ns
set_decimal_places 3

# 25 MHz Clock
# create_clock -period 40.0 -waveform { 0 20.0 } clock1 -name constraint1

# 74.25 MHz Clock
create_clock -period 13.468 -waveform { 0 6.734 } clk -name constraint2
derive_clock_uncertainty