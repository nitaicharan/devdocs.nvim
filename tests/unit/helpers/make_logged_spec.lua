local assert = require("luassert")

describe("make_logged", function()
  local make_logged
  local debug_messages

  before_each(function()
    debug_messages = {}

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function(msg) table.insert(debug_messages, msg) end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.helpers.make_logged"] = nil
    local make_logged_helper = require("devdocs.application.helpers.make_logged")
    make_logged = make_logged_helper.make_logged
  end)

  after_each(function()
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.helpers.make_logged"] = nil
  end)

  it("forwards function calls with correct args and return value", function()
    local module = {
      add = function(a, b) return a + b end,
    }

    local logged = make_logged("math_module", module)
    local result = logged.add(2, 3)

    assert.equals(5, result)
  end)

  it("emits debug log with module name, function name, and args", function()
    local module = {
      greet = function(name) return "hello " .. name end,
    }

    local logged = make_logged("my_module", module)
    logged.greet("world")

    assert.equals(1, #debug_messages)
    assert.truthy(debug_messages[1]:find("%[my_module%->greet%]"))
    assert.truthy(debug_messages[1]:find("world"))
  end)

  it("passes through non-function fields without logging", function()
    local module = {
      version = "1.0",
      count = 42,
    }

    local logged = make_logged("my_module", module)

    assert.equals("1.0", logged.version)
    assert.equals(42, logged.count)
    assert.equals(0, #debug_messages)
  end)

  it("serializes multiple args correctly", function()
    local module = {
      multi = function(a, b, c) return a .. b .. c end,
    }

    local logged = make_logged("my_module", module)
    logged.multi("x", "y", "z")

    assert.equals(1, #debug_messages)
    assert.truthy(debug_messages[1]:find("x"))
    assert.truthy(debug_messages[1]:find("y"))
    assert.truthy(debug_messages[1]:find("z"))
  end)

  it("handles functions with no arguments", function()
    local module = {
      noop = function() return "done" end,
    }

    local logged = make_logged("my_module", module)
    local result = logged.noop()

    assert.equals("done", result)
    assert.equals(1, #debug_messages)
    assert.truthy(debug_messages[1]:find("%[my_module%->noop%]"))
  end)

  it("handles functions that return nil", function()
    local module = {
      void_fn = function() end,
    }

    local logged = make_logged("my_module", module)
    local result = logged.void_fn()

    assert.is_nil(result)
    assert.equals(1, #debug_messages)
  end)
end)
