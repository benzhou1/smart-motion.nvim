--- Configuration handler for smart-motion
local log = require("smart-motion.core.log")

local M = {}

--- Default Configuration
M.defaults = {
	keys = "fjdksleirughtynm",
	highlight = {
		hint = "SmartMotionHint",
		first_char = "SmartMotionFirstChar",
		second_char = "SmartMotionSecondChar",
		first_char_dim = "SmartMotionFirstCharDim",
		dim = "SmartMotionDim",
	},
	line_limit = nil,
	multi_line = true,
	mappings = {
		n = {}, -- Normal mode mappings
		v = {}, -- Visual mode mappings (optional)
	},
}

--- Holds the final validated config
M.validated = nil

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

	if type(config.keys) == "string" then
		config.keys = split_string(config.keys)
	end

	-- Validate mappings
	if type(config.mappings) ~= "table" or not config.mappings.n or not config.mappings.v then
		log.error("`mappings` must be a table with `n` and `v` keys (got: " .. vim.inspect(config.mappings) .. ")")
		error("smart-motion: `mappings` must be a table with `n` and `v` keys")
	end

	-- Apply highlight if table provided
	for name, value in pairs(config.highlight) do
		if type(value) == "table" then
			-- User passed direct highlight table (e.g., { fg = "#E06C75", bg = "none" })
			local group_name = "SmartMotion" .. name:gsub("^%l", string.upper) -- camel case to Pascal case
			vim.api.nvim_set_hl(0, group_name, value)
			config.highlight[name] = group_name
		elseif type(value) ~= "string" then
			log.error("`highlight." .. name .. "` must be either a string highlight group or a table")
			error("smart-motion: `highlight." .. name .. "` must be either a string or a table")
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

	M.validated = config

	return config
end

return M
