local local_cfg = {}
local path = vim.fn.getcwd() .. '/.cmakelocal.lua'
if vim.fn.filereadable(path) == 1 then
	local_cfg = dofile(path)
end

require('cmake-tools').setup(vim.tbl_deep_extend('force', {
	-- global defaults
	cmake_build_directory = function()
		return 'build/${variant:buildType}'
	end,
}, local_cfg))
