local get_floating_term = require("keymaps").get_floating_term

--for auto reload file when ai makes an edit
vim.api.nvim_create_autocmd({ "TermLeave" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "help",
	callback = function()
		vim.cmd("only")
		vim.bo.buflisted = true
	end,
})

require("nvim-treesitter.install").setup_auto_install()

--auto spawn terminal to avoid ~ map race condition
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		get_floating_term("pi"):spawn()
	end,
})

--new java classes get their package declaration from the folder under src/<source>/java
--mirrors IntelliJ's "new class" behaviour
vim.api.nvim_create_autocmd("BufNewFile", {
	pattern = "*.java",
	callback = function(args)
		local rel = vim.fs.dirname(args.file):match("/src/%a+/java/(.+)$")
		local pkg = rel and rel:gsub("/", ".")
		local class_name = vim.fn.fnamemodify(args.file, ":t:r")
		local lines = pkg and { "package " .. pkg .. ";", "" } or {}
		vim.list_extend(lines, { "public class " .. class_name .. " {", "\t", "}" })
		table.insert(lines, "")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
		vim.api.nvim_win_set_cursor(0, { pkg and 4 or 3, 1 })
		vim.bo[args.buf].modified = false
	end,
})
