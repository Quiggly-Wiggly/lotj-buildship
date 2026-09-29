local raw = tostring(matches[2] or ""):gsub(",", "")
autobuildshipestimate.observed = autobuildshipestimate.observed or {}
autobuildshipestimate.observed.circuits = tonumber(raw) or 0
