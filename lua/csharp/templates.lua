-- lua/csharp/templates.lua

local utils = require("csharp.utils")

local M = {}

function M.get_full_namespace(directory)
	local current_dir = utils.get_current_working_directory()

	-- Debug: print current directory
	-- print("Current working directory: " .. current_dir)

	-- Buscar .csproj recursivamente hacia arriba desde el directorio de trabajo
	local csproj_file = vim.fn.findfile("*.csproj", current_dir .. ";")

	-- Debug: print found csproj
	-- print("Found csproj: " .. (csproj_file or "nil"))

	if csproj_file and csproj_file ~= "" then
		-- Usar el nombre del archivo .csproj como namespace base
		local base_namespace = vim.fn.fnamemodify(csproj_file, ":t:r")

		-- Debug: print base namespace
		-- print("Base namespace: " .. base_namespace)

		-- Construir namespace con el directorio especificado
		local namespace_parts = { base_namespace }

		-- Añadir directorio del comando si existe
		if directory then
			for part in string.gmatch(directory, "[^/\\]+") do
				table.insert(namespace_parts, part)
			end
		end

		local result = table.concat(namespace_parts, ".")
		-- print("Final namespace: " .. result)
		return result
	else
		-- Fallback cuando no hay .csproj
		print("No .csproj found, using fallback namespace")
		if directory then
			return "MyProject." .. directory:gsub("[/\\]", ".")
		else
			return "MyProject"
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
