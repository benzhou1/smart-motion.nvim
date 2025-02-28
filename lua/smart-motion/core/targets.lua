--- Central dispatcher for retrieving jump targets.
local word = require("smart-motion.motion.word")
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")

local M = {}

--- Fetches jump targets based on type.
---@param type string "word", "char", "line"
---@param lines string[] Lines to search.
---@param direction "before_cursor"|"after_cursor" Search direction.
---@param start_line integer Starting line (0-based)
---@return table[] List of jump targets.
function M.get_jump_targets(type, ...)
	log.debug("Fetching jump targets for type: " .. type)

	if type == consts.TARGET_TYPES.WORD then
		return word.get_jump_targets_for_word(...)
	end

	log.error("Unknown target type passed to get_jump_targets: " .. tostring(type))

	return {}
end

return M
