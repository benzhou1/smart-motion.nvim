local M = {}

function M.clear_highlights(bufnr, ns_id)
	vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
end

function M.apply_single_hint(bufnr, ns_id, line, col, label)
	vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, col, {
		virt_text = { { label, "SmartMotionHint" } },
		virt_text_pos = "overlay",
		hl_mode = "combine",
	})
end

function M.apply_double_hint(bufnr, ns_id, line, col, label)
	local first_char, second_char = label:sub(1, 1), label:sub(2, 2)

	vim.api.nvim_buf_set_extmark(bufnr, ns_id, line, col, {
		virt_text = {
			{ first_char, "SmartMotionFirstChar" },
			{ second_char, "SmartMotionSecondChar" },
		},
		virt_text_pos = "overlay",
		hl_mode = "combine",
	})
end

function M.filter_double_hints(bufnr, ns_id, active_prefix, jump_targets, hints)
	M.clear_highlights(bufnr, ns_id)

	for target, label in pairs(hints) do
		if label:sub(1, 1) == active_prefix then
			local col = target.start_pos
			local first_char = label:sub(1, 1)
			local second_char = label:sub(2, 2)

			vim.api.nvim_buf_set_extmark(
				bufnr,
				ns_id,
				target.line,
				col({
					virt_text = {
						{ first_char, "SmartMotionFirstChar" },
						{ second_char, "SmartMotionSecondChar" },
					},
					virt_text_pos = "overlay",
					hl_mode = "combine",
				})
			)
		end
	end
end

return M
