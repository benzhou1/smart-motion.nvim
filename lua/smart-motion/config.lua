--- Configuration handler for smart-motion
local log = require("smart-motion.core.log")

local M = {}

--- Default Configuration
M.defaults = {
	keys = "fjdksleirughtynm",
	highlight = {
		hint = "DiagnosticHint",
		first_char = "DiagnosticHint",
		second_char = "DiagnosticHint",
		dim = "Comment",
	},
	line_limit = nil,
	multi_line = true,
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
	log.debug("Validating SmartMotion configuration")

	if user_config and type(user_config) ~= "table" then
		log.error("User config must be a table or nil (got: " .. type(user_config) .. ")")
		error("smart-motion: Invalid user config provided")
	end

	local config = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), user_config or {})

	-- Validate & Convert keys to table of characters
	if type(config.keys) ~= "string" or #config.keys == 0 then
		log.error("`keys` must be a non-empty string of characters (got: " .. tostring(config.keys) .. ")")
		error("smart-motion: `keys` must be a non-empty string")
	end

	config.keys = split_string(config.keys)

	-- Validate mappings
	if type(config.mappings) ~= "table" or not config.mappings.n or not config.mappings.v then
		log.error("`mappings` must be a table with `n` and `v` keys (got: " .. vim.inspect(config.mappings) .. ")")
		error("smart-motion: `mappings` must be a table with `n` and `v` keys")
	end

	-- Validate Highlight
	if type(config.highlight) ~= "table" then
		log.error("`highlight` must be a table (got: " .. type(config.highlight) .. ")")
		error("smart-motion: `highlight` must be a table")
	end

	for _, key in ipairs({ "hint", "first_char", "second_char", "dim" }) do
		if type(config.highlight[key]) ~= "string" then
			log.error("`highlight." .. key .. "` must be a string highlight group")
			error("smart-motion: `highlight." .. key .. "` must be a string highlight group")
		end
	end

	-- Validate line_limit
	if config.line_limit ~= nil and (type(config.line_limit) ~= "number" or config.line_limit < 0) then
		log.error("`line_limit` must be a positive integer or nil (got: " .. tostring(config.line_limit) .. ")")
		error("smart-motion: `line_limit` must be a positive integer or nil")
	end

	-- Validate multi_line
	if type(config.multi_line) ~= "boolean" then
		log.error("`multi_line` must be a boolean (got: " .. type(config.multi_line) .. ")")
		error("smart-motion: `multi_line` must be true or false")
	end

	log.debug("Configuration validated successfully")
end

return M
