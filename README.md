# OpenTX Lua Scripts
Lua scripts for the OpenTX software environment.

http://RCdiy.ca

info@RCdiy.ca

These scripts are documented on the website and within the script files.

## Download

- Click on the script type directory e.g. TELEMETRY
- Click on subsequent folders and follow directions in the read me files.

## Use The Script

- View the script in a text editor to get instructions on where to place the files and configuration options
- New to lua scripts?
  - [http://rcdiy.ca/telemetry-scripts-getting-started/](http://rcdiy.ca/telemetry-scripts-getting-started/)
  - [http://rcdiy.ca/mix-scripts-getting-started/](http://rcdiy.ca/mix-scripts-getting-started/)

## Contribute
- To contribute yours scripts to this repository please send in an email info@RCdiy.ca

Depending on demand this repository may be opened up so others may help maintain it.

### Script Submission Conditions

- Permission to use and modify your scripts (retaining author credit to you) without any conditions except as provided under GPL3.0
- Working on the current release version of OpenTX and Companion simulator

### Suggested Documentation

    OpenTX Lua script
    TELEMETRY

    Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

    Works On OpenTX Companion Version: 2.1.8

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

      The OpenTX global variables have a 1024 limit.

      mAh values are expressed as mAh/100

      2800 mAh will be 28 when stored in an OpenTX global variables

      800 mAh will be 8

    Sensors

      mAh (calculated sensor based on VFAS, FrSky FAS-40)

    Global OpenTX variables used  
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
