-- lua/csharp/utils.lua

local M = {}

function M.get_current_working_directory()
	-- Siempre usar el directorio de trabajo actual, no el del buffer
	return vim.fn.getcwd()
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
