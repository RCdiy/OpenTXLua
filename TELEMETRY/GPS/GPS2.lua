-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
--
-- File Locations On The Transmitter's SD Card
--  This script file  /SCRIPTS/TELEMETRY/
--  Sound files       /SCRIPTS/TELEMETRY/GPS2/

-- Works On OpenTX Companion Version: 2.2
-- Works With Sensor: FrSky GPS

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:  Carbo (forum name) for requesting the ability to use 2 GPS sensors
--            and for german translations of the announcements
--          Painless360
--            http://painless360.webs.com/
--          GIS Map Info
--            http://www.igismap.com
--          Movable Type Scripts
--            http://www.movable-type.co.uk/scripts/latlong.html

-- Date: 2016 July 1
-- Update: 2017 April 17

-- Changes/Additions:
--  Supports up to 2 GPS sensors, attached to the Rx and Tx
--  Arrows are now drawn instead of using image files
--  New announcements

-- To do:
--  Directions relative to a compass on the Tx
--  Write to custom sensors trips, distance

-- Description
--
-- Reads coordinates from up to 2 GPS sensors
--  One GPS on the aircraft and an optional GPS on the Tx (Pilot-Home position)
--  When only one GPS is used the Pilot-Home position is set to where the GPS
--    strats reporting coordinates or when telemetry is reset. This is usually
--    the flying field's location.
-- Reads optional altitude and speed sensors
--  These sensors are used for return home announcements
--
-- Displays a number of parameters all of which are optional
--  Distance between the pilot and aircraft
--  Accumulated trip distance of the pilot and aircraft
--    Distances are in meters and kilometers
--  Headings of the pilot and aircraft
--  Direction from the pilot to the aircraft, the "Find" direction
--    Headings and directions are arrows relative to North
--  Direction from the aircraft to the pilot, the "Home" direction
--    This if off by default;
--  Direction for the aircraft to "Turn" to return home
--    Turns are left and right arrows relative to straight up being don't turn
-- The number of arrows displayed depends on the transmitter's screen width
--  The Taranis X7 can display up to first 3 and the X9 series up to first 4
--  There is an option to force display of all arrows which is achieved
--    by making them smaller
--
-- Announces a number of Aircraft parameters to help return home
--  The announcements are controlled by configurable switches
--    The default is switch "sf" for all but can be controlled individually
--      and in groups
--  The announcements are periodic with the interval for each configurable
--  Distance from the pilot every 60 seconds
--  Heading every 60 seconds
--  Altitude every 10 seconds
--  Speed every 60 seconds
--  Turns every 15 seconds
--
--  A number of the announcements rely on custom sound files
--    Two text files have been provided to help generate these files
--      CSV file following the OpenTX format
--      PSV file following the TTSAutomate format
--    Languages supported by using the corresponding sound files provided
--      English (default)
--      German
--
-- Writes a number of Aircraft parameters to the transmitter's Global Variables
--  These are configurable and are off by default
--  The flight mode of the variables to use is configurable, zero by default
--  Heading
--  Find
--  Home
--  Turns with left being -ve and right being +ve
--  Distance from pilot
--  Accumulated trip distance
--    OpenTX global variables have a range of -1024 to 1024
--    When a distance exceeds 1024 the distance/10 is written
--    When distance/10 exceeds 1024 the distance/100 is written
--    When distance/100 exceeds 1024 no write takes place

-- Configurations
--  For help using telemetry scripts
--    http://rcdiy.ca/telemetry-scripts-getting-started/

-- Sensors
--  Locate sensor name(s) from the OpenTX TELEMETRY screen
-- Change as required
local AircraftGPSSensorName = "GPS" -- Aircraft GPS, attached to Rx
local PilotGPSSensorName = "GPS5" -- Optional Pilot GPS, attached to Tx

-- Optional Sensors
--  Set to "" for none/ignore
--  If the provided sensor name is not found it will be ignored
-- Change as required
local AircraftAltitudeSensorName = "GAlt"
local AircraftSpeedSensorName = "GSpd"
-- Units of the sensors as shown on the OpenTX TELEMETRY screen
--  Complete list https://opentx.gitbooks.io/opentx-2-2-lua-reference-guide/content/appendix/units.html
-- local AircraftAltitudeSensorUnits = 9 -- 9 UNIT_METERS, 10 UNIT_FEET
-- local AircraftSpeedSensorUnits = 7 -- 7 UNIT_KMH, 8 UNIT_MPH, 4 UNIT_KTS

-- Display Distance Text
--  Set to true or false
-- Change as desired
local DisplayDistancePilotToAircraft = true
local DisplayTripPilot = true -- only displays if PilotGPSSensorName is not ""
local DisplayTripAircraft = true

-- Display Heading and Direction Arrows
--  Set to true or false
--  The Taranis X7 can display up to 3 and the X9 series up to 4
-- Change as desired
local DisplayPilotHeading = true -- only displays if PilotGPSSensorName is not ""
local DisplayAircraftHeading = true
local DisplayDirectionFindPilotToAircraft = true
local DisplayDirectionHomeAircraftToPilot= false
local DisplayDirectionToTurnAircraftToComeHome = true -- suggest listening for turns

-- Force Display of Arrows
--  If you want to display all the arrows set to true
--  The arros will be smaller and text titles may get covered
local ForceDisplayofAllArrows = false

-- Announcements Using A Switch
--  Set to "" for none/ignore
--    X9 series switches "sa" to "sh"
--    X9E additinal switches  "si" to "sr"
--    X7 missing switch "se" and "sg"
--  Switch positions
--    "U", "M", "D","notU", "notM", "notD"
-- Change as desired
local AnnouncementsSwitchName = "sf"
local AnnouncementsSwitchPosition = "D"

