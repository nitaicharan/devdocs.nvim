# Async Pandoc Conversion — Design Spec

## Context

The previous async work (HTTP fetching) is done and committed. However, `:DevdocsInstall` still blocks Neovim because `documentations_repository.save()` calls `pandas_client.html_to_markdown()` (which uses `vim.fn.system("pandoc ...")`) synchronously in a loop — once per document page. Large doc sets (e.g., JavaScript) have hundreds of pages, each spawning a blocking pandoc process.

## Problem

`repository.save(documentation, registry.slug)` runs inside a `vim.schedule_wrap` callback (on the main Neovim thread). The `for slug, document in pairs(documentation)` loop calls `vim.fn.system()` per page, blocking the UI until all conversions complete.

## Design

**Approach:** Sequential async — convert pages one at a time using `vim.system()` (Neovim 0.10+, async subprocess API). Neovim stays responsive between conversions. Simple, no concurrency management needed.

### Components

**1. `pandas_client.html_to_markdown_async(html, on_success)`**

- Spawns pandoc via `vim.system()` with stdin input and `on_exit` callback
- Collects stdout, calls `on_success(markdown)` when process exits
- `vim.system()` callback runs on the main thread (no `vim.schedule_wrap` needed)

**2. `documentations_repository.save_async(documentation, id, on_done)`**

- Converts `pairs(documentation)` to an indexed list for sequential iteration
- Processes pages one at a time: convert page N async → write file → convert page N+1 → ... → call `on_done()`
- Uses a recursive `process_next()` pattern to chain async steps
- File writes (`file_util.write`) stay synchronous (fast, runs on main thread between async steps)

**3. `documentations_usecase` callback**

- Replace `repository.save(documentation, registry.slug)` with `repository.save_async(documentation, registry.slug, function() ... end)`
- The rest of the chain (entries install, lock save) moves inside the `on_done` callback

### Interface changes

```
pandas_client:
  + html_to_markdown_async(html: string, on_success: fun(markdown: string))

documentations_repository:
  + save_async(documentation: table<string,string>, id: string, on_done: fun())

documentations_usecase:
  (no interface change — internal callback body updated)
```

### Error handling

- If pandoc fails (non-zero exit), log error and stop processing remaining pages (same as current `xpcall` behavior that returns early on failure)
- `on_done` is NOT called on error (matches current behavior where sync save returns early)

### Testing

- `pandas_client` tests mock `vim.system` to invoke the `on_exit` callback synchronously
- Repository tests mock `pandas_client.html_to_markdown_async` to invoke callback synchronously
- Usecase tests mock `repository.save_async` to invoke `on_done` synchronously
- All tests remain synchronous — no async test infrastructure needed

### Minimum Neovim version

0.10+ (required for `vim.system()`)

---

_Previous plan (Tasks 1-6 for async HTTP) already implemented and committed._

---

## Implementation Plan: Async Pandoc Conversion

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make pandoc HTML→MD conversion non-blocking so Neovim stays responsive during doc installation.

**Architecture:** Add `html_to_markdown_async` to pandas_client using `vim.system()`. Add `save_async` to documentations_repository with sequential async page processing. Update the usecase to chain `save_async` into the existing async flow.

**Tech Stack:** `vim.system()` (Neovim 0.10+)

---

### Task 7: Add `html_to_markdown_async` to pandas_client

**Files:**

- Modify: `lua/devdocs/infrastructure/clients/pandas_client.lua`
- Modify: `tests/integration/clients/pandas_client_spec.lua`

- [ ] **Step 1: Write failing tests for `html_to_markdown_async`**

Add a new `describe("html_to_markdown_async", ...)` block to `tests/integration/clients/pandas_client_spec.lua`:

