local loader = require("./loader")
local addMessageArtContest = require("./add_message")
local client = require("../client")

return function (message)
	if not message.guild or message.author.id == client.user.id then
		return false
	end

	local contest = loader(message.guild)

	if not contest or contest.channel ~= message.channel.id then
		return false
	end

	if not contest.submitLimit or #(contest.submissions[message.author.id] or {}) < contest.submitLimit and message.attachment then
		local extension = string.lower(message.attachment.url:sub(#url - 3, #message.attachment.url))
		
		if extension == ".png" or extension == ".jpg" or extension == ".gif" then
			addMessageArtContest(message)
		end
	end
	message:delete()
	return true
end