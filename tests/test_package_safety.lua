function resetFormat() end
function setFgColor() end
function echo(t) cecho(t) end
local startupPath, missingPath, donePath, nextPath, continuePath, resumePath =
  arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]
assert(startupPath and missingPath and donePath and nextPath and continuePath and resumePath,
  "expected six extracted package scripts")

local sent = {}
local output = {}
local timers = {}
local fakeNow = 100

function send(command)
  sent[#sent + 1] = command
end

function cecho(message)
  output[#output + 1] = message
end

function registerAnonymousEventHandler() end
function getEpoch() return fakeNow end
function tempTimer(_, callback)
  timers[#timers + 1] = callback
  return #timers
end

local function runTimers()
  local pending = timers
  timers = {}
  for _, callback in ipairs(pending) do callback() end
end

dofile(startupPath)

assert(autobuildshipnormalizepart("Engines") == "engine")
assert(autobuildshipnormalizepart("circuit") == "circuits")
assert(autobuildshipvalidship(" frame ") == "frame")
assert(autobuildshipvalidship("bad;command") == nil)

autobuildship = true
currentbuildship = nil
currentbuildpart = "hull"
local before = #sent
assert(autobuildshipsendbuild() == false)
assert(autobuildship == false)
assert(#sent == before)

autobuildship = true
currentbuildship = "frame"
currentbuildpart = "hull"
autobuildshipresetcycle()

local function reportMissing(part)
  matches = {"I see no " .. part .. " here.", part}
  dofile(missingPath)
  fakeNow = fakeNow + 1
end

reportMissing("hull")
assert(currentbuildpart == "circuits")
reportMissing("circuits")
assert(currentbuildpart == "weapons")
reportMissing("weapons")
assert(currentbuildpart == "engine")
before = #sent
reportMissing("engine")
assert(autobuildship == false)
assert(#sent == before, "all-unavailable guard must not send another command")

autobuildship = true
currentbuildship = "frame"
currentbuildpart = "hull"
queuedShips = {"frame", "other"}
autobuildshipresetcycle()
matches = {"Example Freighter isn't here anymore!"}
dofile(donePath)
assert(currentbuildship == "frame", "first duplicate-name queue entry should become current")
assert(#queuedShips == 1 and queuedShips[1] == "other")

dofile(donePath)
assert(currentbuildship == "frame", "duplicate completion event must not skip the new current frame")
assert(#queuedShips == 1 and queuedShips[1] == "other")

runTimers()
fakeNow = fakeNow + 2
dofile(donePath)
assert(currentbuildship == "other")
assert(#queuedShips == 0)

runTimers()
fakeNow = fakeNow + 2
matches = {"You step away from your finished other."}
dofile(continuePath)
assert(autobuildship == true and currentbuildship == "other" and #queuedShips == 0,
  "a local finished message must probe, not advance the queue")

matches = {"You don't see a ship like that nearby to work on."}
dofile(donePath)
assert(autobuildship == false and currentbuildship == nil and currentbuildpart == nil)

autobuildship = true
currentbuildship = "frame"
currentbuildpart = "hull"
autobuildshipresetcycle()
matches = {"Your frame doesn't need any more of that.", "frame"}
dofile(nextPath)
assert(currentbuildpart == "circuits")
dofile(nextPath)
assert(currentbuildpart == "circuits", "duplicate component event must not advance twice")
runTimers()

for _, expected in ipairs({"weapons", "engine", "hull"}) do
  matches = {"Your frame doesn't need any more of that.", "frame"}
  dofile(nextPath)
  assert(currentbuildpart == expected)
  runTimers()
end
assert(autobuildship == true and currentbuildpart == "hull",
  "all four complete component replies must begin another verification pass")
for _, message in ipairs(output) do
  assert(not message:find("waiting for the game's ship%-completion message"),
    "the package must never wait for a character-specific completion message")
end

autobuildship = true
currentbuildship = "frame"
currentbuildpart = "hull"
autobuildshipresetcycle()
local examineCount = 0
for _ = 1, 5 do
  fakeNow = fakeNow + 1
  matches = {"You finish modifying the ship."}
  dofile(continuePath)
end
for _, command in ipairs(sent) do
  if command == "examine frame" then examineCount = examineCount + 1 end
end
assert(examineCount == 1, "the fifth successful work action must examine the current keyword")
assert(autobuildshipsafety.workCount == 5)
runTimers()
assert(sent[#sent] == "buildship frame hull", "building must continue after the examine command")

autobuildshipsafety.partTransition = {}
autobuildshipsafety.shipTransition = true
autobuildshipsafety.inspectTransition = {}
local sentBeforeResume = #sent
dofile(resumePath)
assert(autobuildship == true)
assert(#sent == sentBeforeResume + 1 and sent[#sent] == "buildship frame hull",
  "resume must retry even when automation already reports running")
assert(autobuildshipsafety.partTransition == nil
  and autobuildshipsafety.shipTransition == false
  and autobuildshipsafety.inspectTransition == nil)

autobuildship = false
sentBeforeResume = #sent
dofile(resumePath)
assert(autobuildship == true and #sent == sentBeforeResume + 1,
  "resume must restart and retry after the running flag is turned off")

print("package safety tests passed")
