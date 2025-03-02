--- Module for tracking motion state.
local log = require("smart-motion.core.log")
local consts = require("smart-motion.consts")

local M = {}

M.static = {}

--- Initializes static key-based state once when config is verified.
---@param cfg table Full user config
function M.init_motion_state(cfg)
	if type(cfg.keys) ~= "table" or #cfg.keys == 0 then
		log.error("init_motion_state received invalid keys: expected non-empty table")

		return
	end

	local keys_squared = #cfg.keys * #cfg.keys

	M.static = {
		total_keys = #cfg.keys,
		max_labels = keys_squared,
		max_lines = keys_squared,
	}

	log.debug(
		string.format(
			"Static state initialized - total_keys: %d, max_labels: %d, max_lines: %d",
			M.static.total_keys,
			M.static.max_lines,
			M.static.max_labels
		)
	)
end

--- Creates a fresh motion state (per motion)
---@param direction string Motion direction ("before_cursor" or "after_cursor")
---@param hint_position string Hint position ("start" or "end")
---@param target_type string "word", "char", "line"
---@return table motion_state
function M.create_motion_state(direction, hint_position, target_type)
	return {
		total_keys = M.static.total_keys,
		max_lines = M.static.max_lines,
		max_labels = M.static.max_labels,

		-- Motion Intent
		direction = direction,
		hint_position = hint_position,
		target_type = target_type,

		-- Motion-specific data (starts empty)
		lines = {},
		jump_target_count = 0,
		jump_targets = {},
		hint_labels = {},
		assigned_hint_labels = {},

		-- Label calculations
		single_label_count = 0,
		extra_labels_needed = 0,
		sacrificed_keys_count = 0,

		-- Selection
		selection_mode = consts.SELECTION_MODE.FIRST,
		selection_first_char = nil,
		selected_jump_target = nil,
	}
end

--- Finalizes the motion state after target collection.
---@param motion_state table The current motion state (mutable)
function M.finalize_motion_state(motion_state)
	if motion_state.total_keys == 0 then
		log.error("finalize_motion_state called before static state was initialized")
		return
	end

	local jump_target_count = #motion_state.jump_targets
	motion_state.jump_target_count = jump_target_count

	if type(jump_target_count) ~= "number" or jump_target_count < 0 then
		log.error("finalize_motion_state received invalid jump_target_count: " .. tostring(jump_target_count))
		return
	end

	if jump_target_count <= M.static.total_keys then
		-- We only need singles
		motion_state.single_label_count = jump_target_count
		motion_state.extra_labels_needed = 0
		motion_state.sacrificed_keys_count = 0
	else
		-- We need doubles
		motion_state.extra_labels_needed = jump_target_count - motion_state.total_keys
		motion_state.sacrificed_keys_count = math.ceil(math.sqrt(motion_state.extra_labels_needed))
		motion_state.single_label_count = motion_state.total_keys - motion_state.sacrificed_keys_count
	end

	log.debug(
		string.format(
			"Motion state finalized - jump_targets: %d, singles: %d, extra_needed: %d, sacrificed_keys: %d",
			motion_state.jump_target_count,
			motion_state.single_label_count,
			motion_state.extra_labels_needed,
			motion_state.sacrificed_keys_count
		)
	)
end

function M.reset(motion_state)
	motion_state.single_label_count = 0
	motion_state.extra_labels_needed = 0
	motion_state.sacrificed_keys_count = 0

	motion_state.lines = {}
	motion_state.jump_target_count = 0
	motion_state.jump_targets = {}
	motion_state.hint_labels = {}
	motion_state.assigned_hint_labels = {}

	motion_state.selection_mode = consts.SELECTION_MODE.FIRST
	motion_state.selection_first_char = nil
	motion_state.selected_jump_target = nil
end

return M
