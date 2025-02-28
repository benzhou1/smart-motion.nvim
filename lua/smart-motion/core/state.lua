--- Module for tracking motion state.
local log = require("smart-motion.core.log")

local M = {}

-- Static state (set once during setup)
M.total_keys = 0
M.max_labels = 0
M.max_lines = 0

-- Dynamic state (reset per motion)
M.labels_needed = 0
M.direction = nil
M.hint_position = nil

--- Initializes static key-based state once when config is verified.
---@param base_keys string[] Configured base keys.
function M.init_static_state(base_keys)
	if type(base_keys) ~= "table" or #base_keys == 0 then
		log.error("init_static_state received invalid base_keys: expected non-empty table")

		return
	end

	local base_keys_squared = #base_keys * #base_keys

	M.total_keys = #base_keys
	M.max_lines = base_keys_squared
	M.max_labels = base_keys_squared

	log.debug(
		string.format(
			"Static state initialized - total_keys: %d, max_labels: %d, max_lines: %d",
			M.total_keys,
			M.max_lines,
			M.max_labels
		)
	)
end

--- Sets the initial motion intent (called immediately when motion starts).
---@param direction string Motion direction ("before_cursor" or "after_cursor").
---@param hint_position string Hint position ("start" or "end").
function M.set_motion_intent(direction, hint_position)
	M.direction = direction
	M.hint_position = hint_position

	log.debug(
		string.format(
			"Motion intent set - direction: %s, hint_position: %s",
			tostring(M.direction),
			tostring(M.hint_position)
		)
	)
end

--- Finalizes the motion state after target collection.
---@param jump_target_count integer Number of jump targets found.
function M.finalize_motion_state(jump_target_count)
	if M.total_keys == 0 then
		log.error("finalize_motion_state called before static state was initialized")
		return
	end

	if type(jump_target_count) ~= "number" or jump_target_count < 0 then
		log.error("finalize_motion_state received invalid jump_target_count: " .. tostring(jump_target_count))
		return
	end

	M.labels_needed = math.max(jump_target_count - M.total_keys, 0)

	log.debug(string.format("Motion state finalized - labels_needed: %d", M.labels_needed))
end

--- Getter function for state
function M.get()
	return {
		total_keys = M.total_keys,
		max_lines = M.max_lines,
		max_labels = M.max_labels,
		labels_needed = M.labels_needed,
		direction = M.direction,
		hint_position = M.hint_position,
	}
end

return M
