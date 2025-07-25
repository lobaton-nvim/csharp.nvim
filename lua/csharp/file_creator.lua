-- lua/csharp/file_creator.lua

local templates = require("csharp.templates")
local utils = require("csharp.utils")

local M = {}

function M.create_class(name)
	if not name or name == "" then
		print("Class name required")
		return
	end

	local directory, filename = M.parse_name(name)
	if not filename then
		filename = directory
		directory = nil
	end

	-- Ensure filename follows C# naming convention (PascalCase)
	filename = M.to_pascal_case(filename)

	local full_path = M.create_directory_if_needed(directory)
	local content = templates.class_template(filename, directory)
	local file_path = full_path .. filename .. ".cs"

	M.create_file(file_path, content)
end

function M.create_interface(name)
	if not name or name == "" then
		print("Interface name required")
		return
	end

	local directory, filename = M.parse_name(name)
	if not filename then
		filename = directory
		directory = nil
	end

	-- Ensure interface name follows C# naming convention (starts with I)
	if not filename:match("^I[A-Z]") then
		filename = "I" .. M.to_pascal_case(filename)
	end

	local full_path = M.create_directory_if_needed(directory)
	local content = templates.interface_template(filename, directory)
	local file_path = full_path .. filename .. ".cs"

	M.create_file(file_path, content)
end

function M.create_enum(name)
	if not name or name == "" then
		print("Enum name required")
		return
	end

	local directory, filename = M.parse_name(name)
	if not filename then
		filename = directory
		directory = nil
	end

	-- Ensure enum name follows C# naming convention (PascalCase)
	filename = M.to_pascal_case(filename)

	local full_path = M.create_directory_if_needed(directory)
	local content = templates.enum_template(filename, directory)
	local file_path = full_path .. filename .. ".cs"

	M.create_file(file_path, content)
end

function M.parse_name(name)
	-- Parse "directory.filename" pattern
	local directory, filename = name:match("^(.-)%.(.+)$")
	if directory and filename then
		return directory, filename
	else
		return name, nil
	end
end

function M.create_directory_if_needed(directory)
	local current_path = utils.get_current_working_directory()
	local full_path = current_path .. "/"

	if directory then
		-- Create directory structure
		local dir_path = full_path .. directory
		if vim.fn.isdirectory(dir_path) == 0 then
			-- Create directory recursively
			local success = vim.fn.mkdir(dir_path, "p")
			if success == 0 then
				print("Created directory: " .. directory)
			else
				print("Error creating directory: " .. directory)
			end
		end
		full_path = dir_path .. "/"
	end

	return full_path
end

function M.to_pascal_case(name)
	-- Convert to PascalCase
	if name:sub(1, 1) == "I" and #name > 1 and name:sub(2, 2):match("%u") then
		-- Already starts with I followed by uppercase, keep as is
		return name
	end

	-- Convert first character to uppercase and remove any non-alphanumeric characters except first I
	local result = name:gsub("^%l", string.upper):gsub("[^%w]", "")
	return result
end

function M.create_file(filepath, content)
	if vim.fn.filereadable(filepath) == 1 then
		print("File " .. vim.fn.fnamemodify(filepath, ":t") .. " already exists")
		return
	end

	-- Create the file
	local file = io.open(filepath, "w")
	if file then
		for _, line in ipairs(content) do
			file:write(line .. "\n")
		end
		file:close()
		print("File " .. vim.fn.fnamemodify(filepath, ":t") .. " created successfully")
		-- Open the file
		vim.cmd("edit " .. filepath)
	else
		print("Error creating file " .. filepath)
	end
end

return M
