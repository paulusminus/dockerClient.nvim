local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local docker = require("lua.docker")

local telescope_docker = {}

function telescope_docker.show_docker_images(opts)
	pickers
		.new(opts, {
			finder = finders.new_async_job({
				command_generator = docker.list,
				entry_maker = docker.entry_maker,
				sorter = config.generic_sorter(opts),
				previewer = previewers.new_buffer_previewer({
					title = docker.preview_title,
					define_preview = function(self, entry)
						vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, docker.preview_lines(entry))
					end,
				}),
			}),
		})
		:find()
end

telescope_docker.show_docker_images()

return telescope_docker
