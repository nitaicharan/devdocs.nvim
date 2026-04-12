# Usecase Unit Tests Design

## Goal

Add unit tests for all 5 usecase modules in `lua/devdocs/application/usecases/`, using plain Lua stub tables for mocking and `package.loaded` stubbing for internal requires.

## Test File Structure

```
test/
  usecases/
    registries_usecase_spec.lua
    lifecycle_usecase_spec.lua
    entries_usecase_spec.lua
    documentations_usecase_spec.lua
    log_usecase_spec.lua
```

One file per usecase, using Plenary's Busted runner (`describe`/`it`) and `luassert`.

## Mocking Approach

**Plain Lua stub tables** — no external mocking library.

### Injected dependencies (requests, repositories, pickers)

Passed directly as function arguments using simple tables:

```lua
local mock_request = { list = function() return { { slug = "lua" } } end }
local mock_repository = { save = function() end, list = function() return nil end }
```

### Internal requires (other usecases, domain config)

Stubbed via `package.loaded` before loading the usecase under test:

```lua
package.loaded["devdocs.application.usecases.log_usecase"] = {
  debug = function() end,
  error = function() end,
}
```

### Neovim APIs (vim.notify, vim.api, vim.schedule_wrap)

Stubbed on the `vim` global where needed (e.g., `log_usecase` tests stub `vim.notify` and `vim.schedule_wrap`; `documentations_usecase.show` stubs `vim.api` buffer functions).

### Lifecycle

- `before_each`: set up `package.loaded` stubs and mock tables
- `after_each`: clear `package.loaded` stubs to prevent leaking between tests

## Test Coverage Per Usecase

### registries_usecase (2 functions)

**`install(request, repository)`**

- Skips fetch and save when registry already exists (`repository.list()` returns data)
- Fetches via `request.list()` and saves via `repository.save()` when registry is nil
- Asserts error on nil request or repository

**`list(repository)`**

- Returns result from `repository.list()`
- Asserts error on nil repository

### lifecycle_usecase (1 function)

**`on_plugin_init(registries_request, registries_repository)`**

- Calls `registries_usecase.install` with the provided request and repository
- Asserts error on nil registries_request or registries_repository

### entries_usecase (2 functions)

**`install(request, repository, id)`**

- Fetches entries via `request.list(id)` and saves via `repository.save(entries, id)`
- Returns early without saving when `request.list()` returns nil
- Asserts error on nil request, nil repository, or non-string id

**`find(id)`**

- Returns result from repository (stubbed via `package.loaded` since it hard-requires `entries_repository`)
- Asserts error on non-string id

### documentations_usecase (2 functions)

**`install(request, repository, registries_repository, entries_request, entries_repository, locks_repository, picker, id)`**

- With id: fetches doc via `request.find(id)`, saves via `repository.save()`, installs entries, saves lock
- With id: returns early when `request.find()` returns nil
- Without id: calls `picker.registries()` with callback and registry list
- Errors when `registries_usecase.list()` returns nil
- Asserts error on nil required params

**`show(repository, locks_repository, picker, id)`**

- Without id: calls `picker.locks()` with locks callback and lock list
- Locks callback: fetches entries, then calls `picker.entries()` with entry callback
- Entry callback: reads document via `repository.find()`, creates buffer with content
- Vim API calls (`nvim_create_buf`, `nvim_buf_set_lines`, `nvim_set_option_value`, `nvim_set_current_buf`) are stubbed

### log_usecase (4 functions)

**`debug(message)`**

- Calls `vim.notify` with DEBUG level when `setup_config.debug_mode` is true
- Does not call `vim.notify` when `debug_mode` is false

**`info(message)`**

- Calls `vim.notify` with INFO level

**`warn(message)`**

- Calls `vim.notify` with WARN level

**`error(message)`**

- Calls `vim.notify` with ERROR level

## Running Tests

```bash
# All usecase tests
nvim --headless -u test/init.lua -c "PlenaryBustedDirectory test/usecases/ { init='test/init.lua' }"

# Single usecase test
nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/registries_usecase_spec.lua"
```
