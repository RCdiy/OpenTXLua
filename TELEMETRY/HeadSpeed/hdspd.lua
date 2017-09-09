-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
--
-- File Locations On The Transmitter's SD Card
--  This script file  /SCRIPTS/TELEMETRY/

-- Works On OpenTX Companion Version: 2.2
-- Works With Sensor: FrSky RPM Sensor

-- Author: Brad Kelley
-- Web: http://attituderc.com/

-- Thanks: Brad Kelly (AttitudeRC)

-- Date: 2017 August 16
-- Update: 2017 August 16 RCdiy

-- Changes/Additions:
--  Documentation, variables to configure script, update tp OpenTX 2.2
--  Smaller X7 screen check.

-- To do: n/a

-- Description
--
--  Reads an RPM sensor and calculates the headspeed based on
--  maingear and piniongear teeth.

-- Configurations
--  For help using telemetry scripts
--    http://rcdiy.ca/telemetry-scripts-getting-started/
--  For help configuring the RPM sensor
--    http://rcdiy.ca/frsky-rpm-sensor/

-- Sensors
--  Locate sensor name(s) from the OpenTX TELEMETRY screen
-- Change as required
local RpmSensorName = "RPM"

-- Gears
--  Number of teeth
-- Change as required
local maingear = 162
local piniongear = 14

-- AVOID EDITING BELOW HERE
local rpm = 18000
local gearratio = 0
local headspeed = 0

local function init()
  gearratio = math.floor((maingear / piniongear) * 100 ) / 100
  rpm = getValue(RpmSensorName)
end

local function background()
  rpm = getValue(RpmSensorName)

  headspeed = math.floor((rpm / gearratio) * 100 ) / 100

end

local function run(event)
  background()
  lcd.clear()

  lcd.drawText(1,0,"Headspeed",INVERS)

  lcd.drawText(1,15,"Main Gear:",SMLSIZE)
  lcd.drawText(60,15,maingear,SMLSIZE)

  lcd.drawText(1,22,"Pinion Gear:",SMLSIZE)
  lcd.drawText(60,22,piniongear,SMLSIZE)

  lcd.drawText(1,29,"Gear Ratio:",SMLSIZE)
  lcd.drawText(60,29,gearratio,SMLSIZE)

  if LCD_W < 212 -- Not a Taranis X9series
  then
    lcd.drawText(1,38,"RPM:",SMLSIZE)
    lcd.drawText(40,38,rpm,SMLSIZE)

    lcd.drawText(1,50,"Head Speed:",0)
    lcd.drawText(70,46,headspeed,DBLSIZE)
  else
    lcd.drawText(1,43,"RPM:",SMLSIZE)
    lcd.drawText(40,43,rpm,SMLSIZE)

    lcd.drawText(90,15,"Head Speed:",0)
    lcd.drawText(90,30,headspeed,DBLSIZE)
  end

end

return { init=init, background=background, run=run }
