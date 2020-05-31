local discord = require("discordia")
local timer = require("timer")
local emitter = discord.Emitter()
local client = discord.Client {
	cacheAllMembers = true,
}
local last_day = math.floor(os.time() / 86400)
local token = require("ahri_token")
local http = require("coro-http")
local my_id = "159735059421724672"
local event = {begin = 0, duration = 0}
local already_claimed = {}
local shop = {}
local defaultActions = {}
local whitelist = {}
local daily_reward = 250
local displaysResult = false
local buffering = false
local big_issue = false
local transformToNbr = tonumber
local xpCooldown = {}
local data = nil
local mutedPeople = {}
local unsuccessfull = {}
local escapist = {}
local grabingMee6data = {}
local emojis = {
	cry = "<:cry:418150405147459604>",
	loveyou = "<:loveyou:413686333714726913>",
	essencesEmoji = "<:essencetheft:414363733960163349>",
	defaultShopIcon = "<:Ahri:248944822289825792>",
	no = "<:no:413696297904766976>",
	yes = "<:yes:413696297338404864>",
	thinking = "<:thinking:413696202916495370>",
	badReputation = "<:charmed:415144802447785985>",
	goodReputation = "<:hi:414387549293772801>",
	blush = "<:blush:413696358546014208>",
	hi = "<:hi:414387549293772801>",
	evil = "<:evil:365891335221149696>",
	tilt = "<:tilt:414426713594789888>",
	ban = "<:dab:391584433825644545>",
	nrjEmojis = {
		"<:nrj_0:422814250956750875>",
		"<:nrj_1:422814251095425035>",
		"<:nrj_2:422814251149688832>",
		"<:nrj_3:422814251271585800>"
	}
}
local food = {
    {
        name = "Fruits",
        value = 1,
        chance = 60,
        elements = {
            "🍏",
            "🍎",
            "🍐",
            "🍊",
            "🍋",
            "🍌",
            "🍉",
            "🍇",
            "🍓",
            "🍈",
            "🍒",
            "🍑",
            "🍍",
            "🍅",
            "🥝"
        }
    },
    {
        name = "Vegetables",
        value = 2,
        chance = 25,
        elements = {
            "🍆",
            "🌶",
            "🌽",
            "🍠",
            "🥕",
            "🥒",
            "🥔"
        }
    },
    {
        name = "Bakeries",
        value = 4,
        chance = 10,
        elements = {
            "🍞",
            "🍰",
            "🍩",
            "🍪",
            "🥖",
            "🥐"
        }
    },
    {
        name = "Food",
        value = 7,
        chance = 5,
        elements = {
            "🌮",
            "🥞",
            "🥙",
            "🍔",
            "🌭",
            "🍝",
            "🍕"
        }
    }
}
math.randomseed(os.time())

function tonumber(nbr, base)
    if not nbr then
        return nil
    end
    for i = 1, #tostring(nbr) do
        if (string.sub(tostring(nbr), i, i) == ".") then
            return
        end
    end
    return transformToNbr(nbr, base)
end

function on_ready()
	print("Connected on "..client.user.username)
	client:getUser(my_id):send({
		embed = {
			title = "Startup",
			description = "Bot started up",
			color = 0xFFFF00
		}
	})
	client:setGame("..help for help")
    loadEvent()
    loadClaimed()
    loadWhiteList()
end

function saveShop(id)
    local file = io.open("configs/shop"..id, "w+")
    
    if file == nil then
        return
    end
    io.output(file)
    for i, k in pairs(shop) do
        io.write(k.type.."\n")
        io.write(k.name.."\n")
        io.write(k.icon.."\n")
        io.write(k.price.."\n")
    end
    io.close(file)
end

function saveWhiteList()
    local file = io.open("configs/whitelist", "w+")
    
    if file == nil then
        return
    end
    io.output(file)
    for i, k in pairs(whitelist) do
        io.write(k.."\n")
    end
    io.close(file)
end

