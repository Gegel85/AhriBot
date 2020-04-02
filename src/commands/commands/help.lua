--{
--	name = "help",
--	usage = "help [<command>]",
--	auth = enums.auth.checkPermission,
--	permission = discord.enums.permission.sendMessages,
--	server_only = false,
--	category = "Miscelaneous",
--	nb_args = {0, 1},
--	short_description = "Helps (a lot)",
--	long_description = "Gives help about a command\nVery usefull informations are displayed",
--}

local enums = require("../../enums")
local utils = require("../../utils")
local commands = require("../../commands")
local discord = require("discordia")
local baseHelp = "Arguments between [] are optionnal.\
Arguments with <> have to be replaced with the actual content you want.\
Arguments are separated with spaces.\
If you want to put spaces inside an argument, put the argument between quotes (\", ” or ')\
You can of course put all the arguments between quotes even if there are no spaces in it, but don't forget to close them !\n\
For a list of commands, run ..commands."
local errorHelp = "No done yet"

local function help(self, message, args)
	local prefix = ".."

	if message.guild then
		message:reply("Help sent in your dms 👍")
	end

	if #args == 0 then
		message.author:send({
			embed = {
				title = "Understanding help pages",
				description = baseHelp,
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif args[1] == "error" then
		message.author:send({
			embed = {
				title = "Understanding error messages",
				description = errorHelp,
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif commands.commands[args[1]] then
		local cmd = commands.commands[args[1]]
		local auth = cmd.auth == enums.auth.everyone and "everyone" or cmd.auth == enums.auth.owner and "bot owner" or "People having "..discord.enums.permission(cmd.permission).." permission"
		message.author:send({
			embed = {
				title = cmd.name,
				description = "`"..prefix..cmd.usage.."`\
Category: __"..cmd.category.."__\
Can be used by: "..auth.."\
"..(cmd.server_only and "*Can only be used in a server*\n" or "")..(cmd.long_description or cmd.short_description or "No help provided"),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	else
		utils.error(message.author:getPrivateChannel(), "Cannot find any command called \""..args[1].."\".\nUse ..commands for a list of commands.", "Unknown command", {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	end
end

return {
	name = "help",
	callback = help,
	usage = "help [<command>|errors]",
	auth = enums.auth.everyone,
	server_only = false,
	category = "Help",
	nb_args = {0, 1},
	short_description = "Shows help for commands",
	long_description = "Displays usage of a command and how the commands behaves.\
If the command is given as parameter, it will show a gide on understanding the help messages.\
Alternatively, if 'errors' is given as parameter, it will show a gide on how to understand error messages.",
}