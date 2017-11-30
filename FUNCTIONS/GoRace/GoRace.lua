-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- FUNCTIONS
--
-- File Locations On The Transmitter's SD Card
--  This script file  /SCRIPTS/FUNCTIONS/

-- Works On OpenTX Companion Version: 2.2

-- Author: Dean Church
-- Web: n/a

-- Thanks: Dean Church

-- Date: 2017 November 30
-- Update: 2017 November 30 RCdiy

-- Changes/Additions:
--  Removed debug code
--	Changed how switch position UP, Down, Middle is implemented
--  Removed seperate function call for waitNowQue.

-- To do: n/a

-- Description
--
-- 	A race timer suitable for quad racing.
--  An announcement to get ready to race is made. After a random delay of
--  upto 5 seconds a start buzzer sound is made.

-- 	Race quads starting sequence
-- 		Racers
--			Place their quads on the start line and check to make sure their
--				quad 'arms' ( motors spool up). They then disarm.
-- 			Return to their seat, put on their goggles and wait for instructions.
-- 		Race Starter
--			Asks for a 'thumbs up' from racers when they are ready.
-- 			Instructs racers to arm their quads.
--   			(spool up motors but remain stationary at the start line)
--   			"Pilots arm your quads, we go live on the tone is less then five."
--   		After a delay of up to 5 seconds the start tone sounds.
-- 		Racers take off from the start line and begin to race.
-- 			https://youtu.be/2Y0zDKB0FaU

-- Configurations
--  For help using functions scripts
--    http://rcdiy.ca/getting-started-with-lua-function-scripts/

local startRaceSwitch = "sh"	-- Momentary switch recommended
local startRaceSwitchPosition = "TOWARDS" 	-- Switch active position
																				--	"TOWARDS", "AWAY" or "MIDDLE"
local randomTime = 5		-- Maximum delay is seconds

local audioDir = "/SCRIPTS/FUNCTIONS/GoRace/" -- Location of script audio files
local raceStartPreface = audioDir.."GoRace.wav"	-- Prepare to race announcement
local startTone 		= audioDir.."RaceTone.wav"	-- Race start sound

-- AVOID EDITING BELOW HERE

local TITLE = "GoRace.lua"   -- .lua to start a race.
local DEBUG = false
local startSwitchActivated = false

-- local DOWN, MIDDLE, UP = 1024, 0, -1024  --Switch position DOWN/Toward, MIDDLE, UP/Away
if startRaceSwitchPosition == "TOWARDS" then startRaceSwitchPosition = 1024 end
if startRaceSwitchPosition == "MIDDLE" then startRaceSwitchPosition = 0 end
if startRaceSwitchPosition == "AWAY" then startRaceSwitchPosition = -1024 end

local startRaceSwitchID
local startRaceSwitchVal = 0
local startTimeMilliseconds = 0
local raceStartPrefaceTime = 8000	-- Time to play raceStartPreface in milliSeconds

local targetTimeMilliSeconds = 0
local presentTimeMilliseconds = 0
local waitInProgress = false

--[[ ******************************************************************
to start Wait
startTheWait(waitTime)		- all in mililiSeconds
get present time 						= startTimeMilliseconds
add wait time to presentTime		= targetTimeMilliSeconds
show waiting. set waitInProgress	= true
--]]
local function setWaitMiliSeconds(waitTime)
	if waitInProgress == true then
		return	-- do not restart the wait if we are waiting now
	else
		startTimeMilliseconds = getTime()*10
		targetTimeMilliSeconds = waitTime + startTimeMilliseconds
		waitInProgress = true
	end
end



-- ***************************************************
-- Function: getTelemetryId
-- Parameters: name
-- Desc: Gets global id of telemetry field name requested
local function getTelemetryId(name)
  local field = getFieldInfo(name)
	if field then
		return field.id
	else
		return -1
	end
end--[[getTelemetryId]]

-- Wait for an elapsed time in miliSecond
local startTimeMilliseconds = 0
local targetTimeMilliSeconds = 0
local presentTimeMilliseconds = 0
local waitInProgress = false

--[[ ******************************************************************
to start Wait
startTheWait(waitTime)		- all in mililiSeconds
get present time 						= startTimeMilliseconds
add wait time to presentTime		= targetTimeMilliSeconds
show waiting. set waitInProgress	= true
--]]
local function setWaitMiliSeconds(waitTime)
	if waitInProgress == true then
		return
	else
		startTimeMilliseconds = getTime()*10
		targetTimeMilliSeconds = waitTime + startTimeMilliseconds
		waitInProgress = true
	end
end


--#############################################################################
local function init()

	startSwitchActivated = false
	startRaceSwitchID	= getTelemetryId(startRaceSwitch)
	startTimeMilliseconds = 0
	presentTimeMilliseconds = 0
	waitInProgress = false
end	--init()

--#############################################################################
--#############################################################################
--#############################################################################
--local playedRunOnce = false

local function run()
	local minutes
 	local seconds
 	local randomWait
 	local remaining

	if waitInProgress == false then -- check if start switch activated
		presentTimeMilliseconds = getTime()*10		--convert to milliseconds
		startRaceSwitchVal = getValue(startRaceSwitchID)
		if startRaceSwitchVal == startRaceSwitchPosition
		and startSwitchActivated == false	then
			startSwitchActivated = true -- ensures that file plays once
			playFile(raceStartPreface)
			startTimeMilliseconds = getTime()*10 -- tick count of 10ms each tick to seconds.
			randomWait = math.random(100, randomTime*1000)
			targetTimeMilliSeconds = presentTimeMilliseconds + raceStartPrefaceTime + randomWait
		end
	end

	if presentTimeMilliseconds > targetTimeMilliSeconds then
		waitInProgress = false
		if startRaceSwitchVal ~= startRaceSwitchPosition and startSwitchActivated == true then
			playFile(startTone)

			startSwitchActivated = false
		end
	else
		waitInProgress = true
		presentTimeMilliseconds = getTime()*10
	end
	if startRaceSwitchVal ~= startRaceSwitchPosition and startSwitchActivated == true then
		startSwitchActivated = false
	end

end	-- run()

return { init=init, run=run }
--#############################################################################