-- Announcement Intervals
--  In seconds
--  If the Altitude or Speed sensors are set to none then there corresponding
--    announcements will not be made
-- Change as desired
local AnnounceAircraftDistanceToPilotSeconds = 60
local AnnounceAircraftHeadingSeconds = 60
local AnnounceAircraftAltitudeSeconds = 10
local AnnounceAircraftSpeedSeconds = 60
local AnnounceAircraftReturnHomeTurnsSeconds = 15

-- Announcements Files Path
local SoundFilesPath = "/SCRIPTS/TELEMETRY/GPS2/"

-- OpenTX Global Variables (Global to the model)
--  Set to true or false
-- Change as desired
local WriteAircraftHeadingToGV = false
local WriteFindAircraftDirectionToGV = false
local WriteAircraftDirectionHomeToGV = false
local WriteAircraftReturnToHomeTurnsToGV = false
local WritePilotToAircraftDistanceToGV = false
local WriteAircraftTripToGV = false

-- Do not make changes to this line
local GV = {[1] = 0, [2] = 1, [3] = 2,[4] = 3,[5] = 4,[6] = 5, [7] = 6, [8] = 7, [9] = 8}

-- Change as desired
local AircraftHeadingGV = GV[1] -- GV[1] is GV1 in OpenTX
local FindAircraftDirectionGV = GV[2]
local AircraftDirectionHomeGV = GV[3]
local AircraftReturnToHomeTurnsGV = GV[4]
local PilotToAircraftDistanceGV = GV[5]
local AircraftTripGV = GV[6]

-- Flight Mode To Use For Global Variables
--  0 to 8
-- Change as desired
local FlightMode = 0

-- GPS Sensor Accuracy
--  Locate GPS sensor accuracy form its documentation
--  Meters
-- Change as desired
local AircraftGPSSensorAccuracy = 2.5
local PilotGPSSensorAccuracy = 2.5

-- Update Filter
--  Distances and directions are updated when the GPS has moved a distance
--    greater than this value.
--  Meters
-- Change as desired
local AircraftGPSDistanceFilter = 6 * AircraftGPSSensorAccuracy
local PilotGPSDistanceFilter = 10 * PilotGPSSensorAccuracy

-- Skip these if you want all announcements controlled by the same switch
  local AnnounceDistancePilotToAircraftTxSwitch = {} -- ignore this one line
AnnounceDistancePilotToAircraftTxSwitch.Name = AnnouncementsSwitchName
AnnounceDistancePilotToAircraftTxSwitch.OnPosition = AnnouncementsSwitchPosition
  local AnnounceAircraftHeadingTxSwitch = {} -- ignore this one line
AnnounceAircraftHeadingTxSwitch.Name = AnnouncementsSwitchName
AnnounceAircraftHeadingTxSwitch.OnPosition = AnnouncementsSwitchPosition
  local AnnounceAircraftAltitudeTxSwitch = {} -- ignore this one line
AnnounceAircraftAltitudeTxSwitch.Name = AnnouncementsSwitchName
AnnounceAircraftAltitudeTxSwitch.OnPosition = AnnouncementsSwitchPosition
  local AnnounceAircraftSpeedTxSwitch = {} -- ignore this one line
AnnounceAircraftSpeedTxSwitch.Name = AnnouncementsSwitchName
AnnounceAircraftSpeedTxSwitch.OnPosition = AnnouncementsSwitchPosition
  local AnnounceAircraftReturnHomeTurnsTxSwitch = {} -- ignore this one line
AnnounceAircraftReturnHomeTurnsTxSwitch.Name = AnnouncementsSwitchName
AnnounceAircraftReturnHomeTurnsTxSwitch.OnPosition = AnnouncementsSwitchPosition

-- Extra Information
-- Updates take place when the distance between two reads exceeds a set distance filter
--  If the GPS accuracy is 2.5m then the previous and current position
--  must be greater than 2.5 meters x 6 = 15 meter for updates to take place
-- When stationary or moving very slowly GPS accuracy limitation causes heading
--  and distance variations that lead to inacurate calculations.
--  A distance filter reduces inaccuracies in calculation involving accumulated
--    distance calculations. Reduces accumulated errors.

-- Directions in 1 of 16 compass rose directions
--  N, NNE, NE, ENE as 0, 23, 45, 68
--  E, ESE, SE,SSE as 90, 113, 135, 158
--  S, SSW, SW, WSW as 180, 203, 225, 248
--  W, WNW, NW, NNW as 270, 293, 315, 338

-- Home Turn directions in 1 of 10 degree amounts and 1 of 2 turn directions
--  -ve for left and +ve for right
--  -23, -45, -90, -135, 0, 23, 45, 90, 135, 180

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Sensors
local AircraftGPSSensorId       -- updated in init_func
local PilotGPSSensorId          -- updated in init_func
local AircraftAltitudeSensorId  -- updated in init_func
local AircraftSpeedSensorId     -- updated in init_func
local AircraftAltitudeSensorUnits  -- updated in init_func
local AircraftSpeedSensorUnits     -- updated in init_func

-- Display
local fontSize = 9
local lcdXpos           -- updated in run_func
local lcdXposNext       -- updated in run_func
local LCDyPos = 1       -- updated in run_func

-- Arrows Rx/Aircraft
local ArrowSize = 36        -- updated in displayAircraftArrow, displayPilotArrow
local rxArrowTailAngle = 120  -- arrow shape, 90 degrees, arrow is a triangle
local rxArrowThickness = 4    -- fills in arrow

-- Arrows Tx/Pilot
local txArrowTailAngle = rxArrowTailAngle
local txArrowThickness = 10

-- Direction Rx/Aricraft
local rxDirCurDeg     -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxFindDirDeg    -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxToTxDirDeg    -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxToTxTurnLRDeg -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections

-- Direction Tx/Pilot
local txDirCurDeg -- updated in zeroAllDistancesDirections, updateAlltxDistancesDirections

