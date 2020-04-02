local json = require("json")
local enums = require("../enums")
local utils = require("../utils")
local commands = require("./init")
local discord = require("discordia")
local cmds = {
	
}

for i, k in pairs(cmds) do
	local callback = k.callback
	
	k.callback = nil
	commands:add(callback, k)
end



local function makeAction(filepath)
	local name = filepath:match(".*[.]")
	local file = io.open("actions/"..filepath)
	local database, _, err = json.decode(file:read("*a"))

	name = name:sub(1, #name - 1)
	print("Making action "..name.." (filepath: "..filepath..")")
	file:close()

	if not database then
		error("actions/"..filepath..": "..err)
	end

	local function action(self, message, args)
		local random
		local recievers = {}
		local recieversSet = {}

		--TODO
		for i, _ in pairs(args) do
			for _, l in pairs(utils.getReciever(args[i], message.guild)) do
				recieversSet[l] = true
			end
		end

		for i, _ in pairs(recieversSet) do
			table.insert(recievers, 1, i)
		end

		if database.self and (not recievers or not recievers[1] or #recievers == 1 and recievers[1] == message.author.id) then
			message:reply({
				embed = {
					description = "<@"..message.author.id.."> "..name.."s themselves",
					image = {
						url = database.self[math.random(1, #database.self)],
						width = 640,
						height = 640
					},
					color = 0xFF00FF,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})

		else
			random = math.random(1, (database.fail and #database.fail or 0) + #database.success)
			local reciever = ""
			for i, k in pairs(recievers) do
				if i == #recievers - 1 then
					reciever = reciever.."<@"..k.."> and "
				elseif i ~= #recievers then
					reciever = reciever.."<@"..k..">, "
				else
					reciever = reciever.."<@"..k..">"
				end
			end

			if (random > #database.success) then
				message:reply({
					embed = {
						description = "<@"..message.author.id.."> wanted to "..name.." "..reciever.." but failed",
						image = {
							url = database.fail[random - #database.success],
							width = 640,
							height = 640
						},
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				message:reply({
					embed = {
						description = reciever.."<@"..message.author.id.."> "..name.."s "..reciever.." "..(enums.emojis[name] or enums.emojis.evil),
						image = {
							url = database.success[random],
							width = 640,
							height = 640
						},
						color = 0xFF8800,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			end
		end
	end

	commands:add(action, {
		name = name,
		usage = name.." [<user1>, [<user2>, [...]]]",
		auth = enums.auth.everyone,
		category = "Actions",
		short_description = "Gives a "..name.." to people",
		long_description = "",
		server_only = false
	})
end

for _, k in pairs(utils.scanDir("actions")) do
	makeAction(k)
end