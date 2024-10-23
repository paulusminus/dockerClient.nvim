-- local logger = require("plenary.log"):new()
-- logger.level = "debug"

local docker = {}

function docker.list()
	return { "docker", "image", "ls", "--format", "json" }
end

function docker.entry_maker(entry)
	local parsed = vim.json.decode(entry)
	-- logger.debug(parsed)
	if parsed then
		return {
			value = parsed,
			display = parsed.Repository,
			ordinal = parsed.Repository,
		}
	else
		return {}
	end
end

docker.preview_title = "Docker Image Details"

function docker.preview_lines(entry)
	local image = entry.value
	local lines = {
		"| --- | --- |",
		"| Id | " .. image.ID .. " |",
		"| Repository | " .. image.Repository .. " |",
		"| Tag | " .. image.Tag .. " |",
		"| Size | " .. image.Size .. " |",
	}
	return lines
end

return docker
