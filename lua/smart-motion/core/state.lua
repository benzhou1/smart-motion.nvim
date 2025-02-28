--- Module for tracking motion state.

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
function M.set_static_key_data(base_keys)
	M.total_keys = #base_keys
	M.max_labels = M.total_keys * M.total_keys
	M.max_lines = M.max_labels
end

--- Initializes state for a new motion.
---@param jump_target_count integer Number of jump targets found.
function M.init_for_motion(jump_target_count)
	M.labels_needed = math.max(jump_target_count - M.total_keys, 0)
end

return M
