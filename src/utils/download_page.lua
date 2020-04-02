local http = require("coro-http")

return function (url, path)
	local l, k = http.request("GET", url)
	if path then
		local file = io.open(path, "w+")
		
		file:write(k)
		file:close()
	end
	return k
end