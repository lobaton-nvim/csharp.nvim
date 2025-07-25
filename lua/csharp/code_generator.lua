-- lua/csharp/code_generator.lua

local utils = require("csharp.utils")

local M = {}

function M.generate_constructor_from_properties()
	local lines = utils.get_current_buffer_lines()
	local properties = M.get_public_properties(lines)

	if #properties == 0 then
		print("No public properties found")
		return
	end

	local class_info = M.find_class_info(lines)
	if not class_info then
		print("Class not found")
		return
	end

	local constructor_lines = M.build_constructor_lines(class_info.name, properties, false)
	local insert_at = class_info.body_start
	local new_lines = utils.insert_lines(lines, insert_at, constructor_lines)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

function M.generate_body_expression_constructor()
	local lines = utils.get_current_buffer_lines()
	local properties = M.get_public_properties(lines)

	if #properties == 0 then
		print("No public properties found")
		return
	end

	local class_info = M.find_class_info(lines)
	if not class_info then
		print("Class not found")
		return
	end

	local constructor_lines = M.build_constructor_lines(class_info.name, properties, true)
	local insert_at = class_info.body_start
	local new_lines = utils.insert_lines(lines, insert_at, constructor_lines)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

function M.generate_override_equals()
	local lines = utils.get_current_buffer_lines()
	local class_info = M.find_class_info(lines)

	if not class_info then
		print("Class not found")
		return
	end

	local override_lines = {
		"",
		"    public override bool Equals(object obj)",
		"    {",
		"        if (obj is " .. class_info.name .. " other)",
		"        {",
		"            return Equals(other);",
		"        }",
		"        return false;",
		"    }",
		"",
		"    public bool Equals(" .. class_info.name .. " other)",
		"    {",
		"        if (other is null) return false;",
		"        if (ReferenceEquals(this, other)) return true;",
		"        return true;",
		"    }",
		"",
		"    public override int GetHashCode()",
		"    {",
		"        return HashCode.Combine();",
		"    }",
	}

	local insert_at = class_info.body_end - 1
	local new_lines = utils.insert_lines(lines, insert_at, override_lines)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

function M.generate_to_string()
	local lines = utils.get_current_buffer_lines()
	local class_info = M.find_class_info(lines)

	if not class_info then
		print("Class not found")
		return
	end

	local tostring_lines = {
		"",
		"    public override string ToString()",
		"    {",
		"        return nameof(" .. class_info.name .. ");",
		"    }",
	}

	local insert_at = class_info.body_end - 1
	local new_lines = utils.insert_lines(lines, insert_at, tostring_lines)

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

function M.add_using()
	local namespace = vim.fn.input("Namespace: ")
	if namespace == "" then
		return
	end

	local lines = utils.get_current_buffer_lines()
	local using_line = "using " .. namespace .. ";"

	-- Find where to insert the using (after existing usings)
	local insert_at = M.find_using_insert_position(lines)

	local new_lines = utils.insert_lines(lines, insert_at, { using_line })

	vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
end

-- Helper functions
function M.get_public_properties(lines)
	local properties = {}
	for i, line in ipairs(lines) do
		-- Match public auto-properties: public type Name { get; set; }
		local access, type, name = line:match("%s*(%w+)%s+(%w+)%s+(%w+)%s*{[^}]*};")
		if access and name and access == "public" then
			table.insert(properties, {
				line = line,
				index = i,
				access = access,
				type = type,
				name = name,
			})
		end
	end
	return properties
end

function M.find_class_info(lines)
	for i, line in ipairs(lines) do
		if line:match("public%s+class") or line:match("internal%s+class") then
			local class_name = line:match("class%s+(%w+)")
			return {
				name = class_name,
				line_index = i,
				body_start = M.find_class_body_start(lines, i),
				body_end = M.find_class_end(lines, i),
			}
		end
	end
	return nil
end

function M.find_class_body_start(lines, start_index)
	for i = start_index, #lines do
		if lines[i]:match("{") then
			return i + 1
		end
	end
	return start_index + 1
end

function M.find_class_end(lines, start_index)
	local brace_count = 0
	for i = start_index, #lines do
		local line = lines[i]
		for char in line:gmatch(".") do
			if char == "{" then
				brace_count = brace_count + 1
			elseif char == "}" then
				brace_count = brace_count - 1
				if brace_count == 0 then
					return i + 1
				end
			end
		end
	end
	return #lines
end

function M.find_using_insert_position(lines)
	local last_using_index = 0
	local first_non_blank_index = #lines + 1

	for i, line in ipairs(lines) do
		if line:match("^using%s+") then
			last_using_index = i
		elseif line:match("%S") and first_non_blank_index > #lines then
			first_non_blank_index = i
		end
	end

	if last_using_index > 0 then
		return last_using_index
	elseif first_non_blank_index <= #lines then
		return first_non_blank_index - 1
	else
		return 1
	end
end

function M.build_constructor_lines(class_name, properties, is_body_expression)
	if is_body_expression then
		return M.build_body_expression_constructor(class_name, properties)
	else
		return M.build_regular_constructor(class_name, properties)
	end
end

function M.build_regular_constructor(class_name, properties)
	local lines = {
		"",
		"    public " .. class_name .. "(",
	}

	local param_list = {}
	local assign_list = {}

	for _, prop in ipairs(properties) do
		table.insert(param_list, "        " .. prop.type .. " " .. prop.name:sub(1, 1):lower() .. prop.name:sub(2))
		table.insert(
			assign_list,
			"            " .. prop.name .. " = " .. prop.name:sub(1, 1):lower() .. prop.name:sub(2) .. ";"
		)
	end

	local params = table.concat(param_list, ",\n")
	local assigns = table.concat(assign_list, "\n")

	table.insert(lines, params)
	table.insert(lines, "        )")
	table.insert(lines, "    {")
	table.insert(lines, assigns)
	table.insert(lines, "    }")

	return lines
end

function M.build_body_expression_constructor(class_name, properties)
	local param_list = {}
	local assign_list = {}

	for _, prop in ipairs(properties) do
		table.insert(param_list, prop.type .. " " .. prop.name:sub(1, 1):lower() .. prop.name:sub(2))
		table.insert(assign_list, prop.name .. " = " .. prop.name:sub(1, 1):lower() .. prop.name:sub(2))
	end

	local params = table.concat(param_list, ", ")
	local assigns = table.concat(assign_list, "; ")

	return {
		"",
		"    public " .. class_name .. "(" .. params .. ") => " .. assigns .. ";",
	}
end

return M
