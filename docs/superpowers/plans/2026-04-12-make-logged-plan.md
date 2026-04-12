# Plan: Automatic Debug Logging via `make_logged`

## Context

All modules have manual `log_usecase.debug("[module->func]:..." .. vim.inspect({...}))` calls (11 total across usecases and UIs). This is boilerplate that's inconsistent and easy to forget. The user's nvim config (`~/.config/nvim/lua/application/helpers/make_logged.lua`) already solves this with a metatable proxy pattern. This plan ports that pattern to devdocs.nvim and applies it to all layers.

Spec: `docs/superpowers/specs/2026-04-12-make-logged-design.md`

## Steps

### Step 1: Create `application/helpers/make_logged.lua`

**File:** `lua/devdocs/application/helpers/make_logged.lua`

```lua
local log_usecase = require("devdocs.application.usecases.log_usecase")

return function(module_name, module)
  return setmetatable({}, {
    __index = function(_, func_name)
      local original = module[func_name]

      if type(original) ~= "function" then
        return original
      end

      return function(...)
        log_usecase.debug(
          "[" .. module_name .. "->" .. func_name .. "]:" .. vim.inspect({ ... })
        )
        return original(...)
      end
    end,
  })
end
```

### Step 2: Remove manual debug logs and wrap usecases

For each usecase file, remove all `log_usecase.debug(...)` lines, remove `require("log_usecase")` lines that existed only for debug calls, add `require("make_logged")`, and wrap the return.

**Files:**

- `lua/devdocs/application/usecases/documentations_usecase.lua` — remove 4 debug lines, wrap return
- `lua/devdocs/application/usecases/entries_usecase.lua` — remove 2 debug lines, wrap return
- `lua/devdocs/application/usecases/registries_usecase.lua` — remove 3 debug lines, wrap return
- `lua/devdocs/application/usecases/lifecycle_usecase.lua` — remove 1 debug line, wrap return

Pattern for each:

```lua
local make_logged = require("devdocs.application.helpers.make_logged")
-- ... existing code with debug lines removed ...
return make_logged("documentations_usecase", { install = ..., show = ... })
```

### Step 3: Remove manual debug logs and wrap UIs

**File:** `lua/devdocs/infrastructure/uis/documentations_ui.lua` — remove 2 debug lines, wrap return

### Step 4: Wrap repositories

No debug lines to remove (they have log calls inside functions for non-entry-point logging). Add `make_logged` wrapper to return.

**Files:**

- `lua/devdocs/infrastructure/repositories/documentations_repository.lua`
- `lua/devdocs/infrastructure/repositories/documents_repository.lua`
- `lua/devdocs/infrastructure/repositories/entries_repository.lua`
- `lua/devdocs/infrastructure/repositories/locks_repository.lua`
- `lua/devdocs/infrastructure/repositories/registeries_repository.lua`

### Step 5: Wrap requests

**Files:**

- `lua/devdocs/infrastructure/requests/documentations_request.lua`
- `lua/devdocs/infrastructure/requests/documents_request.lua`
- `lua/devdocs/infrastructure/requests/entries_request.lua`
- `lua/devdocs/infrastructure/requests/registries_request.lua`

### Step 6: Wrap clients and adapters

**Files:**

- `lua/devdocs/infrastructure/clients/http_client.lua`
- `lua/devdocs/infrastructure/clients/pandas_client.lua`
- `lua/devdocs/infrastructure/adapters/buffer.lua`
- `lua/devdocs/infrastructure/adapters/notifier.lua`
- `lua/devdocs/infrastructure/adapters/path.lua`
- `lua/devdocs/infrastructure/adapters/devdocs_adapter.lua`

**Not wrapped:** `log_usecase.lua` (circular dependency).

### Step 7: Write unit test for `make_logged`

**File:** `tests/unit/helpers/make_logged_spec.lua`

Test cases:

- Function calls forwarded with correct args and return values
- Debug log emitted with correct format `[module->func]:{args}`
- Non-function fields pass through without logging
- Multiple args serialized correctly

Mock `log_usecase` via `package.loaded` before requiring `make_logged`.

### Step 8: Update existing tests

Remove any assertions about manual debug log messages in existing test files. The `make_logged` proxy is transparent to tests since they mock via `package.loaded` before `require`.

**Files to check:**

- `tests/unit/usecases/documentations_usecase_spec.lua`
- `tests/unit/usecases/entries_usecase_spec.lua`
- `tests/unit/usecases/registries_usecase_spec.lua`
- `tests/unit/usecases/lifecycle_usecase_spec.lua`
- `tests/unit/usecases/log_usecase_spec.lua`

## Files Modified

| File                                                          | Action                      |
| ------------------------------------------------------------- | --------------------------- |
| `lua/devdocs/application/helpers/make_logged.lua`             | Create                      |
| `lua/devdocs/application/usecases/documentations_usecase.lua` | Remove debug lines, wrap    |
| `lua/devdocs/application/usecases/entries_usecase.lua`        | Remove debug lines, wrap    |
| `lua/devdocs/application/usecases/registries_usecase.lua`     | Remove debug lines, wrap    |
| `lua/devdocs/application/usecases/lifecycle_usecase.lua`      | Remove debug lines, wrap    |
| `lua/devdocs/infrastructure/uis/documentations_ui.lua`        | Remove debug lines, wrap    |
| 5 repository files                                            | Wrap return                 |
| 4 request files                                               | Wrap return                 |
| 2 client files                                                | Wrap return                 |
| 4 adapter files                                               | Wrap return                 |
| `tests/unit/helpers/make_logged_spec.lua`                     | Create                      |
| Existing test files                                           | Remove debug log assertions |

## Verification

```bash
# Run all tests
nvim -l tests/minit.lua --minitest

# Confirm no manual debug log calls remain
grep -rn "log_usecase.debug" lua/devdocs/ --include="*.lua"
# Should return zero results (only make_logged calls log_usecase.debug)
```
