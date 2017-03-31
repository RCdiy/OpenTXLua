-- License https://www.gnu.org/licenses/gpl-3.0.en.html
-- OpenTX Lua script
-- TELEMETRY
-- Place this file in SD Card copy on your computer > /SCRIPTS/TELEMETRY/<name>.lua

-- Works On OpenTX Companion Version: 2.2

-- Author: RC diy
-- Web: http://RCdiy.ca

-- Description
-- This is a code snippet to draw an arrow.
-- The position, direction angle, size, tail angle and thickness are provided
-- as inputs.
-- A tail angle of 90 degrees produces an arrow looking like a triangle.
-- A tail angle of 120 degrees produces an arrow with the trailing points
-- swept back.
-- A thickness equal to half the size produces a filled in arrow.



-- Variables local to this script
-- must use the word "local" before the variable
local x,y = LCD_W/2 , LCD_H/2
local directionDeg = 90
local size = 15
local tailAngle = 120
local thickness = 8

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- Avoid editing below here
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local function DisplayTraingle(x, y, directionDeg, size, tailAngle, thickness)
  -- x,y - center position
  -- directionDeg, angle in degrees, zero points North, 90 East
  -- size - radius, distance from center to tip
  -- tailAngle - shape, position of trail ends relative to tip
  -- A tail angle of 90 degrees produces an arrow looking like a triangle.
  -- A tail angle of 120 degrees produces an arrow with the trailing points
  -- swept back.
  -- thickness - a thickness equal to half the size produces a filled in arrow.

  local x0, y0, x1, y1, x2, y2, x3, y3, count = 0, 0, 0, 0, 0, 0, 0, 0, 0
  while thickness > 0 do
    x0 = x + (count * math.sin(math.rad(directionDeg))) -- move center for thickness
    y0 = y - (count * math.cos(math.rad(directionDeg)))
    x1 = x + (size * math.sin(math.rad(directionDeg))) -- tip
    y1 = y - (size * math.cos(math.rad(directionDeg)))
    x2 = x + (size * math.sin(math.rad(directionDeg+tailAngle))) -- tail
    y2 = y - (size * math.cos(math.rad(directionDeg+tailAngle)))
    x3 = x + (size * math.sin(math.rad(directionDeg-tailAngle))) -- tail
    y3 = y - (size * math.cos(math.rad(directionDeg-tailAngle)))
    -- lcd.drawLine(x, y, x1, y1, SOLID, FORCE) -- center to tip, direction line
    lcd.drawLine(x0, y0, x2, y2, SOLID, FORCE) -- center to tail
    lcd.drawLine(x0, y0, x3, y3, SOLID, FORCE) -- center to tail
    lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE) -- tip to tail
    lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE) -- tip to tail
    thickness = thickness - 1
    size = size - 1
    count = count + 1
  end

end

local function init_func()
  -- Called once when model is loaded
  -- This could be empty

end

local function bg_func()


end

local function run_func(event)
  -- Called periodically when screen is visible
  bg_func()
  lcd.clear()
  lcd.drawText(0,0, "Arrow at "..x..", "..y.." ")
  lcd.drawText(0,10, directionDeg.."@ "..size.." px "..tailAngle.."@")
  DisplayTraingle(x, y, directionDeg, size, tailAngle, thickness)

end



return { run=run_func, background=bg_func, init=init_func  }
