-- lua/csharp/templates.lua

local utils = require("csharp.utils")

local M = {}

function M.get_full_namespace(directory)
	local current_dir = utils.get_current_working_directory()

	-- Buscar .csproj recursivamente hacia arriba desde el directorio actual
	local csproj_file = M.find_csproj_upwards(current_dir)

	if csproj_file ~= "" then
		-- Usar el nombre del archivo .csproj como namespace base
		local base_namespace = vim.fn.fnamemodify(csproj_file, ":t:r") -- nombre sin extensión
		local project_dir = vim.fn.fnamemodify(csproj_file, ":p:h")

		-- Calcular ruta relativa desde el directorio del proyecto
		local relative_path = string.gsub(current_dir, "^" .. vim.pesc(project_dir), "")
		relative_path = string.gsub(relative_path, "^/", "")
		relative_path = string.gsub(relative_path, "/$", "")

		local namespace_parts = {}
		table.insert(namespace_parts, base_namespace)

		-- Agregar partes del path relativo
		if relative_path ~= "" and relative_path ~= "." then
			for part in string.gmatch(relative_path, "[^/]+") do
				if part ~= "" and not part:match("%.cs$") and part ~= "." then
					table.insert(namespace_parts, part)
				end
			end
		end

		-- Agregar directorio especificado
		if directory then
			for part in string.gmatch(directory, "[^/]+") do
				if part ~= "" then
					table.insert(namespace_parts, part)
				end
			end
		end

		return table.concat(namespace_parts, ".")
	else
		-- Fallback cuando no hay .csproj
		local fallback_namespace = "MyProject"
		if directory then
			return fallback_namespace .. "." .. directory:gsub("/", ".")
		else
			return fallback_namespace
		end
	end
end

function M.find_csproj_upwards(start_dir)
	-- Buscar .csproj recursivamente hacia arriba
	return vim.fn.findfile("*.csproj", start_dir .. ";")
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
