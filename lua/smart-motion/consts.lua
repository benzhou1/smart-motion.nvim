local M = {}

M.ns_id = vim.api.nvim_create_namespace("smart_motion")

M.highlights = {
	HintSingle = "SmartMotionHint",
	FirstChar = "SmartMotionFirstChar",
	SecondChar = "SmartMotionSecondChar",
	DimmedChar = "SmartMotionDimmedChar",
}

M.DIRECTION = {
	AFTER = "after",
	BEFORE = "before",
}

M.JUMP_TARGET_LOCATION = {
	FIRST = "first",
	LAST = "last",
}

M.motion_directions = {
	w = M.DIRECTION.AFTER,
	e = M.DIRECTION.AFTER,
	b = M.DIRECTION.BEFORE,
	ge = M.DIRECTION.BEFORE,
}

M.motion_target_char = {
	w = M.JUMP_TARGET_LOCATION.FIRST,
	b = M.JUMP_TARGET_LOCATION.FIRST,
	e = M.JUMP_TARGET_LOCATION.LAST,
	ge = M.JUMP_TARGET_LOCATION.LAST,
}

M.motion_pattern = {
	word = [[\k\+]],
	space = [[\s]],
}

return M
