--- Module for hint generation and assignment.
local log = require("smart-motion.core.log")

local M = {}

--- Generates hint labels based on motion state.
-- Uses single-character labels first, and double-character labels if needed.
-- If there are more targets than labels, uses all available labels (graceful fallback).
---@param ctx table Full context (cursor position, buffer, etc.) — not used here, but part of standard signature.
---@param cfg table Validated config (keys, highlights, etc.) — needed for base_keys.
---@param motion_state table Current motion state (labels needed, direction, etc.)
---@return string[] Final ordered list of hint labels.
function M.generate_hint_labels(ctx, cfg, motion_state)
	if type(cfg.keys) ~= "table" or #cfg.keys == 0 then
		log.error("generate_hint_labels received invalid base_keys in cfg")
		return {}
	end

	if type(motion_state) ~= "table" then
		log.error("generate_hint_labels received invalid motion_state")
		return {}
	end

	local singles = vim.list_slice(cfg.keys, 1, motion_state.single_label_count)
	local double_base = vim.list_slice(cfg.keys, motion_state.single_label_count + 1)

	local doubles = {}
	local doubles_needed = motion_state.extra_labels_needed

	for _, first in ipairs(double_base) do
		for _, second in ipairs(double_base) do
			table.insert(doubles, first .. second)

			if #doubles >= doubles_needed then
				break
			end
		end

		if #doubles >= doubles_needed then
			break
		end
	end

	local final_labels = vim.list_extend(singles, doubles)

	if #final_labels < motion_state.jump_target_count then
		log.warn(
			string.format(
				"Not enough labels for %d targets! Using %d available labels.",
				motion_state.jump_target_count,
				#final_labels
			)
		)
	end

	log.debug(string.format("Generated %d labels (singles: %d, doubles: %d)", #final_labels, #singles, #doubles))

	return final_labels
end

--- Assigns hint labels to targets.
---@param ctx table Full context (cursor position, buffer, etc.) — not used here, but part of standard signature.
---@param cfg table Validated config — not used directly here, but part of standard signature.
---@param motion_state table Current motion state — not used directly here.
---@return table<table, string> Mapping of target to assigned hint .
function M.assign_hint_labels(ctx, cfg, motion_state)
	if #motion_state.jump_targets > #motion_state.hint_labels then
		log.debug(
			string.format(
				"Not enough labels for %d targets! Only assigning labels to the first %d targets.",
				#motion_state.jump_targets,
				#motion_state.hint_labels
			)
		)
	end

	local hints = {}

	for i, target in ipairs(motion_state.jump_targets) do
		if i > #motion_state.hint_labels then
			break
		end

		hints[target] = motion_state.hint_labels[i]
	end

	log.debug(string.format("Assigned %d hints to targets", #hints))

	return hints
end

--- Generates and Assigns labels to targets
---@param ctx table Full context (cursor position, buffer, etc.).
---@param cfg table Validated config.
---@param motion_state table Current motion state.
function M.generate_and_assign_labels(ctx, cfg, motion_state)
	log.debug(string.format("Generating and assigning labels - needed: %d", motion_state.extra_labels_needed))

	motion_state.hint_labels = M.generate_hint_labels(ctx, cfg, motion_state)
	motion_state.assigned_hint_labels = M.assign_hint_labels(ctx, cfg, motion_state)
end

return M
