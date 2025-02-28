--- Module for tracking motion state.
--- For right now, it tracks if user is spamming
--- a motion

local M = {}

---@type string|nil Last triggered motion.
M.last_motion = nil

---@type integer|nil Timestamp of last motion.
M.last_motion_time = nil

--- Checks if the given motion is being spammed (pressed rapidly).
---@param motion string
---@return boolean
function M.is_spam(motion)
	local now = vim.loop.now()

	if M.last_motion == motion and M.last_motion_time and (now - M.last_motion_time < 300) then
		M.last_motion_time = now

		return true
	end

	M.last_motion = motion
	M.last_motion_time = now

	return false
end

return {}
