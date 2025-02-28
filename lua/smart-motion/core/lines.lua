local state = require("smart-motion.core.state")
local consts = require("smart-motion.consts")

local M = {}

--- Fetches lines based on motion direction.
---@param bufnr integer Buffer number.
---@param cursor_line integer 0-based cursor line.
---@param direction "before"|"after"
---@return string[] List of lines to scan.
function M.get_lines_for_motion(bufnr, cursor_line, direction)
	local last_line = vim.api.nvim_buf_line_count(bufnr)

	if direction == consts.DIRECTION.AFTER then
		local max_lines = math.min(state.max_lines, last_line - cursor_line + 1)

		return vim.api.nvim_buf_get_lines(bufnr, cursor_line, cursor_line + max_lines, false)
	elseif direction == consts.DIRECTION.BEFORE then
		local start_line = math.max(cursor_line - state.max_lines, 0)

		return vim.api.nvim_buf_get_lines(bufnr, start_line, cursor_line + 1, false)
	end

	error("Invalid motion direction: " .. tostring(direction))
end

return M
