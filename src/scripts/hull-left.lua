local raw = tostring(matches[2] or ""):gsub(",", "")
autobuildshipestimate.observed = {hull = tonumber(raw) or 0}

