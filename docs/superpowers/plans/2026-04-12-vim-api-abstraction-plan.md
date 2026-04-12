# Plan: Move vim.* Calls to Infrastructure Adapters

## Context

The codebase follows clean architecture but has `vim.*` API calls leaking into the application layer (`log_usecase.lua`, `documentations_usecase.lua`) and domain layer (`setup_config.lua`). This refactor moves all Neovim API calls into infrastructure adapter modules so only the infrastructure layer touches vim APIs.

Spec: `docs/superpowers/specs/2026-04-12-vim-api-abstraction-design.md`

## Steps

### Step 1: Create `infrastructure/adapters/notifier.lua`

**File:** `lua/devdocs/infrastructure/adapters/notifier.lua`

Wrap `vim.schedule_wrap`, `vim.notify`, and `vim.log.levels`:

```lua
local notify = vim.schedule_wrap(function(message, level)
  vim.notify(message, level)
end)

return {
  notify = notify,
  levels = vim.log.levels,
}
```

### Step 2: Create `infrastructure/adapters/buffer.lua`

**File:** `lua/devdocs/infrastructure/adapters/buffer.lua`

Wrap the 5-line buffer creation block from `documentations_usecase.lua:88-92`:

```lua
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

### Step 3: Create `infrastructure/adapters/path.lua`

**File:** `lua/devdocs/infrastructure/adapters/path.lua`

Wrap `vim.fn.stdpath`:

```lua
return {
  stdpath = function(what)
    return vim.fn.stdpath(what)
  end,
}
```

### Step 4: Refactor `log_usecase.lua`

**File:** `lua/devdocs/application/usecases/log_usecase.lua`

- Remove `vim.schedule_wrap` and `vim.notify` calls
- Require `devdocs.infrastructure.adapters.notifier`
- Use `notifier.notify(message, notifier.levels.DEBUG)` etc.

### Step 5: Refactor `documentations_usecase.lua`

**File:** `lua/devdocs/application/usecases/documentations_usecase.lua`

- Add `buffer` as a parameter to the `show` function signature
- Replace lines 88-92 (`vim.api.nvim_create_buf` block) with `buffer.create_scratch_buffer(lines, 'markdown')`
- Add assertion for buffer param
- Update `IDocumentationsUseCase` type annotation for `show`

### Step 6: Refactor `setup_config.lua`

**File:** `lua/devdocs/domain/defaults/setup_config.lua`

- Replace `vim.fn.stdpath("data")` with `require("devdocs.infrastructure.adapters.path").stdpath("data")`

### Step 7: Update `log_usecase_spec.lua`

**File:** `tests/unit/usecases/log_usecase_spec.lua`

- Remove `vim.notify` and `vim.schedule_wrap` mocking (lines 11-16, 27)
- Instead mock the notifier adapter via `package.loaded["devdocs.infrastructure.adapters.notifier"]`
- Mock should capture calls to `notify(message, level)` and expose `levels = vim.log.levels`

### Step 8: Update `documentations_usecase_spec.lua`

**File:** `tests/unit/usecases/documentations_usecase_spec.lua`

- Remove `vim.api.*` mocking/restore (lines 192-209, 254-261)
- Create a mock buffer adapter: `{ create_scratch_buffer = function(lines, ft) ... end }`
- Pass mock buffer adapter as parameter to `usecase.show(...)`
- Update all `show` call sites to include the buffer adapter param

### Step 9: Update callers of `documentations_usecase.show`

Find and update any UI/API code that calls `show` to pass the buffer adapter.

**Files to check:**
- `lua/devdocs/infrastructure/uis/` — UI controllers
- `lua/devdocs/infrastructure/apis/` — API surface

## Files Modified

| File | Action |
|------|--------|
| `lua/devdocs/infrastructure/adapters/notifier.lua` | Create |
| `lua/devdocs/infrastructure/adapters/buffer.lua` | Create |
| `lua/devdocs/infrastructure/adapters/path.lua` | Create |
| `lua/devdocs/application/usecases/log_usecase.lua` | Refactor |
| `lua/devdocs/application/usecases/documentations_usecase.lua` | Refactor |
| `lua/devdocs/domain/defaults/setup_config.lua` | Refactor |
| `tests/unit/usecases/log_usecase_spec.lua` | Update mocks |
| `tests/unit/usecases/documentations_usecase_spec.lua` | Update mocks + show signature |
| Callers of `documentations_usecase.show` | Pass buffer adapter |

## Verification

```bash
# Run all tests
nvim -l tests/minit.lua --minitest

# Confirm no vim.* calls remain outside infrastructure
grep -rn "vim\." lua/devdocs/application/ lua/devdocs/domain/ --include="*.lua" | grep -v "vim.inspect\|vim.split\|vim.tbl_values\|vim.deepcopy"
```

The grep should return zero results — all `vim.*` API calls should only exist in `lua/devdocs/infrastructure/`.
