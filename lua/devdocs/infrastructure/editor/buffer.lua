local make_logged = require("devdocs.application.helpers.make_logged")

---@type RendererPort
local M = {
  create_scratch_buffer = function(lines, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_set_current_buf(buf)
    return buf
  end
}

return make_logged("editor/buffer", M)
