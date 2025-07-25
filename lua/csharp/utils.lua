-- lua/csharp/utils.lua

local M = {}

function M.get_current_working_directory()
	local current_dir = vim.fn.expand("%:p:h")
	if current_dir == "" or current_dir == "." then
		return vim.fn.getcwd()
	end
	return current_dir
end

function M.get_current_buffer_lines()
	return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

function M.insert_lines(lines, row, new_lines)
	local before = vim.list_slice(lines, 1, row)
	local after = vim.list_slice(lines, row + 1)
	local combined = vim.list_extend(before, new_lines)
	combined = vim.list_extend(combined, after)
	return combined
end

return M
