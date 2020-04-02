require("./src/commands/builtins")

local token = require("./ahri_token")
local events = require("./src/events")
local client = require("./src/client")

for event, handler in pairs(events) do
	client:on(event, handler)
end

client:run("Bot "..token)