function loadWhiteList()
    local file = io.open("configs/whitelist", "r")
    local line = ""

    whitelist = {}
    if file == nil then
        return
    end
    io.input(file)
    line = io.read()
    while line ~= nil do
        whitelist[#whitelist + 1] = line
        line = io.read()
    end
    io.close(file)
end

function giveRole(member, roleid, price)
    if (roleid ~= nil and roleid ~= "none" and member:addRole(string.sub(roleid, 4, #roleid - 1))) then
        saveMoney(member.id, getMoney(member.id) - price)
        return true
    end
    return false
end

function giveItem(member, item, price)
    
end

function loadShop(id)
    defaultActions = {Roles = giveRole, Item = giveItem}
    local file
    local line = ""

    shop = {}
    if not id then
        return
    end
    file = io.open("configs/shop"..id, "r")
    if file == nil then
        return
    end
    io.input(file)
    line = io.read()
    while line ~= nil do
        shop[#shop + 1] = {}
        shop[#shop].type = line
        shop[#shop].name = io.read()
        shop[#shop].icon = io.read()
        shop[#shop].price = tonumber(io.read())
        shop[#shop].action = defaultActions[shop[#shop].type]
        line = io.read()
    end
    io.close(file)
end

function isWhitelisted(member)
	if (member == nil) then
		return (false)
	elseif (member.id == my_id) then
		return (true)
	end
    for i, k in pairs(whitelist) do
        if (member.id == k) then
            return (true)
        end
    end
	return (false)
end

function scanDir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"')

    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function cleanBackslash(str)
    local i = 1
    
    while i <= #str do
        if (string.sub(str, i, i) == "\\") then
            str = string.sub(str, 1, i - 1)..string.sub(str, i + 1, #str)
            i = i - 1
        end
        i = i + 1
    end
    return str
end

function parseCommand(content, begin, putCommandInArgs)
    local command = ""
    local args = {}
    local tab = 1
    local q = false
	local s_q = false
	local wierd_q = false
	local wierd_q2 = false

    if (content == nil) then
        return nil
    end
    i = begin
    while string.sub(content, i, i) == " " do
        i = i + 1
    end
    begin = i
    if (not putCommandInArgs) then
        while (string.sub(content, i, i) ~= "" and string.sub(content, i, i) ~= " ") do
            i = i + 1
        end
        command = string.lower(string.sub(content, begin, i - 1))
        i = i + 1
    end
    while (i <= #content) do
        while (string.sub(content, i, i) == " ") do
            i = i + 1
        end
        start = i
        if (string.sub(content, i, i) == "\"") then
            start = start + 1
            i = i + 1
            q = true
        elseif (string.sub(content, i, i) == "\'") then
            start = start + 1
            i = i + 1
            s_q = true
        elseif (string.sub(content, i, i) == "“") then
            start = start + 1
            i = i + 1
            wierd_q = true
        elseif (string.sub(content, i, i) == "“") then
            start = start + 1
            i = i + 1
            wierd_q2 = true
        end
        while string.sub(content, i, i) ~= "" and (string.sub(content, i, i) ~= " " or q or s_q) do
            i = i + 1
            if (string.sub(content, i, i) == "\"" and (string.sub(content, i - 1, i - 1) ~= "\\" or string.sub(content, i - 2, i - 2) == "\\") and not s_q) then
                q = false
            elseif (string.sub(content, i, i) == "\'" and (string.sub(content, i - 1, i - 1) ~= "\\" or string.sub(content, i - 2, i - 2) == "\\") and not q) then
                s_q = false
            elseif (string.sub(content, i, i) == "”" and (string.sub(content, i - 1, i - 1) ~= "\\" or string.sub(content, i - 2, i - 2) == "\\") and not wierd_q) then
                wierd_q = false
            elseif (string.sub(content, i, i) == "“" and (string.sub(content, i - 1, i - 1) ~= "\\" or string.sub(content, i - 2, i - 2) == "\\") and not wierd_q) then
                wierd_q2 = false
            end
        end
        if (string.sub(content, i - 1, i - 1) == "\"" or string.sub(content, i - 1, i - 1) == "\'" or string.sub(content, i - 1, i - 1) == "”" or string.sub(content, i - 1, i - 1) == "“") then
            i = i - 1
        end
        args[tab] = cleanBackslash(string.sub(content, start, i - 1))
        tab = tab + 1
        i = i + 1
    end
    if (putCommandInArgs) then
        return args
    end
    return command, args
end

function reboot(args, authorized, message)
    if (authorized) then
        message:reply({
            embed = {
                title = "Rebooting",
                description = "Restarting bot",
                color = 0xFF8800,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        disconnect = true
        client:stop()
    else
        message:reply({
            embed = {
                title = "Error",
                description = "You are not allowed to perform this command",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function shutdown(args, authorized, message)
    if (authorized) then
        message:reply({
            embed = {
                title = "Disconnecting",
                description = "Disconnecting from discord",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        disconnect = true
        client:stop()
        os.exit(1)
    else
        message:reply({
            embed = {
                title = "Error",
                description = "You are not allowed to perform this command",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function dispHelp(args, authorized, message, admin)
	if args[1] then
		local content = loadFile("help/"..(args[1]:sub(1, 2) == ".." and args[1]:sub(3, #args[1]) or args[1])..".txt")
		
		if (#content == 0) then
			message:reply({
				embed = {
					title = "Error",
					description = "No help page found for \""..(args[1]:sub(1, 2) == ".." and args[1]:sub(3, #args[1]) or args[1]).."\"",
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
					title = ".."..(args[1]:sub(1, 2) == ".." and args[1]:sub(3, #args[1]) or args[1]),
					description = table.concat(content, "\n"),
					color = 0xAAAAAA,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		end
    elseif (authorized) then
        message:reply({
            embed = {
                title = "Help",
                description = "Arguments between [] are optionnal.\
Arguments with <> have to be replaced with the actual content you want.\
Arguments are separated with spaces.\
If you want to put spaces inside an argument, put the argument between quotes (\", ” or ')\
You can of course all the arguments between quotes even there are no spaces in it, but don't forget to close them !\
Here are all the commands you are allowed to use :**\
..__help__ [<command>]\
..__stats__ [<user>]\
..__disconnect__\
..__reboot__\
..__claim__\
..__hug__ [<user1> [<user2> <user3> ...]]\
..__pat__ [<user1> [<user2> <user3> ...]]\
..__event__ [<duration> <amount> [<title>]]\
..__custom_role__ settings [details]\
..__custom_role__ settings <field1> <value1> [<field2> <value2> ...]\
..__custom_role__ create <name> <color>\
..__custom_role__ edit <name>/<id> <new_name> <color>\
..__claimers__\
..__give__ <amount> <user>\
..__buy__ <category> <index>\
..__coinflip__ heads/tails/h/t <essences>\
..__cf__ heads/tails/h/t <essences>\
..__leaderboard__\
..__daily__\
..__change_name__ <new_name>\
..__icon__ [<new_icon>/profile]\
..__mute__ settings [debug/<field1> <value1> [<field2> <value2> ...]]\
..__mute__ <user> <reason> [<time> [s/m/h]]\
..__set_value__ <user> <field> [<value>]\
..__items__ [add/delete <name> [<price>]]\
..__day__ [list/resume/exec/see/add/delete <item> [<field1> <value1> ...]]\
..__rank__/..__exp__/..__xp__ [<user>]\
..__sell__ <item_name> <amount>\
..__listselfassignablerole__/..__lsar__ [add/delete <role>]\
..__iam__/..__selfassign__ <role>\
..__iamnot__/..__selfunassign__ <role>\
..__set__ <user> <essences>\
..__setxproles__ [<level> [<role>]]\
..__levels__\
..__leavemsg__ <field1> <value1> [...]\
..__welcome__ <field1> <value1> [...]\
..__shop__ [add/delete <category> <name>/<index> [<price> <icon>]]\
..__wr/..winrate/..cfwr/..coinflipwinrate/..coinflipstats/..cfstats__ [<user>]\
..__autorole__ [<role>]**",
                color = 0xFFFF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif admin then
        message:reply({
            embed = {
                title = "Help",
                description = "Arguments between [] are optionnal.\
Arguments with <> have to be replaced with the actual content you want.\
Arguments are separated with spaces.\
If you want to put spaces inside an argument, put the argument between quotes (\", ” or ')\
You can of course all the arguments between quotes even there are no spaces in it, but don't forget to close them !\
Here are all the commands you are allowed to use :**\
..__help__ [<command>]\
..__stats__ [<user>]\
..__claim__\
..__hug__ [<user1> [<user2> <user3> ...]]\
..__pat__ [<user1> [<user2> <user3> ...]]\
..__event__\
..__custom_role__ settings [details]\
..__custom_role__ settings <field1> <value1> [<field2> <value2> ...]\
..__custom_role__ create <name> <color>\
..__custom_role__ edit <name>/<id> <new_name> <color>\
..__claimers__\
..__give__ <amount> <user>\
..__buy__ <category> <index>\
..__coinflip__ heads/tails/h/t <essences>\
..__cf__ heads/tails/h/t <essences>\
..__leaderboard__\
..__daily__\
..__change_name__ <new_name>\
..__icon__ [<new_icon>/profile]\
..__mute__ settings [debug/<field1> <value1> [<field2> <value2> ...]]\
..__mute__ <user> <reason> [<time> [s/m/h]]\
..__items__\
..__day__ [resume]\
..__rank__/..__exp__/..__xp__ [<user>]\
..__sell__ <item_name> <amount>\
..__listselfassignablerole__/..__lsar__ [add/delete <role>]\
..__iam__/..__selfassign__ <role>\
..__iamnot__/..__selfunassign__ <role>\
..__setxproles__ [<level> [<role>]]\
..__levels__\
..__leavemsg__ <field1> <value1> [...]\
..__welcome__ <field1> <value1> [...]\
..__shop__ [add/delete <category> <name>/<index> [<price> <icon>]]\
..__wr/..winrate/..cfwr/..coinflipwinrate/..coinflipstats/..cfstats__ [<user>]\
..__autorole__ [<role>]**",
                color = 0xFFFF00,
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
                title = "Help",
                description = "Arguments between [] are optionnal.\
Arguments with <> have to be replaced with the actual content you want.\
Arguments are separated with spaces.\
If you want to put spaces inside an argument, put the argument between quotes\
(\", ” or ')\
You can of course all the arguments between quotes even there are no spaces in it\
but don't forget to close them !\
Here are all the commands you are allowed to use :**\
..__help__ [<command>]\
..__stats__ [<user>]\
..__claim__\
..__hug__ [<user1> [<user2> <user3> ...]]\
..__pat__ [<user1> [<user2> <user3> ...]]\
..__event__\
..__custom_role__ create <name> <color>\
..__custom_role__ edit <name>/<id> <new_name> <color>\
..__claimers__\
..__give__ <amount> <user>\
..__buy__ <category> <index>\
..__coinflip__ heads/tails/h/t <essences>\
..__cf__ heads/tails/h/t <essences>\
..__leaderboard__\
..__daily__\
..__change_name__ <new_name>\
..__icon__ [<new_icon>/profile]\
..__items__\
..__day__ [resume]\
..__rank__/..__exp__/..__xp__ [<user>]\
..__sell__ <item_name> <amount>\
..__listselfassignablerole__/..__lsar__\
..__iam__/..__selfassign__ <role>\
..__iamnot__/..__selfunassign__ <role>\
..__setxproles__\
..__levels__\
..__wr/..winrate/..cfwr/..coinflipwinrate/..coinflipstats/..cfstats__ [<user>]\
..__shop__**",
                color = 0xFFFF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function getMoney(id)
    local money = getPlayer(id, client:getUser(id)).essences

    return money or 0
end

function saveMoney(id, money)
    local player = getPlayer(id, client:getUser(id))
    
    player.essences = money
    savePlayer(id, player)
end

function getDailyTime()
    local file = io.open("daily", "r")
    local line = ""
    local dailies = {}
    
    if (file == nil) then
        return {}
    end
    io.input(file)
    line = io.read()
    while line do
        dailies[line] = tonumber(io.read())
        line = io.read()
    end
    io.close(file)
    return dailies
end

function saveDailyTime(dailies)
    local file = io.open("daily", "w+")
    
    if (file == nil) then
        return
    end
    io.output(file)
    for i, k in pairs(dailies) do
        io.write(tostring(i).."\n")
        io.write(tostring(k).."\n")
    end
    io.close(file)
end

function getTimeString(time)
	local result = tostring(time % 60).." seconds"

	time = math.floor(time / 60)
	if (time > 0) then
		result = tostring(time % 60).." minutes and "..result
	end
	time = math.floor(time / 60)
	if (time > 0) then
		result = tostring(time % 24).." hours "..result
	end
	time = math.floor(time / 24)
	if (time > 0) then
		result = tostring(time).." days "..result
	end
	return (result)
end

function getCustomRolesSettings(id)
    local file = io.open("configs/customs"..id, "r")
    local settings = {
        isActive = false,
        requirement = "none",
        putInShop = false,
        defaultPrice = 0
    }
    
    if (file == nil) then
        return settings
    end
    io.input(file)
    settings.isActive = (io.read() == "true")
    settings.requirement = (io.read() or "none")
    settings.content = io.read()
    settings.content2 = io.read()
    settings.putInShop = (io.read() == "true")
    settings.defaultPrice = (io.read() or 0)
    settings.limit = (io.read() or 0)
    settings.place = io.read() or "nil"
    io.close(file)
    return settings
end

function saveCustomRolesSettings(id, settings)
    local file = io.open("configs/customs"..id, "w+")
    
    if (file == nil) then
        return
    end
    io.output(file)
    io.write(tostring(settings.isActive).."\n")
    io.write(tostring(settings.requirement).."\n")
    io.write(tostring(settings.content).."\n")
    io.write(tostring(settings.content2).."\n")
    io.write(tostring(settings.putInShop).."\n")
    io.write(tostring(settings.defaultPrice).."\n")
    io.write(tostring(settings.limit).."\n")
    io.write(tostring(settings.place).."\n")
    io.close(file)
end

function createCustomRole(args, message)
    if not message.guild then
        message:reply({
            embed = {
                title = "Error",
                description = "You need to use this command on a server",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        return
    end
    if (args[2] and args[3]) then
        local settings = getCustomRolesSettings(message.guild.id)
        local desc = ""
        local allowed = false
        local created = loadFileWithFields("configs/rolesCreated"..message.guild.id)
        
        if not message.member then
            message:reply({
                embed = {
                    title = "Error",
                    description = "I can't create roles in private messages",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (settings.isActive) then
            allowed = true
            if (tonumber(settings.limit) and tonumber(created[message.author.id] or 0) >= tonumber(settings.limit)) then
                desc = desc.."-    You already created "..tonumber((created[message.author.id]) or 0).." custom role(s)\n"
                allowed = false
            end
            if not tonumber(args[3], 16) and (args[3]:sub(1, 1) ~= "#" or not tonumber(args[3]:sub(2, #args[3]), 16)) then
                desc = desc.."-    "..args[3].." is not a valid base 16 number\n"
                allowed = false
            end
            if (settings.requirement == "role") then
                if not message.member:hasRole(string.sub(settings.content, 4, #settings.content - 1)) then
                    allowed = false
                    desc = desc.."-    You don't have the role "..settings.content
                end
            elseif (settings.requirement == "money") then
                if (getPlayer(message.author.id, message.author).essences < (tonumber(settings.content) or 0)) then
                    desc = desc.."-    You don't have enough money to pay "..settings.content.." "..emojis.essencesEmoji
                    allowed = false
                end
            elseif (settings.requirement == "role money") then
                if not message.member:hasRole(string.sub(settings.content, 4, settings.content - 1)) then
                    allowed = false
                    desc = desc.."-    You don't have the role "..settings.content.."\n"
                end
                if (getPlayer(message.author.id, message.author).essences < (tonumber(settings.content2) or 0)) then
                    desc = desc.."-    You don't have enough money to pay "..settings.content2.." "..emojis.essencesEmoji
                    allowed = false
                end
            elseif (settings.requirement ~= "none") then
                allowed = false
                desc = desc.."-    The configuration file is corrupted or invalid (Unknown requirement \""..settings.requirement.."\")"
            end
            if allowed or isAdmin(message.member) or isWhitelisted(message.member) then
                local success, err = message.guild:createRole(args[2])
                
                if not success then
                    message:reply({
                        embed = {
                            title = "Error",
                            description = "I cannot create a custom role right now because :\n"..err,
                            color = 0xFF0000,
                            timestamp = discord.Date():toISO('T', 'Z'),
                            footer = {
                                icon_url = message.author.avatarURL,
                                text = message.author.name
                            }
                        }
                    })
                else
                    if not success:setColor(tonumber(args[3], 16) or tonumber(args[3]:sub(2, #args[3]), 16)) then
                        success:delete()
                        message:reply({
                            embed = {
                                title = "Error",
                                description = "Couldn't set "..args[2].."'s color to "..args[3].." ("..tostring(tonumber(args[3], 16) or tonumber(args[3]:sub(2, #args[3]), 16))..")\n",
                                color = 0xFF0000,
                                timestamp = discord.Date():toISO('T', 'Z'),
                                footer = {
                                    icon_url = message.author.avatarURL,
                                    text = message.author.name
                                }
                            }
                        })
                    else
                        if not message.member:addRole(success.id) then
                            success:delete()
                            message:reply({
                                embed = {
                                    title = "Error",
                                    description = "Couldn't give you the role\n",
                                    color = 0xFF0000,
                                    timestamp = discord.Date():toISO('T', 'Z'),
                                    footer = {
                                        icon_url = message.author.avatarURL,
                                        text = message.author.name
                                    }
                                }
                            })
                        else
                            local highestRole = message.guild.members:get(client.user.id).highestRole
							local player = getPlayer(message.member.id, message.author)
                            
                            if settings.place ~= "nil" and message.guild:getRole(string.sub(settings.place, 4, #settings.place - 1)) then
                                highestRole = message.guild:getRole(string.sub(settings.place, 4, #settings.place - 1))
                            end
                            success:moveUp(highestRole.position - success.position - 1)
                            if settings.putInShop then
                                loadShop(message.guild.id)
                                shop[#shop + 1] = {
									name = "<@&"..success.id..">",
									type = "Roles",
									icon = emojis.defaultShopIcon,
									price = settings.defaultPrice,
									action = defaultActions["Roles"]
								}
                                saveShop(message.guild.id)
                            end
                            message:reply({
                                embed = {
                                    title = "Success",
                                    description = "Successfully created and gave you role <@&"..success.id..">\n",
                                    color = 0x00FF00,
                                    timestamp = discord.Date():toISO('T', 'Z'),
                                    footer = {
                                        icon_url = message.author.avatarURL,
                                        text = message.author.name
                                    }
                                }
                            })
							if not player.ownedRoles then
								player.ownedRoles = {}
							end
							if not player.ownedRoles[message.guild.id] then
								player.ownedRoles[message.guild.id] = {}
							end
							player.ownedRoles[message.guild.id][#player.ownedRoles[message.guild.id] + 1] = "<@&"..success.id..">"
                            created[message.author.id] = (created[message.author.id] or 0) +1
                            saveFileWithFields("configs/rolesCreated"..message.guild.id, created)
							savePlayer(message.member.id, player)
                        end
                    end
                end
            else
                message:reply({
                    embed = {
                        title = "Error",
                        description = "You cannot create a custom role right now because :\n"..desc,
                        color = 0xFF0000,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
            end
        else
            message:reply({
                embed = {
                    title = "Error",
                    description = "Custom roles are disabled on your server.\nAn administrator needs to enable them before.",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        end
    else
        message:reply({
            embed = {
                title = "Error",
                description = "Expected two arguments but got "..(#args - 1),
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function dispCustomRolesSettings(message, details)
    local desc = ""
    if not message.guild then
        message:reply({
            embed = {
                title = "Error",
                description = "You need to use this command on a server",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        return
    end
    local settings = getCustomRolesSettings(message.guild.id)

    if (details) then
        for i, k in pairs(settings) do
            desc = desc..i.."\t\ttype : "..type(k).."\t\tvalue : \""..tostring(k).."\"\n"
        end
    else
        if (settings.isActive) then
            desc = "Custom roles : Enabled\nRequirement : "
            if (settings.requirement == "none") then
                desc = desc.." None\n"
            elseif (settings.requirement == "role") then
                desc = desc.." Have role "..settings.content.."\n"
            elseif (settings.requirement == "money") then
                desc = desc.." Pay "..settings.content.." "..emojis.essencesEmoji.."\n"
            elseif (settings.requirement == "role money") then
                desc = desc.." Have role "..settings.content.." and pay "..settings.content2.." "..emojis.essencesEmoji.."\n"
            else
                desc = desc.." Error : Corrupted or invalid configuration (Unknown requirement \""..settings.requirement.."\")"
            end
            desc = desc.."Put in shop : "..tostring(settings.putInShop)
            if (settings.putInShop) then
                desc = desc.."\nDefault price : "..tostring(settings.defaultPrice).." "..emojis.essencesEmoji
            end
            if ((tonumber(settings.limit) or 0) == 0) then
                desc = desc.."\nLimit : no limit"
            else
                desc = desc.."\nLimit : "..settings.limit.." role(s)"
            end
            if settings.place == "nil" then
                desc = desc.."\nPosition : Below "..message.guild.members:get(client.user.id).highestRole.name
            elseif message.guild:getRole(string.sub(settings.place, 4, #settings.place - 1)) then
                desc = desc.."\nPosition : Below "..message.guild:getRole(string.sub(settings.place, 4, #settings.place - 1)).name
            else
                desc = desc.."\nPosition : Error. Couldn't find role with ID "..string.sub(settings.place, 4, #settings.place - 1)
            end
        else
            desc = "Custom roles : Disabled"
        end
    end
    message:reply({
        embed = {
            title = "Custom roles settings",
            description = desc,
            color = 0xFF00FF,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = {
                icon_url = message.author.avatarURL,
                text = message.author.name
            }
        }
    })
end

function changeCustomRolesSettings(args, authorized, message)
    if not authorized or not args[2] or args[2] == "details" then
        dispCustomRolesSettings(message, args[2] == "details" and authorized)
    else
        local settings = getCustomRolesSettings(message.guild.id)
        
        settings[args[2]] = args[3]
        saveCustomRolesSettings(message.guild.id, settings)
        message:reply({
            embed = {
                title = "Settings update",
                description = "Set field "..args[2].." to "..tostring(args[3]),
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function claimMoney(args, authorized, message)
    if (event.begin + event.duration > os.time()) then
        if (not already_claimed[message.author.id]) then
            saveMoney(message.author.id, getMoney(message.author.id) + event.amount)
            message:reply({
                embed = {
                    title = "Success",
                    description = "You successfully claimed your "..event.amount.." "..emojis.essencesEmoji,
                    color = 0xFFFF00,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
            already_claimed[message.author.id] = true
        else
            message:reply({
                embed = {
                    title = "Error",
                    description = "You already claimed your money for that event",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        end
    else
        message:reply({
            embed = {
                title = "Error",
                description = "No event is currently running",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function dispEvent(message)
    if (event.begin + event.duration < os.time()) then
        message:reply({
            embed = {
                title = "Error",
                description = "No event is currently running",
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
                title = event.title,
                description = "Event active :\
Reward : "..tostring(event.amount).." "..emojis.essencesEmoji.."\
Time left : "..getTimeString(event.begin + event.duration - os.time()).."\
End : "..os.date("%a %d %b %X", event.begin + event.duration).." UTC+00:00\
Use \"..claim\" to claim your reward !"
                ,
                author = event.author,
                color = 0x0000FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function loadEvent()
    local file = io.open("event", "r")
    
    if (not file) then
        return
    end
    io.input(file)
    event.begin = tonumber(io.read())
    event.duration = tonumber(io.read())
    event.amount = tonumber(io.read())
    event.title = io.read()
    event.author = {}
    event.author.name = io.read()
    event.author.icon_url = io.read()
    io.close(file)
end

function saveEvent()
    local file = io.open("event", "w+")
    
    if (not file) then
        return
    end
    io.output(file)
    io.write(event.begin.."\n")
    io.write(event.duration.."\n")
    io.write(event.amount.."\n")
    io.write(event.title.."\n")
    io.write(event.author.name.."\n")
    io.write(event.author.icon_url.."\n")
    io.close(file)
end

function createEvent(args, authorized, message)
    if (args[1] == nil and args[2] == nil or not authorized) then
        dispEvent(message)
    else
        if (tonumber(args[1]) ~= nil and tonumber(args[1]) <= 0) then
            message:reply({
                embed = {
                    title = "Event ?",
                    description = "I don't think that creating an event of "..(tonumber(args[1]) * 60).." seconds is usefull "..emojis.no,
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (tonumber(args[2]) ~= nil and tonumber(args[2]) <= 0) then
            message:reply({
                embed = {
                    title = "Event ?",
                    description = "An event which steals ppl essences "..emojis.thinking.."\nWhat a good idea ! "..emojis.yes,
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil) then
            event = {
                begin = os.time(),
                duration = tonumber(args[1]) * 60,
                amount = tonumber(args[2]),
                title = args[3],
                author = {
                    name = message.author.name,
                    icon_url = message.author.avatarURL,
                }
            }
            if (not event.title or event.title == "") then
                event.title = "Event"
            end
            saveEvent()
            already_claimed = {}
            message:reply({
                embed = {
                    title = "New event !",
                    description = "Event started !\
Title : "..event.title.."\
Reward : "..tostring(event.amount).." "..emojis.essencesEmoji.."\
Time left : "..getTimeString(event.duration).."\
End : "..os.date("%A %d %B %X  UTC+00:00", event.begin + event.duration).."\
Use \"..claim\" to claim your reward !"
                    ,
                    color = 0x88FF88,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (tonumber(args[1]) == nil) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Invalid argument #1 : Expected number",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (tonumber(args[2]) == nil) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Invalid argument #2 : Expected number",
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
                    title = "Error",
                    description = "Unexpected error occured when trying to create event",
                    color = 0xFF0000,
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

function getLeaderboard(guild, fct)
    local leaderboard = {}
    local money = 0

    for member in guild.members:iter() do
        money = fct(member.id, guild.id)
        if (money > 0) then
            if not leaderboard[money] then
                leaderboard[money] = {}
            end
            leaderboard[money][#leaderboard[money] + 1] = member.id
        end
    end
    return leaderboard
end

function getTabLen(array)
    local len = 0

    if (array) then
        for i in pairs(array) do
            len = len + 1
        end
    end
    return len
end

function sort(array)
    local sorted_array = {}
    local biggest = 1
    
    if (array) then
        while getTabLen(array) > 0 do
            biggest = 1
            for i in pairs(array) do
                if (i > biggest) then
                    biggest = i
                end
            end
            sorted_array[#sorted_array + 1] = {data = array[biggest], index = biggest}
            array[biggest] = nil
        end
    end
    return (sorted_array)
end

function dispLeaderBoard(args, authorized, message, start, edit)
    if (message.member) then
        local leaderboard = sort(getLeaderboard(message.guild, getMoney))
        local rank = 1
        local message_description = ""
        local place = {"🥇", "🥈", "🥉"}
        local displayed = false

        start = start or 1
        message:clearReactions()
        for i, k in pairs(leaderboard) do
            if (rank >= start and rank < start + 10) then
                if (rank > #place) then
                    message_description = message_description..rank.." :\tMoney : "..(k.index).." "..emojis.essencesEmoji.."\n"
                    displayed = true
                else
                    message_description = message_description..place[rank].." :\tMoney : "..(k.index).." "..emojis.essencesEmoji.."\n"
                    displayed = true
                end
            end
            for j, l in pairs(k.data) do
                if (rank + j - 1 >= start and rank + j - 1 < start + 10) then
                    if (rank + j >= start and not displayed) then
                        if (rank + j > #place) then
                            message_description = message_description..(rank + j - 1).." :\tMoney : "..(k.index).." "..emojis.essencesEmoji.."\n"
                            displayed = true
                        else
                            message_description = message_description..place[rank + j - 1].." :\tMoney : "..(k.index).." "..emojis.essencesEmoji.."\n"
                            displayed = true
                        end
                    end
                    message_description = message_description.."-\t\t\t\t\t<@"..l.."> ("..client:getUser(l).name..")\n"
                end
            end
            if (rank >= start and rank < start + 10) then
                message_description = message_description.."\n"
            end
            rank = rank + #k.data
        end
        if not edit then
            newMessage = message:reply({
                embed = {
                    title = "Essences Leaderboard",
                    description = message_description,
                    color = 0xFF00FF,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        else
            message:setEmbed({
                title = "Essences Leaderboard",
                description = message_description,
                color = 0xFF00FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            })
            newMessage = message
        end
        if (start > 1) then
            newMessage:addReaction("⬅")
        end
        if (rank > start + 10) then
            newMessage:addReaction("➡")
        end
    else
        message:reply({
            embed = {
                title = "Essences",
                description = "You currently have "..getMoney(message.author.id).." "..emojis.essencesEmoji,
                color = 0x888888,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function saveItems(items)
    local file = io.open("items", "w+")
    
    if not file then
        return
    end
    io.output(file)
    for i, k in pairs(items) do
        io.write(i.."\n"..k.cost.."\n")
    end
    io.close(file)
    return items
end

function loadItems()
    local file = io.open("items", "r")
    local line = ""
    local items = {}
    
    if (not file) then
        return items
    end
    io.input(file)
    line = io.read()
    while line do
        items[line] = {cost = tonumber(io.read())}
        line = io.read()
    end
    io.close(file)
    return items
end

function dispMoney(args, authorized, message)
    if (args[1] == nil) then
        message:reply({
            embed = {
                title = "Money",
                description = "You currently have "..getMoney(message.author.id).." "..emojis.essencesEmoji.."\nWARNING: This command will be soon deleted.\nUse ..stats instead",
                color = 0x888888,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local recievers = getReciever(args[1], message.guild)
        
        if (#recievers == 0) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Cannot find any user called \""..args[1].."\"\nWARNING: This command will be soon deleted.\nUse ..stats instead",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (#recievers >= 2) then
            local string = ""
            
            for i, k in pairs(recievers) do
                string = string.."<@"..k..">\n"
            end
            message:reply({
                embed = {
                    title = "Error",
                    description = "Found several members called \""..args[1].."\":\n"..string.."Use ..money @"..args[1].." to solve this\
WARNING: This command will be soon deleted.\nUse ..stats instead",
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
                    title = "Money",
                    description = "<@"..recievers[1].."> currently have "..getMoney(recievers[1]).." "..emojis.essencesEmoji.."\nWARNING: This command will be soon deleted.\nUse ..stats instead",
                    color = 0x888888,
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

function getReciever(arg, guild)
    local result = {}
    local buffer = 0

    if (arg == nil) then
        return (nil)
    elseif (string.sub(arg, 1, 2) == "<@" and string.sub(arg, #arg, #arg) == ">") then
        if (string.sub(arg, 3, 3) == "!") then
            buffer = 1
        end
        if client:getUser(string.sub(arg, 3 + buffer, #arg - 1)) then
            return ({string.sub(arg, 3 + buffer, #arg - 1)})
        else
            return {}
        end
    else
        if not guild then
            return {}
        end
        for k in guild.members:iter() do
            if (string.lower(k.name) == string.lower(arg)) then
                result[#result + 1] = k.id
            end
        end
        return (result)
    end
end

function giveMoney(args, authorized, message, cheat)
    local recievers = getReciever(args[2], message.guild)

    if (not recievers) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Expected user",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (#recievers == 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "Cannot find any user called \""..args[2].."\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (#recievers >= 2) then
        local string = ""
        
        for i, k in pairs(recievers) do
            string = string.."<@"..k..">\n"
        end
        message:reply({
            embed = {
                title = "Error",
                description = "Found several members called \""..args[2].."\":\n"..string.."Use ..give "..args[1].." @"..args[2].." to solve this",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not tonumber(args[1])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #1 : Number expected",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (tonumber(args[1]) <= 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "You need to GIVE essences ! :smile:",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
	elseif not (tonumber(args[1]) > 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "No",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (tonumber(args[1]) > getMoney(message.author.id)) then
        message:reply({
            embed = {
                title = "Error",
                description = "You don't have enough essences !",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not client:getUser(recievers[1])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Cannot find <@"..recievers[1]..">",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (recievers[1] == message.author.id) then
        message:reply({
            embed = {
                title = "Error",
                description = "You cannot give essences to yourself",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (recievers[1] == client.user.id) then
        saveMoney(message.author.id, getMoney(message.author.id) - tonumber(args[1]))
        saveMoney(recievers[1], getMoney(recievers[1]) + tonumber(args[1]))
        message:reply({
            embed = {
                title = "Thank you ! "..emojis.loveyou,
                description = "Oh, that's for me ? "..emojis.blush.."\nThank you ! "..emojis.loveyou..emojis.loveyou,
                color = 0xFF7777,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (client:getUser(recievers[1]).bot) then
        saveMoney(message.author.id, getMoney(message.author.id) - tonumber(args[1]))
        saveMoney(recievers[1], getMoney(recievers[1]) + tonumber(args[1]))
        message:reply({
            embed = {
                title = "Beep boop 🤖",
                description = "🤖 *Boop boop beep "..args[1].." "..emojis.essencesEmoji.." boop <@"..recievers[1]..">\nBeep beep boop !* "..emojis.loveyou.." 🤖",
                color = 0xFF7777,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
	else
		if not cheat then
			saveMoney(message.author.id, getMoney(message.author.id) - tonumber(args[1]))
		end
        saveMoney(recievers[1], getMoney(recievers[1]) + tonumber(args[1]))
        message:reply({
            embed = {
                title = "Give",
                description = "You gave "..args[1].." "..emojis.essencesEmoji.." to <@"..recievers[1]..">\nThank you ! "..emojis.loveyou,
                color = 0xFF7777,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function showClaimers(args, authorized, message)
    local description = ""

    if (authorized) then
        for i, k in pairs(already_claimed) do
            description = description.."<@"..i.."> : "
            if (k) then
                description = description.."Already claimed\n"
            else
                description = description.."Not claimed\n"
            end
        end
        message:reply({
            embed = {
                title = "Claimers for this event",
                description = description,
                color = 0x880088,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
		if event.begin + event.duration <= os.time() then
            message:reply({
                embed = {
                    title = "Error",
                    description = "No event is currently running",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (already_claimed[message.author.id]) then
            message:reply({
                embed = {
                    title = "Claimed ! ",
                    description = "You already claimed your reward for the running event",
                    color = 0x00FFFF,
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
                    title = "Not claimed ! ",
                    description = "You didn't claim your reward for the running event !\nUse ..claim to claim it now !",
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

function loadClaimed()
    local file = io.open("claimers", "r")
    local line = ""
    
    if (not file) then
        return
    end
    io.input(file)
    line = io.read()
    while line ~= nil do
        already_claimed[line] = true
        line = io.read()
    end
    io.close(file)
end

function saveClaimed()
    local file = io.open("claimers", "w+")
    
    if (not file) then
        return
    end
    io.output(file)
    for i, k in pairs(already_claimed) do
        if (k) then
            io.write(i.."\n")
        end
    end
    io.close(file)
end

function parseChannel(channel, guild)
    if channel == "none" then
        return ("none")
    elseif (string.sub(channel, 1, 2) ~= "<#" or string.sub(channel, #channel, #channel) ~= ">") then
        return nil, "Malformed channel string"
    elseif (guild:getChannel(string.sub(channel, 3, #channel - 1)) == nil) then
        return nil, "Unknown channel id "..tostring(string.sub(channel, 3, #channel - 1))
    end
    return string.sub(channel, 3, #channel - 1)
end

function getLength(nbr)
    local length = 0

    for i = 1, #nbr, 1 do
        if (string.sub(nbr, i, i) == '1') then
            length = length + 1.75
        else
            length = length + 2.85
        end
    end
    return length
end

function showShop(args, authorized, message, edit, index)
    local message_description = {}
    local fields = {}
    local biggest = 0
    local biggest_index = 0
    local machin = {}
    local change = 0
    local reactions = false
    local newMessage
	local footer

    if (buffering and edit) then
        return
    end
	if edit then
		footer = message.embed.footer
		message:setEmbed({})
	end
    buffering = true
    for i, k in pairs(shop) do
        if (getLength(tostring(k.price)) > biggest) then
            biggest = getLength(tostring(k.price))
        end
        if (i > biggest_index) then
            biggest_index = i
        end
    end
    for i, k in pairs(shop) do
        if (machin[k.type] == nil) then
            machin[k.type] = 0
        end
        machin[k.type] = machin[k.type] + 1
        if (i >= index) then
            if (message_description[k.type] == nil) then
                message_description[k.type] = ""
            end
            message_description[k.type] = message_description[k.type]..machin[k.type].."-"
            for i = getLength(tostring(machin[k.type])), getLength(tostring(biggest_index)), 1 do
                message_description[k.type] = message_description[k.type].." "
            end
            message_description[k.type] = message_description[k.type].."      "..k.icon.."    "..k.name.."\n.\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tCost :"
            for i = getLength(tostring(k.price)), biggest, 1 do
                message_description[k.type] = message_description[k.type].." "
            end
            message_description[k.type] = message_description[k.type]..k.price.." "..emojis.essencesEmoji.."\n";
            if (i >= index + 6) then
                break
            end
        end
    end
    for i, k in pairs(message_description) do
        fields[#fields + 1] = {}
        fields[#fields].name = i
        fields[#fields].value = k
    end
    if not edit then
        newMessage = message:reply({
            embed = {
                title = "Shop :",
                description = "Page "..math.floor((index + 6) / 7),
                color = 0xFF8800,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                },
                fields = fields
            }
        })
        if (index > 1) then
            newMessage:addReaction("⬅")
        end
        if (#shop > index + 6) then
            newMessage:addReaction("➡")
        end
    else
        message:clearReactions()
        message:setEmbed({
            title = "Shop :",
            description = "Page "..math.floor((index + 6) / 7),
            color = 0xFF8800,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = footer,
            fields = fields
        })
        if (index > 1) then
            message:addReaction("⬅")
        end
        if (#shop > index + 6) then
            message:addReaction("➡")
        end
    end
    buffering = false
end

function deleteShopItem(args, authorized, message)
    local Type, index = args[2], tonumber(args[3])
    local deleted = false
    local number = 0

    if (not Type or not args[3]) then
        message:reply({
            embed = {
                title = "Error",
                description = "Expected 2 arguments but got "..(#args - 1),
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not index) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Expected number",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (index <= 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Index must be greater than 0",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local machin = {}
        loadShop(message.guild.id)
        for i, k in pairs(shop) do
            if (machin[k.type] == nil) then
                machin[k.type] = 0
            end
            machin[k.type] = machin[k.type] + 1
            if (machin[Type] == index) then
                deleted = true
                message:reply({
                    embed = {
                        title = "Success",
                        description = "Deleted "..index.." of type "..Type.." ("..k.icon.."  "..k.name..")",
                        color = 0xFF00FF,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
                shop[i] = nil
                saveShop(message.guild.id)
                break
            end
        end
        if (not deleted) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Couldn't find index "..index.." for type "..Type,
                    color = 0xFF0000,
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

function addShopItem(args, authorized, message)
    local Type, name, price, icon = args[2], args[3], tonumber(args[4]), args[5]

    if (not Type or not name or not icon or not args[4]) then
        message:reply({
            embed = {
                title = "Error",
                description = "Expected 4 arguments but got "..(#args - 1),
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not price) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #3 : Expected number",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (price < 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "You cannot give the item AND money at the same time",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        loadShop(message.guild.id)
        shop[#shop + 1] = {}
        shop[#shop].name = name
        shop[#shop].type = Type
        shop[#shop].icon = icon
        shop[#shop].price = price
        shop[#shop].action = defaultActions[Type]
        warning = ""
        if (not shop[#shop].action) then
            warning = "\n\nWARNING : No default action are set for "..Type.." which means that buying this item won't do anything"
        end
        saveShop(message.guild.id)
        message:reply({
            embed = {
                title = "Success !",
                description = "Added "..icon.."  "..name.." costing "..price.." "..emojis.essencesEmoji..warning,
                color = 0xAA66FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function buyItem(args, authorized, message)
    local Type, index = args[1], tonumber(args[2])
    local found = false
    local number = 0

    if (not Type or not args[2]) then
        message:reply({
            embed = {
                title = "Error",
                description = "Expected 2 arguments but got "..#args,
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not index) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Expected number",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (index <= 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Index must be greater than 0",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local machin = {}
        loadShop(message.guild.id)
        for i, k in pairs(shop) do
            if (machin[k.type] == nil) then
                machin[k.type] = 0
            end
            machin[k.type] = machin[k.type] + 1
            if (machin[Type] == index) then
                found = true
                if (k.price <= getMoney(message.member.id)) then
                    if (k.action ~= nil) then
                        if k.action(message.member, k.name, k.price) then
                            message:reply({
                                embed = {
                                    title = "Success",
                                    description = "You bought "..k.icon.."  "..k.name.." for "..k.price.." "..emojis.essencesEmoji,
                                    color = 0xFF88FF,
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
                                    title = "Error",
                                    description = "You can't buy any more "..k.icon.."  "..k.name,
                                    color = 0xFF0000,
                                    timestamp = discord.Date():toISO('T', 'Z'),
                                    footer = {
                                        icon_url = message.author.avatarURL,
                                        text = message.author.name
                                    }
                                }
                            })
                        end
                    end
                else
                    message:reply({
                        embed = {
                            title = "Error",
                            description = "You don't have enough money to buy that",
                            color = 0xFF0000,
                            timestamp = discord.Date():toISO('T', 'Z'),
                            footer = {
                                icon_url = message.author.avatarURL,
                                text = message.author.name
                            }
                        }
                    })
                end
                break
            end
        end
        if (not found) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Couldn't find index "..index.." for type "..Type,
                    color = 0xFF0000,
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

function coinFlip(args, authorized, message)
    local result = math.random(0, 1)

    if (not args[2] or not args[1]) then
        message:reply({
            embed = {
                title = "Error",
                description = "Expected 2 arguments but got "..#args,
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (args[1] ~= "h" and args[1] ~= "t" and args[1] ~= "heads" and args[1] ~= "tails") then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #1 : Expected h or t or heads or tails",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not tonumber(args[2])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2 : Expected number",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (tonumber(args[2]) > 0 and tonumber(args[2]) <= getMoney(message.author.id)) then
        if (args[1] == "h" or args[1] == "heads") then
            if (result == 0) then
                message:reply({
                    embed = {
                        title = "Result heads",
                        description = emojis.hi.."\nYou won "..args[2].." "..emojis.essencesEmoji,
                        color = 0x6666FF,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
				player = getPlayer(message.author.id, message.author)
				player.games = (player.games or 0) + 1
				player.wins = (player.wins or 0) + 1
                player.moneyearned = (player.moneyearned or 0) + args[2]
                player.essences = getMoney(message.author.id) + args[2]
				savePlayer(message.author.id, player)
            else
                message:reply({
                    embed = {
                        title = "Result tails",
                        description = emojis.tilt.."\nYou lost "..args[2].." "..emojis.essencesEmoji,
                        color = 0xFF0000,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
				player = getPlayer(message.author.id, message.author)
				player.games = (player.games or 0) + 1
				player.loss = (player.loss or 0) + 1
                player.moneyearned = (player.moneyearned or 0) - args[2]
                player.essences = getMoney(message.author.id) - args[2]
				savePlayer(message.author.id, player)
            end
        elseif (args[1] == "t" or args[1] == "tails") then
            if (result == 0) then
                message:reply({
                    embed = {
                        title = "Result heads",
                        description = emojis.tilt.."\nYou lost "..args[2].." "..emojis.essencesEmoji,
                        color = 0xFF0000,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
				player = getPlayer(message.author.id, message.author)
				player.games = (player.games or 0) + 1
				player.loss = (player.loss or 0) + 1
                player.moneyearned = (player.moneyearned or 0) - args[2]
                player.essences = getMoney(message.author.id) - args[2]
				savePlayer(message.author.id, player)
            else
                message:reply({
                    embed = {
                        title = "Result tails",
                        description = emojis.hi.."\nYou won "..args[2].." "..emojis.essencesEmoji,
                        color = 0x6666FF,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = message.author.avatarURL,
                            text = message.author.name
                        }
                    }
                })
				player = getPlayer(message.author.id, message.author)
				player.games = (player.games or 0) + 1
				player.wins = (player.wins or 0) + 1
                player.moneyearned = (player.moneyearned or 0) + args[2]
                player.essences = getMoney(message.author.id) + args[2]
				savePlayer(message.author.id, player)
            end
        end
    else
        message:reply({
            embed = {
                title = "Error",
                description = "You don't have enough money to bet "..args[2].." "..emojis.essencesEmoji,
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function dispWinrate(args, message)
	local reciever = getReciever(args[1] or "", message.guild)[1] or message.author.id
	local player = getPlayer(reciever, client:getUser(reciever))
	
	message:reply({
		embed = {
			title = "Win rate:",
			description = "Number of coin tossed: "..(player.games or 0).."\
Number of wins: "..(player.wins or 0).."\
Number of loss: "..(player.loss or 0).."\
Win ratio: "..(math.floor((player.wins or 0) / (player.games or 0) * 10000 + 0.5) / 100).."%\
Money earned: "..(player.moneyearned or 0).." "..emojis.essencesEmoji,
			color = 0xFFFFFF,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = {
				icon_url = player.icon,
				text = player.name
			}
		}
	})
end

function whiteListMgr(args, authorized, message)
    if (not args[1]) then
        local desc = ""
        
        for i, k in pairs(whitelist) do
            desc = desc.."<@"..k..">\n"
        end
        message:reply({
            embed = {
                title = "Whitelist",
                description = desc,
                color = 0xFFFFFF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local recievers = getReciever(args[1], message.author.guild)

        whitelist[#whitelist + 1] = recievers[1]
        saveWhiteList()
        message:reply({
            embed = {
                title = "Whitelist",
                description = "Whitelisted <@"..recievers[1]..">",
                color = 0xFFFFFF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function match(string1, string2)
    string1 = string.lower(string1)
    string2 = string.lower(string2)
    for i = 1, #string2 - #string1 + 1 do
        if (string.sub(string2, i, i + #string1 - 1) == string1) then
            return (true);
        end
    end
    return (false)
end

function setMoney(args, authorized, message)
    local recievers = getReciever(args[1], message.guild)

    if not authorized then
        message:reply({
            embed = {
                title = "Error",
                description = "You are not authorized to perform this command",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not recievers) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #1 : Expected user",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (#recievers == 0) then
        message:reply({
            embed = {
                title = "Error",
                description = "Cannot find any user called \""..args[1].."\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (#recievers >= 2) then
        local string = ""
        
        for i, k in pairs(recievers) do
            string = string.."<@"..k..">\n"
        end
        message:reply({
            embed = {
                title = "Error",
                description = "Found several members called \""..args[1].."\":\n"..string.."Use ..set "..args[2].." @"..args[1].." to solve this",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not tonumber(args[2])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #1 : Number expected",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif (not client:getUser(recievers[1])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Cannot find <@"..recievers[1]..">",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        saveMoney(recievers[1], tonumber(args[2]))
        message:reply({
            embed = {
                title = "Give",
                description = "Set <@"..recievers[1]..">'s money to "..args[2].." "..emojis.essencesEmoji,
                color = 0x777777,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function convertString(back, str)
    local i = 1

    if not str then
        return nil
    end
    if (back) then
        while i < #str do
            if (string.sub(str, i, i + 1) == "\\n") then
                str = string.sub(str, 1, i - 1).."\n"..string.sub(str, i + 2, #str)
            end
            i = i + 1
        end
    else
        while i <= #str do
            if (string.sub(str, i, i) == "\n") then
                str = string.sub(str, 1, i - 1).."\\n"..string.sub(str, i + 1, #str)
            end
            i = i + 1
        end
    end
    return (str)
end

function saveStoryItems(story)
    local file = io.open("story", "w+")
    
    if not file then
        return
    end
    io.output(file)
    for i, k in pairs(story) do
        io.write(convertString(false, i).."\n")
        for j, l in pairs(k) do
            io.write(convertString(false, j).."\n")
            io.write(convertString(false, l).."\n")
        end
        io.write("--end\n")
    end
    io.close(file)
end

function loadStoryItems()
    local file = io.open("story", "r")
    local line = ""
    local index = ""
    local buffer = {}
    local story = {}
    
    if not file then
        return (buffer)
    end
    io.input(file)
    line = io.read()
    while line do
        buffer = {}
        index = line
        line = convertString(true, io.read())
        while line ~= "--end" and line do
            buffer[line] = convertString(true, io.read())
            line = convertString(true, io.read())
        end
        story[index] = buffer
        line = convertString(true, io.read())
    end
    io.close(file)
    return (story)
end

function deleteStoryItem(args, authorized, message)
    local newStory = loadStoryItems()
    local desc
    
    if (not args[3]) then
        newStory[args[2]] = nil
        desc = "Deleted item with id \""..args[2].."\""
    elseif (newStory[args[2]]) then
        newStory[args[2]][args[3]] = nil
        desc = "Deleted field \""..args[3].."\" in item \""..args[2].."\""
    else
        desc = "Couldn't find item \""..tostring(args[2]).."\""
    end
    saveStoryItems(newStory)
    message:reply({
        embed = {
            title = "Deleted item",
            description = desc,
            color = 0xFF0000,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = {
                icon_url = message.author.avatarURL,
                text = message.author.name
            },
        }
    })
end

function addStoryItem(args, authorized, message)
    local description = ""
    local newStory = loadStoryItems()
    local fields = {}

    i = 3
    if (not newStory[args[2]]) then
        newStory[args[2]] = {}
    end
    while i < #args do
        newStory[args[2]][args[i]] = args[i + 1]
        fields[#fields + 1] = {}
        fields[#fields].name = args[i]
        fields[#fields].value = args[i + 1]
        i = i + 2
    end
    saveStoryItems(newStory)
    message:reply({
        embed = {
            title = "New item",
            description = "Added new story item (id \""..args[2].."\") with attributes :",
            color = 0x00FF00,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = {
                icon_url = message.author.avatarURL,
                text = message.author.name
            },
            fields = fields
        }
    })
end

function cmp(a, b)
	for i = 1, #a do
		if b:sub(i, i) == "" then
			return true
		end
		if string.byte(a:sub(i, i)) < string.byte(b:sub(i, i)) then
			return false
		elseif string.byte(a:sub(i, i)) > string.byte(b:sub(i, i)) then
			return true
		end
	end
	return false
end

function sortTab(tab, cmp)
	local buff

	for i = 1, #tab - 1 do
		for j = i, #tab - 1 do
			if cmp(tab[j], tab[j + 1]) then
				buff = tab[j]
				tab[j] = tab[j + 1]
				tab[j + 1] = buff
			end
		end
	end
	return tab
end

function seeStoryList(message)
    local story = loadStoryItems()
	local elem = {}
	
    for i, k in pairs(story) do
        elem[#elem + 1] = i
    end
	elem = sortTab(elem, cmp)
    message:reply({
        embed = {
            title = "Items list",
            description = "Here is all the items id :\n-  **"..table.concat(elem, "**\n-  **").."**\n",
            color = 0xFF00FF,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = {
                icon_url = message.author.avatarURL,
                text = message.author.name
            },
            fields = fields
        }
    })
end

function seeStoryAttributes(args, item, message)
    if (not item) then
        message:reply({
            embed = {
                title = "Not found",
                description = "No item exists with id \""..args[2].."\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local fields = {}
        for i, k in pairs(item) do
            fields[#fields + 1] = {}
            fields[#fields].name = i
            fields[#fields].value = k
        end
        message:reply({
            embed = {
                title = "Item",
                description = "Attributes of item of id \""..args[2].."\" :",
                color = 0xFF00FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                },
                fields = fields
            }
        })
    end
end

function seeStoryArchitecture(args, authorized, message)
    
end

function startDay(args, authorized, message)
    
end

function createFields(array)
    local fields = {}
    local name = true

    if (array == nil) then
        return nil
    end
    for i, k in pairs(array) do
        if (name) then
            fields[#fields + 1] = {}
            fields[#fields].name = k
        else
            fields[#fields].value = k
        end
        name = not name
    end
    return fields
end

function getReaction(reaction)
    if (not reaction) then
        return ("")
    elseif (string.sub(reaction, 1, 1) == "<") then
        return (string.sub(reaction, 2, #reaction - 1))
    else
        return (reaction)
    end
end

function claimDaily(args, item, message)
    local dailies = getDailyTime()
	local claimed = dailies[message.author.id]
	local player = getPlayer(message.author.id, message.author)

	if (not claimed) then
		local bonus

		if player.lastDailyClaim and os.time() / 86400 <= player.lastDailyClaim + 2 then
			player.streak = (player.streak or 0) + 1
		else
			player.streak = 0
		end
		bonus = (player.streak or 0) * (player.streak or 0)
        player.essences = player.essences + daily_reward + bonus
		player.lastDailyClaim = math.floor(os.time() / 86400)
		savePlayer(message.author.id, player)
        dailies[message.author.id] = os.time()
		saveDailyTime(dailies)
        message:reply({
            embed = {
                title = "Daily !",
                description = "You claimed your daily "..daily_reward.." "..emojis.essencesEmoji..(player.streak > 0 and "\
You are on a "..(player.streak + 1).." days streak !\
Bonus: "..bonus.." "..emojis.essencesEmoji.."\
Total: "..(daily_reward + bonus).." "..emojis.essencesEmoji or "").."\
You can claim it again in **"..getTimeString(86400 - (os.time() % 86400)).."**",
                color = 0xFF8888,
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
                title = "Daily !",
                description = "You already claimed your reward "..getTimeString(os.time() - claimed).." ago\
You can claim it again in **"..getTimeString(86400 - (os.time() % 86400)).."**\
"..((player.streak or 0) > 1 and "You are on a "..player.streak.." days streak !" or "You are not in a streak."),
                color = 0x222222,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
	end
end

function writeTable(table)
    for i, k in pairs(table) do
        io.write(type(k).."\n")
        io.write(type(i).."\n")
        io.write(i.."\n")
        if (type(k) == "table") then
            writeTable(k)
        else
            io.write(k.."\n")
        end
    end
    io.write("--end\n")
end

function readTable()
    local line = ""
    local indexType = ""
    local index = ""
    local table = {}

    line = io.read()
    while line ~= "--end" do
        indexType = io.read()
        if (indexType == "number") then
            index = tonumber(io.read())
        else
            index = io.read()
        end
        if line == "number" then
            table[index] = tonumber(io.read())
        elseif (line == "table") then
            table[index] = readTable()
        else
            table[index] = io.read()
        end
        line = io.read()
    end
    return table
end

function savePlayer(id, player)
    local file = io.open("players/playerdata"..id, "w+")
    
    if not file then
        return
    end
    io.output(file)
    for i, k in pairs(player) do
        io.write(type(k).."\n")
        io.write(type(i).."\n")
        io.write(i.."\n")
        if (type(k) == "table") then
            writeTable(k)
        else
            io.write(k.."\n")
        end
    end
    io.close(file)
end

function getPlayer(id, author)
    local file = io.open("players/playerdata"..id, "r")
    local line = ""
    local indexType = ""
    local index = ""
    local player = {
        reputation = 0,
        current_location = "forest",
        name = author.name,
        icon = author.avatarURL,
		iconURL = "profile",
        essences = 0,
        item_id = "begin",
        executed = "false",
        items = {},
        energy = 0
    }
    
    if not file then
        return player
    end
    io.input(file)
    line = io.read()
    while line and indexType do
        indexType = io.read()
        if (indexType == "number") then
            index = tonumber(io.read())
        else
            index = io.read()
        end
        if line == "number" then
            player[index] = tonumber(io.read())
        elseif (line == "table") then
            player[index] = readTable()
        else
            player[index] = io.read()
        end
        line = io.read()
    end
    io.close(file)
	if player.iconURL == "profile" then
		player.icon = author.avatarURL;
	else
		player.icon = player.iconURL
	end
    return player
end

function calcLevel(xp)
    local nbr = 0
    local lvlXp = 55
    
    while xp >= lvlXp + 45 + 10 * nbr do
        lvlXp = lvlXp + 45 + 10 * nbr
        nbr = nbr + 1
        xp = xp - lvlXp
    end
    return nbr, xp, lvlXp + 45 + 10 * nbr
end

function dispPlayerStats(args, message)
    local player
    local emoji
    local color
    local inventory = ""
    local fields = {}
    local energy = ""
    local temp
    
    if (#args == 0) then
        player = getPlayer(message.author.id, message.author)
        temp = player.energy or 0
        if (player.reputation < 0) then
            emoji = emojis.badReputation
            color = -player.reputation * 65536
        else
            emoji = emojis.goodReputation
            color = player.reputation * 256 % 65536
        end
        for i = 1, 5 do
            energy = energy..tostring(emojis.nrjEmojis[math.floor((temp - 1) / 5 + 2)]).." "
            temp = temp - 1
            if temp < 0 then
                temp = 0
            end
        end
        if (type(player.items) == "table" and getTabLen(player.items) > 0) then
            local nbr = 1
            local items = loadItems()
            local cost
            
            for i, k in pairs(player.items) do
                cost = items[i] or {cost = "??"}
                inventory = inventory..nbr.."-  "..i.."  ".."x"..k.."     Cost: "..cost.cost.." "..emojis.essencesEmoji.."\n"
                nbr = nbr + 1
            end
            fields = {
                {
                    name = "Inventory",
                    value = inventory
                }
            }
        end
		if (message.guild and type(player.ownedRoles) == "table" and type(player.ownedRoles[message.guild.id]) == "table" and #player.ownedRoles[message.guild.id] > 0) then
			local needToSave = false
			
			inventory = ""
			for i, k in pairs(player.ownedRoles[message.guild.id]) do
				if (message.guild:getRole(k:sub(4, #k - 1))) then
					inventory = inventory..k.."\n"
				else
					player.ownedRoles[message.guild.id][i] = nil
					needToSave = true
				end
			end
			if needToSave then
				savePlayer(message.author.id, player)
			end
			fields[#fields + 1] = {
				name = "Owned roles",
				value = inventory
			}
		end
        message:reply({
            embed = {
                title = message.author.name,
                description = "Essences : "..player.essences.." "..emojis.essencesEmoji.."\
Reputation : "..player.reputation.." "..emoji.."\
Current location : "..player.current_location.."\
Energy left : "..energy.." ("..player.energy..")\n",
                color = color,
                timestamp = message.member and message.member.joinedAt or discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = player.icon or message.author.avatarURL,
                    text = (player.name or message.author.name)..(message.member and message.member.joinedAt and " | Joined the" or "")
                },
                fields = fields
            }
        })
    else
        local recievers = getReciever(args[1], message.guild)

        if (#recievers == 0) then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Cannot find any user called \""..args[1].."\"",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        elseif (#recievers >= 2) then
            local string = ""
            
            for i, k in pairs(recievers) do
                string = string.."<@"..k..">\n"
            end
            message:reply({
                embed = {
                    title = "Error",
                    description = "Found several members called \""..args[1].."\":\n"..string.."Use ..stats @"..args[1].." to solve this",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
        else
            player = getPlayer(recievers[1], client:getUser(recievers[1]))
            if (player.reputation < 0) then
                emoji = emojis.badReputation
                color = -player.reputation * 65536
            else
                emoji = emojis.goodReputation
                color = player.reputation * 256 % 65536
            end
            if (args[2] == "debug" and (isWhitelisted(message.member) or message.author.id == "297395434836459520")) then
                message:reply({
                    embed = {
                        title = client:getUser(recievers[1]).name,
                        description = "```"..transformTab(player).."```",
                        color = color,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = player.icon or message.author.avatarURL,
                            text = player.name or message.author.name
                        }
                    }
                })
            else
				temp = player.energy or 0
				if (player.reputation < 0) then
					emoji = emojis.badReputation
					color = -player.reputation * 65536
				else
					emoji = emojis.goodReputation
					color = player.reputation * 256 % 65536
				end
				for i = 1, 5 do
					energy = energy..tostring(emojis.nrjEmojis[math.floor((temp - 1) / 5 + 2)]).." "
					temp = temp - 1
					if temp < 0 then
						temp = 0
					end
				end
				if (type(player.items) == "table" and getTabLen(player.items) > 0) then
					local nbr = 1
					local items = loadItems()
					local cost
					
					for i, k in pairs(player.items) do
						cost = items[i] or {cost = "??"}
						inventory = inventory..nbr.."-  "..i.."  ".."x"..k.."     Cost: "..cost.cost.." "..emojis.essencesEmoji.."\n"
						nbr = nbr + 1
					end
					fields = {
						{
							name = "Inventory",
							value = inventory
						}
					}
				end
				if (type(player.ownedRoles) == "table" and type(player.ownedRoles[message.guild.id]) == "table") and #player.ownedRoles[message.guild.id] > 0 then
					local needToSave = false
					
					inventory = ""
					tmp = 0
					for i, k in pairs(player.ownedRoles[message.guild.id]) do
						if (message.guild:getRole(k:sub(4, #k - 1))) then
							inventory = inventory..k.."\n"
						else
							player.ownedRoles[message.guild.id][i] = nil
							needToSave = true
						end
					end
					if needToSave then
						savePlayer(recievers[1], player)
					end
					fields[#fields + 1] = {
						name = "Owned roles",
						value = inventory
					}
				end
				message:reply({
					embed = {
						title = message.author.name,
						description = "Essences : "..player.essences.." "..emojis.essencesEmoji.."\
Reputation : "..player.reputation.." "..emoji.."\
Current location : "..player.current_location.."\
Energy left : "..energy.." ("..player.energy..")\n",
						color = color,
						timestamp = message.guild and message.guild:getMember(recievers[1]) and message.guild:getMember(recievers[1]).joinedAt or discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = player.icon or message.author.avatarURL,
							text = (player.name or message.author.name)..(message.guild and message.guild:getMember(recievers[1]) and message.guild:getMember(recievers[1]).joinedAt and " | Joined the" or "")
						},
						fields = fields
					}
				})
            end
        end
    end
end

function saveXp(id, serv_id, xp)
    local xpTab = loadFileWithFields("xp/xp"..serv_id)
    
    xpTab[id] = xp
    saveFileWithFields("xp/xp"..serv_id, xpTab)
end

function getXp(id, serv_id)
    local xpTab = loadFileWithFields("xp/xp"..serv_id)
    local xp = tonumber(xpTab[id] or "0") or 0
    
    return xp
end

function dispXpLeaderBoard(message, start, edit)
	if not message.guild then
		message:reply({
            embed = {
                title = "Error",
                description = "This command can only be used in a server",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
		return
	end
    local leaderboard = sort(getLeaderboard(message.guild, getXp))
    local rank = 1
    local message_description = ""
    local newMessage

    message:clearReactions()
    for i, k in pairs(leaderboard) do
        for j, l in pairs(k.data) do
            local xp = getXp(l, message.guild.id)
            local level, xpRemaining, lvlXp = calcLevel(xp)
            if rank >= start and rank < start + 10 then
                --level = "∞"
                --xpRemaining = "∞"
                --lvlXp = "∞"
                --xp = "∞"
                message_description = message_description.."#"..rank.."\t<@"..l..">\n>\t\t\tLevel "..level.."\t\t\t"..xpRemaining.."/"..lvlXp.." ("..xp..")\n\n"
            end
            rank = rank + 1
        end
    end
    if not edit then
        newMessage = message:reply({
            embed = {
                title = "Leaderboard",
                description = message_description,
                color = 0xFF00FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        message:setEmbed({
            title = "Leaderboard",
            description = message_description,
            color = 0xFF00FF,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = message.embed.footer
        })
        newMessage = message
    end
    if (start > 1) then
        newMessage:addReaction("⬅")
    end
    if (rank > start + 10) then
        newMessage:addReaction("➡")
    end
end

function arrayFromIt(it)
	local arr = {}
	
	for elem in it do
		table.insert(arr, elem)
	end
	return arr
end

function createPlayerXpCard(user, guild, rank, xp, level, xpRemaining, lvlXp, playerColor)
	os.execute("mkdir xp_cards")

	local command = ("python3 utils/create_xp.py %i %i %i %i %i 3 5 64 64 65 53 320 20 %x FFFFFF '%s#%s' '%s' ./ressources/xp_bg.png xp_cards/xp_card_%s_%s.png 2>&1"):format(rank, level, xpRemaining, lvlXp, xp, playerColor, user.name:gsub("'", "’"), user.discriminator, user.avatarURL, guild.id, user.id)
	local file = io.popen(command)
	local lines = arrayFromIt(file:lines())
	local success, _, status = file:close()

	if not success then
		return nil, "Command '"..command.."' exit with error code "..tostring(status)..":\n"..table.concat(lines, "\n")
	else
		return true, ("xp_cards/xp_card_%s_%s.png"):format(guild.id, user.id)
	end
end

function dispXp(message, args)
	if not message.guild then
		message:reply({
            embed = {
                title = "Error",
                description = "This command can only be used in a server",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
		return
	end
    local ranker = message.guild:getMember(getReciever(args[1] or "<@"..message.author.id..">", message.guild)[1] or message.author.id)
    local leaderboard = sort(getLeaderboard(message.guild, getXp))
    local rank = 1
    local found = false
    local xp = getXp(ranker.id, message.guild.id)
    local level, xpRemaining, lvlXp = calcLevel(xp)

    for i, k in pairs(leaderboard) do
        for j, l in pairs(k.data) do
            if l == ranker.id then
                found = true
                break
            end
        end
        if found then
            break
        end
        rank = rank + #k.data
    end
    --level = "∞"
    --xpRemaining = "∞"
    --lvlXp = "∞"
    --xp = "∞"
	
	local success, file = createPlayerXpCard(ranker, message.guild, rank, xp, level, xpRemaining, lvlXp, tonumber(ranker.id) % 0xFFFFFF)
	
	if not success then
		message:reply({
			embed = {
				title = "Error",
				description = "An error occured when trying to create xp card:\n```"..file.."```\
Rank: #"..tostring(rank).."\
Level: "..tostring(level).."\
Xp: "..tostring(xpRemaining).."/"..lvlXp.." (Total: "..xp..")",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = ranker.avatarURL,
					text = ranker.name
				}
			}
		})
	else
		message:reply({
			file = file
		})
	end
end

function splitCond(condition)
    local leftPart, op, rightPart
    local op_start, op_end = 0, 0
    local i = 1
    local left = true
    local char

    if not condition then
        return nil, "==", nil
    end
    while i < #condition do
        char = string.sub(condition, i, i)
        if (char == "=" or char =="<" or char == ">") then
            left = false
            op_end = i
        elseif (left) then
            op_start = i
        end
        i = i + 1
    end
    return string.sub(condition, 1, op_start), string.sub(condition, op_start + 1, op_end), string.sub(condition, op_end + 1, #condition)
end

function getType(var)
    if (var == nil) then
        return "nil"
    elseif (var == "nil") then
        return "nil"
    elseif ((string.sub(var, 1, 1) == '"' or string.sub(var, 1, 1) == "'") and (string.sub(var, #var, #var) == '"' or string.sub(var, #var, #var) == "'")) then
        return "string"
    elseif (tonumber(var)) then
        return "number"
    else
        return "variable"
    end
end

function cleanString(str)
    i = 1
    
    while i <= #str do
        if (string.byte(string.sub(str, i, i)) < 32) then
            str = string.sub(str, 1, i - 1)..string.sub(str, i + 1, #str)
        else
            i = i + 1
        end
    end
    return str
end

function doCond(leftPart, comparator, rightPart, player)
    local typeLeft = getType(leftPart)
    local typeRight = getType(rightPart)
    local leftCompare, rightCompare

    if (typeLeft == "variable") then
        leftCompare = cleanString(tostring(player[leftPart]))
    else
        if (typeLeft == "string") then
            leftCompare = string.sub(leftPart, 2, #leftPart - 1)
        else
            leftCompare = leftPart
        end
    end
    if (typeRight == "variable") then
        rightCompare = cleanString(tostring(player[rightPart]))
    else
        if (typeRight == "string") then
            rightCompare = string.sub(rightPart, 2, #rightPart - 1)
        else
            rightCompare = rightPart
        end
    end
    if (comparator == "==") then
        return leftCompare == rightCompare
    elseif (comparator == "<=") then
        return (tonumber(leftCompare) and tonumber(rightCompare) and tonumber(leftCompare) <= tonumber(rightCompare))
    elseif (comparator == ">=") then
        return (tonumber(leftCompare) and tonumber(rightCompare) and tonumber(leftCompare) >= tonumber(rightCompare))
    elseif (comparator == ">") then
        return (tonumber(leftCompare) and tonumber(rightCompare) and tonumber(leftCompare) > tonumber(rightCompare))
    elseif (comparator == "<") then
        return (tonumber(leftCompare) and tonumber(rightCompare) and tonumber(leftCompare) < tonumber(rightCompare))
    end
    return false
end

function findWarp(item, player, warps, conditions)
    local part1, part2, op

    if not conditions or #conditions == 0 then
        return warps[1]
    end
    for i, k in pairs(warps) do
        part1, op, part2 = splitCond(conditions[i])
        if (doCond(part1, op, part2, player)) then
            return k
        end
    end
end

function createMessage(desc, player)
    local newMessage = ""
    local i = 1
    local var_start = 1
    
    if not desc then
        return nil
    end
    while i <= #desc do
        if (string.sub(desc, i, i + 1) == "{{") then
            i = i + 2
            var_start = i
            while string.sub(desc, i + 1, i + 2) ~= "}}" and i < #desc do
                i = i + 1
            end
            newMessage = newMessage..tostring(player[string.sub(desc, var_start, i)])
            i = i + 2
        else
            newMessage = newMessage..string.sub(desc, i, i)
        end
        i = i + 1
    end
    return newMessage
end

function execDayItem(args, item_id, message, player, id)
    local actions = {}
    local message_content = {}
    local newMessage
    local warping = true
    local item = loadStoryItems()[item_id]

    if (args[1] == "resume" or args[1] == "exec") then
        player.guild = nil
    end
    if (not item or not item.actions) then
        if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
            client:getGuild(player.guild):getChannel(player.channel) and
            client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
            newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
            newMessage:clearReactions()
            newMessage:setEmbed({
                title = "Error",
                description = "No item exists with id \""..item_id.."\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            })
        else
            message:reply({
                embed = {
                    title = "Error",
                    description = "No item exists with id \""..item_id.."\"",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = client.user.avatarURL,
                        text = client.user.name
                    }
                }
            })
        end
        return
    end
    player.item_id = item_id
    while warping do
        warping = false
        player.random = math.random(0, 1000)
        actions = parseCommand(item.actions, 1, true)
        for i, k in pairs(actions) do
            if (k == "end_day") then
                player.item_id = "begin"
				
            elseif (k == "prepare_message") then
                message_content = {
                    title = createMessage(item.title, player),
                    desc = createMessage(item.message, player),
                    color = tonumber(item.color, 16),
                    fields = createFields(parseCommand(item.fields, 1, true)),
                }
				
            elseif (k == "set_position") then
                player.current_location = item.pos
				
            elseif (k == "feed") then
                local random = math.random(1, 100)
                local tempo = 0
                for i, k in pairs(food) do
                    tempo = tempo + k.chance
                    if tempo >= random then
                        tempo = k
                        break
                    end
				end
				message_content.desc = message_content.desc.."\nYou found a "..tempo.elements[math.random(1, #tempo.elements)].." giving you "..tempo.value.." energy."
                if (player.executed == "false") then
					player.energy = player.energy + tempo.value
				end
				
            elseif (k == "give_reputation" and tonumber(item.reputation)) then
                if (tonumber(item.reputation) < 0) then
                    message_content.desc = message_content.desc.."\nYou lost "..(tonumber(item.reputation) * -1).." reputation points "..emojis.badReputation
                else
                    message_content.desc = message_content.desc.."\nYou won "..tonumber(item.reputation).." reputation points "..emojis.goodReputation
                end
                if (player.executed == "false") then
                    player.reputation = player.reputation + tonumber(item.reputation)
                end
				
            elseif (k == "set_var" and tonumber(item.var)) then
                if (player.executed == "false") then
                    player[item.var] = item.value
                end
				
            elseif (k == "use_energy" and tonumber(item.energy)) then
                if (tonumber(item.energy) >= 0) then
                    if (tonumber(player.energy) >= tonumber(item.energy)) then
                        message_content.desc = message_content.desc.."\nThat costs you "..item.energy.." energy"
                        if (player.executed == "false") then
                            player.energy = tonumber(player.energy) - tonumber(item.energy)
                        end
                    else
                        if (tonumber(player.energy) > 0) then
                            message_content.desc = message_content.desc.."\nThat costs you ***"..tonumber(item.energy).."*** energy"
                            message_content.desc = message_content.desc.."\nYou used "..((tonumber(item.energy) - tonumber(player.energy)) * 10).." "..emojis.essencesEmoji.." because you don't have enough energy"
                            if (player.executed == "false") then
                                player.essences = player.essences - (tonumber(item.energy) - tonumber(player.energy)) * 10
                                player.energy = 0
                            end
                        elseif (player.essences < (tonumber(item.energy) - tonumber(player.energy)) * 10) then
                            message_content.desc = message_content.desc.."\nYou neither have enough energy nor essences to survive.\nYou died."
                            for i, k in pairs(player) do
                                player[i] = nil
                            end
                        else
                            message_content.desc = message_content.desc.."\nYou used "..(tonumber(item.energy) * 10).." "..emojis.essencesEmoji.." because you have no energy"
                            if (player.executed == "false") then
                                player.essences = player.essences - tonumber(item.energy) * 10
                            end
                        end
                    end
                else
                    message_content.desc = message_content.desc.."\nYou earned ***"..item.energy.."*** energy"
                    if (player.executed == "false") then
                        player.energy = tonumber(player.energy) + tonumber(item.energy)
                        if player.energy > 15 then
                            player.energy = 15
                        end
                    end
                end
				
            elseif (k == "add") then
                if (player.executed == "false") then
					if not item.var or type(player[item.var]) ~= "string" or not item.value then
						if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
							client:getGuild(player.guild):getChannel(player.channel) and
							client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
							newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
							newMessage:clearReactions()
							newMessage:setEmbed({
								title = "Error",
								description = "Trying to perform arithmetic on a "..(type(player[item.var]) ~= "string" and type(player[item.var]) or "nil").." value",
								color = 0xFF0000,
								timestamp = discord.Date():toISO('T', 'Z'),
								footer = {
									icon_url = client.user.avatarURL,
									text = client.user.name
								}
							})
						else
							message:reply({
								embed = {
									title = "Error",
									description = "Trying to perform arithmetic on a nil value",
									color = 0xFF0000,
									timestamp = discord.Date():toISO('T', 'Z'),
									footer = {
										icon_url = client.user.avatarURL,
										text = client.user.name
									}
								}
							})
						end
						return
					elseif not tonumber(player[item.var]) or not tonumber(item.value) then
						if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
							client:getGuild(player.guild):getChannel(player.channel) and
							client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
							newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
							newMessage:clearReactions()
							newMessage:setEmbed({
								title = "Error",
								description = "Trying to perform arithmetic on a "..(not tonumber(player[item.var]) and type(player[item.var]) or type(item.value)).." value",
								color = 0xFF0000,
								timestamp = discord.Date():toISO('T', 'Z'),
								footer = {
									icon_url = client.user.avatarURL,
									text = client.user.name
								}
							})
						else
							message:reply({
								embed = {
									title = "Error",
									description = "Trying to perform arithmetic on a nil value",
									color = 0xFF0000,
									timestamp = discord.Date():toISO('T', 'Z'),
									footer = {
										icon_url = client.user.avatarURL,
										text = client.user.name
									}
								}
							})
						end
						return
					else
						player[item.var] = player[item.var] + tonumber(item.value)
					end
				end
				
            elseif (k == "give") then
                if (player.executed == "false") then
                    if (type(player.items) ~= "table") then
                        player.items = {}
                    end
					if not item.item then
						if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
							client:getGuild(player.guild):getChannel(player.channel) and
							client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
							newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
							newMessage:clearReactions()
							newMessage:setEmbed({
								title = "Error",
								description = "Trying to give no item (item field is nil)",
								color = 0xFF0000,
								timestamp = discord.Date():toISO('T', 'Z'),
								footer = {
									icon_url = client.user.avatarURL,
									text = client.user.name
								}
							})
						else
							message:reply({
								embed = {
									title = "Error",
									description = "Trying to give no item (item field is nil)",
									color = 0xFF0000,
									timestamp = discord.Date():toISO('T', 'Z'),
									footer = {
										icon_url = client.user.avatarURL,
										text = client.user.name
									}
								}
							})
						end
						return
					end
                    if not player.items[item.item] then
                        player.items[item.item] = 0
                    end
                    player.items[item.item] = player[item.item] + (tonumber(item.number) or 1)
                end
                message_content.desc = message_content.desc.."\nYou found "..(tonumber(item.number) or 1).." "..item.item
				
            elseif (k == "give_essence" and tonumber(item.essence)) then
                if (tonumber(item.essence) < 0) then
                    message_content.desc = message_content.desc.."\nYou used "..(tonumber(item.essence) * -1).." "..emojis.essencesEmoji
                else
                    message_content.desc = message_content.desc.."\nYou stole "..tonumber(item.essence).." "..emojis.essencesEmoji
                end
                if (player.executed == "false") then
                    player.essences = player.essences + tonumber(item.essence)
                end
				
            elseif (k == "ask") then
                if (item.questions) then
                    item.icon = parseCommand(item.icons, 1, true) or {}
                    for i, k in pairs(parseCommand(item.questions, 1, true)) do
                        if (not message_content.fields) then
                            message_content.fields = {}
                        end
                        message_content.fields[#message_content.fields + 1] = {name = item.icon[i], value = k, inline = true}
                    end
                end
				
            elseif (k == "warp") then
                local warp = findWarp(item, player, parseCommand(item.warp, 1, true) or {}, parseCommand(item.warp_requirement, 1, true) or {})

                warping = true
                if not warp then
                    if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
                        client:getGuild(player.guild):getChannel(player.channel) and
                        client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
                        newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
                        newMessage:clearReactions()
                        newMessage:setEmbed({
                            title = "Error",
                            description = "Couldn't choose a warp (No requirements match)",
                            color = 0xFF0000,
                            timestamp = discord.Date():toISO('T', 'Z'),
                            footer = {
                                icon_url = client.user.avatarURL,
                                text = client.user.name
                            }
                        })
                    else
                        message:reply({
                            embed = {
                                title = "Error",
                                description = "Couldn't choose a warp (No requirements match)",
                                color = 0xFF0000,
                                timestamp = discord.Date():toISO('T', 'Z'),
                                footer = {
                                    icon_url = client.user.avatarURL,
                                    text = client.user.name
                                }
                            }
                        })
                    end
                    return
                end
                item = loadStoryItems()[warp]
                if not item then
                    if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
                        client:getGuild(player.guild):getChannel(player.channel) and
                        client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
                        newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
                        newMessage:clearReactions()
                        newMessage:setEmbed({
                            title = "Error",
                            description = "No item exists with id \""..warp.."\"",
                            color = 0xFF0000,
                            timestamp = discord.Date():toISO('T', 'Z'),
                            footer = {
                                icon_url = client.user.avatarURL,
                                text = client.user.name
                            }
                        })
                    else
                        message:reply({
                            embed = {
                                title = "Error",
                                description = "No item exists with id \""..warp.."\"",
                                color = 0xFF0000,
                                timestamp = discord.Date():toISO('T', 'Z'),
                                footer = {
                                    icon_url = client.user.avatarURL,
                                    text = client.user.name
                                }
                            }
                        })
					end
                    return
                end
                player.item_id = warp
				
            elseif (k == "send_message") then
                if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
                    client:getGuild(player.guild):getChannel(player.channel) and
                    client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
                    newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
                    newMessage:clearReactions()
                    newMessage:setEmbed({
                        title = message_content.title,
                        description = message_content.desc,
                        color = message_content.color,
                        timestamp = discord.Date():toISO('T', 'Z'),
                        footer = {
                            icon_url = player.icon or message.author.avatarURL,
                            text = player.name or message.author.name
                        },
                        fields = message_content.fields
                    })
                else
                    newMessage = message:reply({
                        embed = {
                            title = message_content.title,
                            description = message_content.desc,
                            color = message_content.color,
                            timestamp = discord.Date():toISO('T', 'Z'),
                            footer = {
                                icon_url = player.icon or message.author.avatarURL,
                                text = player.name or message.author.name
                            },
                            fields = message_content.fields
                        }
                    })
                end
                if (newMessage) then
                    if item.icon then
                        for i, k in pairs(item.icon) do
                            newMessage:addReaction(getReaction(k))
                        end
                    end
                    if (newMessage.member) then
                        player.guild = newMessage.member.guild.id
                    end
                    player.channel = newMessage.channel.id
                    player.message = newMessage.id
                end
				
            else
				if (message.member and client:getGuild(player.guild) and message.guild.id == player.guild and
					client:getGuild(player.guild):getChannel(player.channel) and
					client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)) then
					newMessage = client:getGuild(player.guild):getChannel(player.channel):getMessage(player.message)
					newMessage:clearReactions()
					newMessage:setEmbed({
						title = "Error",
						description = "Couldn't find action \""..k.."\"",
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = client.user.avatarURL,
							text = client.user.name
						}
					})
				else
					message:reply({
						embed = {
							title = "Error",
							description = "Couldn't find action \""..k.."\"",
							color = 0xFF0000,
							timestamp = discord.Date():toISO('T', 'Z'),
							footer = {
								icon_url = client.user.avatarURL,
								text = client.user.name
							}
						}
					})
				end
                return
            end
        end
        player.executed = "true"
    end
    saveMoney(id, player.essences)
    player.random = nil
    savePlayer(id, player)
end

function isAdmin(member)
	if (member == nil) then
		return (false)
	elseif (member:hasPermission("administrator")) then
		return (true)
	end
	return (false)
end

local function code(str)
    return string.format('```\n%s```', str)
end

function execLua(luaCode, message)
    if not luaCode then
        return
    end
    
    luaCode = luaCode:gsub('```\n?', '')
    local lines = {}
    local sandbox = setmetatable({
        token = { }
    }, { __index = _G })

    local function printLine(...)
        local ret = {}
        for i = 1, select('#', ...) do
            local arg = tostring(select(i, ...))
            table.insert(ret, arg)
        end
        return table.concat(ret, '\t')
    end
    sandbox.message = message
    sandbox.luaCode = luaCode
    sandbox.discord = discord
    sandbox.timer = timer
    sandbox.client = client
    sandbox.emojis = emojis
    sandbox.my_id = my_id
    sandbox.event = event
    sandbox.essencesEmoji = emojis.essencesEmoji
    sandbox.already_claimed = already_claimed
    sandbox.shop = shop
    sandbox.food = food
    sandbox.defaultActions = defaultActions
    sandbox.getLeaderboard = getLeaderboard
    sandbox.grabMeeDatabase = grabMeeDatabase
    sandbox.getLength = getLength
    sandbox.getMoney = getMoney
    sandbox.getRoleByName = getRoleByName
    sandbox.getReaction = getReaction
    sandbox.getReciever = getReciever
    sandbox.getPlayer = getPlayer
    sandbox.getTimeString = getTimeString
    sandbox.giveRole = giveRole
    sandbox.isAdmin = isAdmin
    sandbox.isWhitelisted = isWhitelisted
    sandbox.parseChannel = parseChannel
    sandbox.parseCommand = parseCommand
    sandbox.resumeDay = resumeDay
    sandbox.showShop = showShop
    sandbox.sort = sort
    sandbox.savePlayer = savePlayer
	sandbox.doCond = doCond
    sandbox.scanDir = scanDir
	sandbox.getDailyTime = getDailyTime
    sandbox.createMessage = createMessage
    sandbox.loadStoryItems = loadStoryItems
    sandbox.saveXp = saveXp
    sandbox.getXpRoles = getXpRoles
	sandbox.calcLevel = calcLevel
    sandbox.getXp = getXp
    sandbox.match = match
    sandbox.saveFile = saveFile
    sandbox.loadFile = loadFile
    sandbox.memberLeaving = memberLeaving
    sandbox.saveMoney = saveMoney
    sandbox.loadFileWithFields = loadFileWithFields
    sandbox.saveFileWithFields = saveFileWithFields
    sandbox.transformTab = transformTab
    sandbox.convertString = convertString
    sandbox.splitCond = splitCond
    sandbox.print = function(...)
        table.insert(lines, printLine(...))
    end

    local fct, syntaxError = load(luaCode, 'Ahri', 't', sandbox)
    if not fct then
        return message:reply(code(syntaxError))
    end
    
    local success, runtimeError = pcall(fct)
    if not success then
        return message:reply(code(runtimeError))
    end
    
    lines = table.concat(lines, '\n')
    return message:reply(code(lines))
end

function sellItem(args, message)
    local player = getPlayer(message.author.id, message.author)
    local items = loadItems()
    
    if (#args < 2) then
        message:reply({
            embed = {
                title = "Error",
                description = "Expected 2 arguments but got "..#args,
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    elseif (not items[args[1]] or not items[args[1]].cost) then
        message:reply({
            embed = {
                title = "Error",
                description = "Cannot find any items called \""..args[1].."\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    elseif (not tonumber(args[2])) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #2: Number expected",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    elseif (not player.items or not player.items[args[1]] or tonumber(args[2]) > player.items[args[1]]) then
        message:reply({
            embed = {
                title = "Error",
                description = "You don't have enough "..args[1],
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    else
        player.items[args[1]] = player.items[args[1]] - tonumber(args[2])
        if (player.items[args[1]] <= 0) then
            player.items[args[1]] = nil
        end
        player.essences = player.essences + (tonumber(args[2]) * items[args[1]].cost)
        savePlayer(message.author.id, player)
        message:reply({
            embed = {
                title = "Sold",
                description = "You sold "..args[2].." "..args[1].."\nYou earn "..(tonumber(args[2]) * items[args[1]].cost).." "..emojis.essencesEmoji,
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    end
end

function changeName(args, message)
    local player = getPlayer(message.author.id, message.author)
    local valid = true

    if args[1] then
        for i = 1, #args[1] do
            if args[1]:sub(i, i) == "\n" then
                valid = false
                break
            end
        end
        if valid then
            player.name = args[1]
            savePlayer(message.author.id, player)
            message:reply({
                embed = {
                    title = "New name",
                    description = "Successfully changed your name to "..args[1],
                    color = 0x00FF00,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = client.user.avatarURL,
                        text = client.user.name
                    }
                }
            })
        else
            message:reply({
            embed = {
                title = "Error",
                description = "Line breaks are not allowed in names",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
        end
    else
        local success, err = message:reply({
            embed = {
                title = "Error",
                description = "Expected 1 argument but got 0",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })
    end
end

function changeIcon(args, message)
    local player = getPlayer(message.author.id, message.author)
    
    if args[1] then
        local embed = {
            title = "New icon",
            description = "Successfully changed your icon to ",
            image = {
                url = args[1],
                width = 640,
                height = 640
            },
            color = 0x00FF00,
            timestamp = discord.Date():toISO('T', 'Z'),
            footer = {
                icon_url = client.user.avatarURL,
                text = client.user.name
            }
        }
		if args[1] == "profile" then
			embed.image.url = message.author.avatarURL;
		end
        local success, err = message:reply({embed = embed})

        if not success then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Couldn't change your icon :\n\t\t"..tostring(err or ""),
                    color = 0x000000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = client.user.avatarURL,
                        text = client.user.name
                    }
                }
            })
        else
            player.iconURL = args[1]
            savePlayer(message.author.id, player)
        end
    else
        local success, err = message:reply({
            embed = {
                title = "Icon",
                description = "Here is your current player icon",
                image = {
                    url = player.icon,
                    width = 640,
                    height = 640
                },
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = client.user.avatarURL,
                    text = client.user.name
                }
            }
        })

        if not success then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Couldn't display your current icon :\n\t\t"..tostring(err or ""),
                    color = 0x000000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = client.user.avatarURL,
                        text = client.user.name
                    }
                }
            })
        end
    end
end

function saveFile(path, content)
    local file = io.open(path, "w+")
    
    if not file then
        return
    end
    io.output(file)
    for i, k in pairs(content) do
        io.write(tostring(k).."\n")
    end
    io.close(file)
end

function saveFileWithFields(path, content)
    local file = io.open(path, "w+")
    
    if not file then
        return
    end
    io.output(file)
    for i, k in pairs(content) do
        io.write(tostring(i).."\n")
        io.write(tostring(k).."\n")
    end
    io.close(file)
end

function loadFile(path)
    local file = io.open(path, "r")
    local line = ""
    local content = {}
    
    if not file then
        return {}
    end
    io.input(file)
    line = io.read()
    while line do
        content[#content + 1] = line
        line = io.read()
    end
    io.close(file)
    return content
end

function loadFileWithFields(path)
    local file = io.open(path, "r")
    local line = ""
    local content = {}
    
    if not file then
        return {}
    end
    io.input(file)
    line = io.read()
    while line do
        content[line] = io.read()
        line = io.read()
    end
    io.close(file)
    return content
end

function doHug(args, message)
    local random
    local recievers = {}
    local database= {
        myself = loadFile("hugs/self"),
        fail = loadFile("hugs/fail"),
        success = loadFile("hugs/success"),
    }

    for i, k in pairs(args) do
        for j, l in pairs(getReciever(args[i], message.guild)) do
            recievers[#recievers + 1] = l
        end
    end
    if (args[1] == "myself" or not recievers or not recievers[1] or recievers[1] == message.author.id) then
        message:reply({
            embed = {
                description = "Lonely, <@"..message.author.id.."> hugs himself",
                image = {
                    url = database.myself[math.random(1, #database.myself)],
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
        random = math.random(1, #database.fail + #database.success)
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
                    description = "<@"..message.author.id.."> wanted to hug "..reciever.." but it didn't work :/",
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
                    description = reciever.." recieved a hug from <@"..message.author.id.."> "..emojis.loveyou,
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

function doPat(args, message)
    local random
    local recievers = {}
    local reciever = ""
    local database= {
        fail = loadFile("pats/fail"),
        success = loadFile("pats/success"),
    }

    for i, k in pairs(args) do
        for j, l in pairs(getReciever(args[i], message.guild)) do
            recievers[#recievers + 1] = l
        end
    end
    random = math.random(1, #database.fail + #database.success)
    if (not recievers or not recievers[1] or recievers[1] == message.author.id) then
        reciever = table.concat(args, " ")
    else
        for i, k in pairs(recievers) do
            if i == #recievers - 1 then
                reciever = reciever.."<@"..k.."> and "
            elseif i ~= #recievers then
                reciever = reciever.."<@"..k..">, "
            else
                reciever = reciever.."<@"..k..">"
            end
        end
    end
    if (random > #database.success) then
        message:reply({
            embed = {
                description = "<@"..message.author.id.."> wanted to pat "..reciever.." but nope :/",
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
                description = "<@"..message.author.id.."> pats "..reciever,
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

function dispSAR(sar, message, index, edit)
	local nbr = 0
	local newMsg = message
	local str = ""
    
	sar = sar or loadFile("configs/selfAssignableRoles"..message.guild.id)
	if edit then
		newMsg:clearReactions()
	end
	for i, k in pairs(sar) do
		if message.guild:getRole(k) then
			nbr = nbr + 1
			if nbr - (index - 1) * 30 <= 30 and nbr - (index - 1) * 30 > 0 then
				str = str.."- "..message.guild:getRole(k).name.."\n"
			end
		end
	end
	if not edit then
		newMsg = message:reply({
			embed = {
				title = "Self Assignable Roles Page "..index,
				description = str,
				color = 0xFF00FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	else
		message:setEmbed({
			title = "Self Assignable Roles Page "..index,
			description = str,
			color = 0xFF00FF,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = message.embed.footer
		})
	end
    if (index > 1) then
        newMsg:addReaction("⬅")
    end
    if (nbr - (index - 1) * 30 > 30) then
        newMsg:addReaction("➡")
    end
end

function selfAssignableRole(role, action, message)
    local sar = loadFile("configs/selfAssignableRoles"..message.guild.id)
	local found = false

    if action == "del" then
		for i, k in pairs(sar) do
			if role == k or role:sub(4, #role - 1) == k or message.guild:getRole(k) and message.guild:getRole(k).name == role then
				message:reply({
					embed = {
						title = "Success",
						description = "Successfully deleted <@&"..sar[i].."> from the list",
						color = 0x00FF00,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				sar[i] = nil
				found = true
				break
			end
		end
		if not found then
			message:reply({
				embed = {
					title = "Error",
					description = "Cannot find the role \""..role.."\" in the list",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		end
		saveFile("configs/selfAssignableRoles"..message.guild.id, sar)
    elseif action == "add" then
		if message.guild:getRole(role) then
			sar[#sar + 1] = role
		elseif message.guild:getRole(role:sub(4, #role - 1)) then
			sar[#sar + 1] = role:sub(4, #role - 1)
		else
			for i in message.guild.roles:iter() do
				if i.name == role then
					sar[#sar + 1] = i.id
					found = true
					break
				end
			end
			if not found then
				message:reply({
					embed = {
						title = "Error",
						description = "Cannot find the role \""..role.."\"",
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				return
			end
		end
		message:reply({
			embed = {
				title = "Success",
				description = "Successfully added <@&"..sar[#sar].."> to the list",
				color = 0x00FF00,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
		saveFile("configs/selfAssignableRoles"..message.guild.id, sar)
    elseif action == "see" then
        dispSAR(sar, message, 1)
    else
        error("Unknown action "..action)
    end
end

function saveSuggest(command, failed)
    for i, k in pairs(failed) do
        local a = loadFileWithFields("fails/failed_"..k)
        
        if not a[command] then
            a[command] = 1
        else
            a[command] = a[command] + 1
        end
        saveFileWithFields("fails/failed_"..k, a)
    end
end

function getSuggest(command)
    local suggests = loadFileWithFields("fails/failed_"..command)
    local temp = {}
    local len = 0
    
    for i, k in pairs(suggests) do
        len = len + 1
    end
    if len == 0 then
        return ""
    end
    for i, k in pairs(suggests) do
        for j = 1, tonumber(k) do
            temp[#temp + 1] = i
        end
    end
    return "\n\nDid you want to use \"**.."..temp[math.random(1, #temp)].."**\" ?\n"
end

function dispNo(message)
    message:reply({
        embed = {
            title = "NO !",
            description = 'NOOOOOO '..emojis.no,
            image = {
                url = "http://puu.sh/zwY0J/e1b6dfb342.gif",
                with = 640,
                height = 640
            }
        }
    })
end

function editCustomRole(args, message)
	local allowed = isAdmin(message.member) or isWhitelisted(message.author)
	local player = getPlayer(message.author.id, message)
	local role
	
	for i = 1, 3 do
		args[i] = args[i + 1]
	end
	args[4] = nil
	if not message.guild then
		message:reply({
			embed = {
				title = "Error",
				description = "This command needs to be used on a server",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
		return
	end
	if #args < 3 then
		message:reply({
			embed = {
				title = "Error",
				description = "Not enought arguments: 3 expected but "..#args.." found.\nUsage ..custom_role edit <id>/<name> <new_name> <new_color>",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
		return
	end
	if message.guild and type(player.ownedRoles) == "table" and type(player.ownedRoles[message.guild.id]) == "table" and #player.ownedRoles[message.guild.id] > 0 then
		for i, k in pairs(player.ownedRoles[message.guild.id]) do
			if message.guild:getRole(k:sub(4, #k - 1)) and message.guild:getRole(k:sub(4, #k - 1)).name == args[1] or k:sub(4, #k - 1) == args[1] then
				allowed = true
				role = message.guild:getRole(k:sub(4, #k - 1))
				break
			end
		end
	end
	if not role then
		role = getRoleByName(args[1], message.guild)
	end
	if not role then
		message:reply({
			embed = {
				title = "Error",
				description = "Couldn't find any role called or with id \""..args[1].."\"",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	elseif not allowed then
		message:reply({
			embed = {
				title = "Error",
				description = "You don't own <@&"..role.id..">",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	else
		if not tonumber(args[3], 16) and (args[3]:sub(1, 1) ~= "#" or not tonumber(args[3]:sub(2, #args[3]), 16)) then
			message:reply({
				embed = {
					title = "Error",
					description = args[3].." is not a valid hex number",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not role:setName(args[2]) then
			message:reply({
				embed = {
					title = "Error",
					description = "Couldn't change <@&"..role.id..">'s name to "..args[2],
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not role:setColor(tonumber(args[3], 16) or tonumber(args[3]:sub(2, #args[3]), 16)) then
			message:reply({
				embed = {
					title = "Error",
					description = "Couldn't change <@&"..role.id..">'s color to #"..(tonumber(args[3], 16) or tonumber(args[3]:sub(2, #args[3]), 16)),
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
					title = "Success",
					description = "Changed __**"..args[1].."**__ to <@&"..role.id..">",
					color = tonumber(args[3], 16) or tonumber(args[3]:sub(2, #args[3]), 16),
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

function customRoles(message, authorized, args)
    if (args[1] == "settings") then
        changeCustomRolesSettings(args, authorized or isAdmin(message.member), message)
    elseif (args[1] == "create") then
        createCustomRole(args, message)
    elseif (args[1] == "edit") then
        editCustomRole(args, message)
    else
        message:reply({
            embed = {
                title = "Error",
                description = 'Invalid argument #1: Expected "settings", "edit" or "create"',
                color = 0x0FF000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function setValue(message, args)
    local recievers = getReciever(args[1])
    local player
    
    if (#recievers < 0) then
        return
    end
    player = getPlayer(recievers[1], client:getUser(recievers[1]))
    player[args[2]] = args[3]
    savePlayer(recievers[1], player)
    message:reply({
        embed = {
            description = "<@"..recievers[1].."> player."..args[2].." = "..tostring(args[3]),
            color = 0x000000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
        }
    })
end

function items(message, args, authorized)
    if (args[1] == "delete" and authorized) then
        local items = loadItems()
        
        items[args[2]] = nil
        message:reply({
            embed = {
                title = "Delete",
                description = "Deleted item "..args[2],
                color = 0x000000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        saveItems(items)
    elseif (args[1] == "add" and authorized) then
        local items = loadItems()
        
        items[args[2]] = {cost = tonumber(args[3])}
        message:reply({
            embed = {
                title = "Update",
                description = args[2].." now cost "..args[3].." "..emojis.essencesEmoji,
                color = 0x000000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        saveItems(items)
    else
        local items = loadItems()
        local desc = ""
        
        for i, k in pairs(items) do
            desc = desc..i.."   "..k.cost.." "..emojis.essencesEmoji.."\n"
        end
        message:reply({
            embed = {
                title = "Items",
                description = desc,
                color = 0x000000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function day(message, args, authorized)
    authorized = authorized or message.author.id == "297395434836459520"
    if (args[1] == "delete" and authorized) then
        deleteStoryItem(args, authorized, message)
    elseif (args[1] == "add" and authorized) then
        addStoryItem(args, authorized, message)
    elseif (args[1] == "architechture" and authorized) then
        seeStoryArchitecture(args, authorized, message)
    elseif (args[1] == "see" and authorized) then
        seeStoryAttributes(args, loadStoryItems()[args[2]], message)
    elseif (args[1] == "list" and authorized) then
        seeStoryList(message)
    elseif (args[1] == "exec" and authorized) then
        local player = getPlayer(message.author.id, message.author)
        player.executed = "false"
        execDayItem(args, args[2], message, player, message.author.id)
    else
        execDayItem(args, getPlayer(message.author.id, message.author).item_id, message, getPlayer(message.author.id, message.author), message.author.id)
    end
end

function lsar(message, args, authorized)
	if not message.guild then
        message:reply({
            embed = {
                title = "Error",
                description = "This command needs to be used on a server",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
		return
	end
    authorized = authorized or isAdmin(message.member)
    if args[1] == "add" and authorized then
        selfAssignableRole(args[2], "add", message)
    elseif args[1] == "delete" and authorized then
        selfAssignableRole(args[2], "del", message)
    else
        selfAssignableRole(nil, "see", message)
    end
end

function leaveMsg(message, args, authorized)
    local welcome = {}
    for i = 1, #args, 2 do
        welcome[args[i]] = args[i + 1]
    end
    if not welcome.channel or not message.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid or no channel specified",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local function sendWelcomeMessage(message, content)
            local success, err = message:reply(content) 
            if not success then
                return err
            end
        end
        local success, err = pcall(sendWelcomeMessage, message, {
            content = "Here is what the leave message will look like :",
            embed = {
                title = createMessage(welcome.title, message.member),
                description = createMessage(welcome.description, message.member),
                color = tonumber(welcome.color, 16),
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.member.user.avatarURL,
                    text = message.member.user.name
                },
                image = {
                    url = welcome.image
                }
            }
        })
        if success and not err then
            saveFileWithFields("configs/leavingMessage"..message.guild.id, welcome)
        else
            message:reply({
                embed = {
                    title = "Error",
                    description = err,
                    color = 0xFF0000,
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

function welcomeMsg(message, args, authorized)
    local welcome = {}
    for i = 1, #args, 2 do
        welcome[args[i]] = args[i + 1]
    end
    if not welcome.channel or not message.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)) then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid or no channel specified",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    else
        local function sendWelcomeMessage(message, content)
            local success, err = message:reply(content) 
            if not success then
                return err
            end
        end
        local success, err = pcall(sendWelcomeMessage, message, {
            content = "Here is what the welcome message will look like :",
            embed = {
                title = createMessage(welcome.title, message.member),
                description = createMessage(welcome.description, message.member),
                color = tonumber(welcome.color, 16),
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.member.user.avatarURL,
                    text = message.member.user.name
                },
                image = {
                    url = welcome.image
                }
            }
        })
        if success and not err then
            saveFileWithFields("configs/welcome"..message.guild.id, welcome)
        else
            message:reply({
                embed = {
                    title = "Error",
                    description = err,
                    color = 0xFF0000,
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

function dispShop(message, args, authorized)
    if not message.guild then
        message:reply({
            embed = {
                title = "Error",
                description = "You need to use this command on a server.",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
        return
    end
    loadShop(message.guild.id)
    if (args[1] == "delete" and (authorized or isAdmin(message.member))) then
        deleteShopItem(args, authorized, message)
    elseif (args[1] == "add" and (authorized or isAdmin(message.member))) then
        addShopItem(args, authorized, message)
    else
        showShop(args, authorized, message, false, 1)
    end
end

function autorole(message, args)
    if not args[1] then
        saveFile("configs/autorole"..message.guild.id, {})
        message:reply({
            embed = {
                title = "Success !",
                description = "No roles will be given to joing members",
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif message.guild:getRole(string.sub(args[1], 4, #args[1] - 1)) then
        saveFile("configs/autorole"..message.guild.id, {args[1]})
        message:reply({
            embed = {
                title = "Success !",
                description = "All users joining the server will be assigned to "..args[1],
                color = 0x00FF00,
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
                title = "Error",
                description = "Couldn't get role for "..tostring(args[1]),
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function append(table, id, value)
	local new = {}
	
	for i, k in pairs(table) do
		if i >= id then
			new[i + 1] = table[i]
		else
			new[i] = table[i]
		end
	end
	new[id] = value
	return new
end

function sendProof(message, settings, victim, msg, reason, title)
	if settings.channel then
		local fields = {}
		local nbr = 0
		local time = 0
		local desc2 = ""

		if settings.messages and tonumber(settings.messages) and tonumber(settings.messages) > 0 then
			local tempMsg = message.channel:getLastMessage()
			local ending = false
			local safety = 0
			
			while not ending and nbr < tonumber(settings.messages) and safety < 200 do
				for i in message.channel:getMessagesBefore(tempMsg, 1):iter() do
					if i.author.id == message.author.id or i.author.id == victim then
						nbr = nbr + 1
						fields = append(fields, 1, {name = i.author.name..":", value = tostring(i.content):sub(1, 1900 / tonumber(settings.messages))})
						if fields[1].value == "" then
							fields[1].value = ("Empty message"):sub(1, 1900 / tonumber(settings.messages))
						end
						if (#tostring(i.content) > 1900 / tonumber(settings.messages)) then
							fields[1].value = fields[1].value.."..."
						end
						if nbr == tonumber(settings.messages) then
							break
						end
					end
					if (tempMsg == i) then
						ending = true
					end
					tempMsg = i
				end
				safety = safety + 1
			end
			desc2 = "\n__Last "..tostring(nbr).." messages__:\n"
		end
		if (client:getChannel(settings.channel:sub(3, #settings.channel - 1))) then
			local success, err = client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
				embed = {
					title = title,
					description = msg.."\n**Reason**: "..reason..desc2,
					timestamp = discord.Date():toISO('T', 'Z'),
					fields = fields,
					color = 0xFFFFFF,
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		
			if not success then
				if not client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Couldn't send log message\nHere is the message I tried to send",
							color = 0xFF0000,
							footer = {
								icon_url = client.user.avatarURL,
								text = client.user.name
							}
						}
					}) then
					message:reply({
						embed = {
							title = "Error",
							description = string.format("I cannot write in %s: %s\n", settings.channel, err),
							color = 0xFF0000,
							footer = {
								icon_url = client.user.avatarURL,
								text = client.user.name
							}
						}
					})
					return
				end
			
				for i = 1, #transformTab({
					embed = {
						title = title,
						description = msg.."\n**Reason**: "..reason..desc2,
						timestamp = discord.Date():toISO('T', 'Z'),
						fields = fields,
						color = 0xFFFFFF,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				}), 1900 do
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send(transformTab({
						embed = {
							title = title,
							description = msg.."\n**Reason**: "..reason..desc2,
							timestamp = discord.Date():toISO('T', 'Z'),
							fields = fields,
							color = 0xFFFFFF,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					}):sub(i, i + 1899))
				end
			end
		end
	end
end

function kickCommand(args, authorized, message)
	local settings = loadFileWithFields("configs/mute"..message.guild.id)

	authorized = authorized or (message.member and message.member:hasPermission("kickMembers"))
	if not authorized then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	else
		local settings = loadFileWithFields("configs/mute"..message.guild.id)

		if not args[1] or not args[2] then
			message:reply({
				embed = {
					title = "Error",
					description = "Missing arguments: at least 2 expected but "..#args.." found\nUsage: ..kick <user> \"<reason>\"",
					timestamp = discord.Date():toISO('T', 'Z'),
					color = 0xFF0000,
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local recievers = getReciever(args[1], message.guild)
			
			if #recievers == 0 then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't find anyone called "..args[1],
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif #recievers > 1 then
				local str = ""
				for i, k in pairs(recievers) do
					str = str.."\t\t-\t\t<@"..k..">\n"
				end
				message:reply({
					embed = {
						title = "Error",
						description = "Found multiple user called "..args[1]..":\n"..str,
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not message.guild:getMember(client.user.id):hasPermission("kickMembers") then
				message:reply({
					embed = {
						title = "Error",
						description = "I am missing the \"kickMembers\" permission",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getMember(recievers[1]).highestRole.position >= message.guild:getMember(client.user.id).highestRole.position then
				message:reply({
					embed = {
						title = "Error",
						description = "<@"..recievers[1].."> has an higher than my highest role, preventing me from kicking him",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild.ownerId == recievers[1] then
				message:reply({
					embed = {
						title = "Error",
						description = "<@"..recievers[1].."> is the owner !",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getMember(recievers[1]).highestRole.position >= message.member.highestRole.position and message.guild.ownerId ~= message.author.id then
				message:reply({
					embed = {
						title = "Error",
						description = string.format(
							"You can't kick people that has an higher or the same highest role than yours !\n%i - %s >= %i - %s",
							message.guild:getMember(recievers[1]).highestRole.position,
							message.guild:getMember(recievers[1]).highestRole.name,
							message.member.highestRole.position,
							message.member.highestRole.name
						),
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				client:getUser(recievers[1]):send({
					embed = {
						title = "Kick",
						description = string.format("You got kicked from server \"%s\"\nReason: %s", message.guild.name, args[2]),
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				if not message.guild:getMember(recievers[1]):kick(args[1]) then
					message:reply({
						embed = {
							title = "Error",
							description = "Cannot kick <@"..recievers[1]..">",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
					return
				end
				message:reply({
					embed = {
						title = "**Kicked** "..emojis.evil,
						description = "Successfully kicked <@"..recievers[1]..">"..desc,
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				sendProof(message, settings, recievers[1], "<@"..message.author.id.."> kicked <@"..recievers[1]..">", args[2], "**Kicked** "..emojis.evil)
			end
		end
	end
end

function banCommand(args, authorized, message)
	local settings = loadFileWithFields("configs/mute"..message.guild.id)

	authorized = authorized or (message.member and message.member:hasPermission("banMembers"))
	if not authorized then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	else
		local settings = loadFileWithFields("configs/mute"..message.guild.id)

		if not args[1] or not args[2] then
			message:reply({
				embed = {
					title = "Error",
					description = "Missing arguments: at least 2 expected but "..#args.." found\nUsage: ..ban <user> \"<reason>\" [<time> [s/m/h]]",
					timestamp = discord.Date():toISO('T', 'Z'),
					color = 0xFF0000,
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local recievers = getReciever(args[1], message.guild)
			
			if #recievers == 0 then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't find anyone called "..args[1],
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif #recievers > 1 then
				local str = ""
				for i, k in pairs(recievers) do
					str = str.."\t\t-\t\t<@"..k..">\n"
				end
				message:reply({
					embed = {
						title = "Error",
						description = "Found multiple user called "..args[1]..":\n"..str,
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not message.guild:getMember(client.user.id):hasPermission("banMembers") then
				message:reply({
					embed = {
						title = "Error",
						description = "I am missing the \"banMembers\" permission",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getMember(recievers[1]).highestRole.position >= message.guild:getMember(client.user.id).highestRole.position then
				message:reply({
					embed = {
						title = "Error",
						description = "<@"..recievers[1].."> has an higher than my highest role, preventing me from banning him",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild.ownerId == recievers[1] then
				message:reply({
					embed = {
						title = "Error",
						description = "<@"..recievers[1].."> is the owner !",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getMember(recievers[1]).highestRole.position >= message.member.highestRole.position and message.guild.ownerId ~= message.author.id then
				message:reply({
					embed = {
						title = "Error",
						description = string.format(
							"You can't ban people that has an higher or the same highest role than yours !\n%i - %s >= %i - %s",
							message.guild:getMember(recievers[1]).highestRole.position,
							message.guild:getMember(recievers[1]).highestRole.name,
							message.member.highestRole.position,
							message.member.highestRole.name
						),
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				local desc, time, reason = getReasonTime(args)
				
				client:getUser(recievers[1]):send({
					embed = {
						title = "Banned",
						description = string.format("You got banned from server \"%s\"\nReason: %s\nBan duration: %s", message.guild.name, reason, desc == "" and "Permanent" or desc),
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				if not message.guild:getMember(recievers[1]):ban(args[2], 0) then
					message:reply({
						embed = {
							title = "Error",
							description = "Cannot ban <@"..recievers[1]..">",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
					return
				end
				if time then
					coroutine.wrap(unbanAfter)(message.guild, time, recievers[1])
				end
				message:reply({
					embed = {
						title = "**Banned** "..emojis.ban,
						description = "Successfully banned <@"..recievers[1]..">"..desc,
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				sendProof(message, settings, recievers[1], "<@"..message.author.id.."> banned <@"..recievers[1].."> "..desc, reason, "**Banned** "..emojis.ban)
			end
		end
	end
end

function muteCommand(args, authorized, message)
	local settings = loadFileWithFields("configs/mute"..message.guild.id)
	local auth = parseCommand(settings.authorized, 1, true)

	for k, i in pairs(auth or {}) do
		if message.guild:getRole(string.sub(i, 4, #i - 1)) and message.member:hasRole(string.sub(i, 4, #i - 1)) then
			authorized = true
			break
		end
	end
	if not authorized then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command",
				color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
			}
		})
	else
		local settings = loadFileWithFields("configs/mute"..message.guild.id)
		if (args[1] == "settings") then
			if not args[2] then
				if not settings then
					message:reply({
						embed = {
							title = "Mute settings",
							description = "Not initialized",
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
							title = "Mute settings",
							description = "Role: "..tostring(settings.role).."\
Log channel: "..tostring(settings.channel).."\
Message copied: Last "..tostring(settings.messages).." message(s) from the muter and the muted\
Authorized: "..tostring(settings.authorized),
							timestamp = discord.Date():toISO('T', 'Z'),
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				end
			elseif args[2] == "debug" then
				if not settings then
					message:reply({
						embed = {
							title = "Mute settings",
							description = "settings = nil",
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
							title = "Mute settings",
							description = "settings = "..transformTab(settings),
							timestamp = discord.Date():toISO('T', 'Z'),
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				end
			else
				local desc
				for i = 2, #args, 2 do
					settings[args[i]] = args[i + 1]
				end
				message:reply({
					embed = {
						title = "Mute settings updated",
						description = "Role: "..tostring(settings.role).."\
Log channel: "..tostring(settings.channel).."\
Message copied: Last "..tostring(settings.messages).." message(s) from the muter and the muted\
Authorized: "..tostring(settings.authorized),
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0x00FF00,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
				saveFileWithFields("configs/mute"..message.guild.id, settings)
			end
		else
			if not args[1] then
				message:reply({
					embed = {
						title = "Error",
						description = "Missing arguments: at least 1 expected but "..#args.." found\nUsage: ..mute <user> [\"<reason>\" [<time> [s/m/h/d]]]",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				local recievers = getReciever(args[1])
				
				if #recievers == 0 then
					message:reply({
						embed = {
							title = "Error",
							description = "Couldn't find anyone called "..args[1],
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif #recievers > 1 then
					local str = ""
					for i, k in pairs(recievers) do
						str = str.."\t\t-\t\t<@"..k..">\n"
					end
					message:reply({
						embed = {
							title = "Error",
							description = "Found multiple user called "..args[1]..":\n"..str,
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif not settings.role then
					message:reply({
						embed = {
							title = "Error",
							description = "Default mute role is not defined",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif not message.guild:getMember(client.user.id):hasPermission("manageRoles") then
					message:reply({
						embed = {
							title = "Error",
							description = "I am missing the \"manageRoles\" permission",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif not message.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)) then
					message:reply({
						embed = {
							title = "Error",
							description = "Couldn't find "..settings.role,
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif message.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)).position > message.guild:getMember(client.user.id).highestRole.position then
					message:reply({
						embed = {
							title = "Error",
							description = settings.role.." is higher than my highest role, preventing me from giving it to anyone",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				elseif not message.guild:getMember(recievers[1]):addRole(string.sub(settings.role, 4, #settings.role - 1)) then
					message:reply({
						embed = {
							title = "Error",
							description = "Couldn't add "..settings.role.." to <@"..recievers[1]..">",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
				else
					local desc, time, reason = getReasonTime(args)
					
					if time then
						coroutine.wrap(unmuteAfter)(message.guild:getMember(recievers[1]), time, settings.role:sub(4, #settings.role - 1), message)
					end
					message:reply({
						embed = {
							title = "**Muted** 🤐",
							description = "Successfully muted <@"..recievers[1]..">"..desc,
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFFFFFF,
							footer = {
								icon_url = message.author.avatarURL,
								text = message.author.name
							}
						}
					})
					sendProof(message, settings, recievers[1], "<@"..message.author.id.."> muted <@"..recievers[1].."> "..desc, reason, "**Muted** 🤐")
				end
			end
		end
	end
end

function getReasonTime(args)
    local desc, time, reason = "", nil, ""
    local timeString, number
    
    table.remove(args, 1)
    if #args == 0 then
        return "", nil, "no reason provided"
    end
    if args[#args]:sub(1, 1):byte() and args[#args]:sub(1, 1):byte() >= 48 and args[#args]:sub(1, 1):byte() <= 57 then
        local i = 1
        
        while args[#args]:sub(i, i):byte() and args[#args]:sub(i, i):byte() >= 48 and args[#args]:sub(i, i):byte() <= 57 do
            i = i + 1
        end
        number = tonumber(args[#args]:sub(1, i - 1))
        timeString = i <= #args[#args] and args[#args]:sub(i, #args[#args])
        table.remove(args, #args)
    elseif tonumber(args[#args - 1]) then
        number = tonumber(args[#args - 1])
        timeString = args[#args]
        table.remove(args, #args)
        table.remove(args, #args)
    end
    if number then
        desc = " for "..(tonumber(number or "a") or "∞").." "
        if not timeString or timeString:sub(1, 1):lower() == "m" then
            desc = desc.."minutes"
            time = 60
        elseif timeString:sub(1, 1):lower() == "s" then
            desc = desc.."seconds"
            time = 1
        elseif timeString:sub(1, 1):lower() == "h" then
            desc = desc.."hours"
            time = 3600
        elseif timeString:sub(1, 1):lower() == "d" then
            desc = desc.."days"
            time = 86400
        else
            desc = desc.."minutes"
            time = 60
        end
        time = time * number
    end
	reason = table.concat(args, " ")
	if reason == "" then
		reason = "no reason provided"
	end
    return desc, time, reason
end

function unbanAfter(guild, time, user)
	timer.sleep(time * 1000)
	guild:unbanUser(user)
end

function unmuteAfter(member, time, role, message)
	if not mutedPeople[message.guild.id] then
		mutedPeople[message.guild.id] = {}
	end
	mutedPeople[message.guild.id][message.member.id] = true
	timer.sleep(time * 1000)
	member:removeRole(role)
	message:reply("<@"..member.id.."> you can now talk")
	mutedPeople[member.guild.id][member.id] = nil
end

function getRoleByName(name, guild)
	if not guild or not name then return end
	local role = guild:getRole(name)
	
	if not role then
		role = guild:getRole(name:sub(4, #name - 1))
	end
	if not role then
		for i in guild.roles:iter() do
			if name == i.name then
				role = i
				break
			end
		end
	end
	return role
end

function colorCommand(args, authorized, message)
	if not message.member then
		message:reply({
			embed = {
				title = "Error",
				description = "This command can only be used on a server.",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
		
	elseif args[1] == "add" and authorized and #args >= 3 then
		local role = getRoleByName(args[2], message.guild)
		
		if not role then
			message:reply({
				embed = {
					title = "Error",
					description = "Cannot find \""..args[2].."\"",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not tonumber(args[3]) then
			message:reply({
				embed = {
					title = "Error",
					description = args[3].." is not a valid level number.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local roles = loadFile("configs/colorRoles"..message.guild.id)
			
			roles[#roles + 1] = tonumber(args[3])
			roles[#roles + 1] = role.id
			saveFile("configs/colorRoles"..message.guild.id, roles)
			message:reply({
				embed = {
					title = "Success",
					description = "Added <@&"..role.id.."> to the selfassignable color roles for ppl more than level "..tonumber(args[3]),
					color = role:getColor().value,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		end
		
	elseif args[1] == "create" and authorized and #args >= 3 then
		if not (args[3]:sub(1, 1) == "#" and tonumber(args[3]:sub(2, #args[3]), 16) or tonumber(args[3], 16)) then
			message:reply({
				embed = {
					title = "Error",
					description = args[3].." is not a valid color.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not message.guild:getMember(client.user.id):hasPermission("manageRoles") then
			message:reply({
				embed = {
					title = "Error",
					description = "I am missing the \"manageRoles\" to do that.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local success, err = message.guild:createRole(args[2])
			
			if not success then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't create the role: "..tostring(err),
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not success:setColor(args[3]:sub(1, 1) == "#" and tonumber(args[3]:sub(2, #args[3]), 16) or tonumber(args[3], 16)) then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't set <@&"..success.id.."> color to "..args[3],
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
						title = "All done !",
						description = "You can now freely move the role when you want it to be",
						color = args[3]:sub(1, 1) == "#" and tonumber(args[3]:sub(2, #args[3]), 16) or tonumber(args[3], 16),
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			end
		end
		
	elseif args[1] == "delete" and authorized and #args >= 2 then
		local roles = loadFile("configs/colorRoles"..message.guild.id)
		local role
		
		for i = 1, #roles, 2 do
			if not message.guild:getRole(roles[i + 1]) then
				roles[i] = nil
				roles[i + 1] = nil
			elseif message.guild:getRole(roles[i + 1]).name == args[2] then
				role = i
				break
			end
		end
		if not role then
			saveFile("configs/colorRoles"..message.guild.id, roles)
			message:reply({
				embed = {
					title = "Error",
					description = "Cannot find \""..args[2].."\"",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local old = roles[role + 1]
			
			roles[role] = nil
			roles[role + 1] = nil
			saveFile("configs/colorRoles"..message.guild.id, roles)
			message:reply({
				embed = {
					title = "Deleted",
					description = "Deleted role <@&"..old.."> from the list",
					color = 0xAAAAAA,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		end
		
	elseif args[1] == "edit" and authorized and #args >= 4 then

	elseif not args[1] or args[1] == "roles" or args[1] == "role" then
		dispColorRoles(message, 1)
		
	else
		local display = {}
		local roleName = table.concat(args, " ")
		local roles = loadFile("configs/colorRoles"..message.guild.id)
		
		for i = 1, #roles, 2 do
			if not display[tonumber(roles[i])] then
				display[tonumber(roles[i])] = {}
			end
			if message.guild:getRole(roles[i + 1]) then
				display[tonumber(roles[i])][#display[tonumber(roles[i])] + 1] = roles[i + 1]
			end
		end
		for i, k in pairs(display) do
			for j, l in pairs(k) do
				if message.guild:getRole(l) and message.guild:getRole(l).name == roleName then
					if i <= calcLevel(getXp(message.author.id, message.guild.id)) then
						if not message.member:hasRole(l) then
							if not message.member:addRole(l) then
								message:reply({
									embed = {
										title = "Error",
										description = "Cannot give you <@&"..l..">",
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
										title = "Success !",
										description = "Enjoy your new color !",
										color = message.guild:getRole(l):getColor().value,
										timestamp = discord.Date():toISO('T', 'Z'),
										footer = {
											icon_url = message.author.avatarURL,
											text = message.author.name
										}
									}
								})
							end
						else
							if not message.member:removeRole(l) then
								message:reply({
									embed = {
										title = "Error",
										description = "Cannot take you <@&"..l..">",
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
										title = "Success !",
										description = "You no longer have this color !",
										color = message.guild:getRole(l):getColor().value,
										timestamp = discord.Date():toISO('T', 'Z'),
										footer = {
											icon_url = message.author.avatarURL,
											text = message.author.name
										}
									}
								})
							end
						end
						return
					else
						message:reply({
							embed = {
								title = "Error",
								description = "You need to be at least level "..i.." but you are level "..calcLevel(getXp(message.author.id, message.guild.id)),
								color = 0xFF0000,
								timestamp = discord.Date():toISO('T', 'Z'),
								footer = {
									icon_url = message.author.avatarURL,
									text = message.author.name
								}
							}
						})
						return
					end
				end
			end
		end
		message:reply({
			embed = {
				title = "Error",
				description = "No role is named \""..roleName.."\"",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	end
end

function dispColorRoles(message, page, edit)
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

function selfAssignRole(role, message)
    local sar = loadFile("configs/selfAssignableRoles"..message.guild.id)

	if not role then
		message:reply({
			embed = {
				title = "Error",
				description = "Expected 1 argument but got 0",
				timestamp = discord.Date():toISO('T', 'Z'),
				color = 0xFF0000,
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
		return
	end
	for i, k in pairs(sar) do
		if role == k or role:sub(4, #role - 1) == k or message.guild:getRole(k) and message.guild:getRole(k).name == role then
			if not message.guild:getMember(client.user.id):hasPermission("manageRoles") then
				message:reply({
					embed = {
						title = "Error",
						description = "I am missing the \"manageRoles\" permission",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getRole(sar[i]).position > message.guild:getMember(client.user.id).highestRole.position then
				message:reply({
					embed = {
						title = "Error",
						description = "<@&"..sar[i].."> is higher than my highest role, preventing me from giving it to anyone",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.member:hasRole(sar[i]) then
				message:reply({
					embed = {
						title = "Error",
						description = "You already have <@&"..sar[i]..">",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not message.member:addRole(sar[i]) then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't give you <@&"..sar[i]..">",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				message:reply({
					embed = {
						title = "Success",
						description = "You now have <@&"..sar[i]..">",
						color = 0x00FF00,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			end
			return
		end
	end
	message:reply({
		embed = {
			title = "Error",
			description = "This role is not selfassignable or doesn't exists",
			timestamp = discord.Date():toISO('T', 'Z'),
			color = 0xFF0000,
			footer = {
				icon_url = message.author.avatarURL,
				text = message.author.name
			}
		}
	})
end

function selfUnassignRole(role, message)
    local sar = loadFile("configs/selfAssignableRoles"..message.guild.id)

	if not role then
		message:reply({
			embed = {
				title = "Error",
				description = "Expected 1 argument but got 0",
				timestamp = discord.Date():toISO('T', 'Z'),
				color = 0xFF0000,
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
		return
	end
	for i, k in pairs(sar) do
		if role == k or role:sub(4, #role - 1) == k or message.guild:getRole(k) and message.guild:getRole(k).name == role then
			if not message.guild:getMember(client.user.id):hasPermission("manageRoles") then
				message:reply({
					embed = {
						title = "Error",
						description = "I am missing the \"manageRoles\" permission",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif message.guild:getRole(sar[i]).position > message.guild:getMember(client.user.id).highestRole.position then
				message:reply({
					embed = {
						title = "Error",
						description = "<@&"..sar[i].."> is higher than my highest role, preventing me from giving it to anyone",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not message.member:hasRole(sar[i]) then
				message:reply({
					embed = {
						title = "Error",
						description = "You already don't have <@&"..sar[i]..">",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			elseif not message.member:removeRole(sar[i]) then
				message:reply({
					embed = {
						title = "Error",
						description = "Couldn't give <@&"..sar[i].."> to you",
						timestamp = discord.Date():toISO('T', 'Z'),
						color = 0xFF0000,
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			else
				message:reply({
					embed = {
						title = "Success",
						description = "You no longer have <@&"..sar[i]..">",
						color = 0x00FF00,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = message.author.avatarURL,
							text = message.author.name
						}
					}
				})
			end
			break
		end
	end
end

function artContest(args, authorized, message)
	if (not authorized and args[1] ~= "show") or not message.guild then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command.",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
		return
	end
	local contest = loadFileWithFields("contests/contest"..message.guild.id.."/contest")
	local tripledot = false
	local channel
	
	if args[1] == "addmessage" then
		if not args[3] then
			channel = message.channel
		else
			channel = client:getChannel(args[3]:sub(3, #args[3] - 1))
		end
		if not channel then
			message:reply({
				embed = {
					title = "Error",
					description = "This channel doesn't exist.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = client.user.avatarURL,
						text = client.user.name
					}
				}
			})
			return
		end
		if not channel:getMessage(args[2]) then
			message:reply({
				embed = {
					title = "Error",
					description = "Cannot find this message in <#"..channel.id..">.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = client.user.avatarURL,
						text = client.user.name
					}
				}
			})
			return
		end
		local msg = addMessageArtContest(channel:getMessage(args[2]))
		for i in channel:getMessage(args[2]).reactions:iter() do
			if contest.emoji_upvote == i.emojiName or (i.emojiId and contest.emoji_upvote == "<:"..i.emojiName..":"..i.emojiId..">") then
				for k in i:getUsers():iter() do
					addVoteArtContest(i, contest, k.id, msg)
					channel:getMessage(args[2]):removeReaction(
						contest.emoji_upvote:sub(1, 1) == '<' and contest.emoji_upvote:sub(2, #contest.emoji_upvote - 1) or contest.emoji_upvote,
						k.id
					)
				end
				contest = loadFileWithFields("contests/contest"..message.guild.id.."/contest")
				break
			end
		end
		channel:getMessage(args[2]):delete()
	elseif args[1] == "allvotes" then
		local str = ""
		local messages = {}
		local votes = scanDir("contests/contest"..message.guild.id.."/votes")
		local reciever = args[2] and (getReciever(args[2], message.guild) or {""}) or {""}
		
		if not reciever[1] then
			reciever[1] = true
		end
		for i, k in pairs(votes) do
			vote = loadFile("contests/contest"..message.guild.id.."/votes/"..k)
			for l, j in pairs(vote) do
				if not messages[j.."b"] then
					messages[j.."b"] = loadFileWithFields("contests/contest"..message.guild.id.."/participants/participant"..j).author
				end
				if (not args[2] or messages[j.."b"] == reciever[1] or j == args[2]) and
				#(str.."<@"..k:sub(6, #k).."> voted for "..(messages[j.."b"] and ("<@"..messages[j.."b"]..">") or j).."\n") <= 1950 then
					str = str.."<@"..k:sub(6, #k).."> voted for "..(messages[j.."b"] and ("<@"..messages[j.."b"]..">") or j).."\n"
				elseif not tripledot and ((args[2] and message[j.."b"] == reciever[1]) or j == args[2]) then
					tripledot = true
					str = str.."..."
				end
			end
		end
		if args[2] then
			message:reply({
				embed = {
					timestamp = discord.Date():toISO('T', 'Z'),
					color = 0xFFAAFF,
					description = str ~= "" and str or "No one voted for "..args[2]
				}
			})
		else
			message:reply({
				embed = {
					timestamp = discord.Date():toISO('T', 'Z'),
					color = 0xFFAAFF,
					description = str ~= "" and str or "None voted yet"
				}
			})
		end
	elseif args[1] == "start" then
		if #args < 4 or #args > 7 then
			message:reply({
				embed = {
					title = "Error",
					description = "Expected 3, 4, 5 or 6 arguments but got "..(#args - 1)..".",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not message.guild:getChannel(args[2]:sub(3, #args[2] - 1)) then
			message:reply({
				embed = {
					title = "Error",
					description = "No such channel "..args[2]..".",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not message.guild:getChannel(args[3]:sub(3, #args[3] - 1)) then
			message:reply({
				embed = {
					title = "Error",
					description = "No such channel "..args[3]..".",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif args[5] and not tonumber(args[5]) then
			message:reply({
				embed = {
					title = "Error",
					description = args[5].." is not a valid number",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif args[6] and not tonumber(args[6]) then
			message:reply({
				embed = {
					title = "Error",
					description = args[6].." is not a valid number",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif args[7] and args[7] ~= "true" and args[7] ~= "false" then
			message:reply({
				embed = {
					title = "Error",
					description = "Invalid argument #7: Expected \"true\" or \"false\"",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif contest.channel then
			message:reply({
				embed = {
					title = "Error",
					description = "A contest already exists on that server\
Use '..artcontest stop' to stop it",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			contest = {
				channel = args[2]:sub(3, #args[2] - 1),
				trashcan = args[3]:sub(3, #args[3] - 1),
				emoji_upvote = args[4],
				vote_limit = tonumber(args[5]) and tonumber(args[5]) > 0 and tonumber(args[5]) or nil,
				submit_limit = tonumber(args[6]) and tonumber(args[6]) > 0 and tonumber(args[6]) or nil,
				hide_owner = args[7] == "true"
			}
			os.execute("mkdir contests/contest"..message.guild.id)
			os.execute("mkdir contests/contest"..message.guild.id.."/participants")
			os.execute("mkdir contests/contest"..message.guild.id.."/votes")
			saveFileWithFields("contests/contest"..message.guild.id.."/contest", contest)
			message:reply({
				embed = {
					title = "Success !",
					description = "Created a contest in "..args[2]..":\
Trashcan: "..args[3].."\
Upvote emoji: "..args[4].."\
Max vote per person: "..(args[5] and tonumber(args[5]) > 0 and args[5] or "No limit").."\
Max submition: "..(args[6] and tonumber(args[6]) > 0 and args[6] or "No limit").."\
Owner hidden: "..tostring(args[7] == "true"),
					color = 0x00FF00,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
			message.guild:getChannel(args[2]:sub(3, #args[2] - 1)):send("New contest started in this channel !")
			message.guild:getChannel(args[3]:sub(3, #args[3] - 1)):send("Images from the art contest will be sent here.")
		end
	elseif args[1] == "close" then
		if #args ~= 1 then
			message:reply({
				embed = {
					title = "Error",
					description = "No arguments expected but got "..(#args - 1)..".",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not contest.channel then
			message:reply({
				embed = {
					title = "Error",
					description = "No contest is running in this server.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local msg = message:reply({
				embed = {
					title = "Close contest",
					description = "Do you really want to close the contest ?\
People will still be able to vote but won't be able to add new elements.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		
			if msg then
				msg:addReaction(emojis.yes:sub(2, #emojis.yes - 1))
				msg:addReaction(emojis.no:sub(2, #emojis.no - 1))
			end
		end
	elseif args[1] == "stop" then
		if #args ~= 1 then
			message:reply({
				embed = {
					title = "Error",
					description = "No arguments expected but got "..(#args - 1)..".",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		elseif not contest.channel then
			message:reply({
				embed = {
					title = "Error",
					description = "No contest is running in this server.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local msg = message:reply({
				embed = {
					title = "Stop contest",
					description = "Do you really want to stop the contest ?\
Votes and submition will be closed and the winner will be selected.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		
			if msg then
				msg:addReaction(emojis.yes:sub(2, #emojis.yes - 1))
				msg:addReaction(emojis.no:sub(2, #emojis.no - 1))
			end
		end
	elseif not args[1] or args[1] == "show" then
		if not contest.channel then
			message:reply({
				embed = {
					title = "Error",
					description = "No contest is running in this server.",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		else
			local participants = scanDir("contests/contest"..message.guild.id.."/participants")
			local desc = ""

			for i, k in pairs(participants) do
				participants[i] = loadFileWithFields("contests/contest"..message.guild.id.."/participants/"..k)
			end
			for i, k in pairs(participants) do
				for j = i + 1, #participants do
					if tonumber(participants[i].votes) < tonumber(participants[j].votes) then
						k = participants[i]
						participants[i] = participants[j]
						participants[j] = k
					end
				end
			end
			for i, k in pairs(participants) do
				desc = desc..i.." - <@"..k.author.."> "..k.votes.." upvotes\n"
			end
			message:reply({
				embed = {
					title = "Art contest",
					description = desc,
					color = 0xFFFFFF,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = message.author.avatarURL,
						text = message.author.name
					}
				}
			})
		end
	else
		message:reply({
			embed = {
				title = "Error",
				description = "Invalid argument #1.",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	end
end

function setXpMultiplier(args, authorized, message)
	if not args[1] then
		local mult = loadFile("configs/xpMultiplier"..message.guild.id)[1] or 1
		message:reply({
			embed = {
				title = "XP Multiplier",
				description = "Current mutiplayer: **"..(mult or "1").."**\nXp earned: "..(15 * (mult or 1)).."-"..(25 * (mult or 1)),
				color = 0xFFFFFF,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif not authorized then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif not transformToNbr(args[1]) then
		message:reply({
			embed = {
				title = "Error",
				description = "Invalid number "..args[1],
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	else
		local mult = transformToNbr(args[1])
		
		saveFile("configs/xpMultiplier"..message.guild.id, {transformToNbr(args[1])})
		message:reply({
			embed = {
				title = "XP Multiplier changed !",
				description = "Current mutiplayer: **"..(mult or "1").."**\nXp earned: "..(15 * (mult or 1)).."-"..(25 * (mult or 1)),
				color = 0x00FF00,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	end
end

function getMatchingUsers(source, role)
	local table = {}

	if not role and not source.members then
		return source
	elseif source.members then
		for member in source.members:iter() do
			if not role or member:hasRole(role.id) then
				table[#table + 1] = member
			end
		end
	else
		for i, member in pairs(source) do
			if member:hasRole(role.id) then
				table[#table + 1] = member
			end
		end
	end
	return table
end

function randomPick(args, message)
	if not args[1] then
		message:reply({
			embed = {
				title = "Error",
				description = "Missing argument #1",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
	elseif not tonumber(args[1]) then
		message:reply({
			embed = {
				title = "Error",
				description = "Invalid argument #1: Expected number",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
	else
		local matching = getMatchingUsers(message.guild, nil)
		local str = ""
		local random
		
		for i = 2, #args do
			matching = getMatchingUsers(matching, getRoleByName(args[i], message.guild))
		end
		for i = 1, tonumber(args[1]) do
			if #matching == 0 then
				str = str.."No more users are matching the requirements"
				break
			end
			random = math.random(1, #matching)
			str = str.."<@"..matching[random].id..">\n"
			for j = random, #matching do
				matching[j] = matching[j + 1]
			end
		end
		message:reply(str)
	end
end

function reactionRole(args, authorized, message)
	if #args % 2 == 1 then
		message:reply({
			embed = {
				title = "Error",
				description = "Expected an even number of argument",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
	elseif not authorized or not message.guild then
		message:reply({
			embed = {
				title = "Error",
				description = "You are not authorized to perform this command",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
	else
		local fields = {}
		local desc = ""
		local msg
		local err

		for i = 1, #args, 2 do
			fields[i] = args[i]
			fields[i + 1] = getRoleByName(args[i + 1], message.guild)
			if not fields[i + 1] then
				message:reply({
					embed = {
						title = "Error",
						description = string.format("Cannot find role \"%s\"", args[i + 1]),
						color = 0xFF0000,
						timestamp = discord.Date():toISO('T', 'Z'),
						footer = {
							icon_url = client.user.avatarURL,
							text = client.user.name
						}
					}
				})
				return
			else
				desc = string.format("%s%s: <@&%s> (%s)\n", desc, fields[i], fields[i + 1].id, fields[i + 1].name)
				fields[i + 1] = fields[i + 1].id
			end
		end
		msg, err = message:reply({
			embed = {
				title = "Reaction to Role",
				description = desc,
				color = 0xFFAAAA,
				timestamp = discord.Date():toISO('T', 'Z'),
			}
		})
		if not msg then
			message:reply({
				embed = {
					title = "Error",
					description = "Cannot send resulting message. (Maybe is it too long ?)\n"..tostring(err),
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = client.user.avatarURL,
						text = client.user.name
					}
				}
			})
		end
		for i = 1, #fields, 2 do
			if not msg:addReaction(string.sub(fields[i], 1, 1) == "<" and string.sub(fields[i], 2, #fields[i] - 1) or fields[i]) then
				msg:clearReactions()
				msg:setEmbed({
					title = "Error",
					description = "Cannot put reaction \""..fields[i].."\"",
					color = 0xFF0000,
					timestamp = discord.Date():toISO('T', 'Z'),
					footer = {
						icon_url = client.user.avatarURL,
						text = client.user.name
					}
				})
			end
		end
	end
end

function serverInfos(args, message)
	if not message.guild then
		message:reply({
			embed = {
				title = "Error",
				description = "This command needs to be used in a server",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
		return
	end
	local animEmojisNbr = 0
	local clasEmojisNbr = 0
	local animEmojis = ""
	local clasEmojis = ""
	local guild = message.guild
	local textChannels = 0
	local voiceChannels = 0
	local rolesNbr = 0
	local categoriesNbr = 0
	local emojiString
	local fields
	
	for i in guild.categories:iter() do categoriesNbr = categoriesNbr + 1 end
	for i in guild.roles:iter() do rolesNbr = rolesNbr + 1 end
	for i in guild.textChannels:iter() do textChannels = textChannels + 1 end
	for i in guild.voiceChannels:iter() do voiceChannels = voiceChannels + 1 end
	for emoji in guild.emojis:iter() do
		if emoji.mentionString:sub(2, 2) == "a" then
			animEmojisNbr = animEmojisNbr + 1
			if animEmojisNbr <= 10 then
				animEmojis = string.format("%s%s: %s\n", animEmojis ,emoji.name, emoji.mentionString)
			end
		else
			clasEmojisNbr = clasEmojisNbr + 1
			if clasEmojisNbr <= 10 then
				clasEmojis = string.format("%s%s: %s\n", clasEmojis ,emoji.name, emoji.mentionString)
			end
		end
	end
	msg, err = message:reply({
		embed = {
			author = {
				name = guild.name,
				icon_url = guild.iconURL
			},
			title = "Server info",
			fields = {
				{
					name = "ID",
					value = guild.id,
					inline = true,
				},
				{
					name = "Owner",
					value = guild.owner and "<@"..guild.owner.id.."> ("..guild.owner.user.name.."#"..guild.owner.user.discriminator..")" or "??",
					inline = true,
				},
				{
					name = "Members",
					value = tostring(guild.totalMemberCount),
					inline = true,
				},
				{
					name = "Text channels",
					value = tostring(textChannels),
					inline = true,
				},
				{
					name = "Voice channels",
					value = tostring(voiceChannels),
					inline = true,
				},
				{
					name = "Categories",
					value = tostring(categoriesNbr),
					inline = true,
				},
				{
					name = "Region",
					value = guild.region,
					inline = true,
				},
				{
					name = "Roles",
					value = tostring(rolesNbr),
					inline = true,
				},
				{
					name = "Features",
					value = #guild.features > 0 and table.concat(guild.features, "\n") or "None",
					inline = true,
				},
				{
					name = string.format("Emojis (%i)", clasEmojisNbr),
					value = clasEmojis or "None",
					inline = true
				},
				{
					name = string.format("Animated Emojis (%i)", animEmojisNbr),
					value = animEmojis or "None",
					inline = true
				},
			},
			image = {
				url = guild.iconURL
			},
			color = 0x00FF00,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = {
				icon_url = message.author.avatarURL,
				text = message.author.name
			}
		}
	})
	if not msg then
		message:reply("Something went wrong when trying to send the message:\n"..err)
		print("Something went wrong when trying to send the message:\n"..err)
	end
end

function getValue(table)
	local valueEnd = 0
	
	if not table[1] then return end
	repeat
		valueEnd = valueEnd + 1
	until valueEnd > #table[1] or table[1]:sub(valueEnd, valueEnd):byte() > 57 or table[1]:sub(valueEnd, valueEnd):byte() < 48
	if table[1]:sub(valueEnd, valueEnd) == '.' then
		valueEnd = valueEnd + 1
	end
	while valueEnd <= #table[1] and table[1]:sub(valueEnd, valueEnd):byte() <= 57 and table[1]:sub(valueEnd, valueEnd):byte() >= 48 do
		valueEnd = valueEnd + 1
	end
	if (valueEnd > #table[1]) then
		return transformToNbr(table[1]), table[2], table[3]
	end
	return transformToNbr(table[1]:sub(1, valueEnd - 1)), table[1]:sub(valueEnd, #table[1]), table[2]
end

function createKnownUnits()
	local degree = {}
	local degreeConverter = {}
	local money = {}
	local moneyConverter = {}
	
	degreeConverter["°C"] = function (value) return (value - 32) / 1.8 end
	degree["°F"] = {
		alias = {
			"F",
			"°f",
			"f",
			"farhenheit",
			"°Farhenheit",
			"Farhenheit",
			"°farhenheit",
		},
		converter = degreeConverter
	}
	degreeConverter["°C"] = nil
	degreeConverter["°F"] = function (value) return value * 1.8 + 32 end
	degree["°C"] = {
		alias = {
			"C",
			"°c",
			"c",
			"celsuis",
			"°celsuis",
			"Celsuis",
			"°Celsuis",
		},
		converter = degreeConverter
	}
	
	moneyConverter = {}
	moneyConverter["£"] = function (value) return value / 1.1176 end
	moneyConverter["$"] = function (value) return value / 0.878 end
	money["€"] = {
		alias = {
			"Euro",
			"euro",
			"Euros",
			"euros",
		},
		converter = moneyConverter
	}
	moneyConverter = {}
	moneyConverter["€"] = function (value) return value * 1.1176 end
	moneyConverter["$"] = function (value) return value * 1.2721 end
	money["£"] = {
		alias = {
			"pound",
			"pounds",
			"sterling",
			"Pounds",
			"Pound",
			"Sterling",
		},
		converter = moneyConverter
	}
	moneyConverter = {}
	moneyConverter["£"] = function (value) return value / 1.2721 end
	moneyConverter["€"] = function (value) return value * 0.878 end
	money["$"] = {
		alias = {
			"Dollar",
			"dollar",
			"USDollar",
			"usdollar",
			"Dollars",
			"dollars",
			"USDollars",
			"usdollars",
			"USD",
			"usd",
		},
		converter = moneyConverter
	}
	
	return {
		degree = degree,
		money = money
	}
end

function getUnitStruct(knownUnits, name)
	if not name then return end
	for category, content in pairs(knownUnits) do
		for unitName, struct in pairs(content) do
			if unitName == name then
				return category, unitName, struct
			end
			for i, alias in pairs(struct.alias or {}) do
				if alias == name then
					return category, unitName, struct
				end
			end
		end
	end
end

function convertThings(args, message)
	local value, unit, toConvert = getValue(args)
	local unitType
	local unitCategory, unitName, unitStruct = getUnitStruct(createKnownUnits(), unit)
	local toConvertCategory, toConvertName, toConvertStruct = getUnitStruct(createKnownUnits(), toConvert)
	
	if not value then
		message:reply({
			embed = {
				title = "Error",
				description = "Please give a value to convert",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif not unit then
		message:reply({
			embed = {
				title = "Error",
				description = "Please give the unit of the value given",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif not toConvertCategory and toConvert then
		message:reply({
			embed = {
				title = "Error",
				description = string.format("Cannot find any unit called '%s'", toConvert),
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif not unitCategory then
		message:reply({
			embed = {
				title = "Error",
				description = string.format("Cannot find any unit called '%s'", unit),
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	elseif toConvertCategory and unitCategory ~= toConvertCategory then
		message:reply({
			embed = {
				title = "Error",
				description = string.format("Cannot convert 2 units from different cathegories\n%s is %s and %s is %s", unit, unitCategory, toConvert, toConvertCategory),
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				}
			}
		})
	else
		local desc = ""
		
		for convertedUnitName, converter in pairs(unitStruct.converter or {}) do
			if convertedUnitName == toConvertName then
				desc = string.format("%s\n**%.2f__%s__= %.2f__%s__**", desc, value, unitName, converter(value), convertedUnitName)
			else
				desc = string.format("%s\n%.2f__%s__ = %.2f__%s__", desc, value, unitName, converter(value), convertedUnitName)
			end
		end
		message:reply({
			embed = {
				title = string.format("%.2f%s", value, unitName),
				description = desc,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = client.user.avatarURL,
					text = client.user.name
				}
			}
		})
	end
end

function updateBot(msg)
	local message = msg:reply({
		embed = {
			title = "Updating",
			description = "Updating bot",
			timestamp = discord.Date():toISO('T', 'Z'),
			color = 0xFFFF00,
			footer = {
				icon_url = client.user.avatarURL,
				text = client.user.name
			}
		}
	})
	local file = io.popen("git pull 2>&1")
	local output = table.concat(arrayFromIt(file:lines()), "\n")
	local success, _, err_code = file:close()

	if not success then
		message:setEmbed({
			title = "Update failed",
			description = "Cannot update bot: \nCommand exit with error code "..tostring(err_code).."\n```"..output.."```",
			timestamp = discord.Date():toISO('T', 'Z'),
			color = 0xFF0000,
			footer = {
				icon_url = client.user.avatarURL,
				text = client.user.name
			}
		})
	else
		message:setEmbed({
			title = "Update done",
			description = "Restarting...",
			timestamp = discord.Date():toISO('T', 'Z'),
			color = 0x00FF00,
			footer = {
				icon_url = client.user.avatarURL,
				text = client.user.name
			}
		})
        disconnect = true
        client:stop()
	end
end


function commandMgr(message)
	if not message or message.author == client.user then return end
    local authorized = message.author.id == my_id or isWhitelisted(message.member)
    local command, args = "", {}
    local failed = false
    
    if (message.content:sub(1, 2) == ".." and #message.content > 3 and message.content:sub(3, 3) ~= ".") then
        if not authorized and big_issue then
            message:reply({
                embed = {
                    title = "Error",
                    description = "Commands are disabled due to a big issue. Please try again later.",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = client.user.avatarURL,
                        text = client.user.name
                    }
                }
            })
            return
        end
        command, args = parseCommand(message.content, 3, false)
        if (command == "reboot") then
            reboot(args, authorized, message)
        --elseif (command == "leave") then
        --    memberLeaving(message.member)
		elseif (command == "randompick") then
			randomPick(args, message)
        elseif (command == "disconnect") then
            shutdown(args, authorized, message)
        elseif (command == "help") then
            dispHelp(args, authorized, message, isAdmin(message.member))
        elseif (command == "claim") then
            claimMoney(args, authorized, message)
        elseif (command == "hug") then
            doHug(args, message)
        elseif (command == "serverinfos" or command == "serverinfo") then
            serverInfos(args, message)
        elseif (command == "pat") then
            doPat(args, message)
        elseif (command == "no") then
            dispNo(message)
        elseif (command == "event") then
            createEvent(args, authorized, message)
        elseif (command == "custom_role") then
            customRoles(message, authorized, args)
        elseif (command == "claimers") then
            showClaimers(args, authorized, message)
        elseif (command == "reactionrole") then
			reactionRole(args, authorized or isAdmin(message.member), message)
        elseif (command == "give") then
            giveMoney(args, authorized, message)
        elseif (command == "givecheat" and authorized) then
            giveMoney(args, authorized, message, true)
        elseif (command == "buy") then
            buyItem(args, authorized, message)
        elseif (command == "coinflip" or command == "cf") then
            coinFlip(args, authorized, message)
		elseif (command == "convert") then
			convertThings(args, message)
        elseif (command == "leaderboard") then
            dispLeaderBoard(args, authorized, message)
        elseif (command == "daily") then
            claimDaily(args, authorized, message)
        elseif (command == "change_name") then
            changeName(args, message)
        elseif (command == "artcontest") then
			artContest(args, authorized or isAdmin(message.member), message)
        elseif (command == "icon") then
            changeIcon(args, message)
        elseif (command == "mute") then
			muteCommand(args, authorized or isAdmin(message.member), message)
        elseif (command == "ban") then
			banCommand(args, authorized or isAdmin(message.member), message)
        elseif (command == "kick") then
			kickCommand(args, authorized or isAdmin(message.member), message)
        elseif (command == "stats") then
            dispPlayerStats(args, message)
        elseif (command == "set_value" and authorized and (#args == 3 or #args == 2)) then
            setValue(message, args)
        elseif (command == "items") then
            items(message, args, authorized)
        elseif (command == "day") then
            day(message, args, authorized)
        elseif (command == "rank" or command == "exp" or command == "xp") then
            dispXp(message, args)
        elseif (command == "sell") then
            sellItem(args, message)
        elseif (command == "listselfassignablerole" or command == "lsar") then
            lsar(message, args, authorized)
        elseif (command == "iam" or command == "selfassign") then
            selfAssignRole(table.concat(args, " "), message)
        elseif (command == "iamnot" or command == "selfunassign") then
            selfUnassignRole(args[1], message)
        elseif (command == "setxproles") then
            setXpRoles(args, authorized or isAdmin(message.member), message)
        elseif (command == "color" or command == "colour") then
			colorCommand(args, authorized or isAdmin(message.member), message)
        elseif (command == "levels") then
            dispXpLeaderBoard(message, 1)
        elseif (command == "lua" and message.author.id == my_id) then
            execLua(string.sub(message.content, 7, #message.content), message)
        elseif (command == "leavemsg" and (authorized or isAdmin(message.member))) then
            leaveMsg(message, args, authorized)
        elseif (command == "welcome" and (authorized or isAdmin(message.member))) then
            welcomeMsg(message, args, authorized)
        elseif (command == "shop") then
            dispShop(message, args, authorized)
        elseif (command == "autorole" and (authorized or isAdmin(message.member))) then
            autorole(message, args)
        elseif (command == "wr" or command == "winrate" or command == "cfwr" or command == "coinflipwinrate" or command == "coinflipstats" or command == "cfstats") then
			dispWinrate(args, message)
        elseif (command == "set") then
            setMoney(args, authorized, message)
        elseif (command == "big_issue" and message.author.id == my_id) then
            big_issue = not big_issue
        elseif (command == "whitelist" and message.author.id == my_id) then
            whiteListMgr(args, authorized, message)
		elseif (command == "xpmultiplier") then
			setXpMultiplier(args, authorized or isAdmin(message.member), message)
		elseif (command == "update" and authorized) then
			updateBot(message)
        else
            local suggest = getSuggest(command)
            message:reply({
                embed = {
                    title = "Error",
                    description = "Unknown command \""..command.."\""..suggest.."\nUse \"..help\" for a list of commands",
                    color = 0xFF0000,
                    timestamp = discord.Date():toISO('T', 'Z'),
                    footer = {
                        icon_url = message.author.avatarURL,
                        text = message.author.name
                    }
                }
            })
            unsuccessfull[#unsuccessfull + 1] = command
            failed = true
        end
        if not failed then
            saveSuggest(command, unsuccessfull)
            unsuccessfull = nil
            unsuccessfull = {}
        end
        saveClaimed()
    elseif message.guild and not message.author.bot and (xpCooldown[message.author.id..message.guild.id] or 0) + 60 < os.time() then
		local multiplier = tonumber(loadFile("configs/xpMultiplier"..message.guild.id)[1] or "1") or 1
        local xp = getXp(message.author.id, message.guild.id) + math.random(15, 25) * multiplier
        local level = calcLevel(xp)
        local guildRoles = getXpRoles(message.guild.id)
		local leaderboard = sort(getLeaderboard(message.guild, getXp))
		local roleFirst = guildRoles.first and getRoleByName(guildRoles.first, message.guild)

		if leaderboard[1] and roleFirst then
			if xp > getXp(leaderboard[1].data[1], message.guild.id) then
				for j, l in pairs(leaderboard[1].data) do
					if l ~= message.author.id then
						message.guild:getMember(l):removeRole(roleFirst.id)
					end
				end
			end
			if (
				xp >= getXp(leaderboard[1].data[1], message.guild.id) or (
					leaderboard[1].data[1] == message.author.id and
					not message.member:hasRole(roleFirst.id)
				)
			) then
				message.member:addRole(roleFirst.id)
			end
		end
		saveXp(message.author.id, message.guild.id, xp)
		xpCooldown[message.author.id..message.guild.id] = os.time()
		for i, k in pairs(guildRoles) do
			if tonumber(i) and level >= i and getRoleByName(k, message.guild) and not message.member:hasRole(getRoleByName(k, message.guild).id) then
				message.member:addRole(getRoleByName(k, message.guild).id)
			end
		end
    end
end

function setXpRoles(args, authorized, message)
    local guildRoles = getXpRoles(message.guild.id)
    
    if not authorized then
        message:reply({
            embed = {
                title = "Error",
                description = "You are not allowed to perform this command",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif not args[1] then
        local content = ""
        local biggest = 0
		local role
        
        for i, k in pairs(guildRoles) do
            if tonumber(i) and i > biggest then
                biggest = i
            end
        end
        for i = 1, biggest do
            if not guildRoles[i] then
                guildRoles[i] = "none"
            end
        end
        for i, k in pairs(guildRoles) do
            if k ~= "none" then
                content = content.."Level "..i.." : "
				role = getRoleByName(k, message.guild)
				if role then
					content = string.format("%s<@&%s>\n", content, role.id)
				else 
					content = string.format("%sInvalid role: '%s'", content, k)
				end
            end
        end
        message:reply({
            embed = {
                title = "List",
                description = content,
                color = 0xFF00FF,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif not tonumber(args[1]) and args[1] ~= "first" then
        message:reply({
            embed = {
                title = "Error",
                description = "Invalid argument #1 : Expected number or nothing or \"first\"",
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
	elseif not args[2] then
        local content = args[1] == "first" and "The top 1 won't be assigned to any role" or "No role will be assigned upon reaching level "..args[1]
		
        guildRoles[tonumber(args[1]) or args[1]] = nil
        saveXpRoles(message.guild.id, guildRoles)
        message:reply({
            embed = {
                title = "Success !",
                description = content,
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    elseif not getRoleByName(args[2], message.guild) then
        message:reply({
            embed = {
                title = "Error",
                description = string.format("Invalid argument #2 : Cannot find role '%s'", args[2]),
                color = 0xFF0000,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
	else
        local content = 
		args[1] == "first" and string.format("The top 1 will be assigned to <@&%s>", getRoleByName(args[2], message.guild).id) or
		string.format("People more than level %i will be assigned to role <@&%s>", args[1], getRoleByName(args[2], message.guild).id)
		
        guildRoles[tonumber(args[1]) or args[1]] = getRoleByName(args[2], message.guild).id
        saveXpRoles(message.guild.id, guildRoles)
        message:reply({
            embed = {
                title = "Success !",
                description = content,
                color = 0x00FF00,
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = message.author.avatarURL,
                    text = message.author.name
                }
            }
        })
    end
end

function saveXpRoles(id, data)
    local file = io.open("configs/xproles"..id, "w+")
    
    if not file then return {} end
    io.output(file)
    for i, k in pairs(data) do
        io.write(i.."\n"..k.."\n")
    end
    io.close(file)
end

function grabMeeDatabase(message)
	grabingMee6data[message.guild.id] = true
    for member in message.guild.members:iter() do
        if not member.user.bot then
            message:reply("!rank <@"..member.user.id..">")
            local success, data = emitter:waitFor("ChangeXP")
            if data == "abort" then
                message:reply({
                    embed = {
                        title = "Aborted",
                        description = "Aborted by user",
                        color = 0xFF0000
                    }
                })
                break
            elseif data ~= 0 then
                saveXp(member.user.id, message.guild.id, data)
            end
			local level, xpRemaining, lvlXp = calcLevel(data)
			message:reply({
				embed = {
					title = "Done",
					description = string.format("New xp for <@%s> is now %d (level %d  %d/%d)", member.user.id, data, level, xpRemaining, lvlXp),
					color = 0xFF0000
				}
			})
        end
    end
	grabingMee6data[message.guild.id] = false
end

function getXpRoles(id)
    local data = {}
    local line = ""
    local file = io.open("configs/xproles"..id, "r")
    
    if not file then return {} end
    io.input(file)
    line = io.read()
    while line do
        data[tonumber(line) or line] = io.read()
        line = io.read()
    end
    io.close(file)
    return data
end

function transformTab(table, ind)
    local tabs = ""
    local result
    
    for i = 0, (ind or 0) do
        tabs = tabs.."\t"
    end
    result = "{\n"
    for i, k in pairs(table) do
        if type(i) == "string" then
            result = result..tabs.."\""..i.."\"".." = "
        else
            result = result..tabs..i.." = "
        end
        if type(k) == "table" then
            result = result..transformTab(k, (ind or 0) + 1)
        elseif type(k) == "string" then
            result = result.."\""..k.."\""
        else
            result = result..tostring(k)
        end
        result = result..",\n"
    end
    result = result..string.sub(tabs, 1, #tabs - 1).."}"
    return result
end

function getTheXp(level, xp)
    local nbr = 0
    local lvlXp = 55
    
    while nbr < level do
        lvlXp = lvlXp + 45 + 10 * nbr
        nbr = nbr + 1
        xp = xp + lvlXp
    end
    return xp
end

function addMessageArtContest(message)
	local url = message.attachment and message.attachment.url
	if not url then
		return
	end
	local extension = string.lower(url:sub(#url - 3, #url))
	local l, k = http.request("GET", url)
	local file = io.open("contests/contest"..message.guild.id.."/image"..message.guild.id.."user"..message.author.id..extension, "w+")
	local contest = loadFileWithFields("contests/contest"..message.guild.id.."/contest")
	local msg, msg2
	local part = {}
	local err
	
	contest.hide_owner = contest.hide_owner == "true"
	if not client:getChannel(contest.trashcan) then
		client:getChannel(contest.channel):send({
			title = "Error",
			description = "The trashcan channel "..contest.trashcan.." cannot be found",
			color = 0xFF0000,
			timestamp = discord.Date():toISO('T', 'Z'),
		})
		return
	end
	file:write(k)
	file:close()
	msg, err = client:getChannel(contest.trashcan):send({file = "contests/contest"..message.guild.id.."/image"..message.guild.id.."user"..message.author.id..extension})
	if not msg then
		client:getChannel(contest.channel):send({
			title = "Error",
			description = "Cannot send message in channel <#"..contest.channel..">:\n"..tostring(err),
			color = 0xFF0000,
			timestamp = discord.Date():toISO('T', 'Z'),
		})
		return
	end
	msg2 = client:getChannel(contest.channel):send({
		embed = {
			image = {
				url = msg.attachment.url
			},
			title = "Art contest",
			description = (contest.hide_owner and "Someone" or "<@"..message.author.id..">").." posted a new image !"..(message.content and message.content ~= "" and "\nComment: "..message.content or ""),
			color = 0xFFFF00,
			timestamp = discord.Date():toISO('T', 'Z'),
			footer = {
				icon_url = contest.hide_owner and "https://lescreasdetiti.fr/52303-large_default/motif-thermocollant-point-d-interrogation.jpg" or message.author.avatarURL,
				text = (contest.hide_owner and "Someone" or message.author.name).." | 0 votes"
			}
		}
	})
	if not msg2 then
		client.owner:send(transformTab({
			embed = {
				image = {
					url = msg.attachment.url
				},
				title = "Art contest",
				description = "<@"..message.author.id.."> posted a new image !"..(message.content and message.content ~= "" and "\nComment: "..message.content or ""),
				color = 0xFFFF00,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name.." | 0 votes"
				}
			}
		}):split(1, 2000))
		return
	else
		part.message = msg2.id
	end
	msg2:addReaction(contest.emoji_upvote:sub(1, 1) == '<' and contest.emoji_upvote:sub(2, #contest.emoji_upvote - 1) or contest.emoji_upvote)
	part.author = message.author.id
	part.image = msg.attachment.url
	part.votes = 0
	contest[message.author.id] = (contest[message.author.id] or 0) + 1
	saveFileWithFields("contests/contest"..(message.guild and message.guild.id or "").."/contest", contest)
	saveFileWithFields("contests/contest"..(message.guild and message.guild.id or "").."/participants/participant"..part.message, part)
	return msg2
end

function messageMgr(message)
	local contest = loadFileWithFields("contests/contest"..(message.guild and message.guild.id or "").."/contest")
	
	if message.channel and contest.channel == message.channel.id and contest.channel and message.author.id ~= client.user.id then
		if not contest.submit_limit or tonumber(contest[message.author.id] or "0") < tonumber(contest.submit_limit) and message.attachment  then
			local url = message.attachment and message.attachment.url
			local extension = url and string.lower(url:sub(#url - 3, #url))
			
			if extension == ".png" or extension == ".jpg" or extension == ".jpeg" or extension == ".gif" then
				addMessageArtContest(message)
			end
		end
		message:delete()
	end
    if (last_day ~= math.floor(os.time() / 86400)) then
        last_day = math.floor(os.time() / 86400)
        os.remove("daily")
    end
    if message.guild and message.author.id == my_id and grabingMee6data[message.guild.id] then
		msg = parseCommand(message.content, 1, true)
		if message.content == "abort" then
			emitter:emit("ChangeXP", "abort")
		elseif #msg ~= 2 then
			message:reply({
				embed = {
					title = "Error",
					description = string.format("Invalid number of fields: 2 expected but got %d\nReply is this format: <level> <xp_on_this_level>", #msg),
					color = 0xFF0000,
				}
			})
		elseif not tonumber(msg[1]) then
			message:reply({
				embed = {
					title = "Error",
					description = string.format("Malformed number %s\nReply is this format: <level> <xp_on_this_level>", msg[1]),
					color = 0xFF0000,
				}
			})
		elseif not tonumber(msg[2]) then
			message:reply({
				embed = {
					title = "Error",
					description = string.format("Malformed number %s\nReply is this format: <level> <xp_on_this_level>", msg[1]),
					color = 0xFF0000,
				}
			})
		else
			emitter:emit("ChangeXP", getTheXp(tonumber(msg[1]), tonumber(msg[2])))
		end
	else
		commandMgr(message)
    end
end

function messageCreate(message)
    local tab = {true}

	if not message then return end
    tab = {pcall(messageMgr, message)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(("%s\n%s"):format(stack_trace, debug.traceback()))
        guild = message.guild and ("on server \"%s\""):format(message.guild.name) or "in private messages"
        print(("While recieving \"%s\" by \"%s\" %s"):format(message.author.name, tostring(message.content), guild))
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = string.format("Oh no ! %s", emojis.cry),
                description = string.format("%s\n%s %s\nWhile recieving \"%s\" by \"%s\" (<@%s>) ",
					stack_trace, debug.traceback(), emojis.loveyou, tostring(message.content), message.author.name, message.author.id, guild),
                color = 0xFF0000
            }
        })
        message:reply({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = string.format("Oh no ! %s", emojis.cry),
                description = string.format("%s\n%s %s", stack_trace, debug.traceback(), emojis.loveyou),
                color = 0xFF0000
            }
        })
    end
end

function getShopPage(message)
    local embed = message.embed
    
    if not embed then
        return 0
    else
        return (tonumber(string.sub(embed.description, 6, #embed.description)) - 1) * 7 + 1
    end
end

function getLeaderBoardIndex(description, sep, start)
    local End = start or 2
    local str
    
    while string.sub(description, End, End) ~= (sep or "\t") do
        End = End + 1
    end
    str = string.sub(description, start or 2, End - 1)
    if (str == "🥇") then
        return (1)
    elseif (str == "🥈") then
        return (2)
    elseif (str == "🥉") then
        return (3)
    end
    return tonumber(str)
end

function addVoteArtContest(reaction, contest, userid, message)
	local part = loadFileWithFields("contests/contest"..message.guild.id.."/participants/participant"..message.id)
	local votes = loadFile("contests/contest"..message.guild.id.."/votes/votes"..userid)
	local channel = client:getChannel(contest.channel)
	local oldEmbed = message.embed
	local name = ""
	
	if not part.message then
		return
	end
	for i, k in pairs(votes) do
		if k == message.id then
			return true
		end
	end
	if contest.vote_limit and #votes >= tonumber(contest.vote_limit) then
		for i = 0, #votes - tonumber(contest.vote_limit) do
			local oldMessage = channel:getMessage(votes[1])
			local participant = loadFileWithFields("contests/contest"..message.guild.id.."/participants/participant"..votes[1])
			local oldEmbed = oldMessage and oldMessage.embed
			local name = ""
			
			participant.votes = participant.votes - 1
			saveFileWithFields("contests/contest"..message.guild.id.."/participants/participant"..votes[1], participant)
			if oldMessage then
				for i = 1, #oldEmbed.footer.text do
					name = oldEmbed.footer.text:sub(1, i - 2)
					if oldEmbed.footer.text:sub(i - 1, i) == " |" then
						break
					end
				end
				oldEmbed.footer.text = name.." | "..participant.votes.." votes"
				oldMessage:setEmbed(oldEmbed)
			end
			votes[1] = nil
			local j = 1
			repeat
				votes[j] = votes[j + 1]
				j = j + 1
			until not votes[j]
		end
	end
	part.votes = part.votes + 1
	votes[#votes + 1] = part.message
	saveFile("contests/contest"..message.guild.id.."/votes/votes"..userid, votes)
	saveFileWithFields("contests/contest"..message.guild.id.."/participants/participant"..message.id, part)
	for i = 1, #oldEmbed.footer.text do
		name = oldEmbed.footer.text:sub(1, i - 2)
		if oldEmbed.footer.text:sub(i - 1, i) == " |" then
			break
		end
	end
	oldEmbed.footer.text = name.." | "..part.votes.." votes"
	message:setEmbed(oldEmbed)
	return true
end

function split(str, char)
	local tab = {}
	local start = 1
	
	for i = 1, #str do
		if str:sub(i, i) == char then
			tab[#tab + 1] = str:sub(start, i - 1)
			start = i + 1
		end
	end
	tab[#tab + 1] = str:sub(start, #str)
	return tab
end

function parseReactionRoleMsg(content)
	local roles = {}
	local tmp1, tmp2, tmp3 = 1, 1, false
	
	for i, k in pairs(split(content, "\n")) do
		roles[i] = {}
		tmp1, tmp2 = 1, 1
		tmp3 = k:sub(1, 1) == "<"
		while (tmp3 or k:sub(tmp1 , tmp1) ~= ":") and k:sub(tmp1 , tmp1) ~= "" do
			tmp1 = tmp1 + 1
			tmp3 = tmp3 and k:sub(tmp1 , tmp1) ~= ">"
		end
		tmp2 = tmp1
		while k:sub(tmp2 , tmp2) ~= "(" and k:sub(tmp2 , tmp2) ~= "" do
			tmp2 = tmp2 + 1
		end
		roles[i].reaction = k:sub(1, tmp1 - 1)
		roles[i].role = k:sub(tmp1 + 5, tmp2 - 3)
	end
	return roles
end

function reactionCreate(reaction, userid)
    if (reaction.me and reaction.message.author.id == client.user.id) then
        local player = getPlayer(userid, client:getUser(userid))
        local found = false
        
        if (player.message == reaction.message.id) then
            local story_item = loadStoryItems()[player.item_id]
            local icon = parseCommand(story_item.icons, 1, true) or {}
            local questions = parseCommand(story_item.questions, 1, true) or {}
            
            for j, k in pairs(icon) do
                local warps = parseCommand(story_item["warps_"..j], 1, true) or {}
                local conditions = parseCommand(story_item["warp_requirement_"..j], 1, true) or {}
                local new_warp
                
                if (k == reaction.emojiName or (reaction.emojiId and k == "<:"..reaction.emojiName..":"..reaction.emojiId..">")) then
                    new_warp = findWarp(story_item, player, warps, conditions)
                    if (not new_warp) then
                        reaction.message:clearReactions()
                        reaction.message:setEmbed({
                                title = "Error",
                                description = "Couldn't find a warp.\
Warps were "..tostring(story_item["warps_"..j]).." (warps_"..j..")\
Conditions were "..tostring(story_item["warp_requirement_"..j]).." (warp_requirement_"..j..")",
                                color = 0xFF0000
                        })
                    else
                        player.executed = "false"
                        execDayItem({}, new_warp, reaction.message, player, userid)
                    end
                    found = true
                end
            end
        end
        if not found then
			local contest = reaction.message.guild and loadFileWithFields("contests/contest"..reaction.message.guild.id.."/contest")
			
			contest.hide_owner = contest.hide_owner == "true"
			if reaction.message.guild and reaction.message.embed and reaction.message.embed.title == "Reaction to Role" and reaction.me and reaction.count > 1 then
				local roles = parseReactionRoleMsg(reaction.message.embed.description)
				
				for i, k in pairs(roles) do
					if k.reaction == reaction.emojiName or (reaction.emojiId and k.reaction == "<:"..reaction.emojiName..":"..reaction.emojiId..">") then
						reaction.message.guild:getMember(userid):addRole(k.role)
						reaction.message:removeReaction(
							k.reaction:sub(1, 1) == '<' and k.reaction:sub(2, #k.reaction - 1) or k.reaction,
							userid
						)
						break
					end
				end
			elseif (contest and contest.channel == reaction.message.channel.id and reaction.message.guild and reaction.message.embed.title == "Art contest" and
				(contest.emoji_upvote == reaction.emojiName or (reaction.emojiId and contest.emoji_upvote == "<:"..reaction.emojiName..":"..reaction.emojiId..">"))
				and userid ~= client.user.id)
			then
				if addVoteArtContest(reaction, contest, userid, reaction.message) then
					reaction.message:removeReaction(
						contest.emoji_upvote:sub(1, 1) == '<' and contest.emoji_upvote:sub(2, #contest.emoji_upvote - 1) or contest.emoji_upvote,
						userid
					)
				end
            elseif (reaction.message.embed and reaction.message.embed.title == "Close contest" and reaction.me and reaction.count > 1) then
				reaction.message:clearReactions()
				if reaction.emojiId == "413696297338404864" then
					if contest.closed then
						reaction.message:setEmbed({
							title = "Error",
							description = "This contest has been already been closed.",
							color = 0xFF0000,
							footer = reaction.message.embed.footer
						})
					elseif contest.channel then
						contest.closed = true
						saveFileWithFields("contests/contest"..reaction.message.guild.id.."/contest", contest)
						reaction.message:setEmbed({
							title = "Close contest",
							description = "Submition successfully closed.",
							color = 0x00FF00,
							footer = reaction.message.embed.footer
						})
					else
						reaction.message:setEmbed({
							title = "Error",
							description = "This contest has been deleted.",
							color = 0xFF0000,
							footer = reaction.message.embed.footer
						})
					end
				else
					reaction.message:setEmbed({
						title = "Cancel",
						description = "Canceled.",
						color = 0xFF0000,
						footer = reaction.message.embed.footer
					})
				end
			elseif (reaction.message.embed and reaction.message.embed.title == "Stop contest" and reaction.me and reaction.count > 1) then
				local image_url = ""
				local winner = ""
				local votes = 0
				local participants = scanDir("contests/contest"..reaction.message.guild.id.."/participants")
				
				for i, k in pairs(participants) do
					participants[i] = loadFileWithFields("contests/contest"..reaction.message.guild.id.."/participants/"..k)
				end
				for i, k in pairs(participants) do
					if contest.hide_owner then
						local message = client:getChannel(contest.channel):getMessage(k.message)
						local embed = message and message.embed
						local owner = client:getUser(k.author)
						
						if embed then
							embed.description = "<@"..k.author..">"..embed.description:sub(8, #embed.description)
							embed.footer.text = (owner and owner.name or "Someone")..embed.footer.text:sub(8, #embed.footer.text)
							embed.footer.icon_url = owner and owner.avatarURL
							message:setEmbed(embed)
						end
					end
					for j = i + 1, #participants do
						if tonumber(participants[i].votes) < tonumber(participants[j].votes) then
							k = participants[i]
							participants[i] = participants[j]
							participants[j] = k
						end
					end
				end
				if participants[1] then
					winner = participants[1].author
					votes = participants[1].votes
					image_url = participants[1].image
				end
				reaction.message:clearReactions()
				if reaction.emojiId == "413696297338404864" then
					if contest.channel then
						os.execute("rm -rf contests/contest"..reaction.message.guild.id)
						if not reaction.message:setEmbed({
								title = "Stop contest",
								description = "Contest is now closed.\
The winner is <@"..winner.."> with "..votes.." upvotes",
								color = 0x00FF00,
								image = {
									url = image_url
								},
								footer = {
									icon_url = client:getUser(winner) and client:getUser(winner).avatarURL,
									text = client:getUser(winner) and client:getUser(winner).name or "Error"
								},
							}) then
							reaction.message:setEmbed({
								title = "Stop contest",
								description = "Contest is now closed.\
The winner is <@"..tostring(winner).."> with "..tostring(votes).." upvotes\n"..tostring(image_url),
								color = 0x00FF00,
								footer = {
									icon_url = client:getUser(winner) and client:getUser(winner).avatarURL,
									text = client:getUser(winner) and client:getUser(winner).name or "Error"
								},
							})
						end
					else
						reaction.message:setEmbed({
							title = "Error",
							description = "This contest has been deleted.",
							color = 0xFF0000,
							footer = reaction.message.embed.footer
						})
					end
				else
					reaction.message:setEmbed({
						title = "Cancel",
						description = "Canceled.",
						color = 0xFF0000,
						footer = reaction.message.embed.footer
					})
				end
            elseif (reaction.message.embed and reaction.message.embed.title:sub(1, 21) == "Self Assignable Roles" and reaction.emojiName == "➡" and reaction.me and reaction.count > 1) then
                dispSAR(nil, reaction.message, tonumber(string.sub(reaction.message.embed.title, 28, #reaction.message.embed.title)) + 1, true)
            elseif (reaction.message.embed and reaction.message.embed.title:sub(1, 21) == "Self Assignable Roles" and reaction.emojiName == "⬅" and reaction.me and reaction.count > 1) then
                dispSAR(nil, reaction.message, tonumber(string.sub(reaction.message.embed.title, 28, #reaction.message.embed.title)) - 1, true)
            elseif (reaction.message.embed and reaction.message.embed.title == "Leaderboard" and reaction.emojiName == "➡" and reaction.me and reaction.count > 1) then
                dispXpLeaderBoard(reaction.message, getLeaderBoardIndex(reaction.message.embed.description) + 10, true)
            elseif (reaction.message.embed and reaction.message.embed.title == "Leaderboard" and reaction.emojiName == "⬅" and reaction.me and reaction.count > 1) then
                dispXpLeaderBoard(reaction.message, getLeaderBoardIndex(reaction.message.embed.description) - 10, true)
            elseif (reaction.message.embed and reaction.message.embed.title == "Essences Leaderboard" and reaction.emojiName == "➡" and reaction.me and reaction.count > 1) then
                dispLeaderBoard({}, false, reaction.message, getLeaderBoardIndex(reaction.message.embed.description, " ", 1) + 10, true)
            elseif (reaction.message.embed and reaction.message.embed.title == "Essences Leaderboard" and reaction.emojiName == "⬅" and reaction.me and reaction.count > 1) then
                dispLeaderBoard({}, false, reaction.message, getLeaderBoardIndex(reaction.message.embed.description, " ", 1) - 10, true)
            elseif (reaction.message.embed and reaction.message.embed.title:sub(1, 5) == "Roles" and reaction.emojiName == "➡" and reaction.me and reaction.count > 1) then
				dispColorRoles(reaction.message, tonumber(reaction.message.embed.title:sub(11, #reaction.message.embed.title)) + 1, true)
            elseif (reaction.message.embed and reaction.message.embed.title:sub(1, 5) == "Roles" and reaction.emojiName == "⬅" and reaction.me and reaction.count > 1) then
				dispColorRoles(reaction.message, tonumber(reaction.message.embed.title:sub(11, #reaction.message.embed.title)) - 1, true)
            elseif (reaction.emojiName == "⬅" and reaction.me and reaction.count > 1) then
                loadShop(reaction.message.guild.id)
                showShop(nil, false, reaction.message, true, getShopPage(reaction.message) - 7)
            elseif (reaction.emojiName == "➡" and reaction.me and reaction.count > 1) then
                loadShop(reaction.message.guild.id)
                showShop(nil, false, reaction.message, true, getShopPage(reaction.message) + 7)
            end
        end
    end
end

function reactionAdd(reaction, userid)
	if not reaction then return end
    local tab = {true}
    local message = reaction.message

    tab = {pcall(reactionCreate, reaction, userid)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        guild = "in private messages"
        if (message.guild) then
            guild = "on server \""..message.guild.name
        end
        print("While recieving \""..tostring(message.content).."\" by \""..message.author.name.."\" "..guild.."\"")
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..tostring((client:getUser(userid) or {}).name).." (<@"..userid..">) added "..reaction.emojiName.." on "..guild.."\"",
                color = 0xFF0000
            }
        })
        message:reply({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou,
                color = 0xFF0000
            }
        })
    end
end

function memberJoin(member)
	if not member then return end
    local autorole = loadFile("configs/autorole"..member.guild.id)
    local welcome = loadFileWithFields("configs/welcome"..member.guild.id)
	local logs = loadFileWithFields("configs/logs") or {}
	local settings = loadFileWithFields("configs/mute"..member.guild.id)
    
    if welcome.channel and member.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)) then
        member.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)):send({
			embed = {
				title = createMessage(welcome.title, member),
				description = createMessage(welcome.description, member),
				color = tonumber(welcome.color, 16),
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = member.user.avatarURL,
					text = member.user.name
				},
				image = {
					url = welcome.image
				}
			}
        })
    end
	for i, k in pairs(escapist[member.guild.id] or {}) do
		if k == member.id and not member:hasRole(string.sub(settings.role, 4, #settings.role - 1)) then
			if not settings.role then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Default mute role is not defined",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member.guild:getMember(client.user.id):hasPermission("manageRoles") then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "I am missing the \"manageRoles\" permission",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)) then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Couldn't find "..settings.role,
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif member.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)).position > member.guild:getMember(client.user.id).highestRole.position then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = settings.role.." is higher than my highest role, preventing me from giving it to anyone",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member:addRole(string.sub(settings.role, 4, #settings.role - 1)) then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Couldn't add "..settings.role.." to <@"..member.id..">",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			else
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "**Muted** 🤐",
							description = "<@"..member.id.."> joined back the server and got muted",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFFFFFF,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			end
			escapist[member.guild.id][i] = nil
			break;
		end
	end
	for i, k in pairs(mutedPeople[member.guild.id] or {}) do
		if k == member.id and not member:hasRole(string.sub(settings.role, 4, #settings.role - 1)) then
			if not settings.role then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Default mute role is not defined",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member.guild:getMember(client.user.id):hasPermission("manageRoles") then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "I am missing the \"manageRoles\" permission",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)) then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Couldn't find "..settings.role,
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif member.guild:getRole(string.sub(settings.role, 4, #settings.role - 1)).position > member.guild:getMember(client.user.id).highestRole.position then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = settings.role.." is higher than my highest role, preventing me from giving it to anyone",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			elseif not member:addRole(string.sub(settings.role, 4, #settings.role - 1)) then
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "Error",
							description = "Couldn't add "..settings.role.." to <@"..member.id..">",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFF0000,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			else
				if settings.channel and client:getChannel(settings.channel:sub(3, #settings.channel - 1)) then
					client:getChannel(settings.channel:sub(3, #settings.channel - 1)):send({
						embed = {
							title = "**Muted** 🤐",
							description = "<@"..member.id.."> joined back the server and got muted",
							timestamp = discord.Date():toISO('T', 'Z'),
							color = 0xFFFFFF,
							footer = {
								icon_url = member.user.avatarURL,
								text = member.user.name
							}
						}
					})
				end
			end
			break;
		end
	end
    if autorole[1] then
        member:addRole(string.sub(autorole[1], 4, #autorole[1] - 1))
    end
--	if logs[member.guild.id] and client:getChannel(logs[member.guild.id]) then
--		client:getChannel(logs[member.guild.id]):send({
--			embed = {
--				title = "👤 Member joined !",
--				description = "<@"..member.id.."> ("..member.name..") just joined the server",
--				color = 0x00FF00,
--				timestamp = discord.Date():toISO('T', 'Z'),
--				footer = {
--					icon_url = member.user.avatarURL,
--					text = member.user.name
--				},
--			}
--		})
--	end
end

function memberJoining(member)
    local tab = {true}

	if not member then return end
    tab = {pcall(memberJoin, member)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..member.user.name.." joined "..member.guild.name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..member.user.name.." (<@"..member.user.id..">) joined "..member.guild.name,
                color = 0xFF0000
            }
        })
    end
end

function memberLeft(member)
    local welcome = loadFileWithFields("configs/leavingMessage"..member.guild.id)
	local logs = loadFileWithFields("configs/logs") or {}
	local settings = loadFileWithFields("configs/mute"..member.guild.id)
    
	if settings.role and member:hasRole(settings.role:sub(4, #settings.role - 1)) then
		if not escapist[member.guild.id] then
			escapist[member.guild.id] = {}
		end
		escapist[member.guild.id][#escapist[member.guild.id] + 1] = member.id
	end
    if welcome.channel and member.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)) then
        member.guild:getChannel(string.sub(welcome.channel, 3, #welcome.channel - 1)):send({
            embed = {
                title = createMessage(welcome.title, member),
                description = createMessage(welcome.description, member),
                color = tonumber(welcome.color, 16),
                timestamp = discord.Date():toISO('T', 'Z'),
                footer = {
                    icon_url = member.user.avatarURL,
                    text = member.user.name
                },
                image = {
                    url = welcome.image
                }
            }
        })
    end
	if logs[member.guild.id] and client:getChannel(logs[member.guild.id]) then
		client:getChannel(logs[member.guild.id]):send({
			embed = {
				title = "❌ Member left !",
				description = "<@"..member.id.."> ("..member.name..") just left the server",
				color = 0x00FF00,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = member.user.avatarURL,
					text = member.user.name
				},
			}
		})
	end
end

function memberLeaving(member)
    local tab = {true}

	if not member then return end
    tab = {pcall(memberLeft, member)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..member.user.name.." joined "..member.guild.name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..member.user.name.." (<@"..member.user.id..">) left "..member.guild.name,
                color = 0xFF0000
            }
        })
    end
end

function channelCreate(channel)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if channel.guild and logs[channel.guild.id] and client:getChannel(logs[channel.guild.id]) then
		client:getChannel(logs[channel.guild.id]):send({
			embed = {
				title = "✅ Channel created !",
				description = "Channel "..channel.name.." created",
				color = 0x00AA00,
				timestamp = discord.Date():toISO('T', 'Z')
			}
		})
	end
end

function channelCreated(channel)
    local tab = {true}

	if not channel then return end
    tab = {pcall(channelCreate, channel)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..channel.name.." got created in "..tostring(channel.guild or {}).name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..tostring(channel.name).." got created in "..tostring((channel.guild or {}).name),
                color = 0xFF0000
            }
        })
    end
end

function channelUpdate(channel)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if channel.guild and logs[channel.guild.id] and client:getChannel(logs[channel.guild.id]) then
		client:getChannel(logs[channel.guild.id]):send({
			embed = {
				title = "✳ Channel updated !",
				description = "Channel "..channel.name.." updated",
				color = 0x00AA00,
				timestamp = discord.Date():toISO('T', 'Z')
			}
		})
	end
end

function channelUpdated(channel)
    local tab = {true}

	if not channel then return end
    tab = {pcall(channelUpdate, channel)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..tostring(channel.name).." got updated in "..tostring(channel.guild or {}).name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..tostring(channel.name).." got updated in "..tostring((channel.guild or {}).name),
                color = 0xFF0000
            }
        })
    end
end

function channelDelete(channel)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if not channel then return end
	if channel.guild and logs[channel.guild.id] and client:getChannel(logs[channel.guild.id]) then
		client:getChannel(logs[channel.guild.id]):send({
			embed = {
				title = "❎ Channel deleted !",
				description = "Channel "..channel.name.." deleted",
				color = 0x00AA00,
				timestamp = discord.Date():toISO('T', 'Z')
			}
		})
	end
end

function channelDeleted(channel)
    local tab = {true}

	if not channel then return end
    tab = {pcall(channelDelete, channel)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..tostring(channel.name).." got deleted in "..tostring(channel.guild or {}).name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..tostring(channel.name).." got deleted in "..tostring((channel.guild or {}).name),
                color = 0xFF0000
            }
        })
    end
end

function userBan(user, guild)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if logs[guild.id] and client:getChannel(logs[guild.id]) then
		client:getChannel(logs[guild.id]):send({
			embed = {
				title = "😱 User banned !",
				description = "<@"..user.id.."> ("..user.name..") got banned from the server",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = user.avatarURL,
					text = user.name
				},
			}
		})
	end
end

function userBanned(user, guild)
    local tab = {true}

	if not user or not guild then return end
    tab = {pcall(userBan, user, guild)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..user.name.." got banned from "..guild.name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..tostring(user.name).." got banned from "..tostring(guild.name),
                color = 0xFF0000
            }
        })
    end
end

function userUnban(user, guild)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if logs[guild.id] and client:getChannel(logs[guild.id]) then
		client:getChannel(logs[guild.id]):send({
			embed = {
				title = "😀 User unbanned !",
				description = "<@"..user.id.."> ("..user.name..") got unbanned from the server",
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = user.avatarURL,
					text = user.name
				},
			}
		})
	end
end

function reactionAddUncached(channel, messageId, hash, userId)
	if not channel then return end
	local message = channel:getMessage(messageId)
	local reaction
	
	if not message then
		return
	end
	for i in message.reactions:iter() do
		if i.emojiName == hash or i.emojiId == hash then
			reaction = i
			break
		end
	end
	reactionAdd(reaction, userId)
end

function userUnbanned(user, guild)
    local tab = {true}

	if not user or not guild then return end
    tab = {pcall(userUnban, user, guild)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When "..user.name.." got unbanned from "..guild.name)
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When "..user.name.." got unbanned from "..guild.name,
                color = 0xFF0000
            }
        })
    end
end

function messageUpdated(message)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if not message.guild then return end
	if logs[message.guild.id] and client:getChannel(logs[message.guild.id]) and message.author ~= client.user then
		client:getChannel(logs[message.guild.id]):send({
			embed = {
				title = "📝 Message updated !",
				description = string.format("A message from %s has been updated in #%s\nContent: %s", message.author.name, message.channel.name, message.content),
				color = 0xFF8800,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				},
			}
		})
	end
end

function messageUpdate(message)
    local tab = {true}

	if not message then return end
    tab = {pcall(messageUpdated, message)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When a message got updated in "..(message.guild and message.guild.name or ("?")))
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When a message got updated in "..(message.guild and message.guild.name or ("?")),
                color = 0xFF0000
            }
        })
    end
end

function messageDeleted(message)
	local logs = loadFileWithFields("configs/logs") or {}
	
	if not message.guild then return end
	if logs[message.guild.id] and client:getChannel(logs[message.guild.id]) then
		client:getChannel(logs[message.guild.id]):send({
			embed = {
				title = "❌ Message deleted !",
				description = string.format("A message from %s has been deleted in #%s\nContent: %s", message.author.name, message.channel.name, message.content),
				color = 0xFF0000,
				timestamp = discord.Date():toISO('T', 'Z'),
				footer = {
					icon_url = message.author.avatarURL,
					text = message.author.name
				},
			}
		})
	end
end

function messageDelete(message)
    local tab = {true}

	if not message then return end
    tab = {pcall(messageDeleted, message)}
    if not tab[1] then
        local stack_trace = ""
        for i, k in pairs(tab) do
            if i ~= 1 then
                stack_trace = stack_trace..tostring(k).."\n"
            end
        end
        print(stack_trace.."\n"..debug.traceback())
        print("When a message got deleted in "..(message.guild and message.guild.name or ("?")))
        client:getUser(my_id):send({
            content = ("<@%s>"):format(my_id),
            embed = {
                title = "Oh no ! "..emojis.cry,
                description = stack_trace.."\n"..debug.traceback().." "..emojis.loveyou.."\
When a message got deleted in "..(message.guild and message.guild.name or ("?")),
                color = 0xFF0000
            }
        })
    end
end

client:on('ready', on_ready)
client:on('messageCreate', messageCreate)
client:on('messageUpdate', messageUpdate)
client:on('messageDelete', messageDelete)
client:on('memberJoin', memberJoining)
client:on('memberLeave', memberLeaving)
client:on('reactionAdd', reactionAdd)
client:on('reactionAddUncached', reactionAddUncached)
client:on('channelCreate', channelCreated)
client:on('channelUpdate', channelUpdated)
client:on('channelDelete', channelDeleted)
client:on('userBan', userBanned)
client:on('userUnban', userUnbanned)

client:run("Bot "..token)
