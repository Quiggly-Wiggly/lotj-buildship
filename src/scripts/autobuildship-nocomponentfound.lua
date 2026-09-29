if not autobuildshipguard("handle missing stock") then return end

local reported = autobuildshipnormalizepart(matches[2])
if reported ~= currentbuildpart then return end
if not autobuildshipaccept("missing:" .. currentbuildpart, 0.75) then return end

autobuildshipsafety.unavailable[currentbuildpart] = true
cecho("\n<DimGray>LotJ Buildship: No " .. currentbuildpart .. " stock found; trying another component.\n")

local candidate = currentbuildpart
for _ = 1, #autobuildshipparts do
    candidate = autobuildshipnextpart(candidate)
    if not autobuildshipsafety.unavailable[candidate]
      and not autobuildshipsafety.completed[candidate] then
        currentbuildpart = candidate
        send("take 20 " .. currentbuildpart)
        autobuildshipsendbuild()
        return
    end
end

autobuildshippause("No usable stock for any unfinished component. Restock, then use 'autobuild resume'.")
