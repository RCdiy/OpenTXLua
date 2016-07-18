-- OpenTx Lua script
-- TELEMETRY
-- Place this file in the SD Card folder on your computer
-- SD Card /SCRIPTS/TELEMETRY/
-- Place the accompanying image files in /SCRIPTS/BMP/GPS/
-- Place the accompanying sound files in /SCRIPTS/SOUND/GPS/

-- Works On OpenTx Companion Version: 2.1.8
-- Works With Sensor: FrSky GPS

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:  Painless360 
--            http://painless360.webs.com/
--          GIS Map Info 
--            http://www.igismap.com
--          Movable Type Scripts
--            http://www.movable-type.co.uk/scripts/latlong.html

-- Date: 2016 July 1
-- Update: 2016 July 18

-- Description

-- Reads GPS coordinates

-- Displays "Flying" / "Heading" direction
-- Displays "Find" direction from initial location to current location 
-- Displays "Home" direction from current location to initial location
-- Displays "Turn" turn angle to come home
-- Display of each is optional, on by default

-- Displays distance "Home" from initial location to current location along the ground
-- Displays "Trip", distance flown ground track, altitude not accounted for
-- "Trip" is the accumulated distance between GPS coordinates, distance flown ground track
-- Display of each is optional, on by default

-- Writes directions to OpenTx global variables 
-- Writes of each is optional, off by default 

-- Writes distances to OpenTx global variables 
-- Write of each is optional, off by default
-- OpenTx global variables have a range of -1024 to 1024
-- When a distance exceeds 1024 the distance/10 is written
-- When distance/10 exceeds 1024 the distance/100 is written
-- When distance/100 exceeds 1024 no write takes place

-- Speaks "Flying" direction of movement, must be moving
-- Speaks "Turn" turn direction to come home, up to 90 degrees
-- Speaking of each is optional, off by default
-- Speaing of each can be assigned to a switch
-- Interval between speaking is individually configurable, seconds

-- Initial (runway, pilot) location determined when TELEMETRY is Reset on the Tx

-- Updates take place when the distance between two reads exceeds a set distance filter
-- If the GPS accuracy is 2.5m then the previous and current position
-- must be greater than 2.5 meters x 6 = 15 meter for updates to take place
-- The filter value is configurable

-- Directions in 1 of 16 compass rose directions
-- N, NNE, NE, ENE as 0, 23, 45, 68
-- E, ESE, SE,SSE as 90, 113, 135, 158
-- S, SSW, SW, WSW as 180, 203, 225, 248
-- W, WNW, NW, NNW as 270, 293, 315, 338

-- Home Turn directions in 1 of 9 degree amounts and 1 of 2 turn directions
-- -ve for left and +ve for right
-- Based on compass rose angles
-- 0, 23, 45, 68, 90, 113, 135, 158, 180
-- -23, -45, -68, -90, -113, -135, -158


-- Note
-- The OpenTx global variables have a -1024 to 1024 limit.

-- Sensors 
-- GPS
-- Use GPS sensor name from OpenTx TELEMETRY screen
local GPSSensorName = "GPS" 

local SensorAccuracy = 2.5 -- meters GPS accuracy as per manual
local GPSDistanceFilter = 6 * SensorAccuracy -- suggest 5 to 7, reduces heading flutter, improves trip accuracy

-- Speak Switches
-- Change as desired
local SpeakHeading = false
local SpeakTurn = false

local SpeakHeadingUseTxSwitch = false -- if true here, SpeakHeading is ignored
local SpeakTurnUseTxSwitch = false -- if true here, SpeakTurn is ignored
  -- Tx switches "sa" to "sh"
  -- Tx X9E  "si" to "sr"
  -- Switch position
  -- "U", "M", "D","notU", "notM", "notD"
  -- U < 0, M = 0, D > 0
local SpeakHeadSwitch = "se"
local SpeakHeadSwitchPosition = "D"
local SpeakTurnSwitch = "se"
local SpeakTurnSwitchPosition = "D"

