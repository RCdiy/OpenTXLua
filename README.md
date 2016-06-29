# OpenTxLua
Lua scripts for the OpenTx software environment.

http://RCdiy.ca

To submit requests for a new script to be written or to contribute yours please email info@RCdiy.ca

Depending on demand I may open this repository up so others may help maintain it.

Suggested basic script submission requirements
- Permission to modify your scripts before being uploaded to this repository

Suggested script header format
-- OpenTx Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

-- Author: 
-- Web: http://RCdiy.ca

-- Date: 2016 June 28

-- Description
-- Read a Tx global variable to determine battery capacity in mAh
-- Read a sensor to determine current mAh consumption
-- Display remaining battery mAh
-- Display remaining battery percent
-- Write remaining battery mAh to a Tx global variable
-- Write remaining battery percent to a Tx global variable

-- Note
-- The OpenTx global variables have a 1024 limit.
-- mAh values are expressed as mAh/100
-- 2800 mAh will be 28 when stored in an OpenTx global variables
-- 800 mAh will be 8

-- Sensors 
-- mAh (calculated sensor based on VFAS, FrSky FAS-40)

-- Global OpenTx variables used
-- GV1 = Read battery capacity provided as mAh/100, 2800 mAh would be 28, 800 mAh would be 8
-- GV2 = Write mAh remaining
-- GV3 = Write  remaining

-- Global Lua environment variables used
-- None
-- if required use a naming convention similar to below to reduce conflict with other scripts
-- RCdiy<script file name prefix upto 8 characters>_variablecontent
-- RCdiymAhRmain_CapacityRemainingPercent = 0

-- Variables local to this script
-- must use the word "local" before the variable
local SensorName = "RxBt"
