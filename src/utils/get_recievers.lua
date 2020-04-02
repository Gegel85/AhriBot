local client = require("../client")

return function (arg, guild)
    local result = {}
    local buffer = 0

    if (arg == nil) then
        return (nil)
	elseif tonumber(arg) and client:getUser(arg) then
		return {arg}
    elseif string.sub(arg, 1, 2) == "<@" and string.sub(arg, #arg, #arg) == ">" then
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
        return result
    end
end