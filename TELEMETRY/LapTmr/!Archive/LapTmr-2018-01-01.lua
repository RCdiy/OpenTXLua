-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
-- Place this file in the SD Card folder on your computer and Tx
-- SD Card /SCRIPTS/TELEMETRY/
-- Place the accompanying sound files in /SCRIPTS/SOUNDS/LapTmr/
-- Further instructions http://rcdiy.ca/telemetry-scripts-getting-started/

-- Works On OpenTX Version: 2.1.8 to 2.1.9
-- Works With Sensor: none

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:  none

-- Date: 2017 January 7
-- Update: none

-- Description

-- Displays time elapsed in minutes, seconds an miliseconds.
-- Timer activated by a physical or logical switch.
-- Lap recorded by a second physical or logical switch.
-- Reset to zero by Timer switch being set to off and Lap switch set on.
-- Default Timer switch is "ls1" (logical switch one).
-- OpenTX "ls1" set to a>x, THR, -100
-- Default Lap switch is "sh", a momentary switch.

-- Change as desired
-- sa to sh, ls1 to ls32
-- If you want the timer to start and stop when the throttle is up and down
-- create a logical switch that changes state based on throttle position.
local TimerSwitch = "ls1"
-- Position U (up/away from you), D (down/towards), M (middle)
-- When using logical switches use "U" for true, "D" for false
local TimerSwitchOnPosition = "U"
local LapSwitch = "sh"
local LapSwitchRecordPosition = "U"

-- Audio
local SpeakLapNumber = true
local SpeakLapTime = true

local SpeakLapNumber = true
local SpeakLapTimeHours = 0 -- 1 hours, minutes, seconds else minutes, seconds

local BeepOnLap = true
local BeepFrequency = 200 -- Hz
local BeemLengthMiliseconds = 200
-- File Paths
-- location you placed the accompanying sound files
local SoundFilesPath = "/SCRIPTS/TELEMETRY/LapTmr/"


-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Time Tracking
local StartTimeMiliseconds = -1
local ElapsedTimeMiliseconds = 0
local PreviousElapsedTimeMiliseconds = 0
local LapTime = 0
local LapTimeList = {ElapsedTimeMiliseconds}
local LapTimeRecorded = false
-- Display
local TextHeader = "Lap Timer"
local TextSize = 0
local Debuging = false

local function getTimeMiliSeconds()
	-- Returns the number of miliseconds elapsed since the Tx was turned on
  -- Increments in 10 milisecond intervals
	-- getTime()
	-- Return the time since the radio was started in multiple of 10ms
	-- Number of 10ms ticks since the radio was started Example: run time: 12.54 seconds, return value: 1254
  now = getTime() * 10
  return now
end

local function getMinutesSecondsHundrethsAsString(miliseconds)
  -- Returns MM:SS.hh as a string
  seconds = miliseconds/1000
  minutes = math.floor(seconds/60) -- seconds/60 gives minutes
  seconds = seconds % 60 -- seconds % 60 gives seconds
  return string.format("%02d:%05.2f", minutes, seconds)
end

local function getSwitchPosition( switchID )
  -- Returns switch position as one of U,D,M
  -- Passed a switch identifier sa to sf, ls1 to ls32
  switchValue = getValue(switchID)
  if Debuging == true then
    print(switchValue)
  end
  -- typical Tx switch middle value is
  if switchValue < -100 then
    return "D"
  elseif switchValue < 100 then
    return "M"
  else
    return "U"
  end
end

local function myTableInsert(t,v)
  -- Adds values to the end of the passed table


end

local function init_func()
  -- Called once when model is loaded or telemetry reset.
  StartTimeMiliseconds = -1
  ElapsedTimeMiliseconds = 0
    -- XXLSIZE, MIDSIZE, SMLSIZE, INVERS, BLINK
    if LCD_W > 128 then
      TextSize = MIDSIZE
    else
      TextSize = 0
    end
end
local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx
  --print(#LapTimeList)
  -- Start recording time
	if  getSwitchPosition(TimerSwitch) == TimerSwitchOnPosition then
    -- Start  reference time
		if StartTimeMiliseconds == -1 then
      StartTimeMiliseconds = getTimeMiliSeconds()
    end
    -- Time difference

    ElapsedTimeMiliseconds = getTimeMiliSeconds() - StartTimeMiliseconds
    -- TimerSwitch and LapSwitch On so record the lap time
    if getSwitchPosition(LapSwitch) == LapSwitchRecordPosition then
      if LapTimeRecorded == false then
        LapTime = ElapsedTimeMiliseconds - PreviousElapsedTimeMiliseconds
        PreviousElapsedTimeMiliseconds = ElapsedTimeMiliseconds
        LapTimeList[#LapTimeList+1] = LapTime
        LapTimeRecorded = true
        playTone(BeepFrequency,BeemLengthMiliseconds,0)
        if (#LapTimeList-1) <= 16 then
          filePathName = SoundFilesPath..tostring(#LapTimeList-1)..".wav"
          playFile(filePathName)
        end
        -- playNumber(#LapTimeList-1,0)
        --if (#LapTimeList-1) == 1 then
          --playFile(SoundFilesPath.."laps.wav")
        ---else
          --playFile(SoundFilesPath.."lap.wav")
        --end
        local LapTimeInt = math.floor((LapTime/1000)+0.5)
        playDuration(LapTimeInt, SpeakLapTimeHours)
      end
    else
      LapTimeRecorded = false
    end
  else
    --TimerSwitch Off and LapSwitch On so reset time
    if getSwitchPosition(LapSwitch) == LapSwitchRecordPosition then
      StartTimeMiliseconds = -1
      ElapsedTimeMiliseconds = 0
      PreviousElapsedTimeMiliseconds = 0
      LapTime = 0
      LapTimeList = {0}
    end
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

  lcd.drawText( 0, 0, TextHeader, TextSize + INVERS)

  -- lcd.drawText( lcd.getLastPos(), 15, "s", SMLSIZE)
  x = lcd.getLastPos() + 2
  lcd.drawText( x, 0, getMinutesSecondsHundrethsAsString(ElapsedTimeMiliseconds).."s", TextSize)
  x = lcd.getLastPos() + 2
  lcd.drawText( x, 0, "Laps", TextSize + INVERS)
  x = lcd.getLastPos() + 2
  lcd.drawText( x, 0, #LapTimeList-1, TextSize)
  rowHeight = 12
  x = 0
  y = rowHeight
  -- i = 2 first entry is always 0:00.00 so skippind it
  for i = #LapTimeList, 2, -1 do
    if y % 60 == 0 then
      -- next column
      x = lcd.getLastPos() + 3
      y = rowHeight
    end
    lcd.drawText( x, y, getMinutesSecondsHundrethsAsString(LapTimeList[i]),TextSize)
    y = y + rowHeight
  end

end



return { run=run_func, background=bg_func, init=init_func  }
