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

local cargo_test_doc = {
	"cargo",
	"test",
	"--doc",
}

local options = {
	preview_title = "Docker Image Details",
	prompt_title = "Select image",
}

local function is_rust_project()
	return vim.fn.filereadable(vim.fs.joinpath(vim.fn.getcwd(), "Cargo.toml"))
end

local function log_not_a_rust_project()
	log.error(vim.fn.getcwd(), "is not a rust project")
end

local function run(command_line, on_exit)
	vim.system(command_line, {}, on_exit)
end

local function handle_cargo_run_release_exit(completed)
	log.debug(table.concat(cargo_run_release, " "), completed.code)
end

local function handle_cargo_test_doc_exit(completed)
	local lines = {
		"Exit code: " .. completed.code,
		"Stdout:\n" .. completed.stdout,
		"Stderr:\n" .. completed.stderr,
	}
	log.debug(table.concat(lines, "\n\n"))
end

local M = {}

---@brief [[
--- dockerClient.nvim is a plugin for selecting and running a Docker Image.
---@brief ]]

-- Select a docker image to be run
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

-- Run a binary release of the main crate
M.cargo_run_release = function()
	if is_rust_project() then
		run(cargo_run_release, handle_cargo_run_release_exit)
	else
		log_not_a_rust_project()
	end
end

-- Test the documentations samples
M.cargo_test_doc = function()
	if is_rust_project() then
		run(cargo_test_doc, handle_cargo_test_doc_exit)
	else
		log_not_a_rust_project()
	end
end

-- Configure the plugin
--
---@param opts? table
--- * preview_title:
---     - defaults to "Docker Image Details"
--- * prompt_title:
---     - defaults to "Select Image"
M.setup = function(opts)
	if opts then
		for k, v in pairs(opts) do
			options[k] = v
		end
	end
end

return M
