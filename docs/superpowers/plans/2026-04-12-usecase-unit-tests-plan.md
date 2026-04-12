# Usecase Unit Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add unit tests for all 5 usecase modules with fully mocked dependencies using plain Lua stub tables and `package.loaded` stubbing.

**Architecture:** One test file per usecase in `test/usecases/`. Each test stubs all dependencies (injected and `require()`d) via `package.loaded` in `before_each`, cleans up in `after_each`. Tests use Plenary's Busted runner and luassert.

**Tech Stack:** Plenary.nvim (Busted test runner, luassert), Neovim headless mode

---

### Task 1: registries_usecase tests

**Files:**
- Create: `test/usecases/registries_usecase_spec.lua`

- [ ] **Step 1: Write the test file with all tests**

```lua
local assert = require("luassert")

describe("registries_usecase", function()
  local usecase
  local saved_data

  before_each(function()
    saved_data = nil

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    usecase = require("devdocs.application.usecases.registries_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
  end)

  describe("install", function()
    it("fetches and saves registry when not installed", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      local mock_request = { list = function() return mock_data end }
      local mock_repository = {
        list = function() return nil end,
        save = function(data) saved_data = data end,
      }

      usecase.install(mock_request, mock_repository)

      assert.same(mock_data, saved_data)
    end)

    it("skips fetch when registry already exists", function()
      local mock_request = { list = function() error("should not be called") end }
      local mock_repository = {
        list = function() return { { slug = "lua" } } end,
        save = function() error("should not be called") end,
      }

      usecase.install(mock_request, mock_repository)
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {})
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil)
      end)
    end)
  end)

  describe("list", function()
    it("returns repository result", function()
      local mock_data = { { slug = "lua", name = "Lua" } }
      local mock_repository = { list = function() return mock_data end }

      local result = usecase.list(mock_repository)

      assert.same(mock_data, result)
    end)

    it("returns nil when repository has no data", function()
      local mock_repository = { list = function() return nil end }

      local result = usecase.list(mock_repository)

      assert.is_nil(result)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.list(nil)
      end)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/registries_usecase_spec.lua"`
Expected: All 7 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/usecases/registries_usecase_spec.lua
git commit -m "test: add registries_usecase unit tests"
```

---

### Task 2: lifecycle_usecase tests

**Files:**
- Create: `test/usecases/lifecycle_usecase_spec.lua`

- [ ] **Step 1: Write the test file with all tests**

```lua
local assert = require("luassert")

