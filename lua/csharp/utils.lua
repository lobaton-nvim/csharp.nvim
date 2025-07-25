-- lua/csharp/utils.lua

local M = {}

function M.get_current_working_directory()
	local current_dir = vim.fn.expand("%:p:h")
	if current_dir == "" or current_dir == "." then
		return vim.fn.getcwd()
	end
	return current_dir
end

return M
