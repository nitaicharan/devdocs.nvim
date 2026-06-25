# devdocs.nvim

devdocs.nvim brings [DevDocs](https://devdocs.io) documentation into Neovim with offline support, Snacks.nvim-based search, and pandoc-powered HTML→Markdown conversion.

## Requirements

- Neovim 0.10+
- [pandoc](https://pandoc.org) (system binary, required — HTML→Markdown conversion)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)

## Installation

### lazy.nvim

```lua
{
  "nitaicharan/devdocs.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    -- "MeanderingProgrammer/render-markdown.nvim",
  },
  opts = {}
}
```

## Configuration

```lua
require("devdocs").setup({
  debug_mode = false,
  dir_path = vim.fn.stdpath("data") .. "/devdocs",
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
  after_open = function(bufnr) end,
})
```

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `debug_mode` | `boolean` | `false` | Enable debug logging |
| `dir_path` | `string` | `stdpath("data").."/devdocs"` | Storage directory for downloaded docs |
| `float_win` | `table` | see defaults | Options passed to `nvim_open_win()` for the floating window |
| `wrap` | `boolean` | `false` | Enable text wrap in the floating window |
| `previewer_cmd` | `string\|nil` | `nil` | External previewer command (e.g. `"glow"`) |
| `cmd_args` | `string[]` | `{}` | Arguments for `previewer_cmd` |
| `cmd_ignore` | `string[]` | `{}` | Doc slugs to skip external rendering for |
| `picker_cmd` | `boolean` | `false` | Use `previewer_cmd` inside the picker preview |
| `picker_cmd_args` | `string[]` | `{}` | Arguments for the picker previewer command |
| `ensure_installed` | `string[]` | `{}` | Doc slugs to auto-install on setup |
| `mappings.open_in_browser` | `string` | `""` | Keymap to open the current doc in a browser |
| `after_open` | `function` | no-op | Callback invoked after the doc window opens; receives `bufnr` |

## Usage

devdocs.nvim does not register Neovim commands. Wire them up from your own config:

```lua
local devdocs = require("devdocs")

vim.api.nvim_create_user_command("DevdocsInstall", function(opts)
  devdocs.ui.documentations.install(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })

vim.api.nvim_create_user_command("DevdocsShow", function(opts)
  devdocs.ui.documentations.show(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })
```

Or as keymaps:

```lua
vim.keymap.set("n", "<leader>di", function() require("devdocs").ui.documentations.install() end)
vim.keymap.set("n", "<leader>ds", function() require("devdocs").ui.documentations.show() end)
```

Install is fully non-blocking — a notification appears when the download and pandoc conversion complete.

## Contributing

Pull requests and feature requests are welcome! If you encounter rendering issues with a particular doc, feel free to open an [issue](https://github.com/nitaicharan/devdocs.nvim/issues).

## Similar Projects

- [nvim-telescope-zeal-cli](https://gitlab.com/ivan-cukic/nvim-telescope-zeal-cli) — Zeal documentation in Neovim Telescope.
- [devdocs.vim](https://github.com/girishji/devdocs.vim) — similar features using vimscript and pandoc.

## Credits

- [The DevDocs project](https://github.com/freeCodeCamp/devdocs) for the documentation.
- [devdocs.el](https://github.com/astoff/devdocs.el) for inspiration.
