local startupPath,helpPath,configPath,queuePath=arg[1],arg[2],arg[3],arg[4]
local output,links={},{}
function cecho(t) output[#output+1]=t end
function echo(t) output[#output+1]=t end
function resetFormat() end
function setFgColor() end
function registerAnonymousEventHandler() end
function send() error('UI must not send commands') end
function printCmdLine(t) draft=t end
function echoLink(label,fn) links[#links+1]=fn;echo(label) end
local function screen(path,args)
 output={}; matches={'',args or ''};dofile(path);return table.concat(output)
end
dofile(startupPath)
assert(next(autobuildshipestimate.impacts)==nil and next(autobuildshipestimate.prices)==nil)
assert(autobuildshipestimate.secondsPerPart==nil,'No learned timing default')
local help=screen(helpPath)
for _,cmd in ipairs({'autobuild add','autobuild start','autobuild pause','autobuild resume','autobuild config'}) do assert(help:find(cmd,1,true)) end
local _,lines=help:gsub('\n','');assert(lines<=20,'Compact help')
for line in help:gmatch('[^\n]+') do assert(#line<=72) end
currentbuildship='example frame';autobuildship=true;queuedShips={'second','second'}
local queue=screen(queuePath);assert(queue:find('01') and queue:find('02') and #queuedShips==2)
assert(screen(configPath):find('not set',1,true))
screen(configPath,'impact hull 2');screen(configPath,'price hull 3');screen(configPath,'seconds 4')
assert(autobuildshipestimate.impacts.hull==2 and autobuildshipestimate.prices.hull==3)
screen(configPath,'price unknown 7');assert(autobuildshipestimate.prices.unknown==nil)
for _,fn in ipairs(links) do fn();assert(type(draft)=='string') end
assert(autobuildship==true and #queuedShips==2)
dofile(startupPath);assert(autobuildshipestimate.prices.hull==3)
print('Compact help, empty defaults, setup, links, and queue preservation passed.')
