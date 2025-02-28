local consts = require("smart-motion.consts")
--- Handles virtual text and hint highlighting.

local M = {}

--- Clears all SmartMotion highlights in the buffer.
---@param bufnr integer
function M.clear(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, consts.ns_id, 0, -1)
end

--- Applies a single-character hint.
---@param bufnr integer
---@param line integer 0-based line number.
---@param col integer 0-based column number.
---@param label string The single-character label.
function M.apply_single_hint_label(bufnr, line, col, label)
	vim.api.nvim_buf_set_extmark(bufnr, consts.ns_id, line, col, {
		virt_text = { { label, "SmartMotionHint" } },
		virt_text_pos = "overlay",
		hl_mode = "combine",
	})
end

--- Applies a double-character hint.
---@param bufnr integer
---@param line integer 0-based line number.
---@param col integer 0-based column number.
---@param label string The double-character label.
function M.apply_double_hint_label(bufnr, line, col, label)
	local first_char, second_char = label:sub(1, 1), label:sub(2, 2)

	vim.api.nvim_buf_set_extmark(bufnr, consts.ns_id, line, col, {
		virt_text = {
			{ first_char, "SmartMotionFirstChar" },
			{ second_char, "SmartMotionSecondChar" },
		},
		virt_text_pos = "overlay",
		hl_mode = "combine",
	})
end

--- Applies hints to all jump targets.
---@param bufnr integer
---@param hints table<table, string> Target to hint mapping.
---@param hint_position "start"|"end" Whether to position the hint at the start or end of the word.
function M.apply_hint_labels(bufnr, hints, hint_position)
	for target, label in pairs(hints) do
		local pos = (hint_position == consts.HINT_POSITION.START) and target.start_pos or (target.end_pos - 1)

		if #label == 1 then
			M.apply_single_hint_label(bufnr, target.line, pos, label)
		elseif #label == 2 then
			M.apply_double_hint_label(bufnr, target.line, pos, label)
		else
			vim.notify("smart-motion: Unexpected hint length for '" .. label .. "'", vim.log.levels.ERROR)
		end
	end
end

--- Filters hints to only show those matching the active prefix.
---@param bufnr integer
---@param active_prefix string
---@param hints table<table, string>
function M.filter_double_hints(bufnr, active_prefix, hints)
	M.clear(bufnr)

	for target, label in pairs(hints) do
		if label:sub(1, 1) == active_prefix then
			M.apply_double_hint(bufnr, target.line, target.start_pos, label)
		end
	end
end

return M
