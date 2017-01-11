-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTx Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

-- Works On OpenTx Companion Version: 2.1.8

-- Author: RC diy
-- Web: http://RCdiy.ca

-- Description
-- This is an introductory script to introduce some basics with regards to
-- Reading, displaying and processing telemetry data

-- Sensors
-- RxBt

-- Global OpenTx variables used
-- None

-- Global Lua environment variables used
-- None

-- Variables local to this script
-- must use the word "local" before the variable
local BatterySensor = "RxBt"

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
Avoid editing below here
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local ReceiverBatteryVoltage_current = 0.0
local ReceiverBatteryVoltage_previous = 0.0
local ReceiverBatteryVoltage_startup = 0.0

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



  -- lcd.drawFilledRectangle(x, y, w, h [, flags])
  -- Displays a filled in box
  -- This will paint over existing pixels
  -- x,y location with 0,0 left, top
  -- w,h width and height in pixels
  -- flags are optional
  -- SOLID, GREY_DEFAULT, FORCE (black), ERASE (white)
  --lcd.drawFilledRectangle(2,2,208,60, SOLID)
  --lcd.drawFilledRectangle(4,4,204,56, GREY_DEFAULT)
  --lcd.drawFilledRectangle(6,6,200,52, ERASE)

  -- lcd.drawChannel(x, y, source, flags)
  -- Displays sensor value with units
  -- x,y location with 0,0 left, top
  -- source can only be telemetry sensors
  -- flags are optional
  -- 0 black on white text, 1 blink,
  -- 2 white on black text, 3 blink
  if ReceiverBatteryVoltage_current == ReceiverBatteryVoltage_startup then
    lcd.drawChannel(20,10, BatterySensor)
  else
    lcd.drawChannel(20,10, BatterySensor, 3)
  end

  -- lcd.drawGauge(x, y, w, h, fill, maxfill)
  -- Draws a horizontal gauge, fills from left to right
  -- x,y location with 0,0 left, top
  -- w,h width and height in pixels
  -- fill is the current value (example 20 for 20%)
  -- maxfill is the max gauge value (example 100 for % scale)
  lcd.drawGauge(40, 10, 160, 20, ReceiverBatteryVoltage_current, ReceiverBatteryVoltage_startup)

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
  lcd.drawNumber(40, 40,  ReceiverBatteryVoltage_startup *10, PREC1)

  -- lcd.drawRectangle(x, y, w, h [, flags])
  -- Draws a box/frame
  -- x,y location with 0,0 left, top
  -- w,h width and height in pixels
  -- flags, unsigned number drawing flags
  -- SOLID, GREY_DEFAULT,
  lcd.drawRectangle(26, 38, 175, 11, SOLID)

  -- lcd.drawText(x, y, text [, flags])
  -- Displays text
  -- text is the text to display
  -- flags are optional
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  lcd.drawText( 42, 40, "Volts "..BatterySensor.." value")

  -- lcd.getLastPos()
  -- Returns the last pixel drawn position from the left
  lcd.drawText( lcd.getLastPos(), 40, " at start up.")
end



return { run=run_func, background=bg_func, init=init_func  }
