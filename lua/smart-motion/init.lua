--- Main entry point for smart-motion
local state = require("smart-motion.core.state")
local config = require("smart-motion.config")
local word = require("smart-motion.motion.word")
local consts = require("smart-motion.consts")
local log = require("smart-motion.core.log")

local M = {}

--- Holds final validated config
M.config = {}

--- Helper to detect if which-key.nvim is installed.
local function has_which_key()
	local ok = pcall(require, "which-key")

	return ok
end

--- Register mappings, preferring which-key if available.
---@param mappings table The `n` and `v` mappings table from config.
local function register_mappings(mappings)
	log.debug("Registering mappings")

	if type(mappings) ~= "table" then
		log.error("Mappings should be a table (got: " .. type(mappings) .. ")")

		return
	end

	for mode, mode_mappings in pairs(mappings) do
		if type(mode_mappings) ~= "table" then
			log.warn("Skipping mappings for mode '" .. mode .. "' (expected table, got: " .. type(mode_mappings) .. ")")

			goto continue
		end

		for key, mapping in pairs(mode_mappings) do
			if type(mapping) ~= "table" or type(mapping[1]) ~= "function" then
				log.warn(string.format("Invalid mapping for '%s' in mode '%s'", key, mode))

				goto continue_inner
			end

			local action = mapping[1]
			local opts = { desc = mapping.desc or "smart-motion action" }

			if has_which_key() then
				local wk = require("which-key")
				wk.register({ [key] = opts.desc }, { mode = mode })
			end

			local ok, err = pcall(vim.keymap.set, mode, key, action, opts)
			if not ok then
				log.error(string.format("Failed to register keymap %s in mode %s: %s", key, mode, err))
			else
				log.debug(string.format("Registered keymap %s in mode %s", key, mode))
			end

			::continue_inner::
		end

		::continue::
	end

	log.debug("Mapping registration complete")
end

--- Sets up smart-motion with user-provided config.
--- This should be called froh the user's init.lua/init.vim.
---@param user_config table|nil
function M.setup(user_config)
	log.debug("Setting up SmartMotion")

	local ok, validated_config = pcall(config.validate, user_config)
	if not ok then
		log.error("Failed to validate config: " .. tostring(validated_config))

		return
	end

	M.config = validated_config

	register_mappings(M.config.mappings)

	-- Setup static state based on config (keys and max_labels only need to be computed once)
	state.init_static_state(M.config)

	log.debug("SmartMotion setup complete")
end

--- Initializes smart-motion for a specific motion (w, e, be, ge, etc).
--- This is per-motion state and gets reset every time a new motion starts.
---@param target_count integer
function M.init_state_for_motion(target_count)
	log.debug("Initializing per-motion state for " .. target_count .. " targets")

	if type(target_count) ~= "number" or target_count < 0 then
		log.error("Invalid target_count passed to init_state_for_motion: " .. tostring(target_count))

		return
	end

	state.init_state_for_motion(target_count)

	log.debug("Per-motion state initialized")
end

M.hint_words = word.hint_words

M.DIRECTION = consts.DIRECTION
M.HINT_POSITION = consts.HINT_POSITION

return M
