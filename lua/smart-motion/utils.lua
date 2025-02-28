--- General-purpose utilities.
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")
local context = require("smart-motion.core.context")
local state = require("smart-motion.core.state")
local config = require("smart-motion.config")

local M = {}

--- Closes all diagnostic and completion floating windows.
function M.close_floating_windows()
	log.debug("Closing floating windows (diagnostics & completion)")

	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		local ok, config = pcall(vim.api.nvim_win_get_config, winid)

		if not ok then
			log.warn("Failed to get window config for winid: " .. tostring(winid))

			goto continue
		end

		if vim.tbl_contains({ "cursor", "win" }, config.relative) then
			local success, err = pcall(vim.api.nvim_win_close, winid, true)

			if not success then
				log.warn(string.format("Failed to close floating window %d: %s", winid, err))
			end
		end

		::continue::
	end

	log.debug("Floating window cleanup complete")
end

--- Waits for user to press a hint key.
---@param hints table<table, string> Target to hint mapping.
---@return table|nil Selected target or nil if cancelled.
function M.wait_for_hint_selection(hints)
	log.debug("Waiting for user hint selection")

	if type(hints) ~= "table" or vim.tbl_isempty(hints) then
		log.error("wait_for_hint_selection called with invalid or empty hints table")

		return nil
	end

	local char = vim.fn.getcharstr()

	if char == "" then
		log.warn("User pressed nothing - selection cancelled")

		return nil
	end

	for target, hint in pairs(hints) do
		if char == hint then
			log.debug("User selected hint: " .. hint)

			return target
		end
	end

	log.warn("No matching hint found for input: " .. char)

	return nil
end

--- Executes the actual cursor movement to a target.
---@param target table The jump target (line, start_pos, end_pos).
---@param hint_position "start"|'end' Whether to land on the first or last character.
function M.jump_to_target(target, hint_position)
	log.debug(
		string.format(
			"Executing jump to target - line: %d, start_pos: %d, end_pos: %d, hint_position: %s",
			target.line,
			target.start_pos,
			target.end_pos,
			hint_position
		)
	)

	if type(target) ~= "table" or not target.line or not target.start_pos or not target.end_pos then
		log.error("jump_to_target called with invalid target table: " .. vim.inspect(target))

		return
	end

	local pos

	if hint_position == consts.HINT_POSITION.START then
		pos = target.start_pos
	elseif hint_position == consts.HINT_POSITION.END then
		pos = target.end_pos - 1
	else
		log.error("Invalid hint_position provided: " .. tostring(hint_position))

		return
	end

	local success, err = pcall(vim.api.nvim_win_set_cursor, 0, { target.line + 1, pos })

	if not success then
		log.error("Failed to move cursor: " .. tostring(err))
	else
		log.debug(string.format("Cursor moved to line %d, col %d", target.line + 1, pos))
	end
end

--- Prepares the motion by gathering context, config, and initializing state.
---@param direction "before_cursor"|"after_cursor"
---@param hint_position "start"|"end"
---@return table|nil ctx, table|nil cfg, table|nil motion_state - Returns nils if validation fails.
function M.prepare_motion(direction, hint_position)
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

	state.set_motion_intent(direction, hint_position)

	return ctx, cfg, state.get()
end

return M
