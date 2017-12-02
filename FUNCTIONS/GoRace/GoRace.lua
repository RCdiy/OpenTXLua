-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- FUNCTIONS
--
-- File Locations On The Transmitter's SD Card
--  This script file  /SCRIPTS/FUNCTIONS/
-- 	Accompanying sound files /SCRIPTS/FUNCTIONS/GoRace/

-- Works On OpenTX Companion Version: 2.2

-- Author: Dean Church
-- Web: n/a

-- Thanks: Dean Church

-- Date: 2017 November 30
-- Update: 2017 December 2 RCdiy

-- Changes/Additions:
--  Removed debug code
--	Changed how switch position UP, Down, Middle is implemented
--  Removed seperate function calls; Rewrote run function.

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
--	Configure this script to run as a function script.
--	Select the switch "ON" as the switch and condition in the 1st column.
--		ON	Play Script	GoRace
local startRaceSwitch = "sf"	-- Triggers announcement
local startRaceSwitchPosition = "TOWARDS" 	-- Switch active position
																				--	"TOWARDS", "AWAY" or "MIDDLE"
local randomTimeMilliseconds = 5000		-- Maximum delay

local audioDir = "/SCRIPTS/FUNCTIONS/GoRace/" -- Location of script audio files
local raceStartPreface = audioDir.."GoRace.wav"	-- Prepare to race announcement
local startTone 		= audioDir.."RaceTone.wav"	-- Race start sound

-- AVOID EDITING BELOW HERE

local TITLE = "GoRace.lua"   -- .lua to start a race.
local DEBUG = false

-- local DOWN, MIDDLE, UP = 1024, 0, -1024  --Switch position DOWN/Toward, MIDDLE, UP/Away
if startRaceSwitchPosition == "TOWARDS" then startRaceSwitchPosition = 1024 end
if startRaceSwitchPosition == "MIDDLE" then startRaceSwitchPosition = 0 end
if startRaceSwitchPosition == "AWAY" then startRaceSwitchPosition = -1024 end

local startRaceSwitchID
local startRaceSwitchVal = 0
--local startTimeMilliseconds = 0
local raceStartPrefaceLengthMilliseconds = 8000	-- Time to play raceStartPreface in milliSeconds
local startTonePlayed = false

local targetTimeMilliseconds = 0
local presentTimeMilliseconds = 0
--local waitInProgress = false
local startSequenceReset = true


local function init()
	startRaceSwitchID	= getFieldInfo(startRaceSwitch).id --getTelemetryId(startRaceSwitch)
end	--init()

local function run()
	presentTimeMilliseconds = getTime()*10
	startRaceSwitchVal = getValue(startRaceSwitchID)
	if presentTimeMilliseconds > targetTimeMilliseconds then
		-- not in start sequence
		if startRaceSwitchPosition ==  startRaceSwitchVal and startSequenceReset == true then
			-- enter start sequence
			startSequenceReset = false
			startTonePlayed = false
			playFile(raceStartPreface)
			targetTimeMilliseconds = presentTimeMilliseconds +
																raceStartPrefaceLengthMilliseconds +
																math.random(100, randomTimeMilliseconds)
		end
	else
		-- in start sequence
		if startTonePlayed == false then
			playFile(startTone)
			startTonePlayed = true
		end
	end
	if startRaceSwitchPosition ~=  startRaceSwitchVal then
		--startTonePlayed = false
		startSequenceReset = true
		--targetTimeMilliseconds = 0
	end

end	-- run()

return { init=init, run=run }
--#############################################################################
