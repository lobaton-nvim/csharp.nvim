-- lua/csharp/init.lua

local M = {}

local config = {
	auto_namespace = true,
	default_usings = {
		"System",
		"System.Collections.Generic",
		"System.Linq",
		"System.Threading.Tasks",
	},
	keymaps = {
		enabled = true,
		prefix = "<leader>c",
		mappings = {
			new_class = "c",
			new_interface = "i",
			new_enum = "e",
		},
	},
}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})

	-- Solo comandos para creación de archivos
	vim.api.nvim_create_user_command("CSharpNewClass", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Class name (optional: directory.class): ")
		end
		require("csharp.file_creator").create_class(name)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("CSharpNewInterface", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Interface name (optional: directory.IInterface): ")
		end
		require("csharp.file_creator").create_interface(name)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("CSharpNewEnum", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Enum name (optional: directory.Enum): ")
		end
		require("csharp.file_creator").create_enum(name)
	end, { nargs = "?" })

	-- Configurar atajos de teclado si están habilitados
	if config.keymaps.enabled then
		M.setup_keymaps()
	end
end

function M.setup_keymaps()
	local prefix = config.keymaps.prefix
	local mappings = config.keymaps.mappings

	vim.keymap.set("n", prefix .. mappings.new_class, ":CSharpNewClass<CR>", {
		desc = "Create C# Class",
	})
	vim.keymap.set("n", prefix .. mappings.new_interface, ":CSharpNewInterface<CR>", {
		desc = "Create C# Interface",
	})
	vim.keymap.set("n", prefix .. mappings.new_enum, ":CSharpNewEnum<CR>", {
		desc = "Create C# Enum",
	})
end

function M.get_config()
	return config
end

return M
