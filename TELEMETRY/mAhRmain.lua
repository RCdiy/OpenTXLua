-- OpenTx Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/
-- Place the accompanying sound files in /SOUNDS/en/

-- Works On OpenTx Companion Version: 2.1.8
-- Works With Sensor: FrSky FAS40S

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Date: 2016 June 28
-- Update: 2016 August 7

-- Description
-- Read a Tx global variable to determine battery capacity in mAh
-- Read a sensor to determine current mAh consumption
-- Display remaining battery mAh
-- Display remaining battery percent
-- Write remaining battery mAh to a Tx global variable
-- Write remaining battery percent to a Tx global variable
-- Writes are optional, on by default
-- A reserve of 20% has been set. All values are calculated with
-- reference to this reserve.
-- At 0 mAh and 0 % remaining displayed there is actually 20% remaining.
-- This reserve is easily changed within the script.

-- Note
-- The OpenTx global variables have a 1024 limit.
-- mAh values are expressed as mAh/100
-- 2800 mAh will be 28 when stored in an OpenTx global variables
-- 800 mAh will be 8

-- Tips
-- The GV values (Global OpenTx Variables) that appear on the Tx are global
-- to that model, not across models.
-- Standardise accross all your models which GV will be used for battery
-- capacity. For each model you can set different battery capacities.
-- E.g. Cargo Plane GV7 = 27, Quad 250 GV7 = 13
--
-- Use Logical Switches and Special Functions to play sound tracks
-- E.g.
-- L11 - GV9 < 50
-- L12 - GV9 < 10
-- SF3 - L12 Play Track batcrit
-- SF4 - L11 Play Value GV9 10s
-- SF5 - L11 Play Track #PrcntRm 10s
-- After the remaining battery capicity drops below 50%
-- Every 10 seconds the value of GV9 will be played followed by the sound track

-- Sensors
-- mAh (calculated sensor based on VFAS, FrSky FAS-40)
-- Use consumption sensor name from OpenTx TELEMETRY screen
local SensorName = "mAh"

-- Global OpenTx variables used (Global to the model)
-- GV7 = Read battery capacity provided as mAh/100, 2800 mAh would be 28, 800 mAh would be 8
-- GV8 = Write mAh remaining
-- GV9 = Write  remaining
-- 2345 mAh will be writen as 23, floor(2345/100)
-- 76.7% will be writen as 76, floor(76)
-- Location of battery capacity, GV1=0, GV2=1 and so on
local GV = {[1] = 0, [2] = 1, [3] = 2,[4] = 3,[5] = 4,[6] = 5, [7] = 6, [8] = 7, [9] = 8}

local GVBatteryCapacity = GV[7] -- Use GV[7] for GV7, GV[1] for GV1 and so on
local GVBatteryRemainmAh = GV[8]
local GVBatteryRemainPercent = GV[9]
local WriteGVBatteryRemainmAh = true -- set to false to turn off write
local WriteGVBatteryRemainPercent = true
-- If you have set either write to false you may set the corresponding variable to ""
-- example local GVBatteryRemainmAh = ""


-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE


local BattryCapacityFullmAh = 0
local BattryCapacitymAh = 0
local BatteryUsedmAh = 0
local BatteryRemainmAh = 0
local BatteryRemainPercent = 0
local BatteryReservePercent = 20 -- set to zero to disable

local TextHeader = "Flight Battery                      "

-- Global Lua environment variables used (Global between scripts)
-- None

local function init_func()
  -- Called once when model is loaded
  -- This could be empty

  -- model.getGlobalVariable(index [, phase])
  -- index is the OpenTx GV number, 0 is GV1, 1 is GV2 and so on
  -- phase is the flight mode
  BattryCapacityFullmAh = model.getGlobalVariable(GVBatteryCapacity, 0) * 100
  BattryCapacitymAh = BattryCapacityFullmAh * (100-BatteryReservePercent)/100

end

local function bg_func()
  -- Called periodically when screen is not visible
  -- This could be empty
  -- Place code here that would be executed even when the telemetry
  -- screen is not being displayed on the Tx
  BatteryUsedmAh = getValue(SensorName)
  BatteryRemainmAh = BattryCapacitymAh - BatteryUsedmAh
  if not (BattryCapacitymAh == 0) then
    BatteryRemainPercent = math.floor((BatteryRemainmAh / BattryCapacitymAh) * 100)
  end

  -- model.setGlobalVariable(index, phase, value)
  -- index is the OpenTx GV number, 0 is GV1, 1 is GV2 and so on
  -- phase is the flight mode
  -- value must be between -1024 and 1024
  if WriteGVBatteryRemainmAh == true then
    model.setGlobalVariable(GVBatteryRemainmAh, 0, math.floor(BatteryRemainmAh/100))
  end
  if WriteGVBatteryRemainPercent == true then
    model.setGlobalVariable(GVBatteryRemainPercent, 0, BatteryRemainPercent)
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
  lcd.drawText( 1, 13, "Sensor Name", INVERS)
  lcd.drawText( lcd.getLastPos(), 13, " "..SensorName)
  lcd.drawText( lcd.getLastPos()+3, 13, "Capacity", INVERS)
  lcd.drawText( lcd.getLastPos(), 13, " "..BattryCapacityFullmAh.." mAh")
  lcd.drawText(lcd.getLastPos()+3, 13, "R", INVERS)
  lcd.drawText(lcd.getLastPos()+3, 13, BatteryReservePercent.."%")
  lcd.drawText( 1, 23, BatteryRemainmAh, XXLSIZE)
  lcd.drawText( lcd.getLastPos()+2, 40, " mAh", MIDSIZE)
  lcd.drawText( 126, 23, BatteryRemainPercent, XXLSIZE)
  lcd.drawText( lcd.getLastPos()+2, 40, " %", MIDSIZE)

end



return { run=run_func, background=bg_func, init=init_func  }
