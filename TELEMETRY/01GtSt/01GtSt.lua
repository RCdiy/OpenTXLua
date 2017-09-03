-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

-- Works On OpenTX Companion Version: 2.1.8

-- Author: RC diy
-- Web: http://RCdiy.ca

-- Description
-- This is an introductory script to introduce some basics with regards to
-- Reading, displaying and processing telemetry data

-- Sensors
-- RxBt

-- Global OpenTX variables used
-- None

-- Global Lua environment variables used
-- None

-- Variables local to this script
-- must use the word "local" before the variable
local BatterySensor = "RxBt"

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Avoid editing below here
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local ReceiverBatteryVoltage_current = 0.0
local ReceiverBatteryVoltage_previous = 0.0
local ReceiverBatteryVoltage_startup = 0.0
local x = 0
local y = 0
local fh = 10

local function init_func()
  -- Called once when model is loaded
  -- This could be empty
  ReceiverBatteryVoltage_startup = getValue(BatterySensor)
  -- this works on the simulator however on the
  -- Tx the value is always 0.0
end

local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx
  if ReceiverBatteryVoltage_startup == 0 then
    ReceiverBatteryVoltage_startup = getValue(BatterySensor)
    -- this was added because on Tx when assigning the start up voltage
    -- in the init_func() the value was always 0.0
  end
  ReceiverBatteryVoltage_previous = ReceiverBatteryVoltage_current
  ReceiverBatteryVoltage_current = getValue(BatterySensor)

end

local function run_func(event)
  -- Called periodically when screen is visible
  bg_func() -- a good way to reduce repitition

  -- LCD / Display code
  lcd.clear()

  -- lcd.drawChannel(x, y, source, flags)
  -- Displays sensor value with units
  -- x,y location with 0,0 left, top
  -- source can only be telemetry sensors
  -- flags are optional
  -- 0 black on white text, 1 blink,
  -- 2 white on black text, 3 blink
  x = 1
  y = 1
  if ReceiverBatteryVoltage_current == ReceiverBatteryVoltage_startup then
    lcd.drawChannel(x,y, BatterySensor)
  else
    lcd.drawChannel(x,y, BatterySensor, BLINK)
  end
  -- lcd.getLastPos()
  -- Returns the last pixel drawn position from the left
  lcd.drawText( lcd.getLastPos(), y, " "..BatterySensor.." Sensor" )

  -- lcd.drawGauge(x, y, w, h, fill, maxfill)
  -- Draws a horizontal gauge, fills from left to right
  -- x,y location with 0,0 left, top
  -- w,h width and height in pixels
  -- fill is the current value (example 20 for 20%)
  -- maxfill is the max gauge value (example 100 for % scale)
  y = y + fh
  if ReceiverBatteryVoltage_startup > 0 then
    lcd.drawGauge(x, y, LCD_W-1, 2 * fh, ReceiverBatteryVoltage_current*10, ReceiverBatteryVoltage_startup*10)
  else
    lcd.drawText (x,y, "Rx or Simulator not on")
  end
  -- lcd.drawNumber(x, y, value [, flags])
  -- Display numbers
  -- x,y location with 0,0 left, top
  -- value is the number to display
  -- flags are optional
  -- 0 black on white text, 1 blink,
  -- 2 white on black text, 3 blink
  -- PREC1 is value/10 so 123 becomes 12.3
  -- PREC2 is value/100 so 123 becomes 1.23
  -- if the value is 5.2 then 2 gets dropped
  -- to display 5.2, value x 10 PREC1
  lcd.drawNumber(1, 40,  ReceiverBatteryVoltage_startup *10, PREC1)
  lcd.drawText( lcd.getLastPos(), 40, "V at start up.")
end



return { run=run_func, background=bg_func, init=init_func  }
