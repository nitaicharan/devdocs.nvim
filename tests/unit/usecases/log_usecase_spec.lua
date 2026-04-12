local assert = require("luassert")

describe("log_usecase", function()
  local usecase
  local notify_calls

  before_each(function()
    notify_calls = {}

    package.loaded["devdocs.infrastructure.adapters.notifier"] = {
      notify = function(message, level)
        table.insert(notify_calls, { message = message, level = level })
      end,
      levels = vim.log.levels,
    }

    package.loaded["devdocs.domain.defaults.setup_config"] = {
      debug_mode = false,
    }

    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    usecase = require("devdocs.application.usecases.log_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.infrastructure.adapters.notifier"] = nil
    package.loaded["devdocs.domain.defaults.setup_config"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
  end)

  describe("debug", function()
    it("calls notify with DEBUG level when debug_mode is true", function()
      package.loaded["devdocs.domain.defaults.setup_config"] = { debug_mode = true }
      package.loaded["devdocs.application.usecases.log_usecase"] = nil
      usecase = require("devdocs.application.usecases.log_usecase")

      usecase.debug("test message")

      assert.equals(1, #notify_calls)
      assert.equals("test message", notify_calls[1].message)
      assert.equals(vim.log.levels.DEBUG, notify_calls[1].level)
    end)

    it("does not call notify when debug_mode is false", function()
      usecase.debug("test message")

      assert.equals(0, #notify_calls)
    end)
  end)

  describe("info", function()
    it("calls notify with INFO level", function()
      usecase.info("info message")

      assert.equals(1, #notify_calls)
      assert.equals("info message", notify_calls[1].message)
      assert.equals(vim.log.levels.INFO, notify_calls[1].level)
    end)
  end)

  describe("warn", function()
    it("calls notify with WARN level", function()
      usecase.warn("warn message")

      assert.equals(1, #notify_calls)
      assert.equals("warn message", notify_calls[1].message)
      assert.equals(vim.log.levels.WARN, notify_calls[1].level)
    end)
  end)

  describe("error", function()
    it("calls notify with ERROR level", function()
      usecase.error("error message")

      assert.equals(1, #notify_calls)
      assert.equals("error message", notify_calls[1].message)
      assert.equals(vim.log.levels.ERROR, notify_calls[1].level)
    end)
  end)
end)
