local raw = tostring(matches[2] or ""):gsub(",", "")
autobuildshipestimate.observed = autobuildshipestimate.observed or {}
autobuildshipestimate.observed.weapons = tonumber(raw) or 0
