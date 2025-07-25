if vim.g.loaded_csharp == 1 then
	return
end

vim.g.loaded_csharp = 1

-- Setup autocommands for lazy loading
vim.api.nvim_create_augroup("CSharp", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "CSharp",
	pattern = "cs",
	callback = function()
		-- Commands are already created in init.lua setup
	end,
})
