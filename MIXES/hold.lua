-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTx Lua script
-- MIXES
-- Place this file in the SD Card folder on your computer and Tx
-- SD Card /SCRIPTS/MIXES/
-- Further instructions http://rcdiy.ca/mixer-scripts-getting-started/

-- Works On OpenTx Version: 2.1.8 to 2.1.9

-- Author: RCdiy
-- Web: http://RCdiy.ca

-- Thanks:  Kilrah

-- Date: 2017 January 12
-- Update: none

-- Description

-- Holds the input value.
-- E.g. Keep a boat on a fixed throttle and rudder setting.
-- Enabled using a logical or physical switch.
-- Audio "Hold Enabled" or "Hold Disabled"

-- Upto 4 inputs may be configured.
-- The inputs may be sticks, sliders, switches or channels (any OpenTx input).
-- For each input a corresponding switch is to be provided.
-- The same switch may be used for all inputs.

-- 4 outputs are provided Hld1, Hld2, Hld3, Hld4.
-- THese outputs are to be used as inputs to the mix on the mixer screen.
-- The output is either a pass thru of the input or a fixed value.
-- When the switch is up/away the output equals the input.
-- When the switch is not up/away the input value gets held and from then on
-- the output is a fixed value till the switch is back down/away.
-- If an input is not configured the corresponding output is zero.

-- Configuration

-- Custom Scripts Screen - Select this script and configure inputs.
-- Mixer Screen - Create a mix using one of Hld1, Hld2, Hld3 or Hld4 as input.

-- Change as desired

-- File Paths
-- location you placed the accompanying files
local SoundFilesPath = "/SCRIPTS/SOUNDS/Hold/"


-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable

-- Hold values
local Output1 = 0
local Output2 = 0
local Output3 = 0
local Output4 = 0

-- Other
local Debuging = false

local inputs = {
                 { "1st Input", SOURCE },
                 { "1st Switch", SOURCE },
                 { "2nd Input", SOURCE },
                 { "2nd Switch", SOURCE },
                 { "3rd Input", SOURCE },
                 { "3rd Switch", SOURCE },
                 { "4th Input", SOURCE },
                 { "4th Switch", SOURCE }
               }

local outputs = { "Hld1", "Hld2", "Hld3", "Hld4"}

local function run(Ip1, Sw1, Ip2, Sw2, Ip3, Sw3, Ip4, Sw4)

  -- If the switch is up/away
  --  pass thru the input to the output
  -- else
  --  the output is the last input value before the switch was changed
  if Sw1 < 0 then
    Output1 = Ip1
  end
  if Sw2 < 0 then
    Output2 = Ip2
  end
  if Sw3 < 0 then
    Output3 = Ip3
  end
  if Sw4 < 0 then
    Output4 = Ip4
  end

  print("returning", Output1, Output2, Output3, Output4)
  return Output1, Output2, Output3, Output4
end

return { input=inputs, output=outputs, run=run }
