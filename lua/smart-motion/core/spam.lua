--- Handles motion spam detection.
local consts = require("smart-motion.consts")

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
		last_motion_times[key] = now

		return true
	end

	last_motion_times[key] = now

	return false
end

--- Handles executing word motions when spamming
---@param direction "before_cursor"|"after_cursor"
---@param hint_position "start"|"end"
function M.handle_word_motion_spam(direction, hint_location)
	if direction == consts.DIRECTION.AFTER_CURSOR and hint_location == consts.HINT_POSITION.START then
		vim.cmd("normal! w")
	elseif direction == consts.DIRECTION.BEFORE_CURSOR and hint_location == consts.HINT_POSITION.START then
		vim.cmd("normal! b")
	elseif direction == consts.DIRECTION.AFTER_CURSOR and hint_location == consts.HINT_POSITION.END then
		vim.cmd("normal! e")
	elseif direction == consts.DIRECTION.BEFORE_CURSOR and hint_location == consts.HINT_POSITION.END then
		vim.cmd("normal! ge")
	end
end

--- Clears spam tracking data
function M.reset()
	last_motion_times = {}
end

return M
