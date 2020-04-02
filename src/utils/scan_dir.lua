return function (directory)
    local i, t, popen, pfile = 0, {}, io.popen
	
	-- Check if on Unix or Windows
	if jit.os ~= "Windows" then
		pfile = popen("ls '"..directory.."'")

		for filename in pfile:lines() do
			i = i + 1
			t[i] = filename
		end
	else
		pfile = popen('dir "'..directory:gsub("/", "\\")..'"')

		for filename in pfile:lines() do
			i = i + 1
			if i > 7 then
				t[i - 7] = filename:sub(37, #filename)
			end
		end

		--Delete 2 last lines
		t[#t] = nil
		t[#t] = nil
	end
	if not pfile:close() then
		return
	end
    return t
end