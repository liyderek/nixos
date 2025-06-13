local function open_matching_in_other_split()
	-- Only act on regular file buffers (ignore Neo-tree and special buffers)
	if vim.bo.buftype ~= '' or not vim.bo.buflisted then
		return
	end

	local ext = vim.fn.expand('%:e')
	local base = vim.fn.expand('%:r')
	local alt

	if ext == 'cpp' then
		alt = base .. '.h'
	elseif ext == 'h' then
		alt = base .. '.cpp'
	else
		return
	end

	-- Check if the alt file exists
	if vim.fn.filereadable(alt) ~= 1 then
		return
	end

	local current_win = vim.api.nvim_get_current_win()
	local wins = vim.api.nvim_tabpage_list_wins(0)

	-- Check if the file is already visible in another window
	for _, win in ipairs(wins) do
		if win ~= current_win then
			local buf = vim.api.nvim_win_get_buf(win)
			local name = vim.api.nvim_buf_get_name(buf)
			if name == vim.fn.fnamemodify(alt, ':p') then
				return -- already open, don't do anything
			end
		end
	end

	-- If there's already another window, reuse it
	local target_win = nil
	for _, win in ipairs(wins) do
		if win ~= current_win then
			target_win = win
			break
		end
	end

	if target_win then
		local alt_buf = vim.fn.bufadd(alt)
		vim.fn.bufload(alt_buf)
		vim.api.nvim_win_set_buf(target_win, alt_buf)
	else
		-- No other window, split and open
		vim.cmd('vsplit ' .. alt)
	end
end

vim.api.nvim_create_autocmd('BufEnter', {
	pattern = { '*.cpp', '*.h' },
	callback = open_matching_in_other_split,
})
