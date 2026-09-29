local args = tostring(matches[2] or ""):match("^%s*(.-)%s*$")

if args == "" then
    autobuildshipshowconfig()
    return
end

local setting, rest = args:match("^(%S+)%s+(.+)$")
setting = setting and setting:lower() or ""

if setting == "verbose" then
    local mode = tostring(rest or ""):lower():match("^%s*(.-)%s*$")
    if mode ~= "on" and mode ~= "off" then
        cecho("\n<red>Use: autobuild config verbose on|off\n")
        return
    end
    autobuildshipestimate.verbose = mode == "on"
elseif setting == "engineers" or setting == "seconds" then
    local amount = tonumber(rest)
    if not amount or amount ~= amount or amount == math.huge or not (amount > 0) then
        cecho("\n<red>Estimate value must be greater than zero.\n")
        return
    end
    if setting == "engineers" then
        if amount < 1 then
            cecho("\n<red>Engineer count must be at least one.\n")
            return
        end
        autobuildshipestimate.engineers = math.floor(amount)
    else
        autobuildshipestimate.secondsPerPart = amount
    end
elseif setting == "impact" or setting == "price" then
    local part, amountText = rest:match("^(%S+)%s+(%S+)$")
    part = part and part:lower() or ""
    local amount = tonumber(amountText)
    local target = setting == "impact" and autobuildshipestimate.impacts or autobuildshipestimate.prices
    if not ({hull=true,circuits=true,weapons=true,engines=true})[part] or not amount or amount ~= amount or amount == math.huge or not (amount > 0) then
        cecho("\n<red>Use hull, circuits, weapons, or engines and a positive number.\n")
        return
    end
    target[part] = amount
else
    cecho("\n<red>Unknown estimate setting. Enter 'autobuild config' for help.\n")
    return
end

cecho("\n<green>  Setting updated.<reset>\n")
autobuildshipshowconfig()
