-- Universal SmartMotion Flow
-- Gather Context - Cursor position, buffer number, direction, etc
-- Initial Cleanup - Clear floating windows and clear highlighting
-- Handle Spam - If a spammable motion, handle it
-- Get Lines - Get lines we want to get targets from
-- Collect Targets - Call a shared `get_jump_targets()` function (with target type: word, char, line, etc...)
-- Generate Hints - Call a shared `generate_hint_labels()` to compute labels
-- Assign Hints to Targets - Apply the hints (reusing the same logic for all motions)
-- Apply Highlights - Use a unified highlight function that works for any motion type
-- Wait for Selection - Use `getcharstr()` or similar to wait for user selection
-- Execute Jump - Move cursor to selected target
-- Clear Highlights - Remove all hints after action completes

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
local log = require("smart-motion.core.log")
local init = require("smart-motion.init")

local M = {}

--- Finds all words in a line matching the given pattern.
---@param line string
---@return table[] List of word matches (each with start_pos, end_pos, text).
function M.find_words_in_line(line)
	log.debug("Finding words in line: " .. vim.inspect(line))

	if type(line) ~= "string" then
		log.error("find_words_in_line: Expected string line, got " .. type(line))

		return {}
	end

	local words = {}
	local search_start = 0
	local pattern = consts.WORD_PATTERN

	if not pattern or pattern == "" then
		log.error("WORD_PATTERN is missing or empty in consts")

		return {}
	end

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

	log.debug(string.format("Found %d words in line", #words))

	return words
end

--- Collects word jump targets for a motion.
---@param lines string[] Lines to search.
---@param direction "before_cursor"|"after_cursor"
---@param start_line integer 0-based start line.
---@param cursor_col integer Current cursor column.
---@return table[] List of word targets.
function M.get_jump_targets_for_word(lines, direction, start_line, cursor_col)
	log.debug(
		string.format(
			"Collecting jump targets - direction: %s, start_line: %d, line_count: %d",
			direction,
			start_line,
			#lines
		)
	)

	if not vim.tbl_contains({ consts.DIRECTION.AFTER_CURSOR, consts.DIRECTION.BEFORE_CURSOR }, direction) then
		log.error("get_jump_targets_for_word: Invalid direction: " .. tostring(direction))

		return {}
	end

	if not lines or #lines == 0 then
		log.warn("get_jump_targets_for_word: No lines provided")

		return {}
	end

	local jump_targets = {}

	local function should_stop_collecting()
		return #jump_targets >= state.max_labels
	end

	if direction == consts.DIRECTION.AFTER_CURSOR then
		for line_index, line_text in ipairs(lines) do
			local line_number = start_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for _, word in ipairs(words) do
				if line_number == start_line and word.start_pos <= cursor_col then
					-- Skip words behind cursor on first line
				else
					table.insert(jump_targets, {
						line = line_number,
						start_pos = word.start_pos,
						end_pos = word.end_pos,
					})
				end

				if should_stop_collecting() then
					log.debug("Max labels reached during target collection (after_cursor)")

					return jump_targets
				end
			end
		end
	elseif direction == consts.DIRECTION.BEFORE_CURSOR then
		for line_index = #lines, 1, -1 do
			local line_text = lines[line_index]
			local line_number = start_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for i = #words, 1, -1 do
				local word = words[i]

				if line_number == start_line and word.end_pos >= cursor_col then
					-- Skip words after cursor on first line
				else
					table.insert(jump_targets, {
						line = line_number,
						start_pos = word.start_pos,
						end_pos = word.end_pos,
					})
				end

				if should_stop_collecting() then
					log.debug("Max labels reached during target collection (after_cursor)")

					return jump_targets
				end
			end
		end
	end

	log.debug(string.format("Collected %d jump targets", #jump_targets))

	return jump_targets
end

--- Public method: Hints words from the possible jump targets in a given direction.
---@param direction "before_cursor"|"after_cursor"
---@param hint_position "start"|"end"
---@param is_spammable boolean|nil Optional, allows skipping highlighting if user is spamming the trigger key.
function M.hint_words(direction, hint_position, is_spammable)
	log.debug(
		string.format(
			"Highlighting word - direction: %s, hint_position: %s, is_spammable: %s",
			direction,
			hint_position,
			tostring(is_spammable)
		)
	)

	--
	-- Gather Context
	--
	local ctx = context.get()
	local config = init.config

	if not config or type(config) ~= "table" or not config.keys then
		log.error("highlight_word: Config is missing or invalid")

		return
	end

	--
	-- Initial Cleanup
	--
	utils.close_floating_windows()
	highlight.clear(ctx.bufnr)

	--
	-- Handle spam detection
	--
	local spam_key = direction .. "-" .. hint_position

	if is_spammable and spam.is_spam(spam_key) then
		log.debug(string.format("Spamming detected - executing native motion for: %s", spam_key))

		spam.handle_word_motion_spam(direction, hint_position)

		return
	end

	--
	-- Get lines
	--
	local lines = linesModule.get_lines_for_motion(ctx.bufnr, ctx.cursor_line, direction)
	if not lines or #lines == 0 then
		log.warn("No lines to search - exiting early")

		return
	end

	--
	-- Collect Targets
	--
	local jump_targets = targets.get_jump_targets(consts.TARGET_TYPES.WORD, lines, direction, ctx.cursor_line)

	log.debug(string.format("Found %d jump targets", #jump_targets))

	if #jump_targets == 0 then
		log.warn("No valid jump targets found - exiting early")

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
	highlight.apply_hint_labels(ctx.bufnr, assigned_hint_labels, hint_position)

	--
	-- Wait for Selection
	--
	local selected = utils.wait_for_hint_selection(assigned_hint_labels)

	--
	-- Execute Jump
	--
	if selected then
		utils.jump_to_target(selected, hint_position)

		log.debug(string.format("Jumped to target - line: %d, col: %d", selected.line, selected.start_pos))
	else
		log.warn("No target selected - user cancelled")
	end

	--
	-- Clear highlights
	--
	highlight.clear(ctx.bufnr)

	log.debug("Word motion complete")
end

return M
