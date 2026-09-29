queuedShips = type(queuedShips) == "table" and queuedShips or {}
autobuildshipparts = {"hull", "circuits", "weapons", "engine"}
autobuildshipsafety = type(autobuildshipsafety) == "table" and autobuildshipsafety or {}
autobuildshipsafety.afkProbe = nil
autobuildshipsafety.lastAction = type(autobuildshipsafety.lastAction) == "table" and autobuildshipsafety.lastAction or {}
autobuildshipsafety.unavailable = type(autobuildshipsafety.unavailable) == "table" and autobuildshipsafety.unavailable or {}
autobuildshipsafety.completed = type(autobuildshipsafety.completed) == "table" and autobuildshipsafety.completed or {}

function autobuildshiptrim(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

function autobuildshipvalidship(value)
    local ship = autobuildshiptrim(value)
    if ship == "" or #ship > 120 or ship:find("[;<>\r\n]") then return nil end
    return ship
end

function autobuildshipnormalizepart(value)
    local part = autobuildshiptrim(value):lower()
    if part == "circuit" then part = "circuits" end
    if part == "weapon" then part = "weapons" end
    if part == "engines" then part = "engine" end
    for _, allowed in ipairs(autobuildshipparts) do
        if part == allowed then return part end
    end
    return nil
end

function autobuildshipnextpart(value)
    local part = autobuildshipnormalizepart(value) or "hull"
    for index, allowed in ipairs(autobuildshipparts) do
        if allowed == part then
            return autobuildshipparts[(index % #autobuildshipparts) + 1]
        end
    end
    return "hull"
end

function autobuildshipnow()
    local value
    if type(getEpoch) == "function" then
        local ok, result = pcall(getEpoch)
        if ok then value = tonumber(result) end
    end
    value = value or os.time()
    if value > 100000000000 then value = value / 1000 end
    return value
end

function autobuildshipaccept(key, minimumSeconds)
    autobuildshipsafety.lastAction = type(autobuildshipsafety.lastAction) == "table" and autobuildshipsafety.lastAction or {}
    local now = autobuildshipnow()
    local previous = tonumber(autobuildshipsafety.lastAction[key])
    if previous and now - previous < (tonumber(minimumSeconds) or 0) then return false end
    autobuildshipsafety.lastAction[key] = now
    return true
end

function autobuildshipresetcycle(keepThrottle)
    autobuildshipsafety.afkProbe = nil
    autobuildshipsafety.unavailable = {}
    autobuildshipsafety.completed = {}
    autobuildshipsafety.workCount = 0
    autobuildshipsafety.partTransition = nil
    autobuildshipsafety.inspectTransition = nil
    if not keepThrottle then
        autobuildshipsafety.lastAction = {}
        autobuildshipsafety.shipTransition = false
    end
end

function autobuildshippause(reason)
    autobuildshipsafety.afkProbe = nil
    autobuildship = false
    cecho("\n<yellow>LotJ Buildship PAUSED: <white>" .. tostring(reason or "Safety check failed.") .. "\n")
end

function autobuildshipguard(action)
    if not autobuildship then return false end
    local ship = autobuildshipvalidship(currentbuildship)
    local part = autobuildshipnormalizepart(currentbuildpart)
    if not ship or not part then
        autobuildshippause("Invalid ship/component state while trying to " .. tostring(action or "continue") .. ".")
        return false
    end
    currentbuildship = ship
    currentbuildpart = part
    return true
end

function autobuildshipsendbuild()
    if autobuildshipsafety.afkProbe then return false end
    if not autobuildshipguard("send buildship") then return false end
    local serverPart = currentbuildpart == "engine" and "engines" or currentbuildpart
    autobuildshipsafety.lastBuildCommand = "buildship " .. currentbuildship .. " " .. serverPart
    send(autobuildshipsafety.lastBuildCommand)
    return true
end

function autobuildshipstop(reason)
    autobuildship = false
    currentbuildpart = nil
    currentbuildship = nil
    autobuildshipgag = false
    if autobuildshippromptgagged then
        send("config +prompt")
        autobuildshippromptgagged = false
    end
    if autobuildshipsafety.botStarted then
        send("bot stop")
        autobuildshipsafety.botStarted = false
    end
    autobuildshipresetcycle()
    cecho("\n<green>LotJ Buildship: <white>" .. tostring(reason or "Stopped.") .. "\n")
end

autobuildshipestimate = autobuildshipestimate or {}
autobuildshipexamineevery = math.max(1, math.floor(tonumber(autobuildshipexamineevery) or 5))
autobuildshipestimate.impacts = autobuildshipestimate.impacts or {}
autobuildshipestimate.prices = autobuildshipestimate.prices or {}

-- Impacts, prices, and timing must come from the local player.
autobuildshipestimate.engineers = autobuildshipestimate.engineers or 1
autobuildshipestimate.verbose = autobuildshipestimate.verbose == true

function autobuildshipformatnumber(value)
    local formatted = tostring(math.floor(tonumber(value) or 0))
    while true do
        local replacements
        formatted, replacements = formatted:gsub("^(%d+)(%d%d%d)", "%1,%2")
        if replacements == 0 then break end
    end
    return formatted
end

-- Compact literal-text UI. Command links only prefill the input line.
autobuildshipui = {version="2.8.0",width=66}
local palette={heading={255,190,70},command={70,220,235},text={235,240,245},muted={155,170,185}}
function autobuildshipui.text(value,width)
  local t=tostring(value or "Not set"):gsub("[%c]"," ")
  if width and #t>width then t=t:sub(1,width-3).."..." end
  return t
end
function autobuildshipui.print(tone,value)
  resetFormat(); setFgColor(unpack(palette[tone] or palette.text)); echo(value); resetFormat()
end
function autobuildshipui.header(page)
  autobuildshipui.print('heading','\n  BUILDSHIP  v2.8.0 | '..page..'\n')
end
function autobuildshipui.row(label,value)
  local ui=autobuildshipui
  ui.print('muted','  '..label..': '); ui.print('text',ui.text(value,math.max(8,62-#label))..'\n')
end
function autobuildshipui.command(cmd,description)
  local ui=autobuildshipui; ui.print('command','  ')
  setFgColor(unpack(palette.command))
  if echoLink and printCmdLine then
    echoLink(cmd,function() printCmdLine(cmd:gsub('%[.*','')) end,'Fill the input line; review and press Enter.',true)
  else echo(cmd) end
  ui.print('muted','  '..description..'\n')
end
function autobuildshipshowhelp()
  local ui=autobuildshipui; ui.header('Commands')
  ui.row('State',autobuildship and 'RUNNING' or 'IDLE')
  ui.row('Frame',currentbuildship or 'No frame selected')
  for _,r in ipairs({
    {'autobuild add [ship]','Select / queue a frame'},
    {'autobuild start','Start selected frame'},
    {'autobuild pause','Pause'}, {'autobuild resume','Resume / retry'},
    {'autobuild queue','View waiting frames'}, {'autobuild clearqueue','Clear waiting frames'},
    {'autobuild clear','Stop and clear all'}, {'autobuild gag','Toggle work output'},
    {'autobuild gag prompt','Also toggle prompt'}, {'autobuild blanklines','Toggle blank lines'},
    {'autobuild config','Estimator setup'}, {'autobuild help','Show commands'},
  }) do ui.command(r[1],r[2]) end
  ui.print('muted','  Click to edit; Enter runs it.\n')
end
function autobuildshipshowqueue()
  local ui=autobuildshipui; ui.header('Queue'); ui.row('Current frame',currentbuildship or 'None')
  for i,ship in ipairs(queuedShips) do ui.row(string.format('%02d',i),ship) end
  if #queuedShips==0 then ui.print('muted','  No waiting frames.\n') end
end
function autobuildshipshowconfig()
  local ui=autobuildshipui; local s=autobuildshipestimate; ui.header('Estimator setup')
  for _,part in ipairs({'hull','circuits','weapons','engines'}) do
    ui.row(part,'impact '..(s.impacts[part] or 'not set')..' / price '..(s.prices[part] or 'not set'))
  end
  ui.row('Seconds per item',s.secondsPerPart or 'Not set')
  ui.row('Engineers',s.engineers); ui.row('Detail',s.verbose and 'Verbose' or 'Compact')
  ui.print('muted','  Supply your own learned values; no recipe data is bundled.\n')
  ui.command('autobuild config impact [material] [amount]','')
  ui.command('autobuild config price [material] [credits]','')
  ui.command('autobuild config seconds [number]','')
  ui.command('autobuild config engineers [count]','')
  ui.command('autobuild config verbose on','Show arithmetic')
  ui.command('autobuild config verbose off','Compact estimates')
end
function buildshipstartup()
  autobuildshipui.print('muted','  Buildship ready. Type autobuild help.\n')
end
registerAnonymousEventHandler('sysLoadEvent','buildshipstartup')
