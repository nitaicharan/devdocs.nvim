return {
  debug_mode = false,
  plataform = "devdocs",
  dir_path = vim.fn.stdpath("data") .. "/devdocs",
  telescope = {},
  filetypes = {},
  float_win = {
    relative = "editor",
    height = 25,
    width = 100,
    border = "rounded",
  },
  wrap = false,
  previewer_cmd = nil,
  cmd_args = {},
  cmd_ignore = {},
  picker_cmd = false,
  picker_cmd_args = {},
  ensure_installed = {},
  mappings = {
    open_in_browser = "",
  },
  after_open = function() end,
}
