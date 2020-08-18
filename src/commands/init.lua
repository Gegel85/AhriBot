local utils = require("../utils")
local enums = require("../enums")
local client = require("../client")

--	Example command
--	{
--		name = "help",
--		usage = "help [<command>]",
--		auth = enums.auth.checkPermission,
--		permissions = {discord.enums.permission.sendMessages},
--		server_only = false,
--		category = "Miscelaneous",
--		short_description = "Helps (a lot)",
--		long_description = "Gives help about a command\nVery usefull informations are displayed",
--	}

local function checkPermissions(self, user)
	if user.id == client.owner.id then
		return true
	elseif self.auth == enums.auth.everyone then
		return true
	elseif self.auth == enums.auth.owner then
		return false
	else
		if not user.getPermissions then
			return false
		end
		
		local perms = user:getPermissions()
		
		for i, k in pairs(self.permissions) do
			if not perms:has(k) then
				return false
			end
		end
		return true
	end
	return false
end

local baseCommandTable = {
	checkPermissions = checkPermissions
}

return {
	new = function (callback, cmd)
		callback = callback or function (self, message, args)
			error("This command is not yet implemented")
		end

		for index, value in pairs(baseCommandTable) do
			cmd[index] = value
		end

		return setmetatable(cmd, {
			__call = function (self, message, args)
				message.channel:broadcastTyping()

				if not message.guild and self.server_only then
					utils.error(message.channel, "You need to use this command in a sever", nil, {
						icon_url = message.author.avatarURL,
						text = message.author.name
					})
					return
				elseif not self:checkPermissions(message.member or message.author) then
					utils.error(message.channel, "You are not allowed to use this command", nil, {
						icon_url = message.author.avatarURL,
						text = message.author.name
					})
					return
				elseif self.nb_args then
					local found = false

					for i, k in pairs(self.nb_args) do
						found = found or k == #args
					end
					if not found then
						utils.error(message.channel, "Expected "..table.concat(self.nb_args, " or ").." arguments but "..tostring(#args).." were given.\
Use ..help "..self.name.."", "Bad arguments", {
							icon_url = message.author.avatarURL,
							text = message.author.name
						})
						return
					end
				end
				callback(self, message, args)
			end
		})
	end,
	parse = require("./parse"),
	check = require("./check"),
	add = function (self, callback, cmd)
		self.commands[cmd.name] = self.new(callback, cmd)
		return self.commands[cmd.name]
	end,
	remove = function (self, cmd)
		self.commands[cmd] = nil
	end,
	commands = {}
}