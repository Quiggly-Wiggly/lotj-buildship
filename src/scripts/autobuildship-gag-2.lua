local option = tostring(matches[2] or "")
if not autobuildshipgag then
    autobuildshipgag = true
    cecho("\n<orange>LotJ Buildship:<white> Ship-building spam gagged.\n")
else
    autobuildshipgag = false
    cecho("\n<orange>LotJ Buildship:<white> Ship-building spam ungagged.\n")
    if autobuildshippromptgagged then
        send("config +prompt")
        autobuildshippromptgagged = false
    end
end
if autobuildshipgag and option:find("prompt") then
    cecho("\n<orange>LotJ Buildship:<white> Turning off prompt for minimal spam.\n")
    send("config -prompt")
    autobuildshippromptgagged = true
end
