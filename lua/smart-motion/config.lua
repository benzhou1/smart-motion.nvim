local M = {}

--- Default Configuration
M.defaults = {
	keys = "asdfghjkltyvb",
	highlight = {
		hint = "DiagnosticHint",
		first_char = "DiagnosticHint",
		second_char = "DiagnosticHint",
		dim = "Comment",
	},
	line_limit = nil,
	multi_line = false,
	mappings = {
		n = {}, -- Normal mode mappings
		v = {}, -- Visual mode mappings (optional)
	},
}

--- Splits a string into a table of characters.
---@param str string
---@return string[]
local function split_string(str)
	local result = {}

	for char in str:gmatch(".") do
		table.insert(result, char)
	end

	return result
end

--- Validates user configuration and applies defaults where needed.
---@param user_config table|nil
---@return table final_config
function M.validate(user_config)
	local config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_config or {})

	-- Convert keys to table of characters
	if type(config.keys) ~= "string" or #config.keys == 0 then
		error("smart-motion: `keys` must be a non-empty string of characters")
	end

	config.keys = split_string(config.keys)

	-- Validate mappings (user-defined mappings)
	if type(config.mappings) ~= "table" or not config.mappings.n or not config.mappings.v then
		error("smart-motion: `mappings` must be a table with `n` and `v` keys")
	end

	-- Validate Highlight
	if type(config.highlight) ~= "table" or not config.mappings.n or not config.mappings.v then
		error("smart-motion: `highlight` must be a table")
	end

	-- Validate line_limit
	if config.line_limit ~= nil and (type(config.line_limit) ~= "number" or config.line_limit < 0) then
		error("smart-motion: `line_limit` must be a positive integer or nil")
	end

	-- Validate multi_line
	if type(config.multi_line) ~= "boolean" then
		error("smart-motion: `multi_line` must be true or false")
	end

	return config
end

return M
