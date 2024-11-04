if 1 ~= vim.fn.has("nvim-0.9.0") then
	vim.api.nvim_err_writeln("dockerClient.nvim requires at least nvim-0.9.0.")
	return
end

vim.api.nvim_create_user_command("DockerRunSelectedImage", function()
	require("dockerClient").run_selected_image({})
end, {})
