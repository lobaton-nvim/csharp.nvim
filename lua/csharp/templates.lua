-- lua/csharp/templates.lua

local utils = require("csharp.utils")

local M = {}

function M.get_full_namespace(directory)
	local base_namespace = utils.get_namespace_from_csproj()
	local current_dir = utils.get_current_working_directory()
	local csproj_file = vim.fn.findfile("*.csproj", current_dir .. ";")

	if csproj_file ~= "" then
		local project_dir = vim.fn.fnamemodify(csproj_file, ":p:h")
		local relative_ns = utils.get_relative_namespace(current_dir, project_dir, directory)

		if relative_ns ~= "" then
			return base_namespace .. "." .. relative_ns
		else
			return base_namespace
		end
	else
		-- If no .csproj found, use fallback with directory structure
		if directory then
			return base_namespace .. "." .. directory:gsub("/", ".")
		else
			return base_namespace
		end
	end
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

function M.class_template(name, directory)
	local namespace = M.get_full_namespace(directory)
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

function M.interface_template(name, directory)
	local namespace = M.get_full_namespace(directory)
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

function M.enum_template(name, directory)
	local namespace = M.get_full_namespace(directory)
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
