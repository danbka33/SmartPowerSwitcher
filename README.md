# Factorio - Smart Power Switcher
Adds smart power switcher highly configurable.

## Inputs
### Settings Input
This input is responsible for the Smart Power Switcher settings.
### Data Input
This input is responsible for the data coming from the storages, tanks or circuit network.

## Signals
If no signal is specified, the default settings are used, which can be changed in the mod settings.

### ![Force Enable Signal](https://github.com/danbka33/SmartPowerSwitcher/raw/master/graphics/icons/enabled.png)  Enable Smart Power Switcher 

Forced activation signal for Smart Power Switcher. Set on the settings input.
- If negative value - turns OFF.
- If positive value - turns ON. 

### ![Power Off Delay](https://github.com/danbka33/SmartPowerSwitcher/raw/master/graphics/icons/timeroff.png) Power Off Delay
Determines the delay of turning OFF Smart Power Switcher (in ticks). Set on the settings input.

### ![Power On Delay](https://github.com/danbka33/SmartPowerSwitcher/raw/master/graphics/icons/timeron.png) Power On Delay
Determines the delay of turning ON Smart Power Switcher (in ticks). Set on the settings input.

### ![Power On Delay](https://github.com/danbka33/SmartPowerSwitcher/raw/master/graphics/icons/threshold.png) Threshold
Missing amount of signal triggering a power on. Set on the settings input.

## Examples:
Settings:
- Iron Plate **40,000**
- Threshold **30,000**

If the iron is more than 40,000, then the plant will stop until the iron becomes 10,000 (40,000 - 30,000).

Settings:
- Green signal **150,000**
- Threshold **50,000**
- Red signal **-1**

If the green signal is more than 150,000, then the plant will stop until the green signal becomes 100,000 (150,000 - 50,000).
If the input does not have at least 1 red signal, the plant will shut down.

Settings:
- Iron Ore **-1**
- Coal **-1**
- Iron plate **50,000**
- Threshold **25,000**
  
If the iron plate is more than 50,000, then the plant will stop until the iron plate becomes 25,000 (50,000 - 25,000).
If the input does not have at least 1 coal, the plant will shut down.
If the input does not have at least 1 iron ore, the plant will shut down.

Settings:
- Slag **100,000**
- Hydrogen **150,000**
- Oxygen **150,000**
- Threshold **50,000**

If the slag is more than 100,000, then the plant will stop until the iron plate becomes 50,000 (100,000 - 50,000).
If oxygen or hydrogen is more than 150,000, then the plant will stop until one of them becomes 100,000 (150,000 - 50,000).

## Signal Lamp
### Red
Configuration error.
### Green
Smart Power Switch is connected.
### Yellow
Smart Power Switch is disconnected.
### Pink
Smart Power Switch change connection state.