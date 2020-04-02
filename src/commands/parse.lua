return function (content)
    local quoteList = {
		['"'] = true,
		["'"] = true,
		['“'] = true,
		['”'] = true
	}
	local sepList = {
		[" "] = true,
		["\n"] = true,
		["\t"] = true
	}
	local lastQuote = nil
	local args = {}
	local currentArg = ""
	local start = 1
	local escaped = false

	while sepList[content:sub(start, start)] do
		start = start + 1
	end

	for i = start, #content + 1 do
		local character = content:sub(i, i) or " "

		if escaped then
			escaped = false
			currentArg = currentArg..character
		elseif character == "\\" then
			escaped = true
		elseif not lastQuote and quoteList[character] then
			lastQuote = character
		elseif lastQuote == character then
			lastQuote = nil
		elseif not lastQuote and sepList[character] then
			if currentArg ~= "" then
				args[#args + 1] = currentArg
				currentArg = ""
			end
		else
			currentArg = currentArg..character
		end
	end

	if lastQuote then
		return nil, "Unfinished quote"
	end

	args[#args + 1] = currentArg
	return args
end