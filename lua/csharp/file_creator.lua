-- lua/csharp/file_creator.lua

local templates = require("csharp.templates")

local M = {}

function M.create_class(name)
	if not name or name == "" then
		print("Class name required")
		return
	end

	local content = templates.class_template(name)
	local filename = name .. ".cs"

	M.create_file(filename, content)
end

function M.create_interface(name)
	if not name or name == "" then
		print("Interface name required")
		return
	end

	local content = templates.interface_template(name)
	local filename = name .. ".cs"

	M.create_file(filename, content)
end

function M.create_enum(name)
	if not name or name == "" then
		print("Enum name required")
		return
	end

	local content = templates.enum_template(name)
	local filename = name .. ".cs"

	M.create_file(filename, content)
end

function M.create_file(filename, content)
	local full_path = vim.fn.expand("%:p:h") .. "/" .. filename

	if vim.fn.filereadable(full_path) == 1 then
		print("File " .. filename .. " already exists")
		return
	end

	-- Create the file
	local file = io.open(full_path, "w")
	if file then
		for _, line in ipairs(content) do
			file:write(line .. "\n")
		end
		file:close()
		print("File " .. filename .. " created successfully")
		-- Open the file
		vim.cmd("edit " .. full_path)
	else
		print("Error creating file " .. filename)
	end
end

return M
