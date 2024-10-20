local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")

local logger = require("plenary.log"):new(standalone)

local M = {}

M.show_docker_images = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = {
					{ name = "Yes", value = { 1, 2, 3, 45 } },
					{ name = "No", value = { 1, 2, 3, 45 } },
					{ name = "Maybe", value = { 1, 2, 3, 45 } },
					{ name = "Perhaps", value = { 1, 2, 3, 45 } },
				},
				entry_maker = function(entry)
					return {
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = config.generic_sorter(opts),

			previewer = previewers.new_buffer_previewer({
				title = "Docker Image Details",
				define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, { "Hello", "Paul Min" })
				end,
			}),
		})
		:find()
end

M.show_docker_images()

return M
