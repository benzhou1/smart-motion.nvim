--- General-purpose utilities.
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")
local context = require("smart-motion.core.context")
local state = require("smart-motion.core.state")
local config = require("smart-motion.config")
local highlight = require("smart-motion.core.highlight")
local spam = require("smart-motion.core.spam")

local M = {}

--- Closes all diagnostic and completion floating windows.
function M.close_floating_windows()
	log.debug("Closing floating windows (diagnostics & completion)")

	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		local ok, win_config = pcall(vim.api.nvim_win_get_config, winid)

		if not ok then
			log.warn("Failed to get window config for winid: " .. tostring(winid))

			goto continue
		end

		if vim.tbl_contains({ "cursor", "win" }, win_config.relative) then
			local success, err = pcall(vim.api.nvim_win_close, winid, true)

			if not success then
				log.warn(string.format("Failed to close floating window %d: %s", winid, err))
			end
		end

		::continue::
	end

	log.debug("Floating window cleanup complete")
end

--- Waits for the user to press a hint key and returns the associated jump target.
---@param ctx table  Motion context (contains bufnr, etc.).
---@param cfg table  Validated configuration (not used here but part of the signature).
---@param motion_state table  Current motion state (not used here but part of the signature).
---@return table|nil Selected target if a matching hint is pressed; nil if cancelled.
function M.wait_for_hint_selection(ctx, cfg, motion_state)
	log.debug("Waiting for user hint selection")

	if type(motion_state.assigned_hint_labels) ~= "table" or vim.tbl_isempty(motion_state.assigned_hint_labels) then
		log.error("wait_for_hint_selection called with invalid or empty motion_state.assigned_hint_labels table")

		return nil
	end

	local char = vim.fn.getcharstr()

	if char == "" then
		log.warn("User pressed nothing - selection cancelled")

		return nil
	end

	for target, hint in pairs(motion_state.assigned_hint_labels) do
		if char == hint then
			log.debug("User selected hint: " .. hint)

			return target
		end
	end

	log.warn("No matching hint found for input: " .. char)

	return nil
end

--- Executes the actual cursor movement to the given target.
---@param ctx table  Motion context (must include bufnr).
---@param cfg table  Validated configuration (not used here but part of the signature).
---@param motion_state table  Current motion state (not used here but part of the signature).
function M.jump_to_target(ctx, cfg, motion_state)
	log.debug(
		string.format(
			"Executing jump to target - line: %d, start_pos: %d, end_pos: %d, hint_position: %s",
			motion_state.selected_jump_target.line,
			motion_state.selected_jump_target.start_pos,
			motion_state.selected_jump_target.end_pos,
			motion_state.hint_position
		)
	)

	if
		type(motion_state.selected_jump_target) ~= "table"
		or not motion_state.selected_jump_target.line
		or not motion_state.selected_jump_target.start_pos
		or not motion_state.selected_jump_target.end_pos
	then
		log.error("jump_to_target called with invalid target table: " .. vim.inspect(motion_state.selected_jump_target))

		return
	end

	local pos

	if motion_state.hint_position == consts.HINT_POSITION.START then
		pos = motion_state.selected_jump_target.start_pos
	elseif motion_state.hint_position == consts.HINT_POSITION.END then
		pos = motion_state.selected_jump_target.end_pos - 1
	else
		log.error("Invalid motion_state.hint_position provided: " .. tostring(motion_state.hint_position))

		return
	end

	local success, err = pcall(vim.api.nvim_win_set_cursor, 0, { motion_state.selected_jump_target.line + 1, pos })

	if not success then
		log.error("Failed to move cursor: " .. tostring(err))
	else
		log.debug(string.format("Cursor moved to line %d, col %d", motion_state.selected_jump_target.line + 1, pos))
	end
end

--- Prepares the motion by gathering context, config, and initializing state.
---@param direction "before_cursor"|"after_cursor"
---@param hint_position "start"|"end"
---@param target_type "word"|"char"|"line"
---@return table|nil ctx, table|nil cfg, table|nil motion_state - Returns nils if validation fails.
function M.prepare_motion(direction, hint_position, target_type)
	local ctx = context.get()

	if not vim.tbl_contains({ "before_cursor", "after_cursor" }, direction) then
		log.error("prepare_motion: Invalid direction provided: " .. tostring(direction))

		return nil, nil, nil
	end

	if not vim.tbl_contains({ "start", "end" }, hint_position) then
		log.error("prepare_motion: Invalid hint_position provided: " .. tostring(hint_position))
		return nil, nil, nil
	end

	local cfg = config.validated

	if not cfg or type(cfg) ~= "table" then
		log.error("prepare_motion: Config is missing or invalid")

		return nil, nil, nil
	end

	if type(cfg.keys) ~= "table" or #cfg.keys == 0 then
		log.error("prepare_motion: Config `keys` is missing or improperly formatted")
		return nil, nil, nil
	end

	local motion_state = state.create_motion_state(direction, hint_position, target_type)

	return ctx, cfg, motion_state
end

--- Resets the motion by clearing highlights, closing floating windows,
--- clearing spam tracking, and resetting the dynamic state.
---@param ctx table Motion context (must include bufnr).
---@param cfg table Validated config.
---@param motion_state table Current motion state (will be mutated).
function M.reset_motion(ctx, cfg, motion_state)
	-- Clear any virtual text and extmarks.
	highlight.clear(ctx, cfg, motion_state)

	-- Close floating windows (if you have a function for that).
	M.close_floating_windows()

	-- Reset spam tracker.
	spam.reset() -- Assuming you add a reset function in spam module.

	-- Reset dynamic parts of the motion state.
	state.reset(motion_state)
end

return M
