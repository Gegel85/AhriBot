local enums = require("../../enums")

local function displayColors(message, edit)
	local roles = loadFile("configs/colorRoles"..message.guild.id)
	local display = {}
	local biggest = 0
	local str = ""
	local nbr = 1
	
	if edit then
		message:setEmbed({})
	end
	for i = 1, #roles, 2 do
		if not display[tonumber(roles[i])] then
			display[tonumber(roles[i])] = {}
		end
		if not message.guild:getRole(roles[i]) then
			biggest = biggest <tonumber(roles[i]) and tonumber(roles[i]) or biggest
			display[tonumber(roles[i])][#display[tonumber(roles[i])] + 1] = roles[i + 1]
		end
	end
	for i = 1, biggest do
		if not display[i] then
			display[i] = {}
		end
	end
	for i, k in pairs(display) do
		if #k > 0 and nbr <= page * 25 and nbr > page * 25 - (25 + #k) then
			str = str.."Level "..i..":\n"
			for j, l in pairs(k) do
				if message.guild:getRole(l) and nbr <= page * 25 and nbr > page * 25 - 25 then
					str = str.."-\t\t<@&"..l..">\n"
				end
				if message.guild:getRole(l) then
					nbr = nbr + 1
				end
			end
			str = str.."\n"
		else
			nbr = nbr + #k
		end
	end
	local new
	if not edit then
		new = message:reply({
			embed = {
				title = "Roles page "..page,
				description = str,
				color = 0xAAAAAA,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	else
		new = message
		new:clearReactions()
		new:setEmbed({
			title = "Roles page "..page,
			description = str,
			color = 0xAAAAAA,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = {
				icon_url = message.author.avatarURL,
				text = message.author.name
			}
		})
	end
	if not new then
		return
	end
	if page > 1 then
		new:addReaction("⬅")
	end
	if page * 25 - nbr < 0 then
		new:addReaction("➡")
	end
end

local function color(self, message, args)
	
end

return {
	name = "color",
	callback = color,
	usage = "color [<colorName>]",
	auth = enums.auth.everyone,
	server_only = true,
	category = "Roles",
	nb_args = {0},
	short_description = "Get a color role.",
	long_description = "Assign a color role from the color list.\nTo see the color list, don't give any parameter to the command.",
}