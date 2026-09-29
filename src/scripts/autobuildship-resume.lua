local shipName = autobuildshipvalidship(currentbuildship)
local part = autobuildshipnormalizepart(currentbuildpart)
if not shipName or not part then
    autobuildshippause("Cannot resume: select a valid ship and component first.")
    return
end
currentbuildship = shipName
currentbuildpart = part
autobuildshipsafety.unavailable = {}
autobuildshipsafety.lastAction = {}
autobuildshipsafety.partTransition = nil
autobuildshipsafety.shipTransition = false
autobuildshipsafety.inspectTransition = nil
local wasRunning = autobuildship == true
autobuildship = true
cecho("\n<green>LotJ Buildship: <white>" .. (wasRunning and "Retrying " or "Resuming ")
  .. currentbuildship .. " at " .. currentbuildpart .. ".\n")
autobuildshipsendbuild()