-- Directions Rx/Aricraft in 1 of 16 positions compass rose angles
local rxFindDir16Deg  -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxToTxDir16Deg  -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxToTxTurnLR16Deg -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections

-- GPS Rx/Aricraft
local rxGPSTable      -- updated in updateGPSData
local rxLat           -- updated in updateGPSData
local rxLon           -- updated in updateGPSData
local rxLatPrevious   -- updated in updateGPSData, updateAllrxDistancesDirections
local rxLonPrevious   -- updated in updateGPSData, updateAllrxDistancesDirections
local rxLatAtReset    -- updated in updateGPSData
local rxLonAtReset    -- updated in updateGPSData

-- GPS Tx/Home
local txGPSTable      -- updated in updateGPSData
local txLat           -- updated in updateGPSData
local txLon           -- updated in updateGPSData
local txLatPrevious   -- updated in updateGPSData, updateAlltxDistancesDirections
local txLonPrevious   -- updated in updateGPSData, updateAlltxDistancesDirections
local txLatAtReset    -- updated in updateGPSData
local txLonAtReset    -- updated in updateGPSData

-- Distance Rx/Aricraft
local rxMoved         -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections
local tx_rxDistance   -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections, updateAlltxDistancesDirections
local rxTrip          -- updated in zeroAllDistancesDirections, updateAllrxDistancesDirections
-- Distance Tx/Pilot
local txMoved   -- updated in zeroAllDistancesDirections, updateAlltxDistancesDirections
local txTrip    -- updated in zeroAllDistancesDirections, updateAlltxDistancesDirections

-- Announcements
local timeSecondsCurrent                -- updated in bg_func
local timeSecondsDifference             -- updated in bg_func
local timeSecondsAnnouncedDistance = 0   -- updated in bg_func
local timeSecondsAnnouncedHeading = 0   -- updated in bg_func
local timeSecondsAnnouncedSpeed = 0     -- updated in bg_func
local timeSecondsAnnouncedAltitude = 0  -- updated in bg_func
local timeSecondsAnnouncedTurn = 0      -- updated in bg_func

local Debugging = false
local DebuggingCounter = 0
local DebuggingSkip = 10

-- Diections is 1 of 16 Compose Rose Angles
local CompassRose16Table = {  [0] = "N", [1] = "NNE", [2] = "NE", [3] = "ENE",
                              [4] = "E", [5] = "ESE" , [6] = "SE", [7] = "SSE",
                              [8] = "S", [9] = "SSW", [10] = "SW", [11] = "WSW",
                              [12] = "W", [13] = "WNW", [14] = "NW", [15] = "NNW"
                            }

-- *** This is used to access the Turn sound files
-- *** Want to rewrite associated code ***
--  In the future new file names could be used and updated here
--  There are fewer than 16 direction files because because relative directions
--  are being provided and getting an aircraft to turn exactly is beyond many
--  pilot's flying skills.
local TurnsLR16FileName = { [0] = "R0.wav" , [23] = "R23.wav", [45] = "R45.wav", [68] = "R45.wav",
                                [90] = "R90.wav", [113] = "R135.wav", [135] = "R135.wav", [158] = "R180.wav",
                                [180] = "R180.wav",
                                [-158] = "L135.wav", [-135] = "L135.wav", [-113] = "L135.wav",
                                [-90] = "L90.wav", [-68] = "L45.wav",[-45] = "L45.wav", [-23] = "L23.wav"
                              }

local function getSwitchStatus(switch)
  -- Evaluates switch position settings
  -- Returns true or false
  if switch.Id ~= "" then
    position = getValue(switch.Id)
    if (switch.OnPosition == "U") and (position < 0) then
      return true
    elseif  (switch.OnPosition == "M") and (position == 0) then
      return true
    elseif  (switch.OnPosition == "D") and (position > 0) then
      return true
    elseif  (switch.OnPosition == "notU") and not (position < 0) then
      return true
    elseif  (switch.OnPosition == "notM") and not (position == 0) then
      return true
    elseif  (switch.OnPosition == "notD") and not (position > 0) then
      return true
    else
      return fasle
    end
  else
    return false
  end
end

-- Used for printing to debugging console
local function limitDecimalPlaces( num, decimals)
  -- Returns the number with up to the requested number of decimal places
  -- Used for print statements; Not to be used in any calculations
  -- 123.98765 , 3
  -- 987.988
  if num == nil then
    return num
  end
  return math.floor((num * 10^decimals)+0.5) / 10^decimals
end

local function printToDebugConsoleAllDistancesDirections()
      print(
            "txLat "..txLat.." txLon "..txLon.." rxLat "..rxLat.." rxLon "..rxLon,
            "rxGPSTable pilot-lat "..rxGPSTable["pilot-lat"].." rxGPSTable pilot-lon "..rxGPSTable["pilot-lon"],
            "txDirCurDeg "..limitDecimalPlaces(txDirCurDeg,2).." rxDirCurDeg "..limitDecimalPlaces(rxDirCurDeg,2),
            "rxFindDirDeg "..limitDecimalPlaces(rxFindDirDeg,2),
            "rxFindDir16Deg "..rxFindDir16Deg.." rxToTxDirDeg "..limitDecimalPlaces(rxToTxDirDeg,2),
            "rxToTxDir16Deg "..rxToTxDir16Deg.."rxToTxTurnLRDeg "..limitDecimalPlaces(rxToTxTurnLRDeg,2),
            "rxToTxTurnLR16Deg "..rxToTxTurnLR16Deg.." tx_rxDistance "..tx_rxDistance,
            "rxMoved "..rxMoved.." rxTrip "..rxTrip.." txMoved "..txMoved.." txTrip "..txTrip
          )
end

