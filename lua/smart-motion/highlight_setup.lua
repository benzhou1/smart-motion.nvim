local log = require("smart-motion.core.log")

local default_highlights = {
	SmartMotionHint = { fg = "#E06C75", bg = "none" },
	SmartMotionFirstChar = { fg = "#98C379", bg = "none" },
	SmartMotionSecondChar = { fg = "#61AFEF", bg = "none" },
	SmartMotionFirstCharDim = { fg = "#6F8D57", bg = "none" },
	SmartMotionDim = { fg = "#5C6370", bg = "none" },
}

local M = {}

--- Applies a single highlight group.
---@param group string
---@param opts table
local function apply_highlight(group, opts)
	vim.api.nvim_set_hl(0, group, opts)
end

--- Merges defaults with user-supplied highlight overrides.
---@param cfg table
---@return table merged_highlights
local function merge_highlights(cfg)
	local merged = vim.deepcopy(default_highlights)

	-- Go through each highlight key (hint, first_char, etc.)
	for key, value in pairs(cfg.highlight or {}) do
		local group_name = "SmartMotion" .. key:gsub("^%l", string.upper)

		if type(value) == "table" then
			-- User provided a color table (fg, bg, etc.)
			merged[group_name] = vim.tbl_deep_extend("force", merged[group_name] or {}, value)
		elseif type(value) == "string" then
			-- User provided a group name — we don't change it, just skip merging.
			merged[group_name] = nil -- User is delegating to their own group.
		else
			log.error("Invalid type for highlight." .. key .. ": expected string or table, got " .. type(value))
		end
	end

	return merged
end

--- Sets all SmartMotion highlight groups.
---@param cfg table Validated config (passed from setup)
function M.setup(cfg)
	log.debug("Setting up SmartMotion highlights")

	-- Merge defaults with user overrides
	local merged_highlights = merge_highlights(cfg)

	-- Apply all highlights
	for group, opts in pairs(merged_highlights) do
		apply_highlight(group, opts)
	end

	-- Handle user-defined highlight groups (direct strings, no merging needed)
	for key, value in pairs(cfg.highlight or {}) do
		if type(value) == "string" then
			-- Just verify group exists — don't set it, user controls this.
			local ok = pcall(vim.api.nvim_get_hl_by_name, value, true)
			if not ok then
				log.warn("Highlight group '" .. value .. "' does not exist (referenced in highlight." .. key .. ")")
			end
		end
	end

	log.debug("SmartMotion highlight groups set.")

	-- Reapply highlights on colorscheme change.
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("SmartMotionHighlights", { clear = true }),
		callback = function()
			local reloaded_cfg = require("smart-motion.config").validated
			if reloaded_cfg then
				M.setup(reloaded_cfg)
			end
		end,
	})
end

return M
