--- Module for tracking motion state.
local log = require("smart-motion.core.log")
local consts = require("smart-motion.consts")

local HINT_POSITION = consts.HINT_POSITION
local SELECTION_MODE = consts.SELECTION_MODE

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
		keys = cfg.keys,
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
---@return SmartMotionMotionState
function M.create_motion_state()
	---@type SmartMotionMotionState
	return {
		total_keys = M.static.total_keys,
		max_lines = M.static.max_lines,
		max_labels = M.static.max_labels,
		ignore_whitespace = true,
		hint_position = HINT_POSITION.START,

		-- Motion Intent
		target_type = target_type,

		-- Motion-specific data (starts empty)
		jump_target_count = 0,
		jump_targets = {},
		hint_labels = {},
		assigned_hint_labels = {},

		-- Label calculations
		single_label_count = 0,
		double_label_count = 0,
		sacrificed_keys_count = 0,

		-- Selection
		selection_mode = SELECTION_MODE.FIRST,
		selection_first_char = nil,
		selected_jump_target = nil,
		selected_jump_char = nil,
	}
end

--- Finalizes the motion state after target collection.
--- @param ctx SmartMotionContext
--- @param cfg SmartMotionConfig
--- @param motion_state SmartMotionMotionState
function M.finalize_motion_state(ctx, cfg, motion_state)
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

	-- Allows for the filtering of keys
	if motion_state.keys and type(motion_state.keys) == "function" then
		local keys = motion_state.keys(motion_state)
		local total_keys = #keys
		local keys_squared = total_keys * total_keys

		motion_state.total_keys = total_keys
		motion_state.max_lines = keys_squared
		motion_state.max_labels = keys_squared
		motion_state.keys = keys
	end

	if jump_target_count <= M.static.total_keys then
		-- We only need singles
		motion_state.single_label_count = jump_target_count
		motion_state.double_label_count = 0
		motion_state.sacrificed_keys_count = 0
	else
		local labels_needed = jump_target_count - motion_state.total_keys
		local initial_sacrifice = math.ceil(math.sqrt(labels_needed))

		motion_state.double_label_count = labels_needed + initial_sacrifice

		local adjusted_sacrifice = math.ceil(math.sqrt(motion_state.double_label_count))

		motion_state.sacrificed_keys_count = math.max(initial_sacrifice, adjusted_sacrifice)
		motion_state.single_label_count = motion_state.total_keys - motion_state.sacrificed_keys_count
	end

	log.debug(
		string.format(
			"Motion state finalized - jump_targets: %d, singles: %d, doubles: %d, sacrificed_keys: %d",
			motion_state.jump_target_count,
			motion_state.single_label_count,
			motion_state.double_label_count,
			motion_state.sacrificed_keys_count
		)
	)
end

function M.reset(motion_state)
	motion_state.single_label_count = 0
	motion_state.double_label_count = 0
	motion_state.sacrificed_keys_count = 0

	motion_state.jump_target_count = 0
	motion_state.jump_targets = {}
	motion_state.hint_labels = {}
	motion_state.assigned_hint_labels = {}

	motion_state.selection_mode = SELECTION_MODE.FIRST
	motion_state.selection_first_char = nil
	motion_state.selected_jump_target = nil
end

function M.module_has_motion_state(module)
	return module.metadata and module.metadata.motion_state
end

function M.merge_motion_state(motion_state, motion, modules)
	motion_state = vim.tbl_deep_extend("force", motion_state, motion.metadata.motion_state)

	for _, module in pairs(modules) do
		if M.module_has_motion_state(module) then
			motion_state = vim.tbl_deep_extend("force", motion_state, module.metadata.motion_state)
		end
	end

	return motion_state
end

return M
