-- lua/csharp/templates.lua

local utils = require("csharp.utils")

local M = {}

function M.get_full_namespace(directory)
	local current_dir = utils.get_current_working_directory()

	-- Buscar .csproj de forma más robusta
	local csproj_file = M.find_csproj_robust(current_dir)

	if csproj_file and csproj_file ~= "" then
		-- Usar el nombre del archivo .csproj como namespace base
		local base_namespace = vim.fn.fnamemodify(csproj_file, ":t:r")

		-- Construir namespace con el directorio especificado
		local namespace_parts = { base_namespace }

		-- Añadir directorio del comando si existe
		if directory then
			for part in string.gmatch(directory, "[^/\\]+") do
				table.insert(namespace_parts, part)
			end
		end

		return table.concat(namespace_parts, ".")
	else
		-- Fallback cuando no hay .csproj
		if directory then
			return "MyProject." .. directory:gsub("[/\\]", ".")
		else
			return "MyProject"
		end
	end
end

function M.find_csproj_robust(start_dir)
	-- Método más robusto: buscar recursivamente hacia arriba
	local current = start_dir

	-- Limpiar el path
	current = string.gsub(current, "\\+$", "")
	current = string.gsub(current, "/+$", "")

	-- Buscar en el directorio actual y hacia arriba
	while current and current ~= "" and current ~= "/" and current ~= "." do
		-- Intentar leer el directorio
		local ok, files = pcall(vim.fn.readdir, current)
		if ok and files then
			for _, file in ipairs(files) do
				if file:match("%.csproj$") then
					return current .. "/" .. file
				end
			end
		end

		-- Subir un nivel
		local parent = vim.fn.fnamemodify(current, ":h")
		if parent == current or parent == "" then
			break
		end
		current = parent
	end

	-- Último intento: usar findfile
	local fallback = vim.fn.findfile("*.csproj", start_dir .. ";")
	return fallback
end

function M.class_template(name, directory)
	local namespace = M.get_full_namespace(directory)

	local lines = {}
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

	local lines = {}
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

	local lines = {}
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
