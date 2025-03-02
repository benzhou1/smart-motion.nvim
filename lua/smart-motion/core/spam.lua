--- Handles motion spam detection.
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")

local M = {}

---@type table<string, integer>
local last_motion_times = {}

local SPAM_THRESHOLD = 300

--- Checks if a motion (key or label) is being spammed.
---@param key string Unique key identifying the motion (e.g., "before-first")
---@returr boolean True if spam detected, false otherwise.
function M.is_spam(key)
	local now = vim.loop.now()
	local last_motion_time = last_motion_times[key]

	if last_motion_time and (now - last_motion_time < SPAM_THRESHOLD) then
		log.debug("Spam detected for motion: " .. key)

		last_motion_times[key] = now

		return true
	end

	last_motion_times[key] = now

	return false
end

--- Handles executing word motions when spamming
function M.handle_word_motion_spam(ctx, cfg, motion_state)
	log.debug(
		string.format(
			"Handling spam motion - direction: %s, position: %s",
			motion_state.direction,
			motion_state.hint_position
		)
	)

	if
		motion_state.direction == consts.DIRECTION.AFTER_CURSOR
		and motion_state.hint_position == consts.HINT_POSITION.START
	then
		vim.cmd("normal! w")
	elseif
		motion_state.direction == consts.DIRECTION.BEFORE_CURSOR
		and motion_state.hint_position == consts.HINT_POSITION.START
	then
		vim.cmd("normal! b")
	elseif
		motion_state.direction == consts.DIRECTION.AFTER_CURSOR
		and motion_state.hint_position == consts.HINT_POSITION.END
	then
		vim.cmd("normal! e")
	elseif
		motion_state.direction == consts.DIRECTION.BEFORE_CURSOR
		and motion_state.hint_position == consts.HINT_POSITION.END
	then
		vim.cmd("normal! ge")
	else
		log.warn(
			string.format(
				"Unknown spam motion - direction: %s, position: %s",
				motion_state.direction,
				motion_state.hint_position
			)
		)
	end
end

--- Clears spam tracking data
function M.reset()
	log.debug("Resetting spam tracker")

	last_motion_times = {}
end

return M
