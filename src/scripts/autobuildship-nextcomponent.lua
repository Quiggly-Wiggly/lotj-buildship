if not autobuildshipguard("advance components") then return end
if autobuildshipsafety.partTransition then return end
local finishedPart = currentbuildpart
local transition = {}
autobuildshipsafety.partTransition = transition

autobuildshipsafety.completed[finishedPart] = true
send("drop 100 " .. finishedPart)

local allComplete = true
for _, part in ipairs(autobuildshipparts) do
    if not autobuildshipsafety.completed[part] then
        allComplete = false
        break
    end
end
if allComplete then
    -- Another engineer may finish the frame, so never wait for a completion
    -- message this character might not receive. Begin another verification
    -- pass and let the authoritative missing-frame response advance the queue.
    autobuildshipsafety.completed = {}
end

currentbuildpart = autobuildshipnextpart(finishedPart)
local expectedShip = currentbuildship
local expectedPart = currentbuildpart
local function beginNextPart()
    if autobuildshipsafety.partTransition ~= transition then return end
    autobuildshipsafety.partTransition = nil
    if autobuildship and currentbuildship == expectedShip and currentbuildpart == expectedPart then
        autobuildshipsendbuild()
    end
end
if type(tempTimer) == "function" then
    tempTimer(0.25, beginNextPart)
else
    beginNextPart()
end

