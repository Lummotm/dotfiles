local group = vim.api.nvim_create_augroup("macro-notify", { clear = true })

vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
	desc = "Notify when recording a macro",
	group = group,
	callback = function(ev)
		local register = vim.fn.reg_recording()
		if register == "" then
			register = "..."
		end

		local msg = ev.event == "RecordingEnter" and "Recording to register @" or "Recorded to register @"

		vim.notify(msg .. register, vim.log.levels.INFO, {
			title = "Macro",
			timeout = 3000,
		})
	end,
})
