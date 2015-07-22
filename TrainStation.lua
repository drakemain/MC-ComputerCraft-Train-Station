function main()
  local cartInventory = startupInitializer()
  local routeButtons = {}
  updateStatusWindow( "cartInventory", cartInventory )
  --routeButtons[1] = setButtonProperties( "[RESERVED]", 16, true, "bottom", colors.white )
  routeButtons[1] = setButtonProperties( "Village 1", 16, true, "bottom", colors.orange )
  routeButtons[2] = setButtonProperties( "[AVAILABLE]" , 16, true, "bottom", colors.magenta )
  routeButtons[3] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.lightBlue )
  routeButtons[4] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.yellow )
  routeButtons[5] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.lime )
  routeButtons[6] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.pink )
  routeButtons[7] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.gray )
  routeButtons[8] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.lightGray )
  routeButtons[9] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.cyan )
  routeButtons[10] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.purple )
  routeButtons[11] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.blue )
  routeButtons[12] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.brown )
  routeButtons[13] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.green )
  routeButtons[14] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.red )
  routeButtons[15] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", colors.black )
  routeButtons[16] = setButtonProperties( "[AVAILABLE]", 16, true, "bottom", nil )
  
  while true do
    displayDestinations( routeButtons )
    eventType, eventFunction = eventHandler( routeButtons )

    if eventType == "route_select" then
      deselectButtons( routeButtons )
      trackSelector( routeButtons[eventFunction]["outputSide"], routeButtons[eventFunction]["cableColor"] )
      buttonSelect( routeButtons, eventFunction )
    
    elseif eventType == "cart_dispenser" then
      if tableLen( eventFunction ) == 1 then

        local inputSource = eventFunction[1]
        if inputSource == 1 then
          dispenseCart()
          cartInventory = cartInventory - 1
        elseif inputSource == 4 then
          cartInventory = cartInventory + 1
        end
        rewriteFile( "cartInventory", cartInventory )
        updateStatusWindow( "cartInventory", cartInventory )

      end
    end

  end
end

function startupInitializer()
  --ensures a cart is available to launch on startup
  local cartWasLaunched
  writeToWindow( w2, "Initializing.." )
  writeToWindow( w2, "Launcher check.." )
  input = determineBundledInputSource( "left" )
  for i,v in ipairs(input) do
    if v == 1 then
      writeToWindow(w2, "Launcher empty.\nDispensing cart.")
      dispenseCart()
      cartWasLaunched = true
    end
  end
  writeToWindow( w2, "..complete" )
  sleep(3)
  --
  --gets the current stored cart inventory
  writeToWindow( w2, "Inventory check.." )
  local cartInventory = tonumber( getFile( "cartInventory" ) )
  if cartWasLaunched then
    cartInventory = cartInventory - 1
  end
  writeToWindow( w2, "..complete: "..cartInventory )
  --
  sleep(3)

  initializeStatusWindow()

  return cartInventory
end

function initializeStatusWindow()
  clearWindow(w2)
  term.redirect( w2 )
  write( "Stored carts: ")
end

function updateStatusWindow( toUpdate, info )
  term.redirect( w2 )
  if toUpdate == "cartInventory" then
    term.setCursorPos(1,1)
    justifyRight( "   " )
    justifyRight( info )
  end
end

function writeToWindow( window, text )
  term.redirect( window )
  print( text )
  term.redirect( term.native() )
end

function clearWindow( window )
  term.redirect( window )
  term.clear()
  term.setCursorPos(1,1)
  term.redirect( term.native() )
end

function justifyRight( text )
  local x,y = term.getCursorPos()
  local xMax,yMax = term.getSize()
  local textLen = string.len( text )

  term.setCursorPos( xMax - ( textLen - 1 ), y )
  write( text )
end


function getFile( file )
  if not fs.exists( file ) then
    print( "Database file doesn't exist. Nothing to fetch." )

    local h = fs.open( file, "w" )

    if file == "cartInventory" then
      write("Enter current carts in inventory: ")
      writeToWindow(w2, "Terminal input needed")
      local cartInventory = read()
      h.write( cartInventory )
    end

    h.close()
  
    print( "New database file created" )
    h.close()
  end

  local h = fs.open( file, "r" )
  local db = h.readAll()
  h.close()

  return textutils.unserialize( db )  
end

function rewriteFile( file, toWrite )
  local h = fs.open( file, "w" )
  h.write( toWrite )
  h.close()
end

function setGlobalVars()
  mon = peripheral.wrap("back")
  
  term.redirect( mon )
  monX,monY = term.getSize()
  monCenterX = math.ceil( monX / 2 )
  monCenterY = math.ceil( monY / 2 )
  term.redirect( term.native() )
  
end

function clearMon( color )
  term.redirect( mon )
  term.setBackgroundColor( color )
  term.clear()
  term.redirect( term.native() )
end

