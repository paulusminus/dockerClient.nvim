local health = vim.health or require("health")
local start = vim.health.start or require("health").start
local ok = health.ok or require("health").ok
local warn = health.warn or require("health").warn
local error = health.error or require("health").error

local is_win = vim.api.nvim_call_function("has", { "win32" }) == 1

local required_plugins = {
	{ lib = "plenary", optional = false },
}

local required_bins = {
	{ name = "cargo", optional = false },
	{ name = "docker", optional = false },
}

local function binary_name(name)
	if is_win then
		return name .. ".exe"
	else
		return name
	end
end

local check_binary_installed = function(package)
	local executable = binary_name(package)
	if vim.fn.executable(executable) == 1 then
		local version = vim.fn.systemlist({ package, "--version" })
		if version then
			return true, table.concat(version, ". ")
		else
			return false, ""
		end
	else
		return false, ""
	end
end

local function lualib_installed(lib_name)
	local res, _ = pcall(require, lib_name)
	return res
end

local M = {}

M.check = function()
	-- Required lua libs
	start("Checking for required plugins")
	for _, plugin in ipairs(required_plugins) do
		if lualib_installed(plugin.lib) then
			ok(plugin.lib .. " installed.")
		else
			local lib_not_installed = plugin.lib .. " not found."
			if plugin.optional then
				warn(("%s %s"):format(lib_not_installed, plugin.info))
			else
				error(lib_not_installed)
			end
		end
	end

	start("Checking for required executables")
	for _, bin in ipairs(required_bins) do
		local installed, version = check_binary_installed(bin.name)
		if installed then
			ok(version)
		else
			local bin_not_installed = bin.name .. " not found."
			if bin.optional then
				warn(("%s %s"):format(bin_not_installed, bin.name))
			else
				error(bin_not_installed)
			end
		end
	end
end

return M
