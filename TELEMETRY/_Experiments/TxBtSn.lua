-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

-- Works On OpenTX Companion Version: 2.1.8

-- Author: RC diy
-- Web: http://RCdiy.ca

-- Description
-- This script creates a Tx Battery Gauge on the Telemetry Screen & a sensor.
-- It was developed to try out a couple of functions for the frist time.
-- OpenTX already has a Tx battery gauge and can log it to a file.
--
-- Configuration
--  If you have no experience using Telemetry scripts please read
--  Getting Started. http://rcdiy.ca/telemetry-scripts-getting-started/
-- Run the script.
-- TELEMETRY SCREEN > Discover new sensors


-- Sensors
-- tx-voltage

-- Global OpenTX variables used
-- None

-- Global Lua environment variables used
-- None

-- Variables local to this script
-- must use the word "local" before the variable
local BatterySensor = "tx-voltage"

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Avoid editing below here
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local TxBatteryVoltage_current = 0.0
local TxBatteryVoltage_previous = 0.0
local TxBatteryVoltage_startup = 0.0

local function init_func()
  -- Called once when model is loaded
  -- This could be empty
  TxBatteryVoltage_startup = getValue(BatterySensor)
  -- this works on the simulator however on the
  -- Tx the value is always 0.0
end

local function bg_func()
  -- Called periodically when screen is not visible
  if TxBatteryVoltage_startup == 0 then
    TxBatteryVoltage_startup = getValue(BatterySensor)
    -- this was added because on Tx when assigning the start up voltage
    -- in the init_func() the value was always 0.0
  end
  TxBatteryVoltage_previous = TxBatteryVoltage_current
  TxBatteryVoltage_current = getValue(BatterySensor)
  print(TxBatteryVoltage_current, TxBatteryVoltage_startup)
  precision = 1
  x = 10
  setTelemetryValue(0xFFFF, 0, 32, TxBatteryVoltage_current*x,1,precision)
  print(getValue("FFFF"))

end

local function run_func(event)

  bg_func()
  --
  lcd.clear()

  -- if TxBatteryVoltage_current == TxBatteryVoltage_startup then
  --   lcd.drawChannel(20,10, BatterySensor)
  -- else
  --   lcd.drawChannel(20,10, BatterySensor, 3)
  -- end

  -- lcd.drawGauge(1, 10, 1, 20, 1, 2)
  row = 1
  lcd.drawText(1,row, "Tx Battery")
  lcd.drawText(LCD_W-20,row, TxBatteryVoltage_startup.."V" )
  row = row + 10
  height = 10
  lcd.drawGauge(1, row, LCD_W-2, height, TxBatteryVoltage_current*10, TxBatteryVoltage_startup*10)
  row = row+1
  lcd.drawText(2,row, TxBatteryVoltage_current.."V" )
  -- lcd.drawNumber(1, 22,  TxBatteryVoltage_startup *10, PREC1)
  -- lcd.drawText( )
  --
  -- lcd.drawText( 42, 40, "Volts "..BatterySensor.." value")
  --
  -- lcd.drawText( lcd.getLastPos(), 40, " at start up.")
end



return { run=run_func, background=bg_func, init=init_func  }