function makeWindows()
  w1 = window.create( mon, monCenterX + 1, 1, monCenterX - 1, monCenterY )
  w2 = window.create( mon, monCenterX + 1, monCenterY + 1, monCenterX - 1, monCenterY - 1 )
  w3 = window.create( mon, 1, 1, monCenterX, monY )
  --w4 = window.create( mon, 1, 1, monCenterX - 1, monCenterY - 1 )
  
  w1.setBackgroundColor(colors.green)
  w2.setBackgroundColor(colors.yellow)
  w3.setBackgroundColor(colors.blue)
  --w4.setBackgroundColor(colors.red)
  w1.setTextColor(colors.black)
  w2.setTextColor(colors.black)
  w3.setTextColor(colors.black)
  
  w1.clear()
  w2.clear()
  w3.clear()
  --w4.clear()
end

function setButtonProperties( text, length, isCableOutput, outputSide, cableColor )
  local buttonProps = {}

  buttonProps["text"] = text
  buttonProps["length"] = length
  buttonProps["isCableOutput"] = isCableOutput
  buttonProps["outputSide"] = outputSide
  buttonProps["cableColor"] = cableColor
  buttonProps["isSelected"] = false
  
  if text == "[AVAILABLE]" or text == "[UNDER CONSTR]" or text == "[RESERVED]" then
    buttonProps["isSelectable"] = false
  else
    buttonProps["isSelectable"] = true
  end

  return buttonProps
end

function drawButton( button, color )
  term.setTextColor( colors.black )

  local textLen = string.len( button["text"] )
  local linePos = 0
  local textStartPos = math.floor( ( button["length"]/2 ) - ( textLen/2 ) )
  local monStartX, monY = mon.getCursorPos()

  if button["isSelected"] then
    term.setBackgroundColor( colors.white )
  elseif not button["isSelectable"] then
    term.setBackgroundColor( colors.gray )
  else
    term.setBackgroundColor( color )
  end
  
  while linePos < textStartPos do
    term.write( " " )
    linePos = linePos + 1
  end

  term.write( button["text"] )
  linePos = linePos + textLen

  while linePos < button["length"] do
    write( " " )
    linePos = linePos + 1
  end
  
  button["startX"] = monStartX
  button["endX"] = linePos + monStartX
  button["Y"] = monY
end

function displayDestinations( buttons )
  term.redirect( w3 )
  local color

  for i,v in ipairs(buttons) do
    if (i % 2) == 0 then
      color = colors.cyan
    else 
      color = colors.lightBlue
    end

    term.setCursorPos(2, i + 1)
    drawButton( v, color )

  end

  term.redirect( term.native() )
end

function tableLen(tableToCheck)
  local counter = 0
  
  for i in pairs( tableToCheck ) do
    counter = counter + 1
  end
  
  return counter
end

function buttonPress( buttonList, clickX, clickY )
  for i,v in ipairs( buttonList ) do

    if clickX >= v["startX"] and clickX <= v["endX"] and clickY == v["Y"] then
      --print( v["text"].." clicked. Selected: ".. tostring( v["isSelectable"] ) )

      if v["isSelectable"] then
        return true, i
      end

    end
  end

  return false, nil
end

function trackSelector( outputSide, cableColor )
  if cableColor ~= nil and outputSide ~= nil then
    --print( "Track: "..outputSide..", "..cableColor )
    redstone.setBundledOutput( outputSide, 0 )
    redstone.setBundledOutput( outputSide, cableColor )
  end
end

function deselectButtons( buttonList )
  for i,v in ipairs( buttonList ) do
    if v["isSelectable"] then
      v["isSelected"] = false
    end
  end
end

function buttonSelect( buttonList, buttonIndex )
  buttonList[buttonIndex]["isSelected"] = true
end

function eventHandler( routeButtons )
  while true do
    sleep(.1)
    local event, param1, param2, param3 = os.pullEvent()

    if event == "monitor_touch" and param1 == "back" then
      buttonWasPressed, button = buttonPress( routeButtons, param2, param3 )
      if buttonWasPressed then
        return "route_select", button
      end

    elseif event == "redstone" then
      --print("Cart disp event")
      return "cart_dispenser", determineBundledInputSource( "left" )
    end
  end
end

function determineBundledInputSource( side )
  local activeInputs = {}
  local bundledInput = redstone.getBundledInput( side )
  local i = 15
  local j = 1

  while bundledInput > 0 do
    if bundledInput >= 2 ^ i then
      activeInputs[j] = 2 ^ i
      bundledInput = bundledInput - (2 ^ i)
      j = j + 1
    end

    i = i - 1

  end

  return activeInputs

end

function dispenseCart()
  redstone.setBundledOutput( "left", colors.orange )
  sleep(.1)
  redstone.setBundledOutput( "left", 0 )
end  

function getClick()
  local event, side, x, y = os.pullEvent( "monitor_touch" )
  --print( "clicked: "..x.." "..y )
  return x,y
end

--
redstone.setBundledOutput("bottom", 0)
setGlobalVars()
clearMon( 32768 )
makeWindows()


main()

