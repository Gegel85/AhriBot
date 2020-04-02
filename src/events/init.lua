local client = require("../client")

local function protector(file)
	local func = require("./"..file)

	return function (...)
		local success, err = pcall(func, ...)

		if not success then
			print("Error in event handler "..file..":\n"..err)
			if client.owner then
				client.owner:send("Error in event handler "..file..":\n"..err)
			end
		end
	end
end

return {
	ready =               protector("on_ready"),
	messageCreate =       protector("message_create"),
	--messageUpdate =       protector("message_update"),
	--messageDelete =       protector("message_delete"),
	--memberJoin =          protector("member_joining"),
	--memberLeave =         protector("member_leaving"),
	--reactionAdd =         protector("reaction_add"),
	--reactionAddUncached = protector("reaction_add_uncached"),
	--channelCreate =       protector("channel_created"),
	--channelUpdate =       protector("channel_updated"),
	--channelDelete =       protector("channel_deleted"),
	--userBan =             protector("user_banned"),
	--userUnban =           protector("user_unbanned")
}