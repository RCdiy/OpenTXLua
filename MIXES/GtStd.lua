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

-- A simple getting started mixer script.
-- Takes an input suchs as a stick and an integer.
-- Outputs the stick value multiplied by the integer divided by 100.

-- Configuration

-- Custom Scripts Screen
-- Select this script and configure inputs.

-- Mixer Screen
-- Create a mix using the input "GtSt" which is the output from this script.

-- ----------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------

-- AVOID EDITING BELOW HERE

-- Global Lua environment variables used (Global between scripts)
-- None

-- Variables local to this script
-- must use the word "local" before the variable
local inputs = {
                 { "Input", SOURCE },
                 { "Percent", VALUE, -100, 100, 5 }
               }
-- The display prompt and input type on the left of the custom scripts screen.
-- Maximum of 10 characters will be displayed.
-- SOURCE provides a popup menu from which any OpenTx input may be selected.
--  Inputs may be switches, sliders, sticks, chanels or outputs from other
--  mixer scripts.
-- VALUE provides a number entry field ranging from -100 to 100 default of 5.
local outputs = { "GtSt" }
-- The names of the outputs from this script as they appear on the
-- right of the custom scripts screen and in OptenTx list of inputs.
-- Maximum of 4 characters will be displayed.

local function run(i, p)
  return i*p/100
end

return { input=inputs, output=outputs, run=run }