-- Speak Time Interval
local SpeakHeadSeconds = 30
local SpeakTurnSeconds = 15

-- Display
-- Change as desired
local DisplayDirectionCurrent = true
local DisplayDirectionFind = true
local DisplayDirectionHome = true
local DisplayDirectionHomeTurnLR = true
local DisplayDistanceHome = true
local DisplayTrip = true

-- Global OpenTx variables (Global to the model)
-- Change as desired
-- GV1 = "Flying" / "Heading"
-- GV2 = "Find" 
-- GV3 = "Home" 
-- GV4 = "Home Turn" 
-- If "Home Turn" is -ve then turn aircraft to its left
-- If "Home Turn" is +ve then turn aircraft to its right
-- GV5 = "Distance" 
-- GV6 = "Trip" 
local GV = {[1] = 0, [2] = 1, [3] = 2,[4] = 3,[5] = 4,[6] = 5, [7] = 6, [8] = 7, [9] = 8}

local GVDirectionHeading = GV[1] -- Location to write
local GVDirectionFind = GV[2]
local GVDirectionHome = GV[3]
local GVDirectionHomeTurnLR = GV[4]
local GVDistance = GV[5]
local GVTrip = GV[6]

local WriteGVDirectionHeading = false
local WriteGVDirectionFind = false
local WriteGVDirectionHome = false
local WriteGVDirectionHomeTurnLR = false
local WriteGVDistance = false
local WriteGVTrip = false

-- File Paths
-- location you placed the accompanying files
local ImageFilesPath = "/SCRIPTS/BMP/GPS/"
local SoundFilesPath = "/SCRIPTS/SOUNDS/GPS/"

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Display
local TextHeader = GPSSensorName.." Based Directions"

local ScreenXsize = 212
local ScreenYsize = 64

local ImageXsize = 40
local ImageYsize = 40

local ImageXpos = 0
local ImageYpos = ScreenYsize - ImageYsize
local ImageXmargin = 17

-- Direction
local DirectionCurrentDegrees = -1.0 -- Direction in degrees from 0.0 to 359.9
local DirectionFindDegrees = -1.0
local DirectionHomeDegrees = -1.0
local DirectionHomeTurnLRDegrees = -360

-- Directions in 1 of 16 positions compass rose angles
local DirectionCurrent16Degrees = -360
local DirectionFind16Degrees = -360
local DirectionHome16Degrees = -360
local DirectionHomeTurnLR16Degrees = -360

-- GPS
local GPSDataTable = nil
local GPSlatHome = 0.0
local GPSlonHome = 0.0
local GPSlat = 0.0
local GPSlon = 0.0
local GPSlatPrevious = 0.0
local GPSlonPrevious = 0.0

-- Diatance
local DistanceBetweenCoordinates = -1000
local DistanceToModel = -1000
local DistanceTrip = -1000

-- Time
local timeSecondsPreviousHead = 0.0
local timeSecondsPreviousTurn = 0.0
-- local timeSecondsDifference = 0.0


local Debuging = false

-- Diections is 1 of 16 Compose Rose Angles
local CompassRose16Table = {  [0] = "N", [23] = "NNE", [45] = "NE", [68] = "ENE",
                              [90] = "E", [113] = "ESE" , [135] = "SE", [158] = "SSE",
                              [180] = "S", [203] = "SSW", [225] = "SW", [248] = "WSW",
                              [270] = "W", [293] = "WNW", [315] = "NW", [338] = "NNW" 
                            }


-- This is used to access the Direction image files
-- In the future new file names could be used and updated here
local DisplayHeading16FileName = { [0] = "HN.bmp", [23] = "HNNE.bmp", [45] = "HNE.bmp", [68] = "HENE.bmp",
                                [90] = "HE.bmp", [113] = "HESE.bmp" , [135] = "HSE.bmp", [158] = "HSSE.bmp",
                                [180] = "HS.bmp", [203] = "HSSW.bmp", [225] = "HSW.bmp", [248] = "HWSW.bmp",
                                [270] = "HW.bmp", [293] = "HWNW.bmp", [315] = "HNW.bmp", [338] = "HNNW.bmp" 
                                }
