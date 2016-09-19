# OpenTxLua
Lua scripts for the OpenTx software environment.

http://RCdiy.ca

info@RCdiy.ca

These scripts are described on the website RCdiy.ca

To use these scripts:
- Click on the script type directory e.g. TELEMETRY
- Click on the file to display it's contents e.g. 01GtStrd.lua
- Right click on the "Raw" buttom to download/save it to your computer
- Move/copy the file as described in the file e.g. SD Card Copy/SCRIPTS/TELEMETRY/01GtStrd.lua
- Test the script on your computer using OpenTx Companion
  - Test instructions http://rcdiy.ca/telemetry-scripts-getting-started/ 

To submit requests for a new script to be written or to contribute yours please send in an email.

Depending on demand this repository may be opened up so others may help maintain it.

Script Submission Conditions
- Permission to modify your scripts (retaining author credit to you)
- Working on the current version of OpenTx Companion
- Documentation as suggested below

Suggested Documentation

    OpenTx Lua script
    TELEMETRY

    Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua
  
    Works On OpenTx Companion Version: 2.1.8

    Author: RCdiy
   Web: http://RCdiy.ca
    Date: 2016 June 28

    Description
      
      Read a Tx global variable to determine battery capacity in mAh
      
      Read a sensor to determine current mAh consumption
      
      Display remaining battery mAh
      
      Display remaining battery percent
      
      Write remaining battery mAh to a Tx global variable
      
      Write remaining battery percent to a Tx global variable

    Note
      
      The OpenTx global variables have a 1024 limit.
      
      mAh values are expressed as mAh/100
      
      2800 mAh will be 28 when stored in an OpenTx global variables
      
      800 mAh will be 8

    Sensors 
      
      mAh (calculated sensor based on VFAS, FrSky FAS-40)
  
    Global OpenTx variables used  
      GV1 = Read battery capacity provided as mAh/100, 2800 mAh would be 28, 800 mAh would be 8
      
      GV2 = Write mAh remaining
      
      GV3 = Write % remaining

    Global Lua environment variables used
      
      None
      
      if required use a naming convention similar to below to reduce conflict with other scripts
        
        RCdiy<script file name prefix upto 8 characters>_variablecontent
        
        e.g. RCdiymAhRmain_CapacityRemainingPercent = 0
  
    Variables local to this script must use the word "local" before the variable
    
      e.g. local SensorName = "RxBt"