describe("lifecycle_usecase", function()
  local usecase
  local registries_install_args

  before_each(function()
    registries_install_args = nil

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = {
      install = function(request, repository)
        registries_install_args = { request = request, repository = repository }
      end,
    }

    package.loaded["devdocs.application.usecases.lifecycle_usecase"] = nil
    usecase = require("devdocs.application.usecases.lifecycle_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    package.loaded["devdocs.application.usecases.lifecycle_usecase"] = nil
  end)

  describe("on_plugin_init", function()
    it("calls registries_usecase.install with correct args", function()
      local mock_request = { list = function() end }
      local mock_repository = { save = function() end, list = function() end }

      usecase.on_plugin_init(mock_request, mock_repository)

      assert.is_not_nil(registries_install_args)
      assert.equals(mock_request, registries_install_args.request)
      assert.equals(mock_repository, registries_install_args.repository)
    end)

    it("asserts on nil registries_request", function()
      assert.has_error(function()
        usecase.on_plugin_init(nil, {})
      end)
    end)

    it("asserts on nil registries_repository", function()
      assert.has_error(function()
        usecase.on_plugin_init({}, nil)
      end)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/lifecycle_usecase_spec.lua"`
Expected: All 3 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/usecases/lifecycle_usecase_spec.lua
git commit -m "test: add lifecycle_usecase unit tests"
```

---

### Task 3: entries_usecase tests

**Files:**
- Create: `test/usecases/entries_usecase_spec.lua`

- [ ] **Step 1: Write the test file with all tests**

```lua
local assert = require("luassert")

describe("entries_usecase", function()
  local usecase
  local saved_entries
  local saved_id

  before_each(function()
    saved_entries = nil
    saved_id = nil

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.infrastructure.repositories.entries_repository"] = {
      find = function(id) return { { name = "Array", path = "array", type = "Method", slug = id } } end,
    }

    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
    usecase = require("devdocs.application.usecases.entries_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.infrastructure.repositories.entries_repository"] = nil
    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
  end)

  describe("install", function()
    it("fetches and saves entries", function()
      local mock_entries = { { name = "Array", path = "array" } }
      local mock_request = { list = function() return mock_entries end }
      local mock_repository = {
        save = function(entries, id)
          saved_entries = entries
          saved_id = id
        end,
      }

      usecase.install(mock_request, mock_repository, "lua~5.4")

      assert.same(mock_entries, saved_entries)
      assert.equals("lua~5.4", saved_id)
    end)

    it("returns early when request returns nil", function()
      local mock_request = { list = function() return nil end }
      local mock_repository = {
        save = function() error("should not be called") end,
      }

      usecase.install(mock_request, mock_repository, "lua~5.4")
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {}, "lua~5.4")
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil, "lua~5.4")
      end)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        usecase.install({}, {}, 123)
      end)
    end)
  end)

  describe("find", function()
    it("returns entries from repository", function()
      local result = usecase.find("lua~5.4")

      assert.same({ { name = "Array", path = "array", type = "Method", slug = "lua~5.4" } }, result)
    end)

    it("returns nil when repository has no data", function()
      package.loaded["devdocs.infrastructure.repositories.entries_repository"] = {
        find = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.entries_usecase"] = nil
      usecase = require("devdocs.application.usecases.entries_usecase")

      local result = usecase.find("nonexistent")

      assert.is_nil(result)
    end)

    it("asserts on non-string id", function()
      assert.has_error(function()
        usecase.find(123)
      end)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/entries_usecase_spec.lua"`
Expected: All 7 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/usecases/entries_usecase_spec.lua
git commit -m "test: add entries_usecase unit tests"
```

---

### Task 4: documentations_usecase tests

**Files:**
- Create: `test/usecases/documentations_usecase_spec.lua`

- [ ] **Step 1: Write the test file with all tests**

```lua
local assert = require("luassert")

describe("documentations_usecase", function()
  local usecase
  local saved_doc_args
  local saved_lock_args
  local entries_install_args
  local picker_registries_args
  local picker_locks_args
  local picker_entries_args
  local log_error_message
  local buf_lines
  local buf_filetype
  local created_buf

  before_each(function()
    saved_doc_args = nil
    saved_lock_args = nil
    entries_install_args = nil
    picker_registries_args = nil
    picker_locks_args = nil
    picker_entries_args = nil
    log_error_message = nil
    buf_lines = nil
    buf_filetype = nil
    created_buf = 42

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function(msg) log_error_message = msg end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = {
      list = function()
        return { { slug = "lua~5.4", name = "Lua" }, { slug = "javascript", name = "JavaScript" } }
      end,
    }

    package.loaded["devdocs.application.usecases.entries_usecase"] = {
      install = function(request, repository, slug)
        entries_install_args = { request = request, repository = repository, slug = slug }
      end,
      find = function(id)
        return { { name = "Array", path = "array#section", type = "Method" } }
      end,
    }

    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
    usecase = require("devdocs.application.usecases.documentations_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    package.loaded["devdocs.application.usecases.entries_usecase"] = nil
    package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
  end)

  describe("install", function()
    local mock_entries_request
    local mock_entries_repository

    before_each(function()
      mock_entries_request = { list = function() end }
      mock_entries_repository = { save = function() end }
    end)

    it("fetches, saves doc, installs entries, and saves lock when given id", function()
      local mock_doc = { html = "<h1>Lua</h1>" }
      local mock_request = { find = function() return mock_doc end }
      local mock_repository = {
        save = function(doc, slug)
          saved_doc_args = { doc = doc, slug = slug }
        end,
      }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = {
        save = function(data) saved_lock_args = data end,
      }
      local mock_picker = {}
      local mock_registry = { slug = "lua~5.4", name = "Lua" }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker, mock_registry
      )

      assert.same({ doc = mock_doc, slug = "lua~5.4" }, saved_doc_args)
      assert.same({ id = "lua~5.4", name = "Lua" }, saved_lock_args)
      assert.is_not_nil(entries_install_args)
      assert.equals("lua~5.4", entries_install_args.slug)
    end)

    it("returns early when request.find returns nil", function()
      local mock_request = { find = function() return nil end }
      local mock_repository = {
        save = function() error("should not be called") end,
      }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = {
        save = function() error("should not be called") end,
      }
      local mock_picker = {}
      local mock_registry = { slug = "lua~5.4", name = "Lua" }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker, mock_registry
      )
    end)

    it("delegates to picker when no id given", function()
      local mock_request = { find = function() end }
      local mock_repository = { save = function() end }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = { save = function() end }
      local mock_picker = {
        registries = function(callback, registries)
          picker_registries_args = { callback = callback, registries = registries }
        end,
      }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )

      assert.is_not_nil(picker_registries_args)
      assert.equals(2, #picker_registries_args.registries)
    end)

    it("errors when registries list returns nil", function()
      package.loaded["devdocs.application.usecases.registries_usecase"] = {
        list = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      local mock_request = { find = function() end }
      local mock_repository = { save = function() end }
      local mock_registries_repository = { list = function() end }
      local mock_locks_repository = { save = function() end }
      local mock_picker = { registries = function() error("should not be called") end }

      usecase.install(
        mock_request, mock_repository, mock_registries_repository,
        mock_entries_request, mock_entries_repository, mock_locks_repository,
        mock_picker
      )

      assert.equals("Registries not found!", log_error_message)
    end)

    it("asserts on nil request", function()
      assert.has_error(function()
        usecase.install(nil, {}, {}, {}, {}, {}, {})
      end)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.install({}, nil, {}, {}, {}, {}, {})
      end)
    end)

    it("asserts on nil picker", function()
      assert.has_error(function()
        usecase.install({}, {}, {}, {}, {}, {}, nil)
      end)
    end)
  end)

  describe("show", function()
    it("delegates to picker.locks when no id given", function()
      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback, locks)
          picker_locks_args = { callback = callback, locks = locks }
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker)

      assert.is_not_nil(picker_locks_args)
      assert.equals(1, #picker_locks_args.locks)
    end)

    it("locks callback fetches entries and delegates to picker.entries", function()
      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback, id, entries)
          picker_entries_args = { callback = callback, id = id, entries = entries }
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker)

      assert.is_not_nil(picker_entries_args)
      assert.equals("lua~5.4", picker_entries_args.id)
      assert.equals(1, #picker_entries_args.entries)
    end)

    it("entry callback reads document and creates buffer", function()
      local original_create_buf = vim.api.nvim_create_buf
      local original_buf_set_lines = vim.api.nvim_buf_set_lines
      local original_set_option_value = vim.api.nvim_set_option_value
      local original_set_current_buf = vim.api.nvim_set_current_buf

      vim.api.nvim_create_buf = function() return created_buf end
      vim.api.nvim_buf_set_lines = function(buf, start, finish, strict, lines)
        buf_lines = { buf = buf, lines = lines }
      end
      vim.api.nvim_set_option_value = function(key, value, opts)
        if key == "filetype" then buf_filetype = value end
      end
      vim.api.nvim_set_current_buf = function() end

      local mock_repository = {
        find = function() return "# Lua\n\nContent here" end,
      }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function(callback)
          callback({ name = "Array", path = "array#section" })
        end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker)

      assert.equals(created_buf, buf_lines.buf)
      assert.same({ "# Lua", "", "Content here" }, buf_lines.lines)
      assert.equals("markdown", buf_filetype)

      vim.api.nvim_create_buf = original_create_buf
      vim.api.nvim_buf_set_lines = original_buf_set_lines
      vim.api.nvim_set_option_value = original_set_option_value
      vim.api.nvim_set_current_buf = original_set_current_buf
    end)

    it("locks callback errors when entries not found", function()
      package.loaded["devdocs.application.usecases.entries_usecase"] = {
        install = function() end,
        find = function() return nil end,
      }

      package.loaded["devdocs.application.usecases.documentations_usecase"] = nil
      usecase = require("devdocs.application.usecases.documentations_usecase")

      local mock_repository = { find = function() end }
      local mock_locks_repository = {
        list = function()
          return { ["lua~5.4"] = { id = "lua~5.4", name = "Lua" } }
        end,
      }
      local mock_picker = {
        locks = function(callback)
          callback({ id = "lua~5.4", name = "Lua" })
        end,
        entries = function() error("should not be called") end,
      }

      usecase.show(mock_repository, mock_locks_repository, mock_picker)

      assert.is_not_nil(log_error_message)
    end)

    it("asserts on nil repository", function()
      assert.has_error(function()
        usecase.show(nil, {}, {})
      end)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/documentations_usecase_spec.lua"`
Expected: All 10 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/usecases/documentations_usecase_spec.lua
git commit -m "test: add documentations_usecase unit tests"
```

---

### Task 5: log_usecase tests

**Files:**
- Create: `test/usecases/log_usecase_spec.lua`

- [ ] **Step 1: Write the test file with all tests**

```lua
local assert = require("luassert")

describe("log_usecase", function()
  local usecase
  local notify_calls
  local original_schedule_wrap

  before_each(function()
    notify_calls = {}

    vim.notify = function(message, level)
      table.insert(notify_calls, { message = message, level = level })
    end

    original_schedule_wrap = vim.schedule_wrap
    vim.schedule_wrap = function(fn) return fn end

    package.loaded["devdocs.domain.defaults.setup_config"] = {
      debug_mode = false,
    }

    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    usecase = require("devdocs.application.usecases.log_usecase")
  end)

  after_each(function()
    vim.schedule_wrap = original_schedule_wrap
    package.loaded["devdocs.domain.defaults.setup_config"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
  end)

  describe("debug", function()
    it("calls vim.notify with DEBUG level when debug_mode is true", function()
      package.loaded["devdocs.domain.defaults.setup_config"] = { debug_mode = true }
      package.loaded["devdocs.application.usecases.log_usecase"] = nil
      usecase = require("devdocs.application.usecases.log_usecase")

      usecase.debug("test message")

      assert.equals(1, #notify_calls)
      assert.equals("test message", notify_calls[1].message)
      assert.equals(vim.log.levels.DEBUG, notify_calls[1].level)
    end)

    it("does not call vim.notify when debug_mode is false", function()
      usecase.debug("test message")

      assert.equals(0, #notify_calls)
    end)
  end)

  describe("info", function()
    it("calls vim.notify with INFO level", function()
      usecase.info("info message")

      assert.equals(1, #notify_calls)
      assert.equals("info message", notify_calls[1].message)
      assert.equals(vim.log.levels.INFO, notify_calls[1].level)
    end)
  end)

  describe("warn", function()
    it("calls vim.notify with WARN level", function()
      usecase.warn("warn message")

      assert.equals(1, #notify_calls)
      assert.equals("warn message", notify_calls[1].message)
      assert.equals(vim.log.levels.WARN, notify_calls[1].level)
    end)
  end)

  describe("error", function()
    it("calls vim.notify with ERROR level", function()
      usecase.error("error message")

      assert.equals(1, #notify_calls)
      assert.equals("error message", notify_calls[1].message)
      assert.equals(vim.log.levels.ERROR, notify_calls[1].level)
    end)
  end)
end)
```

- [ ] **Step 2: Run tests to verify they pass**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedFile test/usecases/log_usecase_spec.lua"`
Expected: All 5 tests pass

- [ ] **Step 3: Commit**

```bash
git add test/usecases/log_usecase_spec.lua
git commit -m "test: add log_usecase unit tests"
```

---

### Task 6: Final verification

- [ ] **Step 1: Run all usecase tests together**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedDirectory test/usecases/ { init='test/init.lua' }"`
Expected: All 32 tests pass across 5 files

- [ ] **Step 2: Run full test suite to check for regressions**

Run: `nvim --headless -u test/init.lua -c "PlenaryBustedDirectory test/ { init='test/init.lua' }"`
Expected: All tests pass (usecases + existing transpiler tests)
