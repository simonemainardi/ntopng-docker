local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

-- json library
local json = require "dkjson"

-- host discovery utils
local discover = require "discover_utils"

sendHTTPContentTypeHeader('text/html')
ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")
dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

-- Some defines
SAFE_BROWSING_BASE_URL = "https://safebrowsing.googleapis.com/v4/threatMatches:find"
API_KEY = "AIzaSyAo83nAdynv_mn-WQQh7y8OwfNc2CfUmRQ"
SAFE_BROWSING_FULL_URL = SAFE_BROWSING_BASE_URL .. "?key=" .. API_KEY

-- Some helpers
local function exec_command(c)
  -- Debug
  io.write(c .. "\n")
  local f = assert(io.popen(c, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return s
end

-- Get the active HTTP flows
local flows = interface.getFlowsInfo(nil, {
  l7protoFilter = interface.getnDPIProtoId("HTTP"), -- only get HTTP flows
  detailsLevel = "max",                             -- get all the flow details
})

-- URLs to check
local urls = {}

for _, flow in pairs(flows.flows) do
  urls[#urls + 1] = {url=flow.host_server_name}
end

-- Build the request
local request = {
  threatInfo = {
    threatTypes = { "MALWARE", "SOCIAL_ENGINEERING",
      "POTENTIALLY_HARMFUL_APPLICATION", "UNWANTED_SOFTWARE"},
    platformTypes = { "WINDOWS", },
    threatEntryTypes = { "URL", },
    threatEntries = urls, -- the URL to check
  }
}

-- Format lua table into JSON data
local json_request = json.encode(request)

-- Perform the actual POST request
local response_data = exec_command(
  "curl -H 'Content-Type: application/json' -s --data '" ..  json_request ..
  "' " .. SAFE_BROWSING_FULL_URL)

-- Parse the result
local response = json.decode(response_data)

if (response ~= nil) and (response.matches ~= nil) then
  print("<h2>Malware sites detected</h2>")
  print("<pre>")

  for _, match in pairs(response.matches) do
    print(match.threat.url .. " : " .. match.threatType .. "\n")
  end

  print("</pre>")
else
  print("<h2>No malware sites found</h2>")
end

dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")
