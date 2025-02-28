local state = require("smart-motion.core.state")
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")

local M = {}

--- Fetches lines based on motion direction.
---@param bufnr integer Buffer number.
---@param cursor_line integer 0-based cursor line.
---@param direction "before_cursor"|"after_cursor"
---@return string[] List of lines to scan.
function M.get_lines_for_motion(bufnr, cursor_line, direction)
	log.debug(
		string.format("Fetching lines - bufnr: %d, cursor_line: %d, direction: %s", bufnr, cursor_line, direction)
	)

	if not vim.api.nvim_buf_is_valid(bufnr) then
		log.error("get_lines_for_motion received invalid buffer: " .. tostring(bufnr))

		return {}
	end

	local last_line = vim.api.nvim_buf_line_count(bufnr)

	if direction == consts.DIRECTION.AFTER_CURSOR then
		local max_lines = math.min(state.max_lines, last_line - cursor_line + 1)

		log.debug(string.format("Scanning after cursor - max_lines: %d (last_line: %d)", max_lines, last_line))

		return vim.api.nvim_buf_get_lines(bufnr, cursor_line, cursor_line + max_lines, false)
	elseif direction == consts.DIRECTION.BEFORE_CURSOR then
		local start_line = math.max(cursor_line - state.max_lines, 0)

		log.debug(string.format("Scanning before cursor - start_line: %d", start_line))

		return vim.api.nvim_buf_get_lines(bufnr, start_line, cursor_line + 1, false)
	end

	log.error("invalid motion direction passed: " .. tostring(direction))

	return {}
end

return M
