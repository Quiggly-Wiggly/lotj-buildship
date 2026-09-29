if not autobuildship then return end
local activeShip = autobuildshipvalidship(currentbuildship)
if not activeShip then
    autobuildshippause("A completion message arrived without a valid current ship.")
    return
end
if autobuildshipsafety.shipTransition then return end
autobuildshipsafety.shipTransition = true
currentbuildship = activeShip

queuedShips = type(queuedShips) == "table" and queuedShips or {}
local oldShip = currentbuildship or "current frame"
cecho("\n<yellow>LotJ Buildship: <white>" .. oldShip .. " is not here; removed only that queue position.\n")

local nextShip
while #queuedShips > 0 and not nextShip do
    local candidate = table.remove(queuedShips, 1)
    nextShip = autobuildshipvalidship(candidate)
    if not nextShip then
        cecho("<yellow>LotJ Buildship: Removed an invalid queue entry.\n")
    end
end

if nextShip then
    currentbuildship = nextShip
    currentbuildpart = "hull"
    autobuildshipresetcycle(true)
    cecho("<green>LotJ Buildship: <white>Building next: " .. currentbuildship .. "\n")
    local expectedShip = currentbuildship
    local function beginNextShip()
        if not autobuildshipsafety.shipTransition then return end
        autobuildshipsafety.shipTransition = false
        if autobuildship and currentbuildship == expectedShip then autobuildshipsendbuild() end
    end
    if type(tempTimer) == "function" then
        tempTimer(0.35, beginNextShip)
    else
        beginNextShip()
    end
else
    autobuildshipstop("Queue finished.")
end
