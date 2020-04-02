local utils = require("../utils")
local loader = require("./loader")
local enums = require("../enums")
local client = require("../client")
local discord = require("discordia")

return function (message)
	local url = message.attachment.url
	local extension = url:match("[.]%w*$"):lower()
	local contest = loader(message.guild)
	local contestChannel = client:getChannel(contest.channel)
	local trashcanChannel = client:getChannel(contest.trashcan)

	if not trashcanChannel then
		return nil, utils.error(contestChannel, "The trashcan channel "..contest.trashcan.." cannot be found")
	end

	utils.download(url, "contests/contest"..message.guild.id.."/image"..message.guild.id.."user"..message.author.id..extension)

	local msg, err = trashcanChannel:send({
		file = "contests/contest"..message.guild.id.."/image"..message.guild.id.."user"..message.author.id..extension
	})
	if not msg then
		return nil, utils.error(contestChannel, "Cannot send message in channel <#"..contest.channel..">:\n"..tostring(err))
	end

	local desc = (contest.hide_owner and "Someone" or "<@"..message.author.id..">").." posted a new image !"
	msg = contestChannel:send({
		embed = {
			image = {
				url = msg.attachment.url
			},
			title = "Art contest",
			description = desc..(message.content and message.content ~= "" and "\nComment: "..message.content or ""),
			color = 0xFFFF00,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = {
				icon_url = contest.hide_owner and enums.images.questionMark or message.author.avatarURL,
				text = (contest.hide_owner and "Someone" or message.author.name).." | 0 votes"
			}
		}
	})
	
	local part = {
		message = msg.id,
		author = message.author.id,
		image = msg.attachment.url,
		votes = 0
	}
	msg:addReaction(contest.emoji_upvote:sub(1, 1) == '<' and contest.emoji_upvote:sub(2, #contest.emoji_upvote - 1) or contest.emoji_upvote)
	if not contest.submission[message.author.id] then
		contest.submission[message.author.id] = {}
	end
	table.insert(contest.submission[message.author.id], part)
	contest:save()
	return msg
end