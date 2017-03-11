-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
-- Place this file in the SD Card folder on your computer
-- SD Card /SCRIPTS/TELEMETRY/

-- Works On OpenTX Companion Version: 2.1.8
-- Works With Sensor: none

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:  none

-- Date: 2016 August 5
-- Update: none

-- Description

-- Reads getDateTime()
-- Reads model.getTimer( Timer 1)
-- Reads getTime()
-- Reads getValue( Timer 1 )

-- Displays seconds elapsed from getDateTime()
-- Displays seconds elapsed from model.getTimer( Timer 1)
-- Displays seconds elapsed from getTime()
-- Displays seconds elapsed from getValue( Timer 1 )

-- Change as desired
local TimerSwitch = "sf"

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Time Tracking
local startGetDateTimeSeconds = -1
local startGetTimeSeconds = -1
local startGetTimerSeconds = -1
local startgetValueSeconds = -1

local elapsedGetDateTimeSeconds = 0
local elapsedGetTimeMiliSeconds = 0
local elapsedGetTimerSeconds  = 0
local elapsedGetValueSeconds  = 0

-- Display
local TextHeader = "Time API Comparison"

local Debuging = false

local function getDateTimeSeconds()
    -- Returns the approximate number of seconds elapsed since January 1, 2016
    -- Increments in 1 second intervals
    -- getDateTime()
    -- Returns a table with Tx's current date and time
    -- { [year] = 2016 , [mon] = 12, [day] = 28, [hour] = 23 , [min] = 59, [sec] = 59 }
    now = getDateTime()
    nowSeconds = now.sec + (now.min * 60) + (now.hour * 3600) + (now.day * 86400) + (now.mon * 2678400) +
              ( (2016-now.year) * 31622400 ) -- 31 days/month 365 days/year
    return nowSeconds
end

local function getTimeMiliSeconds()
	-- Returns the number of miliseconds elapsed since the Tx was turned on
  -- Increments in 10 milisecond intervals
	-- getTime()
	-- Return the time since the radio was started in multiple of 10ms
	-- Number of 10ms ticks since the radio was started Example: run time: 12.54 seconds, return value: 1254
  now = getTime() * 10
  return now
end

local function getTimerSeconds()
	-- Returns the number of seconds elapsed since the Timer was started
    -- Increments in 1 second intervals
    now = model.getTimer(0)
	nowSeconds = now.value
	return nowSeconds
	-- return getValue("timer1")
end

local function getValueSeconds()
	-- Returns the number of seconds elapsed since the Timer was started
    -- Increments in 1 second intervals
	return getValue("timer1")
end

local function getMinutesSecondsAsString(seconds)
  -- Returns MM:SS as a string
  minutes = math.floor(seconds/60)
  seconds = seconds % 60.0
  return string.format("%02d:%05.2f", minutes, seconds)
end

local function init_func()
  -- Called once when model is loaded
  -- This could be empty

  -- model.getGlobalVariable(index [, phase])
  -- index is the OpenTX GV number, 0 is GV1, 1 is GV2 and so on
  -- phase is the flight mode

end
local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx

  -- Start recording time
	if getValue(TimerSwitch) > 0 then
    -- Start  reference time
		if startGetDateTimeSeconds == -1 then
			startGetDateTimeSeconds = getDateTimeSeconds()
      startGetTimeSeconds = getTimeMiliSeconds()
      startGetTimerSeconds = getTimerSeconds()
      startgetValueSeconds = getValueSeconds()
    end
    -- Time difference
    elapsedGetDateTimeSeconds = getDateTimeSeconds() - startGetDateTimeSeconds
    elapsedGetTimeMiliSeconds = getTimeMiliSeconds() - startGetTimeSeconds
    elapsedGetTimerSeconds = getTimerSeconds() - startGetTimerSeconds
    elapsedGetValueSeconds = getValueSeconds() - startgetValueSeconds
  else
    -- reset for next time switch is used.
    startGetDateTimeSeconds = -1
    startGetTimeSeconds = -1
    startGetTimerSeconds = -1
    startgetValueSeconds = -1
  end


end

local function run_func(event)
  -- Called periodically when screen is visible
  bg_func() -- a good way to reduce repitition

  -- LCD / Display code
  lcd.clear()

  -- lcd.drawText(x, y, text [, flags])
  -- Displays text
  -- text is the text to display
  -- flags are optional
  -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
  lcd.drawText( 0, 0, TextHeader, MIDSIZE + INVERS)

  -- lcd.drawText( lcd.getLastPos(), 15, "s", SMLSIZE)
  lcd.drawText( 1, 12, "getDateTime()", MIDSIZE)
  x = lcd.getLastPos() + 4
  lcd.drawText( 1, 24, "getTime()", MIDSIZE)
  lcd.drawText( 1, 36, "getTimer()", MIDSIZE)
  lcd.drawText( 1, 48, "getValue()", MIDSIZE)
  lcd.drawText( x, 12, getMinutesSecondsAsString(elapsedGetDateTimeSeconds).."s", MIDSIZE)
  lcd.drawText( x, 24, getMinutesSecondsAsString(elapsedGetTimeMiliSeconds/1000).."s", MIDSIZE)
  lcd.drawText( x, 36, getMinutesSecondsAsString(elapsedGetTimerSeconds).."s", MIDSIZE)
  lcd.drawText( x, 48, getMinutesSecondsAsString(elapsedGetValueSeconds).."s", MIDSIZE)

end



return { run=run_func, background=bg_func, init=init_func  }
