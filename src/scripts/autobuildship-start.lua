local shipName = autobuildshipvalidship(currentbuildship)
if not shipName then
    autobuildshippause("No valid ship selected. Use 'autobuild add <ship>'.")
    return
end
if autobuildship then
    cecho("\n<yellow>LotJ Buildship: Already running; start command ignored.\n")
    return
end
currentbuildship = shipName
currentbuildpart = autobuildshipnormalizepart(currentbuildpart) or "hull"
autobuildshipresetcycle()

send("drop 100 engine")
send("drop 100 hull")
send("drop 100 circuit")
send("drop 100 weapons")
send("stand")
autobuildship = true
cecho("\n<green>LotJ Buildship: <white>Starting " .. currentbuildship .. " at " .. currentbuildpart .. ".\n")
autobuildshipsendbuild()
