--- Central dispatcher for retrieving jump targets.
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")
local linesModule = require("smart-motion.core.lines")

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
---@param ctx table Motion context (bufnr, cursor_line, etc.)
---@param cfg table Validated config.
---@param motion_state table Current motion state.
---@return table[] List of word targets.
function M.get_jump_targets_for_word(ctx, cfg, motion_state)
	local lines = linesModule.get_lines_for_motion(ctx, cfg, motion_state)
	if not lines or #lines == 0 then
		log.warn("No lines to search - exiting early")

		return {}
	end

	log.debug(
		string.format(
			"Collecting jump targets - direction: %s, start_line: %d, line_count: %d",
			motion_state.direction,
			ctx.cursor_line,
			#lines
		)
	)

	if
		not vim.tbl_contains({ consts.DIRECTION.AFTER_CURSOR, consts.DIRECTION.BEFORE_CURSOR }, motion_state.direction)
	then
		log.error("get_jump_targets_for_word: Invalid direction: " .. tostring(motion_state.direction))

		return {}
	end

	if not lines or #lines == 0 then
		log.warn("get_jump_targets_for_word: No lines provided")

		return {}
	end

	local jump_targets = {}

	local function should_stop_collecting()
		return #jump_targets >= motion_state.max_labels
	end

	if motion_state.direction == consts.DIRECTION.AFTER_CURSOR then
		for line_index, line_text in ipairs(lines) do
			local line_number = ctx.cursor_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for _, word in ipairs(words) do
				if line_number == ctx.cursor_line and word.start_pos <= ctx.cursor_col then
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
	elseif motion_state.direction == consts.DIRECTION.BEFORE_CURSOR then
		for line_index = #lines, 1, -1 do
			local line_text = lines[line_index]
			local line_number = ctx.cursor_line + line_index - 1
			local words = M.find_words_in_line(line_text)

			for i = #words, 1, -1 do
				local word = words[i]

				if line_number == ctx.cursor_line and word.end_pos >= ctx.cursor_col then
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

--- Fetches jump targets based on type.
---@param target_type string "word", "char", "line"
---@param ctx table Motion context (bufnr, cursor_line, etc.)
---@param cfg table Validated config.
---@param motion_state table Current motion state.
---@return table[] List of jump targets.
function M.get_jump_targets(target_type, ctx, cfg, motion_state)
	log.debug("Fetching jump targets for target_type: " .. target_type)

	if target_type == consts.TARGET_TYPES.WORD then
		return M.get_jump_targets_for_word(ctx, cfg, motion_state)
	end

	log.error("Unknown target target_type passed to get_jump_targets: " .. tostring(target_type))

	return {}
end

return M
