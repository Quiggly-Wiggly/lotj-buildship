local raw = tostring(matches[2] or ""):gsub(",", "")
autobuildshipestimate.observed = autobuildshipestimate.observed or {}
autobuildshipestimate.observed.engines = tonumber(raw) or 0

local observed = autobuildshipestimate.observed
local order = {"hull", "circuits", "weapons", "engines"}
local labels = {
    hull = "Hull sheets",
    circuits = "Circuit bundles",
    weapons = "Weapon boxes",
    engines = "Engine boxes",
}

for _, part in ipairs(order) do
    if observed[part] == nil then return end
end

for _, part in ipairs(order) do
    if not autobuildshipestimate.impacts[part] or not autobuildshipestimate.prices[part]
      or not autobuildshipestimate.secondsPerPart then
        cecho("\n<yellow>Estimate needs your values. Use autobuild config.<reset>\n")
        return
    end
end
local totalParts = 0
local materialCost = 0
local rows = {}
for _, part in ipairs(order) do
    local required = observed[part]
    local impact = tonumber(autobuildshipestimate.impacts[part])
    local price = tonumber(autobuildshipestimate.prices[part])
    if required ~= required or required == math.huge or required < 0
      or not impact or impact ~= impact or impact == math.huge or impact <= 0
      or not price or price ~= price or price == math.huge or price < 0 then
        cecho("\n<red>LotJ Buildship ESTIMATE: Invalid " .. part .. " requirement, impact, or price.\n")
        return
    end
    local exact = required / impact
    local whole = math.ceil(exact)
    local subtotal = whole * price
    totalParts = totalParts + whole
    materialCost = materialCost + subtotal
    rows[#rows + 1] = {
        part = part, label = labels[part], required = required, impact = impact,
        exact = exact, whole = whole, price = price, subtotal = subtotal,
    }
end

local engineers = math.max(1, math.floor(tonumber(autobuildshipestimate.engineers) or 1))
local secondsPerPart = tonumber(autobuildshipestimate.secondsPerPart)
local cycles = math.ceil(totalParts / engineers)
local elapsedSeconds = cycles * secondsPerPart

local function formatDuration(value)
    local seconds = math.floor((tonumber(value) or 0) + 0.5)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    seconds = seconds % 60
    if hours > 0 then
        return string.format("%dh %02dm %02ds", hours, minutes, seconds)
    end
    return string.format("%dm %02ds", minutes, seconds)
end

if autobuildshipestimate.verbose then
    cecho("\n<cyan>Build estimate <DimGray>(detailed)\n")
    for _, row in ipairs(rows) do
        cecho("<DimGray>  " .. row.label .. ": <white>"
          .. autobuildshipformatnumber(row.required) .. " / " .. autobuildshipformatnumber(row.impact)
          .. " = " .. string.format("%.2f", row.exact) .. " -> " .. row.whole
          .. " stock x " .. autobuildshipformatnumber(row.price) .. "c = "
          .. autobuildshipformatnumber(row.subtotal) .. "c\n")
    end
else
    cecho("\n<cyan>Stock to buy\n")
    for _, row in ipairs(rows) do
        cecho("<DimGray>  stock <white>" .. string.format("%-5d", row.whole)
          .. "<cyan>" .. row.part .. "\n")
    end
end
cecho("<DimGray>  Total: <white>" .. autobuildshipformatnumber(totalParts)
  .. " parts  <DimGray>Cost: <white>" .. autobuildshipformatnumber(materialCost) .. "c\n")
cecho("<DimGray>  ETA: <white>" .. formatDuration(elapsedSeconds)
  .. " <DimGray>@ <white>" .. engineers .. " engineer(s)\n\n")
