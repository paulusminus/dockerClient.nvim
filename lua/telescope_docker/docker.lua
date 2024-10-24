local plenary = require("plenary")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")

local list_images_command = { "docker", "image", "ls", "--format", "json" }
local preview_title = "Docker Image Details"

local function preview_content(entry)
	local image = entry.value
	local lines = {
		"```bash",
		'ID = "' .. image.ID .. '"',
		'Repository = "' .. image.Repository .. '"',
		'Tag = "' .. image.Tag .. '"',
		'Size = "' .. image.Size .. '"',
		"```",
	}
	return lines
end

local M = {}

M.list_fn = function()
	return plenary.job:new(list_images_command):sync()
end

M.entry_maker = function(entry)
	local parsed = vim.json.decode(entry)
	if parsed then
		return {
			value = parsed,
			display = parsed.Repository,
			ordinal = parsed.Repository,
		}
	end
end

M.previewer = previewers.new_buffer_previewer({
	title = preview_title,
	define_preview = function(self, entry)
		vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, preview_content(entry))
		utils.highlighter(self.state.bufnr, "markdown", {})
	end,
})

return M
