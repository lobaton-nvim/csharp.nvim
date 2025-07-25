-- lua/csharp/utils.lua

local M = {}

function M.get_namespace_from_csproj()
	local current_dir = vim.fn.expand("%:p:h")
	local csproj_file = vim.fn.findfile("*.csproj", current_dir .. ";")

	if csproj_file ~= "" then
		-- Read the file and extract the namespace
		local content = vim.fn.readfile(csproj_file)
		for _, line in ipairs(content) do
			local root_namespace = line:match("<RootNamespace>(.-)</RootNamespace>")
			if root_namespace then
				return root_namespace
			end
		end

		-- Fallback: use the project directory name
		local project_dir = vim.fn.fnamemodify(csproj_file, ":h")
		return vim.fn.fnamemodify(project_dir, ":t")
	end

	return "MyNamespace"
end

function M.get_relative_namespace(current_path, base_path)
	local rel_path = string.gsub(current_path, base_path .. "/", "")
	local namespace_parts = {}

	for part in string.gmatch(rel_path, "[^/]+") do
		if part ~= "" and not part:match("%.cs$") then
			table.insert(namespace_parts, part)
		end
	end

	return table.concat(namespace_parts, ".")
end

return M
