local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local plenary = require("plenary")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")

local list_images_command = { "docker", "image", "ls", "--format", "json" }

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

M.previewer = function(preview_title)
	previewers.new_buffer_previewer({
		title = preview_title,
		define_preview = function(self, entry)
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, preview_content(entry))
			utils.highlighter(self.state.bufnr, "markdown", {})
		end,
	})
end

M.action = function(prompt_bufnr)
	actions.select_default:replace(function()
		actions.close(prompt_bufnr)
		local selection = actions_state.get_selected_entry()
		local command = {
			"edit",
			"term://docker",
			"run",
			"-it",
			selection.value.Repository,
		}
		local docker_command = vim.fn.join(command, " ")
		vim.cmd(docker_command)
	end)

	return true
end

return M
