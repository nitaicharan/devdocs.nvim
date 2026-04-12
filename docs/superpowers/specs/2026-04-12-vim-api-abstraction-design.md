# Vim API Abstraction — Move vim.\* Calls to Infrastructure Adapters

## Goal

Remove all direct `vim.*` API calls from the application and domain layers, moving them into infrastructure adapter modules. This enforces the clean architecture boundary: only infrastructure touches Neovim APIs.

## Scope

Only actual Neovim API calls move. Pure Lua utilities (`vim.inspect`, `vim.split`, `vim.tbl_values`) stay in place — they have no side effects and don't interact with the editor.

## Current State

| File                                              | vim.\* calls                                                                             | Layer       |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------- | ----------- |
| `application/usecases/documentations_usecase.lua` | `nvim_create_buf`, `nvim_buf_set_lines`, `nvim_set_option_value`, `nvim_set_current_buf` | application |
| `application/usecases/log_usecase.lua`            | `vim.schedule_wrap`, `vim.notify`, `vim.log.levels.*`                                    | application |
| `domain/defaults/setup_config.lua`                | `vim.fn.stdpath("data")`                                                                 | domain      |

## Design

### 3 New Infrastructure Adapters

All placed in `lua/devdocs/infrastructure/adapters/`.

#### 1. `buffer.lua`

Wraps Neovim buffer operations used by `documentations_usecase.show()`.

```lua
---@class IBufferAdapter
---@field create_scratch_buffer fun(lines: string[], filetype: string): number

return {
  create_scratch_buffer = function(lines, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value('filetype', filetype, { buf = buf })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
    vim.api.nvim_set_current_buf(buf)
    return buf
  end,
}
```

#### 2. `notifier.lua`

Wraps `vim.notify` with `vim.schedule_wrap` and exposes log-level functions.

```lua
---@class INotifierAdapter
---@field notify fun(message: string, level: number)

local notify = vim.schedule_wrap(function(message, level)
  vim.notify(message, level)
end)

return {
  notify = notify,
  levels = vim.log.levels,
}
```

#### 3. `path.lua`

Wraps `vim.fn.stdpath`.

```lua
---@class IPathAdapter
---@field stdpath fun(what: string): string

return {
  stdpath = function(what)
    return vim.fn.stdpath(what)
  end,
}
```

### Changes to Consumers

#### `log_usecase.lua`

Receives notifier via `require("devdocs.infrastructure.adapters.notifier")` internally, removing direct `vim.schedule_wrap`/`vim.notify`/`vim.log.levels` calls.

#### `documentations_usecase.lua`

The `show` function receives a `buffer` adapter parameter. The 5-line buffer creation block is replaced with a single call to `buffer.create_scratch_buffer(lines, 'markdown')`.

#### `setup_config.lua`

Uses `require("devdocs.infrastructure.adapters.path").stdpath("data")` instead of `vim.fn.stdpath("data")`.

### Test Impact

- **`log_usecase_spec.lua`**: Currently mocks `vim.notify` and `vim.schedule_wrap` directly. After refactor, mock the notifier adapter via `package.loaded` instead.
- **`documentations_usecase_spec.lua`**: Currently mocks `vim.api.*` functions. After refactor, pass a mock buffer adapter as a parameter — cleaner test isolation.
- **Other usecase specs**: No changes needed.

### Interface Types

New type definition files in `application/types/`:

- `buffer-adapter-type.lua` — defines `IBufferAdapter`
- `notifier-adapter-type.lua` — defines `INotifierAdapter`
- `path-adapter-type.lua` — defines `IPathAdapter`

These follow the existing pattern (e.g., `locks-repository-type.lua`).
