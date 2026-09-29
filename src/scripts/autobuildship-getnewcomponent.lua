if not autobuildshipguard("get stock") then return end
if not autobuildshipaccept("take:" .. currentbuildpart, 0.75) then return end
send("take 20 " .. currentbuildpart)
autobuildshipsendbuild()