-- Used when telemetry has been reset and model loaded
local function zeroAllDistancesDirections()
  -- Direction Rx/Aricraft
  rxDirCurDeg = 0
  rxFindDirDeg = 0
  rxToTxDirDeg = 0
  rxToTxTurnLRDeg = 0
  -- Direction Tx/Pilot
  txDirCurDeg = 0

  -- Directions Rx/Aricraft in 1 of 16 positions compass rose angles
  rxFindDir16Deg = 0
  rxToTxDir16Deg = 0
  rxToTxTurnLR16Deg = 0

  -- Distance Rx/Aricraft
  rxMoved = 0
  tx_rxDistance = 0
  rxTrip = 0
  -- Distance Tx/Pilot
  txMoved = 0
  txTrip = 0
end

local function getMetersBetweenCoordinates(Lat1, Lon1, Lat2, Lon2)
  -- Returns distance in meters between two GPS positions
  -- Latitude and Longitude in decimal degrees
  -- E.g. 40.1234, -75.4523342
  -- http://www.movable-type.co.uk/scripts/latlong.html
  R = 6371 * 10^3 -- radius of the earth in metres (meter)
  Phi1 = math.rad(Lat1)
  Phi2 = math.rad(Lat2)
  dPhi = math.rad(Lat2-Lat1)
  dLambda = math.rad(Lon2-Lon1)
  a = math.sin(dPhi/2)^2 + math.cos(Phi1) * math.cos(Phi2) * math.sin(dLambda/2)^2
  c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))

  distance = R * c
  return distance
end

local function getDegreesBetweenCoordinates(LatFrom, LonFrom, LatTo, LonTo)
  -- Returns the angle in degrees between two GPS positions
  -- Latitude and Longitude in decimal degrees
  -- E.g. 40.1234, -75.4523342
  -- http://www.igismap.com/formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
  -- A: LatFrom, LonFrom
  -- B: LatTo, LonTo
  --LatFrom = 39.099912
  --LonFrom = -94.581213
  --LatTo = 38.627089
  --LonTo = -90.200203
  -- correct answer is X  = 0.05967668696, Y = -0.00681261948, β = 96.51°
  X =  math.cos(math.rad(LatTo)) * math.sin(math.rad(LonTo-LonFrom))

  Y = (math.cos(math.rad(LatFrom)) * math.sin(math.rad(LatTo))) - (
  math.sin(math.rad(LatFrom)) * math.cos(math.rad(LatTo)) * math.cos(math.rad(LonTo-LonFrom)))

  Bearing = math.deg(math.atan2(math.rad(X), math.rad(Y)))

  if Bearing < 0 then
    return 360 + Bearing
  else
    return Bearing
  end
end

-- *** Want to rewrite code ***
local function getCompassDirection16Degrees(degrees)
  -- Converts degrees to 1 of 16 compass rose directions
  -- degrees must be positive and less than equal to 360

  if degrees >= 0 then
    if degrees < 11.25 then
      return 0
    elseif degrees < 33.75 then
      return 23
    elseif degrees < 56.25 then
      return 45
    elseif degrees < 78.75 then
      return 68
    elseif degrees < 101.25 then
      return 90
    elseif degrees < 123.75 then
      return 113
    elseif degrees < 146.25 then
      return 135
    elseif degrees < 168.75 then
      return 158
    elseif degrees < 191.25 then
      return 180
    elseif degrees < 213.75 then
      return 203
    elseif degrees < 236.25 then
      return 225
    elseif degrees < 258.75 then
      return 248
    elseif degrees < 281.25 then
      return 270
    elseif degrees < 303.75 then
      return 293
    elseif degrees < 326.25 then
      return 315
    elseif degrees < 348.75 then
      return 338
    elseif degrees <= 360 then
      return 0
    elseif Debugging == true then
      print("getCompassDirection16Degrees(): ERROR")
      return error
    end
  end
end

local function getTurnAmountLR16Degrees(degrees)
  -- Returns turn degrees in 1 of 16 angles, -ve for left and +ve for right
  -- Based on the 16 compass rose direction angles
  -- 0, 23, 45, 68, 90, 113, 135, 158, 180
  -- -23, -45, -68, -90, -113, -135, -158
  -- (biased to turning right, fix??)

  if math.abs(degrees) > 360  then return "err" end

  if degrees< 0 then
    -- turn left but make sure not past -180
    if degrees <= -168.75 then
      -- turn right, +ve
      return getCompassDirection16Degrees(360+degrees)
    else -- > --168.75 and < 0
      -- turn left, -ve
      -- convert to +ve, get direction16, convert back to -ve
      return -getCompassDirection16Degrees(-degrees)
    end
  else
    -- turn right but make sure not larger than 180
    if degrees > 180 then
      -- turn left, -ve
      return -getCompassDirection16Degrees(360-degrees)
    else -- <= 180 and >= 0
      -- turn right, +ve
      return getCompassDirection16Degrees(degrees)
    end
  end
end

-- *** Want to move filter check here
local function updateAllrxDistancesDirections()
  -- Direction
  rxDirCurDeg = getDegreesBetweenCoordinates(rxLatPrevious, rxLonPrevious, rxLat, rxLon)
  rxFindDirDeg = getDegreesBetweenCoordinates(txLat, txLon, rxLat, rxLon)
  rxToTxDirDeg = (rxFindDirDeg + 180)%360
  rxToTxTurnLRDeg = rxToTxDirDeg - rxDirCurDeg

  -- Directions in 1 of 16 positions compass rose angles
  rxFindDir16Deg = getCompassDirection16Degrees(rxFindDirDeg)
  rxToTxDir16Deg = getCompassDirection16Degrees(rxToTxDirDeg)
  rxToTxTurnLR16Deg = getTurnAmountLR16Degrees(rxToTxTurnLRDeg)

  -- Distances
  rxMoved = getMetersBetweenCoordinates(rxLatPrevious, rxLonPrevious, rxLat, rxLon)
  tx_rxDistance = getMetersBetweenCoordinates(txLat, txLon, rxLat, rxLon)
  rxTrip = rxTrip + rxMoved
    -- Once discance and directions using current and previous positons have been updated
    -- a repeated call for an update should only update distances if current position has changed
    rxLatPrevious = rxLat
    rxLonPrevious = rxLon
