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

M.JUMP_LOCATION = {
	FIRST = "first",
	LAST = "last",
}

M.WORD_MOTIONS = {
	w = "w",
	b = "b",
	e = "e",
	ge = "ge",
}

M.motion_directions = {
	[M.WORD_MOTIONS.w] = M.DIRECTION.AFTER,
	[M.WORD_MOTIONS.b] = M.DIRECTION.BEFORE,
	[M.WORD_MOTIONS.e] = M.DIRECTION.AFTER,
	[M.WORD_MOTIONS.ge] = M.DIRECTION.BEFORE,
}

M.motion_target_char = {
	[M.WORD_MOTIONS.w] = M.JUMP_LOCATION.FIRST,
	[M.WORD_MOTIONS.b] = M.JUMP_LOCATION.FIRST,
	[M.WORD_MOTIONS.e] = M.JUMP_LOCATION.LAST,
	[M.WORD_MOTIONS.ge] = M.JUMP_LOCATION.LAST,
}

M.WORD_PATTERN = [[\k\+]]

M.TARGET_TYPES = {
	WORD = "word",
	CHAR = "char",
	LINE = "line",
}

return M
