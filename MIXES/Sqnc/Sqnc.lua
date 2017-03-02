-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTx Lua script
-- MIXES
-- Place this file in the SD Card folder on your computer and Tx
-- SD Card /SCRIPTS/MIXES/
-- Place accompanying sound files in the SD Card folder on your computer and Tx
-- SD Card /SCRIPTS/MIXES/Sqnc/

-- Further instructions http://rcdiy.ca/mixer-scripts-getting-started/

-- Works On OpenTx Version: 2.1.8 to 2.1.9

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:

-- Date: 2017 February 14
-- Update:

-- Description

-- Two Step Sequence Of Output Values
--  The script provides outputs to be used as inputs to mixes. The input to
--  the mix starts with an initial precentage value. After a defined delay
--  in seconds the value changes to the second configured value.
--  Messages are played when the sequence starts, stops, is interrupted and
--  at one second intervals during the countdown delay. The sequence and mix
--  line are configured to start and and enable with the same switch in the
--  down/towards pilot position.

-- E.g. Hand launch a plane which has a flight controller with auto level
--  Pilot places flight controller into auto level mode using a switch/pot on
--    the Tx
--  Pilot starts the sequence by moving the sequence switch down/towards pilot
--  Sequence starts a countdown with voice prompts in seconds every second
--  Pilot puts down the Tx and picks up the plane, checks auto level is working
--  Sequence countdown reaches zero seconds the throttle goes up, some up
--    elevator is added
--  Pilot hand launches the plane
--  Pilot picks up the Tx and moves the switch to turn off the sequence
--  Pilot flies the plane

-- Sequence - Inputs
-- 	Switch (Any Tx switch) [E.g. SA, When SA down, sequence starts)
-- 	Delay Seconds (0 to 120) [E.g. 20]
-- 	Start Value 1 (-100 to 100) [E.g. 60]
-- 	End Value  1 (-100 to 100) [E.g. 20]
-- 	Start Value 2 
-- 	End Value  2
-- 	Start Value 3 
-- 	End Value  3

-- Sequence - Outputs
-- 	Seq1 - output used as input to mix
-- 	Seq2
-- 	Seq3
-- 	Spoken messages when
--    the sequence starts
-- 	  the sequence stops
-- 	  the sequence is interrupted
-- 	  the model is loaded with sequence configured and sequence switch is down
-- Spoken countdown with 1 second intervals

-- Safety
-- 	The script can affect critical flight controls through a mix.
-- 	The mix line must be set up with a switch to enable and disable it. Use the
--    same switch as the sequence trigger switch.
--  If the script cause any unwanted behaviour the mix can be disabled using
--    the assigned switch.

-- What happens if a sequence is interrupted and is selected to restart?
-- 	The delay timer is reset and the sequence starts again from the beginning. 
--  If during the delay a problem is noticed the sequence can be stopped and
--    restarted from the beginning

-- Tx Configuration

-- CUSTOM SCRIPTS Screen
-- Select this script and configure inputs.

-- MIXER Screen
-- Create one or more mixes using one of Seq1, Seq2, Seq3 as input.

-- Change as desired

-- Default values for configuration screen

local delaySeconds = 20 -- The delay in seconds between start and end values

local startValue1 = 60 -- Precent, the default values displayed when configuring
local startValue2 = 0
local startValue3 = 0

local endValue1 = 20 -- Precent, the default values displayed when configuring
local endValue2 = 0
local endValue3 = 0
-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Sound
local soundFilesPath = "/SCRIPTS/SOUNDS/Sqnc/"
local startFile = "start.wav"
local endFile = "end.wav"
local stopFile = "stop.wav"
local errorFile = "error.wav"
local startPlayed = false
local stopPlayed = false
local errorPlayed = false

local playedSeconds = 0;

-- Other
local debuging = true

local startTime = 0;

local function getTimeSeconds()
	-- Returns the number of miliseconds elapsed since the Tx was turned on
  -- Increments in 10 milisecond intervals
	-- getTime()
	-- Return the time since the radio was started in multiple of 10ms
	-- Number of 10ms ticks since the radio was started
  -- Example: run time: 12.54 seconds, return value: 1254
  return getTime()/100
end

local inputs = {
                 { "Switch", SOURCE },
                 { "Delay Sec.", VALUE, 0, 120, delaySeconds },
                 { "Start Val1", VALUE, -100, 100, startValue1 },
                 { "End Val1", VALUE, -100, 100, endValue1 },
                 { "Start Val2", VALUE, -100, 100, startValue2 },
                 { "End Val2", VALUE, -100, 100, endValue2 },
                 { "Start Val3", VALUE, -100, 100, startValue3 },
                 { "End Val3", VALUE, -100, 100, endValue3 }
               } -- Maximum of 10 characters will be displayed.

local outputs = { "Seq1", "Seq2", "Seq3" } -- Maximum 4 characters

local function run(switch, delay, start1, end1, start2, end2, start3, end3)
  --print("Switch ", switch, delay, start1, end1, start2, end2, start3, end3)

  if switch > 0 and startTime == 0 then -- Error, Script loaded with switch down
    if not errorPlayed then
      playFile(soundFilesPath..errorFile)
      errorPlayed = true
    end
    return start1*10.24, start2*10.24, start3*10.24
  elseif switch > 0 then -- Switch is down/towards, Countdown start
    if not startPlayed then -- Announce start, Play file only once
      playFile(soundFilesPath..startFile)
      startPlayed = true
      -- Add here to account for time to play file
      remainSeconds = delay - (getTimeSeconds() - startTime)
      playNumber(remainSeconds,0) -- 0 no units played
      playedSeconds = remainSeconds
    end
    remainSeconds = delay - (getTimeSeconds() - startTime)
    if remainSeconds > 0 then -- Countdown in progress
      if playedSeconds - remainSeconds >= 1 then -- Play value once every second
        playNumber(remainSeconds,0) -- 0 no units played
        playedSeconds = remainSeconds
      end
      return start1*10.24, start2*10.24, start3*10.24
    else -- Countdown ended
      if not stopPlayed then -- Announce end, Play file only once
        playFile(soundFilesPath..endFile)
        stopPlayed = true
      end
      return end1*10.24, end2*10.24, end3*10.24
    end
  else -- Countdown not started or has been interupted
    startTime = getTimeSeconds()
    if startPlayed and not stopPlayed then -- Countdown interrupted
      playFile(soundFilesPath..stopFile) -- Plays once
      startPlayed = false -- Reset variables
    elseif stopPlayed then -- Countdown completed
      startPlayed = false -- Reset variables
      stopPlayed = false
    end
    return start1*10.24, start2*10.24, start3*10.24
  end
end

return { input=inputs, output=outputs, run=run }