-- This is used to access the Turn image files
-- In the future new file names could be used and updated here
local DisplayTurn16FileName = { [0] = "R0.bmp" , [23] = "R23.bmp", [45] = "R45.bmp", [68] = "R45.bmp", 
                                [90] = "R90.bmp", [113] = "R113.bmp", [135] = "R135.bmp", [158] = "R158.bmp", 
                                [180] = "R180.bmp", 
                                [-158] = "L158.bmp", [-135] = "L135.bmp", [-113] = "L135.bmp", 
                                [-90] = "L90.bmp", [-68] = "L68.bmp",[-45] = "L45.bmp", [-23] = "L23.bmp"
                
              }
-- This is used to access the Heading sound files
-- In the future new file names could be used and updated here
local SpeakHeading16FileName ={ [0] = "HN.wav", [23] = "HNNE.wav", [45] = "HNE.wav", [68] = "HENE.wav",
                                [90] = "HE.wav", [113] = "HESE.wav" , [135] = "HSE.wav", [158] = "HSSE.wav",
                                [180] = "HS.wav", [203] = "HSSW.wav", [225] = "HSW.wav", [248] = "HWSW.wav",
                                [270] = "HW.wav", [293] = "HWNW.wav", [315] = "HNW.wav", [338] = "HNNW.wav" 
                              }
-- This is used to access the Turn sound files
-- In the future new file names could be used and updated here
-- There are fewer than 16 direction files because because relative directions
-- are being provided and getting an aircraft to turn exactly is beyond many
-- pilot's flying skills.
local SpeakTurnLR16FileName = { [0] = "R0.wav" , [23] = "R23.wav", [45] = "R45.wav", [68] = "R45.wav", 
                                [90] = "R90.wav", [113] = "R135.wav", [135] = "R135.wav", [158] = "R180.wav", 
                                [180] = "R180.wav", 
                                [-158] = "L135.wav", [-135] = "L135.wav", [-113] = "L135.wav", 
                                [-90] = "L90.wav", [-68] = "L45.wav",[-45] = "L45.wav", [-23] = "L23.wav"
                              }



local function getSpeakHeadingStatus()
  -- Evaluates speak settings
  -- Returns true or false 
  if SpeakHeadingUseTxSwitch == true then
    -- "U", "M", "D","notU", "notM", "notD"
    position = getValue(SpeakHeadSwitch)
    if (SpeakHeadSwitchPosition == "U") and (position < 0) then
      return true
    elseif  (SpeakHeadSwitchPosition == "M") and (position == 0) then
      return true
    elseif  (SpeakHeadSwitchPosition == "D") and (position > 0) then
      return true
    elseif  (SpeakHeadSwitchPosition == "notU") and not (position < 0) then
      return true
        elseif  (SpeakHeadSwitchPosition == "notM") and not (position == 0) then
      return true
        elseif  (SpeakHeadSwitchPosition == "notD") and not (position > 0) then
      return true
    else
      return fasle
    end
  else
    return SpeakHeading
  end
end
local function getSpeakTurnStatus()
  -- Evaluates speak settings
  -- Returns true or false 
  if SpeakTurnUseTxSwitch == true then
    -- "U", "M", "D","notU", "notM", "notD"
    position = getValue(SpeakTurnSwitch)
    if (SpeakTurnSwitchPosition == "U") and (position < 0) then
      return true
    elseif  (SpeakTurnSwitchPosition == "M") and (position == 0) then
      return true
    elseif  (SpeakTurnSwitchPosition == "D") and (position > 0) then
      return true
    elseif  (SpeakTurnSwitchPosition == "notU") and not (position < 0) then
      return true
        elseif  (SpeakTurnSwitchPosition == "notM") and not (position == 0) then
      return true
        elseif  (SpeakTurnSwitchPosition == "notD") and not (position > 0) then
      return true
    else
      return fasle
    end
  else
    return SpeakTurn
  end
