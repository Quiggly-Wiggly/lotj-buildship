queuedShips = type(queuedShips) == "table" and queuedShips or {}
local shipName = autobuildshipvalidship(matches[2])
if not shipName then
    cecho("\n<red>LotJ Buildship: Ship name is empty, too long, or contains unsafe characters.\n")
    return
end

if not autobuildshipvalidship(currentbuildship) then
    currentbuildship = shipName
    cecho("\n<orange>LotJ Buildship: <white>" .. shipName .. " selected.\n")
else
    table.insert(queuedShips, shipName)
    cecho("\n<orange>LotJ Buildship: <white>" .. shipName .. " added to the build queue.\n")
end