```lua
describe("html_to_markdown_async", function()
  it("converts HTML to markdown asynchronously", function()
    local result
    local done = false

    pandas_client.html_to_markdown_async("<h1>Hello</h1>", function(markdown)
      result = markdown
      done = true
    end)

    -- vim.system is async; in test env we need to wait for completion
    vim.wait(5000, function() return done end)

    assert.is_true(done)
    assert.is_not_nil(result)
    assert.is_not_nil(string.find(result, "Hello"))
  end)

  it("handles empty HTML input", function()
    local result
    local done = false

    pandas_client.html_to_markdown_async("", function(markdown)
      result = markdown
      done = true
    end)

    vim.wait(5000, function() return done end)

    assert.is_true(done)
    assert.is_not_nil(result)
  end)

  it("asserts on non-string html", function()
    assert.has_error(function() pandas_client.html_to_markdown_async(123, function() end) end)
  end)

  it("asserts on non-function callback", function()
    assert.has_error(function() pandas_client.html_to_markdown_async("<h1>X</h1>", "not a fn") end)
  end)
end)
```

**Note:** These are integration tests (like the existing pandoc tests) because they spawn real pandoc. Use `vim.wait()` to block the test until the async callback fires.

- [ ] **Step 2: Run tests to verify they fail**

Run: `nvim -l tests/minit.lua --minitest tests/integration/clients/pandas_client_spec.lua`

- [ ] **Step 3: Implement `html_to_markdown_async`**

In `lua/devdocs/infrastructure/clients/pandas_client.lua`, add to the module table:

```lua
html_to_markdown_async = function(html, on_success)
  assert(type(html) == "string", "html must be a string")
  assert(type(on_success) == "function", "on_success must be a function")

  local transpile_command = {
    "pandoc",
    "--from", "html",
    "--to", "gfm-raw_html",
    "--wrap", "none",
  }

  vim.system(transpile_command, { stdin = html }, function(result)
    on_success(result.stdout)
  end)
end
```

Update the type annotation:

```lua
---@class IPandasClient
---@field html_to_markdown fun(html: string): string
---@field html_to_markdown_async fun(html: string, on_success: fun(markdown: string))
```

`vim.system()` with a callback is non-blocking. The callback runs on the main Neovim thread (no `vim.schedule_wrap` needed).

- [ ] **Step 4: Run tests to verify they pass**

Run: `nvim -l tests/minit.lua --minitest tests/integration/clients/pandas_client_spec.lua`

- [ ] **Step 5: Commit**

```
feat(pandas_client): add html_to_markdown_async using vim.system
```

---

### Task 8: Add `save_async` to documentations_repository

**Files:**

- Modify: `lua/devdocs/infrastructure/repositories/documentations_repository.lua`
- Create: `tests/unit/repositories/documentations_repository_spec.lua`

- [ ] **Step 1: Write failing tests for `save_async`**

```lua
-- tests/unit/repositories/documentations_repository_spec.lua
local assert = require("luassert")

describe("documentations_repository", function()
  local repository
  local written_files
  local converted_slugs

  before_each(function()
    written_files = {}
    converted_slugs = {}

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.clients.pandas_client"] = {
      html_to_markdown_async = function(html, on_success)
        table.insert(converted_slugs, html)
        on_success("# converted")
      end,
    }

    package.loaded["devdocs.infrastructure.utils.files_util"] = {
      joinpath = function(...) return table.concat({ ... }, "/") end,
      write = function(path, content)
        table.insert(written_files, { path = path, content = content })
      end,
    }

    package.loaded["devdocs.domain.defaults.setup_config"] = {
      plataform = "test",
    }

    package.loaded["devdocs.infrastructure.repositories.documentations_repository"] = nil
    repository = require("devdocs.infrastructure.repositories.documentations_repository")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.clients.pandas_client"] = nil
    package.loaded["devdocs.infrastructure.utils.files_util"] = nil
    package.loaded["devdocs.domain.defaults.setup_config"] = nil
    package.loaded["devdocs.infrastructure.repositories.documentations_repository"] = nil
  end)

  describe("save_async", function()
    it("converts and writes all pages sequentially", function()
      local documentation = {
        ["page1"] = "<h1>Page 1</h1>",
        ["page2"] = "<h1>Page 2</h1>",
      }
      local done_called = false

      repository.save_async(documentation, "lua~5.4", function()
        done_called = true
      end)

      assert.is_true(done_called)
      assert.equals(2, #written_files)
      assert.equals(2, #converted_slugs)
    end)

    it("calls on_done with empty documentation", function()
      local done_called = false

      repository.save_async({}, "lua~5.4", function()
        done_called = true
      end)

      assert.is_true(done_called)
      assert.equals(0, #written_files)
    end)

    it("asserts on non-table documentation", function()
      assert.has_error(function()
        repository.save_async("not a table", "lua~5.4", function() end)
      end)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        repository.save_async({}, 123, function() end)
      end)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `nvim -l tests/minit.lua --minitest tests/unit/repositories/documentations_repository_spec.lua`

- [ ] **Step 3: Implement `save_async`**

In `lua/devdocs/infrastructure/repositories/documentations_repository.lua`, add to the module table:

```lua
save_async = function(documentation, id, on_done)
  assert(type(documentation) == "table", "documentations param is required")
  assert(type(id) == "string", "id must be a string")
  assert(type(on_done) == "function", "on_done must be a function")

  local pandas_client = require("devdocs.infrastructure.clients.pandas_client")
  local file_util = require("devdocs.infrastructure.utils.files_util")
  local setup_config = require("devdocs.domain.defaults.setup_config")

  -- Convert pairs iterator to indexed list for sequential processing
  local pages = {}
  for slug, document in pairs(documentation) do
    table.insert(pages, { slug = slug, document = document })
  end

  local index = 1

  local function process_next()
    if index > #pages then
      on_done()
      return
    end

    local page = pages[index]
    index = index + 1

    pandas_client.html_to_markdown_async(page.document, function(markdown)
      local path = file_util.joinpath(
        vim.fn.stdpath("data"), "devdocs", setup_config.plataform, id, page.slug .. ".md"
      )
      file_util.write(path, markdown)
      process_next()
    end)
  end

  process_next()
