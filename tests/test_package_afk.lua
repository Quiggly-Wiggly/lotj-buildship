function resetFormat() end
function setFgColor() end
function echo(t) cecho(t) end
local startupPath, botPath, warningPath = arg[1], arg[2], arg[3]
local sent, timers = {}, {}
local now = 100
function send(command) sent[#sent + 1] = command end
function cecho() end
function registerAnonymousEventHandler() end
function getEpoch() return now end
function tempTimer(seconds, callback)
  assert(seconds == 1, "AFK check must wait one second")
  timers[#timers + 1] = callback
end
local function flush()
  local pending = timers
  timers = {}
  for _, callback in ipairs(pending) do callback() end
end
dofile(startupPath)
local function setup()
  sent = {}
  now = now + 2
  autobuildship = true
  currentbuildship = "lethisk"
  currentbuildpart = "hull"
  autobuildshipresetcycle()
end
for _, afk in ipairs({false, true}) do
  setup()
  dofile(botPath)
  assert(#sent == 1 and sent[1] == "look")
  dofile(botPath)
  assert(#sent == 1 and #timers == 1, "duplicate cooldown must not start another probe")
  assert(not autobuildshipsendbuild(), "build commands must wait for the probe")
  if afk then dofile(warningPath); dofile(warningPath) end
  assert(#sent == 1, "must wait for timeout")
  flush()
  assert(table.concat(sent, "|") == (afk
    and "look|afk|bot start|buildship lethisk hull"
    or "look|bot start|buildship lethisk hull"))
  dofile(warningPath)
  flush()
  assert(#sent == (afk and 4 or 3), "late warning must not toggle AFK")
end
setup()
dofile(warningPath)
assert(#sent == 0 and autobuildshipsafety.afkProbe == nil)
for _, cancel in ipairs({
  function() autobuildshippause("test") end,
  function() autobuildshipstop("test") end,
  function() autobuildshipresetcycle(true); currentbuildship = "other" end,
}) do
  setup()
  dofile(botPath)
  dofile(warningPath)
  cancel()
  local count = #sent
  flush()
  assert(#sent == count, "cancelled probe must not resume or toggle AFK")
end
setup()
autobuildship = false
dofile(botPath)
assert(#sent == 0 and #timers == 0, "inactive cooldown must be ignored")
print("Package AFK recovery tests passed.")
