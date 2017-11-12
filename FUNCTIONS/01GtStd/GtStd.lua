-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- FUNCTIONS
-- Place this file in SD Card copy on your computer > /SCRIPTS/FUNCTIONS/<name>.lua

-- Works On OpenTX Companion Version: 2.2

-- Author: RC diy
-- Web: http://RCdiy.ca

-- Description
--  This is an introductory script to introduce some basics with regards to
--  executing a function script. This scripts announces the hours and minutes
--  since midnight.

-- Global OpenTX variables used
--  None

-- Global Lua environment variables used
--  None

-- Variables local to this script
--  must use the word "local" before the variable


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Avoid editing below here
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local timenow
local timenowSeconds
local hours
local minutes
local seconds
local secondsNext
local secondsGap

local function init()
  secondsNext = 0
  secondsGap = 2
end

local function run()

  timenow = getTime()
  timenowSeconds = math.floor(timenow/100) -- 10ms tick count
  seconds = timenowSeconds % 60

  minutes = getValue('clock') -- minutes since midnght
  hours = minutes/60
  minutes = minutes % 60

  -- delay to allow previous announcemenst to complete
  if timenowSeconds > secondsNext then
    secondsNext = timenowSeconds + secondsGap
    -- playNumber(hours, 24, 0)
    -- playNumber(minutes, 25, 0)
    playNumber(hours, 0)
    playNumber(minutes, 0)
  end
end

return { init=init, run=run }