end

-- *** Want to move filter check here
local function updateAlltxDistancesDirections()
  -- Update all variables related to txGPS Lat & Lon
  -- Direction
  --rxDirCurDeg = getDegreesBetweenCoordinates(rxLatPrevious, rxLonPrevious, rxLat, rxLon)
  txDirCurDeg = getDegreesBetweenCoordinates(txLatPrevious, txLonPrevious, txLat, txLon)
  rxFindDirDeg = getDegreesBetweenCoordinates(txLat, txLon, rxLat, rxLon)
  rxToTxDirDeg = (rxFindDirDeg + 180)%360
  rxToTxTurnLRDeg = rxToTxDirDeg - rxDirCurDeg

  -- Directions in 1 of 16 positions compass rose angles
  rxFindDir16Deg = getCompassDirection16Degrees(rxFindDirDeg)
  rxToTxDir16Deg = getCompassDirection16Degrees(rxToTxDirDeg)
  rxToTxTurnLR16Deg = getTurnAmountLR16Degrees(rxToTxTurnLRDeg)

  -- Distances
  txMoved = getMetersBetweenCoordinates(txLatPrevious, txLonPrevious, txLat, txLon)
  tx_rxDistance = getMetersBetweenCoordinates(txLat, txLon, rxLat, rxLon)
  txTrip = txTrip + txMoved
    -- Once discance and directions using current and previous positons have been updated
    -- a repeated call for an update should only update distances if current position has changed
    txLatPrevious = txLat
    txLonPrevious = txLon
end

-- *** Want to rewrite this from scratch
local function updateGPSData()
  -- Updates GPS Data
  -- Return true if success, else false
  -- Update rxLat, rxLon and zero distances and directions
  -- If single GPS Only when telemetry has been reset update
  -- txLat, txLon, rxLatPrevious, rxLonPrevious
  -- else always update them.

  -- Aircraft GPS required
  if AircraftGPSSensorId ~= nil then
    rxGPSTable = getValue(AircraftGPSSensorId)
  end
  if PilotGPSSensorName ~= "" then -- Two GPS case
    if PilotGPSSensorId ~= nil then
      txGPSTable = getValue(PilotGPSSensorId)
    end
    if type(txGPSTable) == "table" then
        -- Telemetry reset check
        if (txLatAtReset ~= txGPSTable["pilot-lat"])
        or (txLonAtReset ~= txGPSTable["pilot-lon"]) then
          txLatAtReset = txGPSTable["pilot-lat"]
          txLonAtReset = txGPSTable["pilot-lon"]
          txLatPrevious = txLatAtReset
          txLonPrevious = txLonAtReset
          zeroAllDistancesDirections()
        end
      txLat = txGPSTable["lat"]
      txLon = txGPSTable["lon"]
    end
    if type(rxGPSTable) == "table" then
        -- Telemetry reset check
        if (rxLatAtReset ~= rxGPSTable["pilot-lat"])
        or (rxLonAtReset ~= rxGPSTable["pilot-lon"]) then
          rxLatAtReset = rxGPSTable["pilot-lat"]
          rxLonAtReset = rxGPSTable["pilot-lon"]
          rxLatPrevious = rxLatAtReset
          rxLonPrevious = rxLonAtReset
          zeroAllDistancesDirections()
        end
      rxLat = rxGPSTable["lat"]
      rxLon = rxGPSTable["lon"]
      -- *** hmm, needs to be un-nested
      -- Return true if both updated
      if (type(txGPSTable) == "table") and (type(rxGPSTable) == "table") then
        return true
      else
        return false
      end
    end
  else -- Single GPS
    if type(rxGPSTable) == "table" then
      -- Telemetry reset check
      if (txLat ~= rxGPSTable["pilot-lat"])
      or (txLon ~= rxGPSTable["pilot-lon"]) then
        txLat = rxGPSTable["pilot-lat"]
        txLon = rxGPSTable["pilot-lon"]
        rxLatPrevious = txLat
        rxLonPrevious = txLon
        zeroAllDistancesDirections()
      end
      rxLat = rxGPSTable["lat"]
      rxLon = rxGPSTable["lon"]
      return true
    else
      return false
    end
  end
end

