local config = require("telescope.config").values
local finders = require("telescope.finders")
local image = require("dockerClient.image")
local pickers = require("telescope.pickers")
local log = require("dockerClient.log")

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
	log.debug(vim.fn.getcwd(), "is not a rust project")
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

local dockerClient = {}

---@brief [[
--- dockerClient.nvim is a plugin for running a selected Docker image.
---
--- Getting started with dockerClient:
---   1. Run `:checkhealth dockerClient` to make sure everything is installed.
---   2. Evaluate it is working with
---      `:DockerRunSelectedImage` or
---      `:lua require("dockerClient").run_selected_image()`
---   3. Put a `require("dockerClient").setup()` call somewhere in your neovim config.
---   4. Read |dockerClient.setup| to check what config keys are available and what you can put inside the setup call
---   6. Profit
---
--- <pre>
--- To find out more:
--- https://github.com/paulusminus/dockerClient.nvim
---
---   :h dockerClient.run_selected_image
---   :h dockerClient.setup
--- </pre>
---@brief ]]

---@tag dockerClient.nvim
---@config { ["name"] = "INTRODUCTION" }

--- Select a docker image and run it
---
---@param opts? table: Options for configuring telescope picker
dockerClient.run_selected_image = function(opts)
	pickers
		.new({}, {
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

-- Run the release binary of the main crate
dockerClient.cargo_run_release = function()
	if is_rust_project() then
		run(cargo_run_release, handle_cargo_run_release_exit)
	else
		log_not_a_rust_project()
	end
end

-- Run the documentation tests
dockerClient.cargo_test_doc = function()
	if is_rust_project() then
		run(cargo_test_doc, handle_cargo_test_doc_exit)
	else
		log_not_a_rust_project()
	end
end

--- Setup function to be run by user. Configures the defaults of dockerClient.
---
---@param opts? table: options to pass to setup
dockerClient.setup = function(opts)
	if opts then
		for k, v in pairs(opts) do
			options[k] = v
		end
	end
end

return dockerClient
