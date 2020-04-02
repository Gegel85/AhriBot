local discord = require("discordia")

return function (channel, err, title, footer)
	channel:send({
		embed = {
			title = title or "Error",
			description = err,
			color = 0xFF0000,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = footer
		}
	})
end