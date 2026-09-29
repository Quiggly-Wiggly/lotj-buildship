if not autobuildshipguard("resume after bot cooldown") then return end
if not autobuildshipaccept("bot-restart", 1.5) then return end
if autobuildshipsafety.afkProbe then return end
local probe = {isAfk = false}
autobuildshipsafety.afkProbe = probe
send("look")
tempTimer(1, function()
    if autobuildshipsafety.afkProbe ~= probe then return end
    autobuildshipsafety.afkProbe = nil
    if not autobuildshipguard("resume after AFK check") then return end
    if probe.isAfk then send("afk") end
    send("bot start")
    autobuildshipsafety.botStarted = true
    autobuildshipsendbuild()
end)