end
local function limitDecimalPlaces( num, decimals)
  -- Returns the number with up to the requested number of decimal places
  -- Used for print statements; Not used in any calculations
  -- 123.98765 , 3
  -- 987.987
  -- good enough for this application
  if num == nil then
    return num
  end
  a = num * 10^decimals
  b = math.floor(a)
  c = b / 10^decimals

  return c
end
local function printToDebugConsoleAllDistancesDirections()
      print(
            "Current", limitDecimalPlaces(DirectionCurrentDegrees,2), 
            "Current16", DirectionCurrent16Degrees,
            "Find", limitDecimalPlaces(DirectionFindDegrees,2), 
            "Find16", DirectionFind16Degrees,
            "Home", limitDecimalPlaces(DirectionHomeDegrees,2), 
            "Home16", DirectionHome16Degrees,
            "HomeLR", limitDecimalPlaces(DirectionHomeTurnLRDegrees,2), 
            "HomeLR16", DirectionHomeTurnLR16Degrees,
            "Between", DistanceBetweenCoordinates, "To", DistanceToModel, "Trip", DistanceTrip
          )
end

local function zeroAllDistancesDirections()
  -- Direction
  DirectionCurrentDegrees = 0
  DirectionFindDegrees = 0
  DirectionHomeDegrees = 0
  DirectionHomeTurnLRDegrees = 0

  -- Directions in 1 of 16 positions compass rose angles
  DirectionCurrent16Degrees = 0
  DirectionFind16Degrees = 0
  DirectionHome16Degrees = 0
  DirectionHomeTurnLR16Degrees = 0

  -- Diatance
  DistanceBetweenCoordinates = 0
  DistanceToModel = 0
  DistanceTrip = 0
end
local function getSecondsElapsedSince2016()
    -- Returns the number of seconds elapsed since this script started
    -- Accurate to a 1 second or greater interval
    -- getDateTime()
    -- Returns a table with Tx's current date and time 
    -- { [year] = 2016 , [mon] = 12, [day] = 28, [hour] = 23 , [min] = 59, [sec] = 59 }
    now = getDateTime()
    nowSeconds = now.sec + (now.min * 60) + (now.hour * 3600) + (now.day * 86400) + (now.mon * 2678400) +
              ( (2016-now.year) * 31622400 ) -- 31 days/month 365 days/year

    if Debuging == true then
      print("getDateTime", nowSeconds, now.sec, now.min, now.hour, now.day, now.mon, now.year)
    end
    
    return nowSeconds
end
local function getDistanceBetweenCoordinates(Lat1, Lon1, Lat2, Lon2)
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
    elseif Debuging == true then
      printToDebugConsoleAllDistancesDirections()
      return error
    end
  end
