local enums = require("../../enums")
local utils = require("../../utils")
local commands = require("../../commands")
local discord = require("discordia")

local function listCommands(self, message, args)
	local categories = {}
	local fields = {}
	local prefix = ".."
	
	for _, cmd in pairs(commands.commands) do
		if cmd:checkPermissions(message.member or message.author) then
			if not categories[cmd.category] then
				categories[cmd.category] = {}
			end
			table.insert(categories[cmd.category], 1, cmd.usage)
		end
	end
	
	for category, commands in pairs(categories) do
		fields[#fields + 1] = {
			name = category,
			value = "`"..prefix..table.concat(commands, "`\n`"..prefix).."`"
		}
	end
	
	message:reply({
		embed = {
			title = "Commands list",
			description = "Use "..prefix.."help <command> for a more detailed explanation of a command.",
			color = 0x00FF00,
			fields = fields,
			footer = {
				text = message.author.name,
				icon_url = message.author.avatarURL
			}
		}
	})
end

return {
	name = "commands",
	callback = listCommands,
	usage = "commands",
	auth = enums.auth.everyone,
	server_only = false,
	category = "Help",
	nb_args = {0},
	short_description = "Shows the list of all commands sorted by category.",
	long_description = "",
}