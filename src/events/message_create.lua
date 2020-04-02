local client = require("../client")
local artContest = require("../art_contest")
local utils = require("../utils")
local enums = require("../enums")
local commands = require("../commands")

return function (message)
	if not message or message.author == client.user then
		return
	end

	if artContest.handleMessage(message) then
		return
	end

	local success, start = commands:check(message)

	if not success then
		return
	end
	
	local args, err = commands.parse(message.content:sub(start, #message.content))

	if not args then
		utils.error(message.channel, 'Cannot process command because it is malformed or invalid: '..err, err, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	end
	
	local cmd = table.remove(args, 1)
	local obj = commands.commands[cmd]

	if not obj then
		utils.error(message.channel, 'Unknown command "'..cmd..'"', nil, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	elseif not message.guild and obj.server_only then
		utils.error(message.channel, "You need to use this command in a sever", nil, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	elseif not obj:checkPermissions(message.author) then
		utils.error(message.channel, "You are not allowed to use this command", nil, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	else
		local success, err = pcall(commands.commands[cmd], message, args)

		if not success then
			utils.error(
				message.channel,
				"A fatal error occured when trying to run your command.\
Sorry for the inconvinience.\n\
Command line: `"..tostring(message.content).."`\
Command: `"..cmd.."`\
Args: `"..(#args == 0 and "None" or table.concat(args, "` `")).."`\
Error: ```"..err.."```\
Please report this error to the bot developper.",
				"Fatal error "..enums.emojis.cry, {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			)
		end
	end
end