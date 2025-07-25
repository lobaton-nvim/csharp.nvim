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

	-- File creation commands
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

	-- Code generation commands
	vim.api.nvim_create_user_command("CSharpGenConstructor", function()
		require("csharp.code_generator").generate_constructor_from_properties()
	end, {})

	vim.api.nvim_create_user_command("CSharpGenBodyConstructor", function()
		require("csharp.code_generator").generate_body_expression_constructor()
	end, {})

	vim.api.nvim_create_user_command("CSharpAddUsing", function()
		require("csharp.code_generator").add_using()
	end, {})

	vim.api.nvim_create_user_command("CSharpGenOverrideEquals", function()
		require("csharp.code_generator").generate_override_equals()
	end, {})

	vim.api.nvim_create_user_command("CSharpGenToString", function()
		require("csharp.code_generator").generate_to_string()
	end, {})
end

function M.get_config()
	return config
end

return M
