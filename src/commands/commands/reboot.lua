local enums = require("../../enums")

return {
	name = "reboot",
	callback = function (self, message) message:reply("Restarting...") os.exit(0) end,
	usage = "reboot",
	auth = enums.auth.owner,
	category = "Bot management",
	short_description = "Restarts the bot"
}