local function is_valid_file_buffer(buf)
	return vim.api.nvim_buf_is_loaded(buf)
		and vim.bo[buf].buftype == ''
		and vim.bo[buf].buflisted
end

local function open_corresponding_file()
	local current_buf = vim.api.nvim_get_current_buf()
	if not is_valid_file_buffer(current_buf) then
		return
	end

	local file = vim.api.nvim_buf_get_name(current_buf)
	local ext = vim.fn.fnamemodify(file, ':e')
	local base = vim.fn.fnamemodify(file, ':r')
	local alt = nil

	if ext == 'cpp' then
		alt = base .. '.h'
	elseif ext == 'h' then
		alt = base .. '.cpp'
	else
		return
	end

	if vim.fn.filereadable(alt) ~= 1 then
		return
	end

	-- Check if it's already visible
	local wins = vim.api.nvim_list_wins()
	local alt_abs = vim.fn.fnamemodify(alt, ':p')

	for _, win in ipairs(wins) do
		local b = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_name(b) == alt_abs then
			return
		end
	end

	-- Open in other window if available, else vsplit
	vim.defer_fn(function()
		local current_win = vim.api.nvim_get_current_win()
		local alt_buf = vim.fn.bufadd(alt)
		vim.fn.bufload(alt_buf)

		local wins_now = vim.api.nvim_list_wins()
		local other_win = nil

		for _, win in ipairs(wins_now) do
			if win ~= current_win then
				other_win = win
				break
			end
		end

		if other_win then
			vim.api.nvim_win_set_buf(other_win, alt_buf)
		else
			vim.cmd('vsplit ' .. alt_abs)
		end
	end, 100) -- small delay to wait for Neo-tree to finish
end

vim.api.nvim_create_autocmd('BufEnter', {
	pattern = { '*.cpp', '*.h' },
	callback = open_corresponding_file,
})
