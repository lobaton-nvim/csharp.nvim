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
}

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", config, user_config or {})

	-- Commands for file creation (available immediately)
	vim.api.nvim_create_user_command("CSharpNewClass", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Class name: ")
		end
		require("csharp.file_creator").create_class(name)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("CSharpNewInterface", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Interface name: ")
		end
		require("csharp.file_creator").create_interface(name)
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("CSharpNewEnum", function(opts)
		local name = opts.args
		if name == "" then
			name = vim.fn.input("Enum name: ")
		end
		require("csharp.file_creator").create_enum(name)
	end, { nargs = "?" })
end

function M.get_config()
	return config
end

return M
