--- Word motion handler.
local consts = require("smart-motion.consts")
local context = require("smart-motion.core.context")
local state = require("smart-motion.core.state")
local utils = require("smart-motion.utils")
local highlight = require("smart-motion.core.highlight")
local targets = require("smart-motion.core.targets")
local hints = require("smart-motion.core.hints")
local linesModule = require("smart-motion.core.lines")
local spam = require("smart-motion.core.spam")

local M = {}

--- Finds all words in a line matching the given pattern.
---@param line string
---@return table[] List of word matches (each with start_pos, end_pos, text).
function M.find_words_in_line(line)
	local words = {}
	local search_start = 0
	local pattern = consts.WORD_PATTERN

	while true do
		local match_data = vim.fn.matchstrpos(line, pattern, search_start)
		local match_text, start_pos, end_pos = match_data[1], match_data[2], match_data[3]

		if start_pos == -1 then
			break
		end

		table.insert(words, {
			start_pos = start_pos,
			end_pos = end_pos,
			text = match_text,
		})

		search_start = end_pos + 1
	end

	return words
end

--- Collects word jump targets for a motion.
---@param lines string[] Lines to search.
---@param direction "before"|"after"
---@param start_line integer 0-based start line.
---@return table[] List of word targets.
function M.get_jump_targets_for_word(lines, direction, start_line)
	local ctx = context.get()
	local jump_targets = {}

	local function should_stop_collecting()
		return #targets >= state.max_labels
	end

	if direction == consts.DIRECTION.AFTER then
		for line_index, line_text in ipairs(lines) do
			local line_number = start_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for _, word in ipairs(words) do
				if line_number == start_line and word.start_pos <= ctx.cursor_col then
				-- Skip words behind cursor on first line
				else
					table.insert(jump_targets, {
						line = line_number,
						start_pos = word.start_pos,
						end_pos = word.end_pos,
					})
				end

				if should_stop_collecting() then
					return jump_targets
				end
			end
		end
	elseif direction == consts.DIRECTION.BEFORE then
		for line_index = #lines, 1, -1 do
			local line_text = lines[line_index]
			local line_number = start_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for i = #words, 1, -1 do
				local word = words[i]

				if line_number == start_line and word.end_pos >= ctx.cursor_col then
				-- Skip words after cursor on first line
				else
					table.insert(jump_targets, {
						line = line_number,
						start_pos = word.start_pos,
						end_pos = word.end_pos,
					})
				end

				if should_stop_collecting() then
					return jump_targets
				end
			end
		end
	end

	return jump_targets
end

--- Public method: Highlights word jump targets in a given direction.
---@param direction "before"|"after"
---@param jump_location "first"|"last"
---@param config table
---@param is_spammable boolean|nil Optional, allows skipping highlighting if user is spamming the trigger key.
function M.highlight_word(direction, jump_location, config, is_spammable)
	--
	-- Gather Context
	--
	local ctx = context.get()

	--
	-- Initial Cleanup
	--
	utils.close_floating_windows()
	highlight.clear(ctx.bufnr)

	--
	-- Handle spam detection
	--
	local spam_key = direction .. "-" .. jump_location

	if is_spammable and spam.is_spam(spam_key) then
		spam.handle_word_motion_spam(direction, jump_location)

		return
	end

	--
	-- Get lines
	--
	local lines = linesModule.get_lines_for_motion(ctx.bufnr, ctx.cursor_line, direction)
	if not lines or #lines == 0 then
		return
	end

	--
	-- Collect Targets
	--
	local jump_targets = targets.get_jump_targets(consts.TARGET_TYPES.WORD, lines, direction, ctx.cursor_line)
	if #jump_targets == 0 then
		return
	end

	state.init_for_motion(#jump_targets)

	--
	-- Assign Hints
	--
	local assigned_hint_labels = hints.generate_and_assign_labels(jump_targets, config.keys, state.labels_needed)

	--
	-- Apply Highlights
	--
	highlight.apply_hint_labels(ctx.bufnr, assigned_hint_labels, jump_location)

	--
	-- Wait for Selection
	--
	local selected = utils.wait_for_hint_selection(assigned_hint_labels)

	--
	-- Execute Jump
	--
	if selected then
		local jump_pos = (jump_location == consts.JUMP_LOCATION.FIRST) and selected.start_pos or (selected.end_pos - 1)

		vim.api.nvim_win_set_cursor(0, { selected.line + 1, jump_pos })
	end

	--
	-- Clear highlights
	--
	highlight.clear(ctx.bufnr)
end

return M
