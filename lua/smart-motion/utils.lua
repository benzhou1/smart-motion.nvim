--- General-purpose utilities.
local consts = require("smart-motion.consts")

local M = {}

--- Closes all diagnostic and completion floating windows.
function M.close_floating_windows()
	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		local config = vim.api.nvim_win_get_config(winid)
		if vim.tbl_contains({ "cursor", "win" }, config.relative) then
			vim.api.nvim_win_close(winid, true)
		end
	end
end

--- Waits for user to press a hint key.
---@param hints table<table, string> Target to hint mapping.
---@return table|nil Selected target or nil if cancelled.
function M.wait_for_hint_selection(hints)
	local char = vim.fn.getcharstr()

	for target, hint in pairs(hints) do
		if char == hint then
			return target
		end
	end
end

--- Executes the actual cursor movement to a target.
---@param target table The jump target (line, start_pos, end_pos).
---@param hint_position "start"|'end' Whether to land on the first or last character.
function M.jump_to_target(target, hint_position)
	local line = target.line
	local pos

	if hint_position == consts.HINT_POSITION.START then
		pos = target.start_pos
	elseif hint_position == consts.HINT_POSITION.END then
		pos = target.end_pos - 1
	else
		error("smart-motion: Invalid hint position '" .. tostring(hint_position) .. "'")
	end

	vim.api.nvim_win_set_cursor(0, { line + 1, pos })
end

return M
