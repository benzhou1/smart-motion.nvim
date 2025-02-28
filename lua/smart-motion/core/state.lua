--- Module for tracking motion state.
local log = require("smart-motion.core.log")

local M = {}

---@type integer Total number of base keys (single-character keys).
M.total_keys = 0

---@type integer Maximum number of labels (single + double).
M.max_labels = 0

---@type integer Maximum number of lines to search.
M.max_lines = 0

---@type integer Number of labels actually needed (after single keys are used).
M.labels_needed = 0

--- Initializes static key-based state once when config is verified.
---@param base_keys string Configured base keys.
function M.init_static_state(base_keys)
	if type(base_keys) ~= "table" or #base_keys == 0 then
		log.error("init_static_state received invalid base_keys: expected non-empty table")

		return
	end

	M.total_keys = #base_keys
	M.max_labels = M.total_keys * M.total_keys
	M.max_lines = M.max_labels

	log.debug(
		string.format(
			"Static state initialized - total_keys: %d, max_labels: %d, max_lines: %d",
			M.total_keys,
			M.max_labels,
			M.max_lines
		)
	)
end

--- Initializes state for a new motion.
---@param jump_target_count integer Number of jump targets found.
function M.init_state_for_motion(jump_target_count)
	if M.total_keys == 0 then
		log.error("init_state_for_motion called before static state was initialized")

		return
	end

	if type(jump_target_count) ~= "number" or jump_target_count < 0 then
		log.error("init_state_for_motion received invalid jump_target_count: " .. tostring(jump_target_count))

		return
	end

	M.labels_needed = math.max(jump_target_count - M.total_keys, 0)

	log.debug("Motion state initialized - labels_needed: " .. M.labels_needed)
end

return M