local function displayArrowDegrees(x, y, directionDeg, size, tailAngle, thickness, labelType)
  -- Displays an image corresponding to the direction provided
  -- x,y - center position
  -- directionDeg, angle in degrees, zero points North, 90 East
  -- size - divide by 2 is radius, distance from center to tip
  -- tailAngle - shape, position of trail ends relative to tip
  -- A tail angle of 90 degrees produces an arrow looking like a triangle.
  -- A tail angle of 120 degrees produces an arrow with the trailing points
  -- swept back.
  -- thickness - a thickness equal to half the size produces a filled in arrow.
  -- labelType - "","NSEW","LR"
  local r = size/2
  local dirRadians = math.rad(directionDeg)
  local tailRadians = math.rad(tailAngle)
  local x0, y0, x1, y1, x2, y2, x3, y3, count = 0, 0, 0, 0, 0, 0, 0, 0, 0
  while thickness > 0 do
    x0 = x + (count * math.sin(dirRadians)) -- move center for thickness
    y0 = y - (count * math.cos(dirRadians))
    x1 = x + (r * math.sin(dirRadians)) -- tip
    y1 = y - (r * math.cos(dirRadians))
    x2 = x + (r * math.sin(dirRadians+tailRadians)) -- tail
    y2 = y - (r * math.cos(dirRadians+tailRadians))
    x3 = x + (r * math.sin(dirRadians-tailRadians)) -- tail
    y3 = y - (r * math.cos(dirRadians-tailRadians))
    -- lcd.drawLine(x, y, x1, y1, SOLID, FORCE) -- center to tip, direction line
    lcd.drawLine(x0, y0, x2, y2, SOLID, FORCE) -- center to tail
    lcd.drawLine(x0, y0, x3, y3, SOLID, FORCE) -- center to tail
    lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE) -- tip to tail
    lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE) -- tip to tail
    thickness = thickness - 1
    r = r - 1
    count = count + 1
  end
  if labelType == "NSEW" then -- Display N, E, S, W, NNE, NW and so on
    local direction16Text = CompassRose16Table[math.floor((directionDeg/22.5) +0.5)]
    if type(direction16Text) == "string" then
      -- x1 = x1 - (string.len(direction16Text)*2) -- center text
      -- lcd.drawText(x1,y1, direction16Text, SMLSIZE + INVERS)
      x1 = x - (string.len(direction16Text)*2) -- center text
      y1 = y - 3
      lcd.drawText(x1,y, direction16Text, SMLSIZE + INVERS)
    end
  elseif  labelType == "LR" then -- Display Left,Right
    if directionDeg < 0 then
      local direction16Text = "L"
      x1 = x - (string.len(direction16Text)*2) -- center text
      y1 = y - 3
      lcd.drawText(x1,y, direction16Text, SMLSIZE + INVERS)
    elseif directionDeg > 0 then
      local direction16Text = "R"
      x1 = x - (string.len(direction16Text)*2) -- center text
      y1 = y - 3
      lcd.drawText(x1,y, direction16Text, SMLSIZE + INVERS)
    else
      local direction16Text = "0"
      x1 = x - (string.len(direction16Text)*2) -- center text
      y1 = y - 3
      lcd.drawText(x1,y, direction16Text, SMLSIZE + INVERS)
    end
  end
end

local function displayAircraftArrow(x, y, title, fontFlags, fontH, deg, labelType)
  --local xNext = x + ArrowSize/2
  if x + ArrowSize < LCD_W then
    lcd.drawText( x, y, title, fontFlags)
    x = x + ArrowSize/2
    displayArrowDegrees(x, y + fontH + ArrowSize/2 ,
       deg, ArrowSize, rxArrowTailAngle, rxArrowThickness, labelType)
  elseif ForceDisplayofAllArrows then
    ArrowSize = ArrowSize - 1
  end
  return x + ArrowSize/2
end

local function displayPilotArrow(x, y, title, fontFlags, fontH, deg, labelType)
  --local xNext = x + ArrowSize/2
  if x + ArrowSize < LCD_W then
    lcd.drawText( x, y, title, fontFlags)
    x = x + ArrowSize/2
    displayArrowDegrees(x, y + fontH + ArrowSize/2 ,
       deg, ArrowSize, txArrowTailAngle, txArrowThickness, labelType)
  elseif ForceDisplayofAllArrows then
    ArrowSize = ArrowSize - 1
  end
  return x + ArrowSize/2
end

local function writeOpenTXGVariablesIfTrue()
  if WriteAircraftHeadingToGV == true then
    model.setGlobalVariable(AircraftHeadingGV, FlightMode, rxDirCurDeg)
  end
  if WriteFindAircraftDirectionToGV == true then
     model.setGlobalVariable(FindAircraftDirectionGV, 0, rxFindDir16Deg)
  end
  if WriteAircraftDirectionHomeToGV == true then
    model.setGlobalVariable(AircraftDirectionHomeGV, FlightMode, rxToTxDir16Deg)
  end
  if WriteAircraftReturnToHomeTurnsToGV == true then
    model.setGlobalVariable(AircraftReturnToHomeTurnsGV, FlightMode, rxToTxTurnLR16Deg)
  end
  if WritePilotToAircraftDistanceToGV == true then
    if tx_rxDistance <= 1000 then
      model.setGlobalVariable(PilotToAircraftDistanceGV, FlightMode, math.floor(tx_rxDistance) )
    elseif (tx_rxDistance/10) <= 1000 then
      model.setGlobalVariable(PilotToAircraftDistanceGV, FlightMode, math.floor(tx_rxDistance/10) )
    elseif (tx_rxDistance/100) <= 1000 then
      model.setGlobalVariable(PilotToAircraftDistanceGV, FlightMode, math.floor(tx_rxDistance/100) )
    end
  end
  if WriteAircraftTripToGV == true then
    if rxTrip <= 1000 then
      model.setGlobalVariable(AircraftTripGV, FlightMode, math.floor(rxTrip) )
    elseif (rxTrip/10) <= 1000 then
      model.setGlobalVariable(AircraftTripGV, FlightMode, math.floor(rxTrip/10) )
    elseif (rxTrip/100) <= 1000 then
      model.setGlobalVariable(AircraftTripGV, FlightMode, math.floor(rxTrip/100) )
    end
  end
end

local function playHeading16Degrees(degrees)
  -- Plays a heading sound file corresponding to the direction provided
  --  degrees is converted to 1 of 16 compass rose deadings
  headingFile = "H"..CompassRose16Table[math.floor((degrees/22.5) +0.5)]..".wav"
  if headingFile ~= nil then
    headingFile = SoundFilesPath..headingFile
    playFile(headingFile)
  end
end

