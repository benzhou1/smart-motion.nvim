--- Module for hint generation and assignment.
local log = require("smart-motion.core.log")

local M = {}

--- Generates a list of unique hint keys (labels) for SmartMotion targets.
-- This function adapts based on the number of targets, using single-character labels
-- when possible and gracefully falling back to double-character labels if necessary.
--
-- The logic follows these steps:
-- 1. Use single-character labels for as many targets as possible (fastest to type).
-- 2. If single-character labels are not enough, "sacrifice" some keys to form pairs (double labels).
-- 3. Ensure the final set of labels has no ambiguity — singles and doubles never overlap.
-- 4. This guarantees that `a` and `aa` are never both used in the same context.

---@param base_keys string[] List of allowed characters for labels (from user config).
---@param labels_needed integer Total number of jump targets we need to label.
---@return string[] Final ordered list of hint keys (exactly `labels_needed` long).
function M.generate_hint_labels(base_keys, labels_needed)
	if type(base_keys) ~= "table" or #base_keys == 0 then
		log.error("generate_hint_labels received invalid base_keys")
		return {}
	end

	if type(labels_needed) ~= "number" or labels_needed <= 0 then
		log.error("generate_hint_labels received invalid labels_needed: " .. tostring(labels_needed))
		return {}
	end

	local keys = vim.deepcopy(base_keys)

	if labels_needed <= #keys then
		local single_char_labels = vim.list_slice(keys, 1, labels_needed)

		log.debug("Using single-character labels: " .. table.concat(single_char_labels, ", "))

		return single_char_labels
	end

	local extra_needed = labels_needed - #keys
	local x = math.ceil(math.sqrt(extra_needed))

	local remaining_singles = #keys - x
	local singles = vim.list_slice(keys, 1, remaining_singles)
	local double_base = vim.list_slice(keys, remaining_singles + 1)

	local doubles = {}

	for _, first in ipairs(double_base) do
		for _, second in ipairs(double_base) do
			table.insert(doubles, first .. second)

			if #doubles >= extra_needed then
				break
			end
		end
		if #doubles >= extra_needed then
			break
		end
	end

	local final_labels = vim.list_extend(singles, doubles)

	if #final_labels < labels_needed then
		log.error(
			string.format(
				"Not enough labels for %d targets! This should never happen. Consider adding more keys to your list",
				labels_needed
			)
		)
	end

	log.debug("Generated labels: " .. table.concat(final_labels, ", "))

	return final_labels
end

--- Assigns hint labels to targets.
---@param jump_targets table[] List of jump targets.
---@param hint_labels string[] Generated hint labels.
---@return table<table, string> Mapping of target to assigned hint .
function M.assign_hint_labels(jump_targets, hint_labels)
	if #jump_targets > #hint_labels then
		log.error(
			string.format("assign_hint_labels received more targets (%d) than labels (%d)", #jump_targets, #hint_labels)
		)

		return {}
	end

	local hints = {}

	for i, target in ipairs(jump_targets) do
		if i > #hint_labels then
			break
		end
		hints[target] = hint_labels[i]
	end

	log.debug(string.format("Assigned %d hints to targets", #hints))

	return hints
end

--- Generates and Assigns labels to targets
---@param jump_targets table[] List of jump targets.
---@param base_keys string[] Available hint keys.
---@param labels_needed integer Total number of jump targets we need to label.
---@return table<table, string> Mapping of target to assigned hint .
function M.generate_and_assign_labels(jump_targets, base_keys, labels_needed)
	log.debug(string.format("Generating and assigning labels - needed: %d", labels_needed))

	local hint_labels = M.generate_hint_labels(base_keys, labels_needed)

	return M.assign_hint_labels(jump_targets, hint_labels)
end

return M
