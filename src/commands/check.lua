return function (self, message)
	local prefix = ".." -- TODO: Add a way to change it
	local content = message.content
	
	if content:sub(1, #prefix) == prefix then
		return true, #prefix + 1
	end
	return false
end