end
local function getCompassDirection16Table(degrees)
  -- Returns a table with 1 of 16 compass rose directions
  -- { "NNE", 23 }

  if degrees >= 0 then
    if degrees < 11.25 then
      return { "N", 0 }
    elseif degrees < 33.75 then
      return { "NNE", 23 }
    elseif degrees < 56.25 then
      return { "NE", 45 }  
    elseif degrees < 78.75 then
      return { "ENE", 68 }
    elseif degrees < 101.25 then
      return { "E", 90 }
    elseif degrees < 123.75 then
      return { "ESE", 113 }
    elseif degrees < 146.25 then
      return { "SE", 135 }
    elseif degrees < 168.75 then
      return { "SSE", 158 }
    elseif degrees < 191.25 then
      return { "S", 180 }
    elseif degrees < 213.75 then
      return { "SSW", 203 }
    elseif degrees < 236.25 then
      return { "SW", 225 }
    elseif degrees < 258.75 then
      return { "WSW", 248 }
    elseif degrees < 281.25 then
      return { "W", 270 }
    elseif degrees < 303.75 then
      return { "WNW", 293 }
    elseif degrees < 326.25 then
      return { "NW", 315 }
    elseif degrees < 348.75 then
      return { "NNW", 338 }
    else
      return {"err", degrees}
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
local function updateAllDistancesDirections()
  -- Direction
  DirectionCurrentDegrees = getDegreesBetweenCoordinates(GPSlatPrevious, GPSlonPrevious, GPSlat, GPSlon)
  DirectionFindDegrees = getDegreesBetweenCoordinates(GPSlatHome, GPSlonHome, GPSlat, GPSlon)
  DirectionHomeDegrees = (DirectionFindDegrees + 180)%360
  DirectionHomeTurnLRDegrees = DirectionHomeDegrees - DirectionCurrentDegrees

  -- Directions in 1 of 16 positions compass rose angles
  DirectionCurrent16Degrees = getCompassDirection16Degrees(DirectionCurrentDegrees) 
  DirectionFind16Degrees = getCompassDirection16Degrees(DirectionFindDegrees)
  DirectionHome16Degrees = getCompassDirection16Degrees(DirectionHomeDegrees)
  DirectionHomeTurnLR16Degrees = getTurnAmountLR16Degrees(DirectionHomeTurnLRDegrees)

  -- Diatance
  DistanceBetweenCoordinates = getDistanceBetweenCoordinates(GPSlatPrevious, GPSlonPrevious, GPSlat, GPSlon)
  DistanceToModel = getDistanceBetweenCoordinates(GPSlatHome, GPSlonHome, GPSlat, GPSlon)
  DistanceTrip = DistanceTrip + DistanceBetweenCoordinates
    -- Should I have these here?
    -- Once discance and directions using current and previous positons have been updated
    -- a repeated call for an update should only update distances if current position has changed
    GPSlatPrevious = GPSlat
    GPSlonPrevious = GPSlon
    if Debuging == true then
      printToDebugConsoleAllDistancesDirections()
    end
end
local function updateGPSData()
  -- Get GPS Data
  -- Return true if success, else false
  -- Update GPSlat, GPSlon, 
  -- Only when telemetry has been reset update 
  -- GPSlatHome, GPSlonHome, GPSlatPrevious, GPSlonPrevious
  -- and zero distances and directions
  
  -- getValue(source)
  -- Returns the value of a source.
  -- The list of valid sources is available:
  -- http://downloads-21.open-tx.org/firmware/lua_fields_taranis_x9e.txt
  -- To determine what whic data type was returned use type(anyValue)
  GPSDataTable = getValue(GPSSensorName)
  if type(GPSDataTable) == "table" then
    if (GPSlatHome ~= GPSDataTable["pilot-lat"]) or 
        (GPSlonHome ~= GPSDataTable["pilot-lon"]) then
      -- Telemetry has been reset
      GPSlatHome = GPSDataTable["pilot-lat"]
      GPSlonHome = GPSDataTable["pilot-lon"]
      GPSlatPrevious = GPSlatHome
      GPSlonPrevious = GPSlonHome
      zeroAllDistancesDirections()
    end
    GPSlat = GPSDataTable["lat"]
    GPSlon = GPSDataTable["lon"]
    return true
  else
    return false
  end

  -- This code has been left here for you to try
  -- for i,v in pairs(GPSDataTable) do print(i,v) end
  --  output
  --    pilot-lon	-91.152
  --    lon	      -91.152
  --    lat	      33.1042
  --    pilot-lat	33.1042
end
local function displayCompass16Degrees(degree16, X, Y)
  -- Displays an image corresponding to the direction provided
  -- X pixels from the left
  -- Y pixels from the top
  -- degree16 must be 1 of 16 compass rose angles
    directionFile = DisplayHeading16FileName[degree16]
  if directionFile ~= nil then
    directionFile = ImageFilesPath..directionFile
    -- lcd.drawPixmap(x, y, filename)
    -- Displays a bmp image
    -- file name is file name with path
    -- e.g. "/SCRIPTS/BMP/NNW.bmp"
    lcd.drawPixmap(X, Y, directionFile)
  elseif Debuging == true then
    print("displayCompass16Degrees", degree16)
    return error
  end
