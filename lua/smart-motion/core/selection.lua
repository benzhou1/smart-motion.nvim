local log = require("smart-motion.core.log")
local highlight = require("smart-motion.core.highlight")
local consts = require("smart-motion.consts")

local M = {}

--- Waits for the user to press a hint key and handles both single and double character hints.
---@param ctx table Motion context (bufnr, etc.)
---@param cfg table Validated configuration
---@param motion_state table Current motion state (holds assigned hints)
function M.wait_for_hint_selection(ctx, cfg, motion_state)
	log.debug("Waiting for user hint selection (mode: " .. tostring(motion_state.selection_mode) .. ")")

	if type(motion_state.assigned_hint_labels) ~= "table" or vim.tbl_isempty(motion_state.assigned_hint_labels) then
		log.error("wait_for_hint_selection called with invalid or empty assigned_hint_labels")
		return
	end

	local char = vim.fn.getcharstr()

	if char == "" then
		log.debug("User pressed nothing - selection cancelled")
		return
	end

	if motion_state.selection_mode == consts.SELECTION_MODE.FIRST then
		-- Check if it's a single-char match
		for target, hint in pairs(motion_state.assigned_hint_labels) do
			if char == hint then
				log.debug("User selected single-char hint: " .. hint)

				motion_state.selected_jump_target = target

				return
			end
		end

		-- Check if it's the first character of any double-char hint
		local has_double_char_hints = false

		for _, hint in pairs(motion_state.assigned_hint_labels) do
			if hint:sub(1, 1) == char and #hint == 2 then
				has_double_char_hints = true
				break
			end
		end

		if has_double_char_hints then
			-- Enter second character selection phase
			motion_state.selection_mode = consts.SELECTION_MODE.SECOND
			motion_state.selection_first_char = char

			-- Filter and update highlights to show only matching second chars
			highlight.filter_double_hints(ctx, cfg, motion_state, char, motion_state.assigned_hint_labels)

			log.debug("Entering double-char mode after selecting first char: " .. char)

			-- Immediately recurse to handle the second char (simpler for caller)
			return M.wait_for_hint_selection(ctx, cfg, motion_state)
		else
			log.debug("No matching single or double-char hint found for input: " .. char)

			return
		end
	elseif motion_state.selection_mode == consts.SELECTION_MODE.SECOND then
		local first_char = motion_state.selection_first_char
		local full_hint = first_char .. char

		-- Find full double-char match
		for target, hint in pairs(motion_state.assigned_hint_labels) do
			if hint == full_hint then
				log.debug("User completed double-char selection: " .. full_hint)

				motion_state.selected_jump_target = target

				return
			end
		end

		log.debug("No matching double-char hint found for input: " .. full_hint)

		return
	end

	log.error("Unexpected selection state mode: " .. tostring(motion_state.selection_mode))
end

return M
