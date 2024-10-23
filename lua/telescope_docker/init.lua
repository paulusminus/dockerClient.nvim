local pickers = require("telescope.pickers")
local config = require("telescope.config").values
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")
local docker = require("telescope_docker.docker")
local plenary = require("plenary")
local log = require("plenary.log"):new()
log.level = "debug"

local M = {}

M.select_s = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_table({
				results = {
					{ name = "Yes", values = { 9, 4 } },
					{ name = "No", values = { 0, 3 } },
					{ name = "Maybe", values = { 1, 8 } },
					{ name = "Perhaps", values = { 2, 3 } },
				},
				entry_maker = function(entry)
					log.debug(entry)
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name,
					}
				end,
			}),
			sorter = config.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Hallo",
				define_preview = function(self, entry)
					local lines = {}
					table.insert(lines, entry.name)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, lines)
				end,
			}),
		})
		:find()
end

M.select_docker_image = function(opts)
	pickers
		.new(opts, {
			finder = finders.new_dynamic({
				fn = docker.list_fn,
				entry_maker = docker.entry_maker,
			}),
			sorter = config.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = docker.preview_title,
				define_preview = function(self, entry)
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, docker.preview_lines(entry))
					utils.highlighter(self.state.bufnr, "markdown", {})
				end,
			}),
		})
		:find()
end

return M
