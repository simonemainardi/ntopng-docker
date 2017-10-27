local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

sendHTTPContentTypeHeader('text/html')
ntop.dumpFile(dirs.installdir .. "/httpdocs/inc/header.inc")
dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

-- *****************************************************************************

local devices = interface.getMacsInfo(nil, nil, nil, nil, nil,
  true, -- sourceMacsOnly - only devices which have begun at lease one flow
  true  -- hostsMacsOnly - only devices which are associated to an L3 host
)

-- terminal debug
--tprint(devices)

print("<pre>")

for _, device in pairs(devices.macs) do
  print(device.mac)
  print("\tHosts: " .. device["num_hosts"])
  print("\tBytes Sent: " .. bytesToSize(device["bytes.sent"]))
  print("\tBytes Received: " .. bytesToSize(device["bytes.rcvd"]))
  print("\n")
end

print("</pre>")

-- *****************************************************************************

dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")
