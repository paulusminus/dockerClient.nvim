local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local docker = require("telescope_docker.docker")

local M = {}

M.select_docker_image = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_dynamic({
				fn = docker.list_fn,
				entry_maker = docker.entry_maker,
			}),
			sorter = config.generic_sorter(opts),
			previewer = docker.previewer,
		})
		:find()
end

return M
