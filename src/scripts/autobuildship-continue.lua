if not autobuildshipguard("continue building") then return end
local message = tostring(matches[1] or "")
local finishedShip = message:find("You step away from your finished ", 1, true) ~= nil
local completedWork = message == "You finish modifying the ship."
local actionKey = finishedShip and "verify-finished-ship" or ("continue:" .. currentbuildpart)
if not autobuildshipaccept(actionKey, 0.5) then return end
autobuildshipsafety.unavailable[currentbuildpart] = nil

if completedWork then
    autobuildshipsafety.workCount = (tonumber(autobuildshipsafety.workCount) or 0) + 1
    local every = math.max(1, math.floor(tonumber(autobuildshipexamineevery) or 5))
    if autobuildshipsafety.workCount % every == 0 then
        cecho("\n<DimGray>LotJ Buildship: " .. autobuildshipsafety.workCount
          .. " work actions complete; examining " .. currentbuildship .. ".\n")
        send("examine " .. currentbuildship)

        local expectedShip = currentbuildship
        local expectedPart = currentbuildpart
        local transition = {}
        autobuildshipsafety.inspectTransition = transition
        local function continueAfterExamine()
            if autobuildshipsafety.inspectTransition ~= transition then return end
            autobuildshipsafety.inspectTransition = nil
            if autobuildship and currentbuildship == expectedShip and currentbuildpart == expectedPart then
                autobuildshipsendbuild()
            end
        end
        if type(tempTimer) == "function" then
            tempTimer(0.25, continueAfterExamine)
        else
            continueAfterExamine()
        end
        return
    end
end

autobuildshipsendbuild()