end
local function displayTurnLR16Degrees(degreeLR16, X, Y)
  -- Displays an image corresponding to the direction provided
  -- X pixels from the left
  -- Y pixels from the top
  -- degreeLR16 must be one of 
  -- 0, 23, 45, 68, 90, 113, 135, 158, 180
  -- -23, -45, -68, -90, -113, -135, -158
  directionFile = DisplayTurn16FileName[degreeLR16]
  if directionFile ~= nil then
    directionFile = ImageFilesPath..directionFile
    -- lcd.drawPixmap(x, y, filename)
    -- Displays a bmp image
    -- file name is file name with path
    -- e.g. "/SCRIPTS/BMP/NNW.bmp"
    lcd.drawPixmap(X, Y, directionFile)
  elseif Debuging == true then
    print("displayTurnLR16Degrees", degreeLR16)
    return error
  end
end

local function writeOpenTxGVariablesIfTrue()
  if WriteGVDirectionHeading == true then
    model.setGlobalVariable(GVDirectionHeading, 0, DirectionCurrent16Degrees)
  end
  if WriteGVDirectionFind == true then
     model.setGlobalVariable(GVDirectionFind, 0, DirectionFind16Degrees)
  end
  if WriteGVDirectionHome == true then
    model.setGlobalVariable(GVDirectionHome, 0, DirectionHome16Degrees)
  end  
  if WriteGVDirectionHomeTurnLR == true then
    model.setGlobalVariable(GVDirectionHomeTurnLR, 0, DirectionHomeTurnLR16Degrees)
  end  
  if WriteGVDistance == true then
    if DistanceToModel <= 1000 then
      model.setGlobalVariable(GVDistance, 0, math.floor(DistanceToModel) )
    elseif (DistanceToModel/10) <= 1000 then
      model.setGlobalVariable(GVDistance, 0, math.floor(DistanceToModel/10) )
    elseif (DistanceToModel/100) <= 1000 then
      model.setGlobalVariable(GVDistance, 0, math.floor(DistanceToModel/100) )
    end
  end  
  if WriteGVTrip == true then
    if DistanceTrip <= 1000 then
      model.setGlobalVariable(GVTrip, 0, math.floor(DistanceTrip) )
    elseif (DistanceTrip/10) <= 1000 then
      model.setGlobalVariable(GVTrip, 0, math.floor(DistanceTrip/10) )
    elseif (DistanceTrip/100) <= 1000 then
      model.setGlobalVariable(GVTrip, 0, math.floor(DistanceTrip/100) )
    end
  end
end
local function playHeading16Degrees(degree16)
  -- Plays a heading sound file corresponding to the direction provided
  -- degreeLR16 must be 1 of 16 compass rose angles
  headingFile = SpeakHeading16FileName[degree16]
  if not (headingFile == nil) then
    headingFile = SoundFilesPath..headingFile
    -- playFile(name)
    -- name is full path to sound file
    -- e.g. /SCRIPTS/SOUNDS/GPS/E.wave
    playFile(headingFile)
  elseif Debuging == true then
    print("playHeading16Degrees", degree16)
  end
end
local function playTurnLR16Degrees(degreeLR16)
  -- Plays a direction to turn sound file corresponding to the direction provided
  -- degreeLR16 must be one of 
  -- 0, 23, 45, 68, 90, 113, 135, 158, 180
  -- -23, -45, -68, -90, -113, -135, -158
  turnFile = SpeakTurnLR16FileName[degreeLR16]
  if not (turnFile == nil) then
    turnFile = SoundFilesPath..turnFile
    -- playFile(name)
    -- name is full path to sound file
    -- e.g. /SCRIPTS/SOUNDS/GPS/E.wave
    playFile(turnFile)
  elseif Debuging == true then
    print("Play Turn:", degreeLR16)
  end
