-- lua/csharp/templates.lua

local utils = require("csharp.utils")

local M = {}

function M.get_full_namespace()
	local base_namespace = utils.get_namespace_from_csproj()
	local current_file = vim.fn.expand("%:p")
	local csproj_file = vim.fn.findfile("*.csproj", vim.fn.expand("%:p:h") .. ";")

	if csproj_file ~= "" then
		local project_dir = vim.fn.fnamemodify(csproj_file, ":p:h")
		local relative_ns = utils.get_relative_namespace(vim.fn.fnamemodify(current_file, ":p:h"), project_dir)

		if relative_ns ~= "" then
			return base_namespace .. "." .. relative_ns
		end
	end

	return base_namespace
end

function M.get_default_usings()
	local config = require("csharp").get_config()
	return config.default_usings
		or {
			"System",
			"System.Collections.Generic",
			"System.Linq",
			"System.Threading.Tasks",
		}
end

function M.class_template(name)
	local namespace = M.get_full_namespace()
	local usings = M.get_default_usings()

	local lines = {}
	for _, using in ipairs(usings) do
		table.insert(lines, "using " .. using .. ";")
	end
	table.insert(lines, "")
	table.insert(lines, "namespace " .. namespace)
	table.insert(lines, "{")
	table.insert(lines, "    public class " .. name)
	table.insert(lines, "    {")
	table.insert(lines, "        ")
	table.insert(lines, "    }")
	table.insert(lines, "}")

	return lines
end

function M.interface_template(name)
	local namespace = M.get_full_namespace()
	local usings = M.get_default_usings()

	local lines = {}
	for _, using in ipairs(usings) do
		table.insert(lines, "using " .. using .. ";")
	end
	table.insert(lines, "")
	table.insert(lines, "namespace " .. namespace)
	table.insert(lines, "{")
	table.insert(lines, "    public interface " .. name)
	table.insert(lines, "    {")
	table.insert(lines, "        ")
	table.insert(lines, "    }")
	table.insert(lines, "}")

	return lines
end

function M.enum_template(name)
	local namespace = M.get_full_namespace()
	local usings = M.get_default_usings()

	local lines = {}
	for _, using in ipairs(usings) do
		table.insert(lines, "using " .. using .. ";")
	end
	table.insert(lines, "")
	table.insert(lines, "namespace " .. namespace)
	table.insert(lines, "{")
	table.insert(lines, "    public enum " .. name)
	table.insert(lines, "    {")
	table.insert(lines, "        ")
	table.insert(lines, "    }")
	table.insert(lines, "}")

	return lines
end

return M