end,
```

Update the type annotation:

```lua
---@class IDocumentationsRepository
---@field save fun(documentations: table<string,string>, slug: string)
---@field save_async fun(documentations: table<string,string>, slug: string, on_done: fun())
---@field find fun(is: string, slug: string): string
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `nvim -l tests/minit.lua --minitest tests/unit/repositories/documentations_repository_spec.lua`

- [ ] **Step 5: Run full test suite**

Run: `nvim -l tests/minit.lua --minitest`

- [ ] **Step 6: Commit**

```
feat(documentations_repository): add save_async for non-blocking pandoc conversion
```

---

### Task 9: Wire `save_async` into documentations_usecase

**Files:**

- Modify: `lua/devdocs/application/usecases/documentations_usecase.lua`
- Modify: `tests/unit/usecases/documentations_usecase_spec.lua`

- [ ] **Step 1: Update test mock_repository to include `save_async`**

In `tests/unit/usecases/documentations_usecase_spec.lua`, in the "fetches, saves doc" test, change mock_repository:

```lua
local mock_repository = {
  save_async = function(doc, slug, on_done)
    saved_doc_args = { doc = doc, slug = slug }
    on_done()
  end,
}
```

Also update any other tests that create mock_repository with `save` to use `save_async`.

- [ ] **Step 2: Run tests to see failures**

Run: `nvim -l tests/minit.lua --minitest tests/unit/usecases/documentations_usecase_spec.lua`

- [ ] **Step 3: Update the usecase callback to use `repository.save_async`**

In `lua/devdocs/application/usecases/documentations_usecase.lua`, change the callback from:

```lua
repository.save(documentation, registry.slug)

entries_usecase.install_async(entries_request, entries_repository, registry.slug, function()
  locks_repository.save({ id = registry.slug, name = registry.name })
  log_usecase.info(string.format("%s documentation installed successfully", registry.name))
end)
```

To:

```lua
repository.save_async(documentation, registry.slug, function()
  entries_usecase.install_async(entries_request, entries_repository, registry.slug, function()
    locks_repository.save({ id = registry.slug, name = registry.name })
    log_usecase.info(string.format("%s documentation installed successfully", registry.name))
  end)
end)
```

- [ ] **Step 4: Run all tests**

Run: `nvim -l tests/minit.lua --minitest`
Expected: ALL PASS

- [ ] **Step 5: Commit**

```
feat(documentations_usecase): use save_async for non-blocking pandoc conversion
```

---

## Verification

1. **Unit tests**: `nvim -l tests/minit.lua --minitest` — all pass
2. **Manual test**: Open Neovim, run `:DevdocsInstall`, pick a doc — Neovim should remain fully responsive during the entire install process (HTTP fetch + pandoc conversion + file writes)
