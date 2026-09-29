local source=arg[1]
local out={}
function cecho(t) out[#out+1]=t end
function registerAnonymousEventHandler() end
dofile(source..'/autobuildship-startup.lua')
autobuildshipestimate.observed={hull=10,circuits=10,weapons=10}
matches={'','10'};dofile(source..'/engines-left.lua')
assert(table.concat(out):find('Use autobuild config',1,true))
for _,part in ipairs({'hull','circuits','weapons','engines'}) do
 autobuildshipestimate.impacts[part]=2;autobuildshipestimate.prices[part]=3
end
autobuildshipestimate.secondsPerPart=4;out={};dofile(source..'/engines-left.lua')
local text=table.concat(out)
assert(text:find('20') and text:find('60') and text:find('1m 20s'))
print('Estimator requires local values and calculates synthetic inputs correctly.')