end
local function init_func()
  -- Called once when model is loaded
  -- This could be empty
  
  -- model.getGlobalVariable(index [, phase])
  -- index is the OpenTx GV number, 0 is GV1, 1 is GV2 and so on
  -- phase is the flight mode 

end
local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx

  if updateGPSData() == true then
    -- Filter out inaccuracies due to sensor inaccuracies
    -- Without this "Flying"/"Heading" directions are in often inaccurate 
    checkDist = getDistanceBetweenCoordinates(GPSlatPrevious, GPSlonPrevious, GPSlat, GPSlon)
    if checkDist > GPSDistanceFilter then
      updateAllDistancesDirections()

      writeOpenTxGVariablesIfTrue()
    end  
  
    if getSpeakHeadingStatus() == true then
      timeSecondsCurrent = getSecondsElapsedSince2016()
      timeSecondsDifferenceHeading = timeSecondsCurrent - timeSecondsPreviousHead
      if (timeSecondsDifferenceHeading >= SpeakHeadSeconds) then
        timeSecondsPreviousHead = timeSecondsCurrent
        playHeading16Degrees(DirectionCurrent16Degrees)
      end
    end
      
    if getSpeakTurnStatus() == true then
      timeSecondsCurrent = getSecondsElapsedSince2016()
      timeSecondsDifferenceTurn = timeSecondsCurrent - timeSecondsPreviousTurn
      if (timeSecondsDifferenceTurn >= SpeakTurnSeconds) then
        timeSecondsPreviousTurn = timeSecondsCurrent
        playTurnLR16Degrees(DirectionHomeTurnLR16Degrees)
      end 
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
  lcd.drawText( 0, 0, TextHeader, MIDSIZE + INVERS)
  
  if type(GPSDataTable) ~= "table" then
    lcd.drawText( ImageXpos, ImageYpos, "No GPS Data Yet!", MIDSIZE + BLINK)
  else
    if DisplayTrip == true then
      lcd.drawText( lcd.getLastPos()+2, 1, "Trip", SMLSIZE + INVERS)
      lcd.drawText( lcd.getLastPos()+1, 1, math.floor(DistanceTrip).."m", SMLSIZE)
    end
  
    if DisplayDirectionCurrent == true then
      lcd.drawText( ImageXpos, 12, "Flying", MIDSIZE + INVERS)
      displayCompass16Degrees(DirectionCurrent16Degrees, ImageXpos, ImageYpos)
    end
    
    nextImageXpos = ImageXpos + ImageXsize + ImageXmargin
    if  DisplayDirectionFind == true then
      lcd.drawText( nextImageXpos, 12, "Find", MIDSIZE + INVERS)
      displayCompass16Degrees(DirectionFind16Degrees, nextImageXpos, ImageYpos)
    end
    
    nextImageXpos = nextImageXpos + ImageXsize + ImageXmargin
    if DisplayDirectionHome == true then
      lcd.drawText( nextImageXpos, 12, "Home", MIDSIZE + INVERS)
      displayCompass16Degrees(DirectionHome16Degrees, nextImageXpos, ImageYpos)
    end
    if DisplayDistanceHome == true then
      lcd.drawText( lcd.getLastPos(), 15, math.floor(DistanceToModel).."m", SMLSIZE)
    end
    
    nextImageXpos = nextImageXpos + ImageXsize + ImageXmargin +2
    if DisplayDirectionHomeTurnLR == true then
      lcd.drawText( nextImageXpos, 12, "Turn  ", MIDSIZE + INVERS)
      displayTurnLR16Degrees(DirectionHomeTurnLR16Degrees, nextImageXpos-1, ImageYpos)
      --DisplayDirection16("N", nextImageXpos, ImageYpos)
    end
    
  --  lcd.drawText( lcd.getLastPos()+2, 40, " %", MIDSIZE) 
    if Debuging == true then
      print("Memory", collectgarbage("count"))
      printToDebugConsoleAllDistancesDirections()
    end
  end
  
end



return { run=run_func, background=bg_func, init=init_func  }
