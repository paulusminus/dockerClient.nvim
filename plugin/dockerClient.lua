vim.api.nvim_create_user_command("CargoDocTest", require("dockerClient").run_cargo_doctest(), {})
