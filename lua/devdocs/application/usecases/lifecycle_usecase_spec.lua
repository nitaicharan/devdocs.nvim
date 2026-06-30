local assert = require("luassert")

describe("lifecycle_usecase", function()
  local usecase
  local install_called

  before_each(function()
    install_called = false

    package.loaded["devdocs.application.usecases.log_usecase"] = {
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }

    package.loaded["devdocs.application.usecases.registries_usecase"] = {
      install = function()
        install_called = true
      end,
    }

    package.loaded["devdocs.application.usecases.lifecycle_usecase"] = nil
    usecase = require("devdocs.application.usecases.lifecycle_usecase")
  end)

  after_each(function()
    package.loaded["devdocs.application.helpers.make_logged"] = nil
    package.loaded["devdocs.application.usecases.log_usecase"] = nil
    package.loaded["devdocs.application.usecases.registries_usecase"] = nil
    package.loaded["devdocs.application.usecases.lifecycle_usecase"] = nil
  end)

  describe("on_plugin_init", function()
    it("calls registries_usecase.install", function()
      usecase.on_plugin_init()

      assert.is_true(install_called)
    end)
  end)
end)
