-- local logger = require("plenary.log"):new()
-- logger.level = "debug"
local plenary = require("plenary")
local list = { "docker", "image", "ls", "--format", "json" }

local M = {}

M.list_fn = function()
	return plenary.job:new(list):sync()
end

M.entry_maker = function(entry)
	local parsed = vim.json.decode(entry)
	-- logger.debug(parsed)
	if parsed then
		return {
			value = parsed,
			display = parsed.Repository,
			ordinal = parsed.Repository,
		}
	end
end

M.preview_title = "Docker Image Details"

M.preview_lines = function(entry)
	local image = entry.value
	local lines = {
		"# " .. image.ID,
		"",
		"Repository: *" .. image.Repository .. "*",
		"Tag: *" .. image.Tag .. "*",
		"Size: *" .. image.Size .. "*",
	}
	return lines
end

return M
