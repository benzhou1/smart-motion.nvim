local log = require("smart-motion.core.log")

local TIMEOUT_MS = 300 -- This will need to be on the config

local function get_timestamp()
return vim.loop.hrtime() / 1e6
end

local M = {}

M.flow_state = {
	is_active = false,
	last_motion_timestamp = nil,
	is_paused = false,
	pause_started_at = nil,
}

--- Exits flow and clears related state.
function M.exit_flow()
	M.flow_state.is_active = false
	M.flow_state.is_paused = false
	M.flow_state.pause_started_at = nil
end

function M.start_flow()
	M.flow_state.is_active = true
	M.flow_state.last_motion_timestamp = get_timestamp()
	M.flow_state.is_paused = false
end

function M.stop_flow()
	M.flow_state.is_active = false
	M.flow_state.last_motion_timestamp = nil
	M.flow_state.is_paused = false
end

function M.pause_flow()
	if not M.flow_state.is_active then
		return
	end

	M.flow_state.is_paused = true
	M.flow_state.pause_started_at = get_timestamp()
end

function M.resume_flow()
	if not M.flow_state.is_active or not M.flow_state.is_paused then
		return
	end

	local now = get_timestamp()
	local paused_duration = now - M.flow_state.pause_started_at

	-- Add the paused time back into the last mostion timestamp
	M.flow_state.last_motion_timestamp = M.flow_state.last_motion_timestamp + paused_duration
	M.flow_state.is_paused = false
end

function M.is_flow_active()
	if not M.flow_state.is_active then
		return
	end

	if M.flow_state.is_paused then
		return true -- Pause freezes the timer
	end

	local now = get_timestamp()
	local elapsed_ms = now - M.flow_state.last_motion_timestamp

	return elapsed_ms <= TIMEOUT_MS
end

function M.refresh_flow()
	if M.flow_state.is_paused then
		return
	end

	M.flow_state.last_motion_timestamp = get_timestamp()
end

return M
