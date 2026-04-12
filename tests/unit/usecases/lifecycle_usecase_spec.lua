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
    package.loaded["devdocs.application.helpers.make_logged"] = nil
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
