# Design: Automatic Debug Logging via `make_logged` Wrapper

## Problem

Manual `log_usecase.debug("[module->func]:..." .. vim.inspect({...}))` calls are scattered across 11 call sites in usecases and UIs. This is boilerplate-heavy, inconsistent (some functions log args, some don't), and easy to forget when adding new functions.

## Solution

A single higher-order function `make_logged(module_name, module)` that returns a metatable proxy. Any function call on the proxy automatically logs the module name, function name, and arguments via `log_usecase.debug`, then forwards the call. Non-function fields pass through unchanged.

## Location

`lua/devdocs/application/helpers/make_logged.lua`

Same placement as the user's nvim config pattern. Depends on `log_usecase` (same layer). Uses `vim.inspect` for argument serialization — allowed as a pure utility exception to the infrastructure-only vim API rule.

## Log Format

```
[module_name->function_name]: {arg1 = value1, arg2 = value2}
```

Arguments are serialized with `vim.inspect({...})`.

## Wrapping Strategy

Each module wraps itself at the return statement:

```lua
local make_logged = require("devdocs.application.helpers.make_logged")

local M = {
  find = function(id) ... end,
  list = function() ... end,
}

return make_logged("registries_usecase", M)
```

Consumers don't change — `require()` returns the logged proxy transparently.

## Modules to Wrap

| Layer        | Modules                                                |
| ------------ | ------------------------------------------------------ |
| Usecases     | documentations, entries, registries, lifecycle         |
| UIs          | documentations_ui                                      |
| Repositories | documentations, documents, entries, locks, registeries |
| Requests     | documentations, documents, entries, registries         |
| Clients      | http_client, pandas_client                             |
| Adapters     | buffer, notifier, path, devdocs_adapter                |

**Excluded:** `log_usecase` — wrapping it would create a circular dependency since `make_logged` depends on it.

## What Gets Removed

All 11 manual `log_usecase.debug(...)` calls across:

- `documentations_usecase.lua` (4 calls)
- `registries_usecase.lua` (2 calls)
- `entries_usecase.lua` (2 calls)
- `lifecycle_usecase.lua` (1 call)
- `documentations_ui.lua` (2 calls)

Also remove `require("devdocs.application.usecases.log_usecase")` lines that existed solely for those debug calls.

## Tests

Existing tests mock modules via `package.loaded` before `require`. The proxy wraps whatever the mock returns, so tests remain transparent. The only test changes needed are removing assertions about manual debug log messages.

A unit test for `make_logged` itself verifies:

- Function calls are forwarded with correct arguments and return values
- Debug log is emitted with correct format (module name, function name, args)
- Non-function fields pass through without logging
- Debug logging respects `setup_config.debug_mode` (via log_usecase)
