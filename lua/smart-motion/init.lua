-- lua/smart-motion/
-- ├── init.lua              -- Main entry point, exposes public API
-- ├── motion/
-- │   ├── word.lua           -- Collect word targets
-- │   ├── char.lua           -- Collect character targets
-- │   ├── line.lua           -- Collect line targets
-- │   └── object.lua         -- (future: treesitter objects, optional)
-- ├── core/
-- │   ├── targets.lua        -- Handles generic get_jump_targets(), dispatching to correct motion type
-- │   ├── hints.lua          -- Generates and assigns hints (uses generate_hint_keys)
-- │   ├── highlight.lua      -- Applies/clears all virtual text & highlights
-- │   ├── state.lua          -- (future: for multi-step management like f/t double char labels)
-- ├── utils.lua               -- Shared helpers
-- ├── consts.lua               -- Namespace, highlight names, defaults
-- └── config.lua               -- Default settings + user config merge

local M = {}

local state = require("smart-motion.core.state")
local config = require("smart-motion.config")

--- Holds final validated config
M.config = {}

--- Helper to detect if which-key.nvim is installed.
local function has_which_key()
	return package.loaded["which-key"] ~= nil
end

--- Register mappings, preferring which-key if available.
---@param mappings table The `n` and `v` mappings table from config.
local function register_mappings(mappings)
	for mode, mode_mappings in pairs(mappings) do
		for key, mapping in pairs(mode_mappings) do
			local action = mapping[1]
			local opts = { desc = mapping.desc or "smart-motion action" }

			if has_which_key() then
				require("which-key").register({
					[key] = opts.desc,
				}, { mode = mode })
			end

			vim.keymap.set(mode, key, action, opts)
		end
	end
end

--- Sets up smart-motion with user-provided config.
--- This should be called froh the user's init.lua/init.vim.
---@param user_config table|nil
function M.setup(user_config)
	M.config = config.validate(user_config)

	register_mappings(M.config.mappings)

	-- Setup static state based on config (keys and max_labels only need to be computed once)
	state.init_static_state(M.config)
end

--- Initializes smart-motion for a specific motion (w, e, be, ge, etc).
--- This is per-motion state and gets reset every time a new motion starts.
---@param target_count integer
function M.init_state_for_motion(target_count)
	state.init_state_for_motion(target_count)
end

return M
