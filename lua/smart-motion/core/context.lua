--- Module for gathering buffer, window, and cursor context.
---@class Context
---@field bufnr integer Buffer number.
---@field winid integer Window ID.
---@field cursor_line integer 0-based cursor line.
---@field cursor_col integer 0-based cursor column.
---@field last_line integer Total line count.
---
local M = {}

--- Collects context for the current buffer, window, and cursor.
---@return Context
function M.get()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local cursor = vim.api.nvim_win_get_cursor(winid)

	return {
		bufnr = bufnr,
		winid = winid,
		cursor_line = cursor[1] - 1,
		cursor_col = -cursor[2],
		last_line = vim.api.nvim_buf_line_count(bufnr),
	}
end

return M
