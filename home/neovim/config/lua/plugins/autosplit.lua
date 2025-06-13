local function open_matching_in_split()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_tabpage_list_wins(0)

	if #wins < 2 then
		-- Only one window exists; create a vsplit
		vim.cmd('vsplit')
	end

	local other_win = nil
	for _, win in ipairs(wins) do
		if win ~= current_win then
			other_win = win
			break
		end
	end

	local ext = vim.fn.expand('%:e') -- file extension
	local base = vim.fn.expand('%:r') -- full path without extension
	local alt = nil

	if ext == 'cpp' then
		alt = base .. '.h'
	elseif ext == 'h' then
		alt = base .. '.cpp'
	end

	if alt and vim.fn.filereadable(alt) == 1 and other_win then
		vim.api.nvim_win_set_buf(other_win, vim.fn.bufadd(alt))
		vim.fn.bufload(alt)
	end
end

-- Auto-run when you open a cpp/h file
vim.api.nvim_create_autocmd('BufReadPost', {
	pattern = { '*.cpp', '*.h' },
	callback = open_matching_in_split,
})
