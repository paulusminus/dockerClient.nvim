local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local utils = require("telescope.previewers.utils")

local list_images_command = { "docker", "image", "ls", "--format", "json" }

local function preview_content(entry)
	local image = entry.value
	local lines = {
		"```bash",
		' Created = "' .. image.CreatedAt .. '"',
		' ID = "' .. image.ID .. '"',
		' Repository = "' .. image.Repository .. '"',
		' Size = "' .. image.Size .. '"',
		' Tag = "' .. image.Tag .. '"',
		"```",
	}
	return lines
end

local image = {}

image.list_fn = function()
	return vim.fn.systemlist(list_images_command)
end

image.entry_maker = function(entry)
	local parsed = vim.json.decode(vim.trim(entry))
	if parsed then
		return {
			value = parsed,
			display = parsed.Repository,
			ordinal = parsed.Repository,
		}
	end
end

image.previewer = function(preview_title)
	return previewers.new_buffer_previewer({
		title = preview_title,
		define_preview = function(self, entry)
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, preview_content(entry))
			utils.highlighter(self.state.bufnr, "markdown", {})
		end,
	})
end

image.action = function(prompt_bufnr)
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

return image
