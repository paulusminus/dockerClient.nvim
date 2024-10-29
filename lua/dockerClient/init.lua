local config = require("telescope.config").values
local finders = require("telescope.finders")
local image = require("dockerClient.image")
local pickers = require("telescope.pickers")
local log = require("plenary.log"):new()
log.level = "debug"

local cargo_run_release = {
	"cargo",
	"run",
	"--release",
}

local options = {
	preview_title = "Docker Image Details",
	prompt_title = "Select image",
}

local M = {}

M.run_selected_image = function(opts)
	pickers
		.new(opts, {
			prompt_title = options.prompt_title,
			finder = finders.new_dynamic({
				fn = image.list_fn,
				entry_maker = image.entry_maker,
			}),
			sorter = config.generic_sorter(opts),
			previewer = image.previewer(options.preview_title),
			attach_mappings = image.action,
		})
		:find()
end

M.cargo_run_release = function()
	vim.system(cargo_run_release, {}, function(completed)
		local lines = table.concat(cargo_run_release, " ")
		log.debug(lines, completed.code)
	end)
end

M.cargo_doctest = function()
	vim.system({ "cargo", "test", "--doc" }, {}, function(completed)
		local lines = "Exit code: "
			.. completed.code
			.. "\n\nStdout: "
			.. completed.stdout
			.. "\n\nStderr: "
			.. completed.stderr
		log.debug(lines)
	end)
end

M.setup = function(opts)
	for k, v in pairs(opts) do
		options[k] = v
	end
end

return M