local function playTurnLR16Degrees(degreeLR16)
  -- Plays a direction to turn sound file corresponding to the direction provided
  -- degreeLR16 must be one of
  -- 0, 23, 45, 68, 90, 113, 135, 158, 180
  -- -23, -45, -68, -90, -113, -135, -158
  turnFile = TurnsLR16FileName[degreeLR16]
  if turnFile ~= nil then
    turnFile = SoundFilesPath..turnFile
    -- playFile(name)
    -- name is full path to sound file
    -- e.g. /SCRIPTS/SOUNDS/GPS/E.wave
    playFile(turnFile)
  elseif Debugging == true then
    print("playTurnLR16Degrees() turnFile == nil ", degreeLR16)
  end
end

local function AnnounceAircraftDistanceToPilot()
  if getSwitchStatus(AnnounceDistancePilotToAircraftTxSwitch) then
    timeSecondsCurrent = getTime()/100
    timeSecondsDifference = timeSecondsCurrent - timeSecondsAnnouncedDistance
    if timeSecondsDifference >= AnnounceAircraftDistanceToPilotSeconds then
      playFile(SoundFilesPath.."Dist.wav")
      playNumber(tx_rxDistance, 9) -- 9 UNIT_METERS,
      timeSecondsAnnouncedDistance = timeSecondsCurrent
    end
  else
      timeSecondsAnnouncedDistance = 0
  end
end

local function AnnounceAircraftHeading()
  if getSwitchStatus(AnnounceAircraftHeadingTxSwitch) then
    timeSecondsCurrent = getTime()/100
    timeSecondsDifference = timeSecondsCurrent - timeSecondsAnnouncedHeading
    if timeSecondsDifference >= AnnounceAircraftHeadingSeconds then
      playHeading16Degrees(rxDirCurDeg)
      timeSecondsAnnouncedHeading = timeSecondsCurrent
    end
  else
      timeSecondsAnnouncedHeading = 0
  end
end

local function AnnounceAircraftAltitude()
  if getSwitchStatus(AnnounceAircraftAltitudeTxSwitch) then
    timeSecondsCurrent = getTime()/100
    timeSecondsDifference = timeSecondsCurrent - timeSecondsAnnouncedAltitude
    if timeSecondsDifference >= AnnounceAircraftAltitudeSeconds then
      if AircraftAltitudeSensorId ~= nil then
        playFile(SoundFilesPath.."Alt.wav")
        playNumber(getValue(AircraftAltitudeSensorId), AircraftAltitudeSensorUnits)
        timeSecondsAnnouncedAltitude = timeSecondsCurrent
      end
    end
  else
      timeSecondsAnnouncedAltitude = 0
  end
end

local function AnnounceAircraftSpeed()
  if getSwitchStatus(AnnounceAircraftSpeedTxSwitch) then
    timeSecondsCurrent = getTime()/100
    timeSecondsDifference = timeSecondsCurrent - timeSecondsAnnouncedSpeed
    if timeSecondsDifference >= AnnounceAircraftSpeedSeconds then
      if AircraftSpeedSensorId ~= nil then
        playNumber(getValue(AircraftSpeedSensorId), AircraftSpeedSensorUnits)
        timeSecondsAnnouncedSpeed = timeSecondsCurrent
      end
    end
  else
      timeSecondsAnnouncedSpeed = 0
  end
end

local function AnnounceAircraftReturnHomeTurns()
  if getSwitchStatus(AnnounceAircraftReturnHomeTurnsTxSwitch) then
    timeSecondsCurrent = getTime()/100
    timeSecondsDifference = timeSecondsCurrent - timeSecondsAnnouncedTurn
    if timeSecondsDifference >= AnnounceAircraftReturnHomeTurnsSeconds then
      if AircraftSpeedSensorName ~= "" then
        playTurnLR16Degrees(rxToTxTurnLR16Deg)
        timeSecondsAnnouncedTurn = timeSecondsCurrent
      end
    end
  else
      timeSecondsAnnouncedTurn = 0
  end
end

local function getHasAircraftMoved()
  return getMetersBetweenCoordinates(rxLatPrevious, rxLonPrevious, rxLat, rxLon)
   > AircraftGPSDistanceFilter
end

local function getHasPilotMoved()
  return getMetersBetweenCoordinates(txLatPrevious, txLonPrevious, txLat, txLon)
      > PilotGPSDistanceFilter
end

local function getSensorId(sensorName)
  if getFieldInfo(sensorName) ~= nil then
    return getFieldInfo(sensorName).id
  end
  return nil
end

local function getSensorUnit(sensorName)
  if getFieldInfo(sensorName) ~= nil then
    return getFieldInfo(sensorName).unit
  end
  return 0
end

local function Debugging(message)
  if Debugging then
    print(message)
    if DebuggingCounter % DebuggingSkip == 0 then
      printToDebugConsoleAllDistancesDirections()
    end
    DebuggingCounter = DebuggingCounter + 1
  end
end

local function init_func()
  -- Called once when model is loaded
  AircraftGPSSensorId = getSensorId(AircraftGPSSensorName)
  PilotGPSSensorId = getSensorId(PilotGPSSensorName)
  AircraftAltitudeSensorId = getSensorId(AircraftAltitudeSensorName)
  AircraftSpeedSensorId = getSensorId(AircraftSpeedSensorName)
  AircraftAltitudeSensorUnits = getSensorUnit(AircraftAltitudeSensorName)
  AircraftSpeedSensorUnits = getSensorUnit(AircraftSpeedSensorName)

  AnnounceDistancePilotToAircraftTxSwitch.Id = getSensorId(AnnounceDistancePilotToAircraftTxSwitch.Name)
  AnnounceAircraftHeadingTxSwitch.Id = getSensorId(AnnounceAircraftHeadingTxSwitch.Name)
  AnnounceAircraftAltitudeTxSwitch.Id = getSensorId(AnnounceAircraftAltitudeTxSwitch.Name)
  AnnounceAircraftSpeedTxSwitch.Id = getSensorId(AnnounceAircraftSpeedTxSwitch.Name)
  AnnounceAircraftReturnHomeTurnsTxSwitch.Id = getSensorId(AnnounceAircraftReturnHomeTurnsTxSwitch.Name)

  zeroAllDistancesDirections()

  DisplayPilotHeading = DisplayPilotHeading and PilotGPSSensorName ~= ""
  DisplayTripPilot = DisplayTripPilot and PilotGPSSensorName ~= ""
