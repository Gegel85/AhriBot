local enums = require("../../enums")
local utils = require("../../utils")
local client = require("../../client")
local discord = require("discordia")

local function getAvatar(self, message, args)
	local name = table.concat(args, " ")
	local recievers = utils.getReciever(name, message.guild)

	if #recievers == 0 then
		utils.error(message.channel, "Couldn't find anyone called '"..name.."'", nil, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	elseif #recievers > 1 then
		local str = ""
		
		for i, k in pairs(recievers) do
			str = str.."\t\t-\t\t<@"..k..">\n"
		end

		utils.error(message.channel, "Found multiple user called "..args[1]..":\n"..str, nil, {
			icon_url = message.author.avatarURL,
			text = message.author.name
		})
	else
		local user = client:getUser(recievers[1])

		message:reply({
			embed = {
				title = user.name.."'s avatar",
				image = {
					url = user.avatarURL
				},
				color = 0x00FF00,
				footer = {
					text = message.author.name,
					icon_url = message.author.avatarURL
				}
			}
		})
	end
end

return {
	name = "avatar",
	callback = getAvatar,
	usage = "avatar <user>",
	auth = enums.auth.everyone,
	server_only = false,
	category = "Miscellaneous",
	short_description = "Displays the avatar of the given user.",
	long_description = "",
}