end

local function bg_func()
  -- Called periodically when screen is not visible
  if updateGPSData() == true then
    -- Filter out inaccuracies due to sensor inaccuracies
    -- Without this trip, distances and directions are often inaccurate
    if getHasAircraftMoved() then
      updateAllrxDistancesDirections()
      writeOpenTXGVariablesIfTrue()
    end

    if  PilotGPSSensorName ~= "" and getHasPilotMoved() then
      updateAlltxDistancesDirections()
      writeOpenTXGVariablesIfTrue()
    end

    AnnounceAircraftDistanceToPilot()
    AnnounceAircraftHeading()
    AnnounceAircraftAltitude()
    AnnounceAircraftSpeed()
    AnnounceAircraftReturnHomeTurns()
  end
end

local function run_func(event)
  bg_func()
  lcd.clear()
  -- lcd.drawText(x, y, text [, flags])
  -- https://opentx.gitbooks.io/opentx-2-2-lua-reference-guide/content/lcd/drawText.html
  lcdXpos = 1
  LCDyPos = 1
  -- Check if Aircraft GPS sensor data is available
  if type(rxGPSTable) ~= "table" then
    lcd.drawText(lcdXpos, LCDyPos, AircraftGPSSensorName.." Sensor", INVERS)
    lcd.drawText( lcd.getLastPos()+1, LCDyPos, " Not Found!", BLINK)
    LCDyPos = LCDyPos + fontSize
  end
  -- If configured check if Pilot/Transmitter GPS sensor data is available
  if PilotGPSSensorName ~="" and type(txGPSTable) ~= "table" then
    lcd.drawText(lcdXpos, LCDyPos, PilotGPSSensorName.." Sensor", INVERS)
    lcd.drawText( lcd.getLastPos()+1, LCDyPos, " Not Found!", BLINK)
    LCDyPos = LCDyPos + fontSize
  end
  -- If configured check if Aircraft Altitude sensor data is available
  if AircraftAltitudeSensorName~= "" and AircraftAltitudeSensorId == nil then
    lcd.drawText(lcdXpos, LCDyPos, AircraftAltitudeSensorName.." Sensor", INVERS)
    lcd.drawText( lcd.getLastPos()+1, LCDyPos, " Not Found!", BLINK)
    LCDyPos = LCDyPos + fontSize
  end
  -- If configured check if Aircraft Speed sensor data is available
  if AircraftSpeedSensorName~= "" and AircraftSpeedSensorId == nil then
    lcd.drawText(lcdXpos, LCDyPos, AircraftSpeedSensorName.." Sensor", INVERS)
    lcd.drawText( lcd.getLastPos()+1, LCDyPos, " Not Found!", BLINK)
    LCDyPos = LCDyPos + fontSize
  end
  -- Display if Aircraft GPS sensor data is available
  if type(rxGPSTable) == "table" then

    if DisplayDistancePilotToAircraft == true then
      lcd.drawText( lcdXpos, LCDyPos, "Pilot to Aircraft", INVERS)
      if tx_rxDistance < 1000 then -- meters
        lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor(tx_rxDistance).."m")
      else -- kilometers
        lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor((tx_rxDistance/1000)+.05).."km")
      end
      LCDyPos = LCDyPos + fontSize
    end

    if DisplayTripPilot or DisplayTripAircraft then
      lcd.drawText( lcdXpos, LCDyPos, "Trip", INVERS)
    end

    if DisplayTripPilot then
      if type(txGPSTable) == "table" then
        lcd.drawText( lcd.getLastPos()+1, LCDyPos, "Plt", INVERS)
        if txTrip < 1000 then
          lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor(txTrip).."m")
        else
          lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor((txTrip/1000)+.5).."km")
        end
      end
    end

    if DisplayTripAircraft then
      lcd.drawText( lcd.getLastPos()+1, LCDyPos, "Acr", INVERS)
      if rxTrip < 1000 then
        lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor(rxTrip).."m")-- meters
      else
        lcd.drawText( lcd.getLastPos()+1, LCDyPos, math.floor((rxTrip/1000)+.5).."km")-- kilometers
      end
    end

    lcdXpos = 1
    LCDyPos = LCD_H - fontSize - ArrowSize -- want arrow bottom = LCD bottom

    if DisplayPilotHeading then
      lcdXpos = displayPilotArrow(lcdXpos, LCDyPos, "  Pilot ", INVERS, fontSize,
                                                            txDirCurDeg, "NSEW")
    end

    if DisplayDirectionFindPilotToAircraft then
      lcdXpos = displayPilotArrow(lcdXpos, LCDyPos, "  Find   ", INVERS, fontSize,
                                                            rxFindDirDeg, "NSEW")
    end

    if DisplayAircraftHeading then
      lcdXpos = displayAircraftArrow(lcdXpos, LCDyPos, "Arcrft", INVERS, fontSize,
                                                            rxDirCurDeg, "NSEW")
    end

    if DisplayDirectionHomeAircraftToPilot then
      lcdXpos = displayAircraftArrow(lcdXpos, LCDyPos, "  Home  ", INVERS, fontSize,
                                                            rxToTxDirDeg, "NSEW")
    end

    if DisplayDirectionToTurnAircraftToComeHome then
      lcdXpos = displayAircraftArrow(lcdXpos, LCDyPos, "  Turn  ", INVERS, fontSize,
                                                            rxToTxTurnLRDeg, "LR")
    end

  end

end



return { run=run_func, background=bg_func, init=init_func  }
